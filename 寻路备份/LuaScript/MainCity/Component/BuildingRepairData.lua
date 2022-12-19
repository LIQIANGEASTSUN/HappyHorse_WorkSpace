---@class BuildingRepairData 建筑修复组件
local BuildingRepairData = class(nil, 'BuildingRepairData')
function BuildingRepairData:ctor(sceneId, agentId, templateId, buildingMsg)
	self.agentId = agentId
    self.sceneId = sceneId
    self.level = -1
    ---@type RepairState
    ---修复状态
    self.state = nil
    ---模板id
    self.templateId = templateId
    ---监听的道具id
    self.listenItems = {}
    ---锁定的任务Id
    self.taskListenId = nil
    ---障碍物还未清理
    self.isClearing = nil
    ---是否满级
    self.levelFull = nil

    ---注册过的监听
    self._registers = {}
    local cfg = self:GetCfg()
    self.levelmax = cfg.levelmax
    if buildingMsg then
        self:UpdateBuildingMsg(buildingMsg)
    end
end

function BuildingRepairData:GetCfg()
    if self.templateId then
	    return AppServices.Meta:GetBuildingRepair(self.templateId)
    end
end

function BuildingRepairData:GetName()
    if self.templateId then
        return Runtime.Translate(self:GetCfg().name)
    end
end

---更新等级
function BuildingRepairData:UpdateLevel(level)
    self.level = level
    local old = self.levelFull
    self.levelFull = self.level == self.levelmax
    if old ~= self.levelFull and self.levelFull then
        AppServices.BuildingRepair:SetLevelFull(self.sceneId, self.agentId, self.levelmax)
        self:CheckStateChange()
    end
end

function BuildingRepairData:LevelUp(level)
    self.level = level
    self.levelFull = self.level == self.levelmax
    if not self.levelFull then
        self:updateListenItems(true)
    else
        AppServices.BuildingRepair:SetLevelFull(self.sceneId, self.agentId, self.levelmax)
    end
    self.state = nil
    self:CheckStateChange()
end

function BuildingRepairData:GetLevel()
    return self.level
end

---更新状态
function BuildingRepairData:UpdateState(newState)
    local curState = self:GetState()
    if curState == newState then
        -- console.lzl('BuildingRepairData update sameState', self)
        return
    end
    self:SetState(newState)
    self:CheckBubble(newState)
    if newState == RepairState.CanRepair and self:CanAutoRepair() then
        self:AutoRepair()
    end
end

function BuildingRepairData:GetState()
    return self.state
end

function BuildingRepairData:SetState(newState)
    self.state = newState
end

function BuildingRepairData:CanAutoRepair()
    if self.repairKind == BuildingRepairKind.AgentClean then
        return true
    end
end

function BuildingRepairData:AutoRepair()
    local cfg = self:GetCfg()
    local DramaControl = cfg.DramaControl
    if DramaControl and DramaControl[self.level] == 1 then
        AppServices.BuildingRepair:BuildingLevelUpRequest(self.sceneId, self.agentId, self.templateId)
    else
        AppServices.Jump.FocusAgentById(self.agentId, function()
            AppServices.BuildingRepair:BuildingLevelUpRequest(self.sceneId, self.agentId, self.templateId)
        end)
    end
end

---@param agent BaseAgent
function BuildingRepairData:UpdateInfoByAgent(agent)
    if not agent then
        -- console.lzl('---error call---', self.agentId, self.sceneId, self.templateId) --@DEL
        return
    end
    -- local level = agent:GetRepaireLevel()
    -- self:UpdateLevel(level)
    self:CalState(agent)
    self:CheckStateChange(true, true)
end

-- function BuildingRepairData:

function BuildingRepairData:UpdateBuildingMsg(buildingMsg)
    self:UpdateLevel(buildingMsg.level)
    self.progress = buildingMsg.progress
end

function BuildingRepairData:CheckOtherScene(isLogin)
    self:CalState(nil, isLogin)
    self:CheckStateChange(nil, nil, isLogin)
end

---根据数据计算状态
function BuildingRepairData:CalState(agent, isLogin)
    ---等级满
    if self.level == self.levelmax then
        self.levelFull = true
        -- TODO 满级后初始化时的处理
    end
    ---任务锁定
    self:initTaskLock()
    ---agent清理
    self:initAgentClearing(agent, isLogin)
    ---计算材料
    self:updateListenItems()
end

---------------------------------------任务---------------------------------------

---@private
---初始化任务状态
function BuildingRepairData:initTaskLock()
    local cfg = self:GetCfg()
    local taskId = cfg.taskunlock
    if not taskId or taskId == "" then
        self.taskListenId = nil
    else
        local isFinish = AppServices.Task:IsTaskSubmit(taskId)
        if not isFinish then
            self.taskListenId = taskId
            self:AddListener('OnTaskSubmit', MessageType.Task_After_TaskSubmit)
        else
            self.taskListenId = nil
        end
    end
end

function BuildingRepairData:isTaskLock()
    if not self.taskListenId then
        return fasle
    end
    return not AppServices.Task:IsTaskSubmit(self.taskListenId)
end

function BuildingRepairData:OnTaskSubmit(taskId)
    if self.taskListenId ~= taskId then
        return
    end
    self.taskListenId = nil
    self:RemoveListener(MessageType.Task_After_TaskSubmit)
    self:CheckStateChange(true, nil, nil, true)
end

---------------------------------------agent清理---------------------------------------


function BuildingRepairData:initAgentClearing(agent, isLogin)
    local curSceneId = App.scene:GetCurrentSceneId()
    local sceneId, agentId = self.sceneId, self.agentId
    if curSceneId ~= sceneId then -- 不同场景的检查
        -- 通过agentAppear查询
        local isClearing, noData = AppServices.AgentAppear:IsAgentAppear(sceneId, agentId)
        ---没有数据, 需要向网络请求
        if noData then
            console.lzl("请求查询依赖障碍物", self.sceneId, self.agentId, self.templateId, sceneId, agentId)
            AppServices.AgentAppear:RequestState(sceneId, agentId, function(sId, aId, state)
                if sId == self.sceneId then
                    self:UpdateAgentClearingState(aId, state >= CleanState.clearing, true, isLogin)
                end
            end)
        else
            self:UpdateAgentClearingState(agentId, isClearing, false, isLogin)
        end
    else  -- 相同场景的检查
        -- -- console.lzl('----------initAgentClearing-----2', self:GetName(), agent and agent:GetState())
        if agent then
            self:UpdateAgentClearingState(agentId, agent:GetState() >= CleanState.clearing)
        end
    end
end

function BuildingRepairData:UpdateAgentClearingState(agentId, isClearing, needCheck, isLogin)
    if agentId ~= self.agentId then
        return
    end
    -- -- console.lzl('UpdateAgentClearingState~~~', self:GetName(), agentId, isClearing)
    local old = not not self.isClearing
    -- 已经露出来
    if isClearing then
        self.isClearing = true
        AppServices.AgentAppear:SetAgentAppear(self.sceneId, self.agentId)
        self:RemoveListener(MessageType.Global_After_Agent_Clearing)
    else -- 未露出来
        self.isClearing = false
        self:AddListener('OnAgentClearing', MessageType.Global_After_Agent_Clearing)
    end
    if needCheck and old ~= self.isClearing then
        self:CheckStateChange(false, false, isLogin)
    end
end

function BuildingRepairData:OnAgentClearing(sceneId, agentId)
    if sceneId ~= self.sceneId or agentId ~= self.agentId then
        return
    end
    self.isClearing = true
    AppServices.AgentAppear:SetAgentAppear(self.sceneId, agentId)
    self:CheckStateChange(true, nil, nil, true)
    self:RemoveListener(MessageType.Global_After_Agent_Clearing)
end
---------------------------------------道具---------------------------------------

---@private
---初始化监听道具
function BuildingRepairData:updateListenItems(isLvup)
	if self.levelFull then
        self:RemoveItemListenByRepairKind(self.repairKind)
        return
    end
    local curLevel = self.level
    local oldRepairKind = self.repairKind
    local newRepairKind = AppServices.BuildingRepair.getRepairKind(self.templateId, curLevel)
    local kindChanged = oldRepairKind ~= newRepairKind
    if kindChanged then
        self:RemoveItemListenByRepairKind(oldRepairKind)
    end

    self.repairKind = newRepairKind
    if newRepairKind == BuildingRepairKind.Normal then
        if isLvup then
            table.clear(self.listenItems)
        end
        local items = AppServices.BuildingRepair.GetLevelItems(self.templateId, curLevel)
        for _, item in ipairs(items) do
            self.listenItems[tostring(item[1])] = item[2]
        end
    elseif newRepairKind == BuildingRepairKind.AgentClean then
        local items = AppServices.BuildingRepair.GetLevelItems(self.templateId, curLevel)
        for i, item in ipairs(items) do
            if item[1] == -1 then
                self.listenItems[i] = tostring(item[2])
            end
        end
    end
    if kindChanged then
        self:AddItemListenByRepairKind(newRepairKind)
    end
end

function BuildingRepairData:IsItemEnough()
    local repairKind = self.repairKind
    if repairKind == BuildingRepairKind.Energy then
        return true
    elseif repairKind == BuildingRepairKind.AgentClean then
        local curSceneId = App.scene:GetCurrentSceneId()
        if curSceneId ~= self.sceneId then
            return false
        end
        for _, agentId in ipairs(self.listenItems) do
            local agent = App.scene.objectManager:GetAgent(agentId)
            if agent and agent:GetState() ~= CleanState.cleared then
                return false
            end
        end
        return true
    elseif repairKind == BuildingRepairKind.Normal then
        for itemId, need in pairs(self.listenItems) do
            local have = AppServices.User:GetItemAmount(itemId)
            if have < need then
                return false
            end
        end
        return true
    end
end

function BuildingRepairData:RemoveItemListenByRepairKind(repairKind)
    if not repairKind then
        return
    end
    table.clear(self.listenItems)
    if repairKind == BuildingRepairKind.Normal then
        self:RemoveListener(MessageType.Global_After_AddItem)
        self:RemoveListener(MessageType.Global_After_UseItem)
    elseif repairKind == BuildingRepairKind.AgentClean then
        self:RemoveListener(MessageType.Global_After_Plant_Cleared)
    end
end

function BuildingRepairData:AddItemListenByRepairKind(repairKind)
    if repairKind == BuildingRepairKind.Normal then
        self:AddListener("OnItemChange", MessageType.Global_After_AddItem)
        self:AddListener("OnItemChange", MessageType.Global_After_UseItem)
    elseif repairKind == BuildingRepairKind.AgentClean then
        self:AddListener("OnAgentClean", MessageType.Global_After_Plant_Cleared)
    end
end

---监听道具变化
function BuildingRepairData:OnItemChange(itemId)
    if not self.listenItems then
        return
    end
    if not self.listenItems[itemId] then
        return
    end
    if self.levelFull then
        return
    end
    local CanRepair = self:CanRepaire()
    local isTrigger = CanRepair and self.state ~= RepairState.CanRepair or not CanRepair and self.state == RepairState.CanRepair
    if isTrigger then
        self:CheckStateChange()
    end
end

---监听障碍物清理
function BuildingRepairData:OnAgentClean(sceneId, agentId)
    if sceneId ~= self.sceneId then
        return
    end
    if not table.exists(self.listenItems, agentId) then
        return
    end
    for _, agentId in ipairs(self.listenItems) do
        local agent = App.scene.objectManager:GetAgent(agentId)
        if agent and agent:GetState() ~= CleanState.cleared then
            return
        end
    end
    self:CheckStateChange()
end

---获取障碍物是否可以升级
function BuildingRepairData:CanRepaire()
    if self.levelFull then -- 满级
        return false, 1
    end

    -- if table.isEmpty(self.listenItems) then --没有监听道具
    --     return false, 2
    -- end

    if not self:IsItemEnough() then
        return false, 2
    end
    if not self.isClearing then --障碍物还没漏出来
        return false, 3
    end
    --[==[
    if self.taskListenId then
        return false, 6
    end
    --]==]
    if AppServices.BuildingRepair:IsEnergyLvUp(self.templateId, self.level) then --消耗体力的, 不显示
        return false, 4
    end

    return true
end
----------------------------状态检查------------------------
local _showStateChangeMap = {
    [RepairState.CanRepair] = {
        [RepairState.Lock] = true,
        [RepairState.Closed] = true,
        [RepairState.Repairing] = true,
    },
    [RepairState.Repairing] = {
        [RepairState.CanRepair] = true,
    },
    [RepairState.Lock] = {
        [RepairState.CanRepair] = true,
    },
}

function BuildingRepairData:CalNewState()
    local newState
    if self.levelFull then
        newState = RepairState.Closed
    -- elseif self.taskListenId then
    --     newState = RepairState.Lock
    elseif not self.isClearing then
        newState = RepairState.Lock
    elseif self:CanRepaire() then
        newState = RepairState.CanRepair
    else
        newState = RepairState.Repairing
    end

    if AppServices.BuildingRepair:IsEnergyLvUp(self.templateId, self.level) then
        newState = RepairState.Lock
    end
    return newState
end

function BuildingRepairData:CheckStateChange(forceCheckBubble, waitBatchRefresh, isLogin, forceLog)
    local curState = self.state
    local newState = self:CalNewState()
    if newState ~= curState then
        self:UpdateState(newState)
        if curState ~= nil and not isLogin then
            self:Log()
        end
        ---要显隐刷新
        local showStateChange = _showStateChangeMap[newState] and _showStateChangeMap[newState][curState]
        if not waitBatchRefresh then
            local cfg = self:GetCfg()
            if cfg.RepairableTips ==1 and not self.taskListenId then
                MessageDispatcher:SendMessage(MessageType.Building_RepairState_Changed, self, showStateChange, isLogin)
            end
        end
    else
        if forceCheckBubble then
            self:CheckBubble()
        end
        if forceLog then
            self:Log()
        end
    end
end

function BuildingRepairData:CheckBubble()
    if self.sceneId ~= App.scene:GetCurrentSceneId() then
        return
    end
    local cfg = self:GetCfg()
    if cfg.bubbleType == -1 then
        return
    end
    local repairKind = AppServices.BuildingRepair.getRepairKind(self.templateId, self.level)

    local agentId = self.agentId
    if MapBubbleManager:IsShowedBubble(agentId) then
        MapBubbleManager:CloseBubble(agentId)
    end
    if repairKind == BuildingRepairKind.AgentClean then
        return
    end
    local curState = self.state
    if curState ~= RepairState.Repairing and curState ~= RepairState.CanRepair then
        return
    end

    if self:isTaskLock() then
        return
    end
    if not cfg.bubbleType then
        return
    end
    local bubbleType = BubbleType.Building_Repair
    if curState == RepairState.Repairing then
        if not cfg.bubbleType or cfg.bubbleType == 0 then
            return
        else
            bubbleType = cfg.bubbleType
        end
    end
    local agent = App.scene.objectManager:GetAgent(agentId)
    if not agent then
        -- console.lzl('-----更新修复建筑泡泡没有建筑', self)
        return
    end
    if agent:IsRenderValid() then
        MapBubbleManager:ShowBubble(agentId, bubbleType)--, onClick)
    else
        local cbk = function()
            MapBubbleManager:ShowBubble(agentId, bubbleType)--, onClick)
        end
        if agent.render then
            agent.render:SetObjLoadedCallback(cbk)
        else
            -- console.lzl('-------error no render', self)
        end
    end
end

function BuildingRepairData:SetCleanOnDramaOver(repairDrawMsg)
    local cfg = self:GetCfg()
    self.cleanOnDramaOver = cfg.CleanOnDramaOver
    self:AddListener('OnDramaOver', MessageType.Global_Drama_Over)
    self.repairDrawMsg = repairDrawMsg

end

function BuildingRepairData:SetCleanOnDramaPlay(repairDrawMsg)
    self.repairDrawMsg = repairDrawMsg
    local cfg = self:GetCfg()
    self.cleanOnDramaPlay = cfg.CleanOnDramaBegin
    self:AddListener('OnDramaStart', MessageType.Global_Drama_Start)
end

function BuildingRepairData:OnDramaOver(dramaName)
    if self.cleanOnDramaOver == dramaName then
        local agent = App.scene.objectManager:GetAgent(self.agentId)
        if agent then
            agent:RepaireDone(self.repairDrawMsg)
        end
    end
end

function BuildingRepairData:OnDramaStart(dramaName)
    if self.cleanOnDramaPlay == dramaName then
        local agent = App.scene.objectManager:GetAgent(self.agentId)
        if agent then
            agent:RepaireDone(self.repairDrawMsg)
        end
    end
end

function BuildingRepairData:AddListener(funcName, messageType)
    if not self._registers[messageType] then
        self._registers[messageType] = funcName
        MessageDispatcher:AddMessageListener(messageType, self[funcName], self)
    end
end

function BuildingRepairData:RemoveListener(messageType)
    if self._registers[messageType] then
        local funcName = self._registers[messageType]
        MessageDispatcher:RemoveMessageListener(messageType, self[funcName], self)
        self._registers[messageType] = nil
    end
end

function BuildingRepairData:RemoveAllListener()
    for messageType, funcName in pairs(self._registers) do
        MessageDispatcher:RemoveMessageListener(messageType, self[funcName], self)
    end
end

function BuildingRepairData:__tostring()
    return string.format( "[%s] SceneId=[%s] AgentId=[%s] TemplateId=[%s] Level = [%d] State=[%d] ", self.class.classname, self.sceneId or '', self.agentId or '', self.templateId or '', self.level or -1, self.state or -1)
end

function BuildingRepairData:Log()
    local cloudStatus = self.isClearing and 1 or 0
    local taskStatus = (self.taskListenId and not AppServices.Task:IsTaskSubmit(self.taskListenId)) and 0 or 1
    local buildingStatus = cloudStatus == 1 and taskStatus == 1 and 1 or 0
    local params = {
        sceneId = self.sceneId, --场景id
        buildingId = self.templateId,--建筑id
        buildingLevel = self.level, --当前等级
        buildingStatus = buildingStatus, -- 建筑修复状态	0未解锁，1已解锁
        cloudStatus = cloudStatus, -- 云遮盖状态	0遮盖，1打开
        taskStatus = taskStatus, -- 任务限制状态	0限制，1打开
        itemStatus = self:CanRepaire() and 1 or 0, -- 道具限制状态	0不可修复，1可修复
        buildingLevelMax = self.levelmax,
    }
    -- local str = table.serialize(params)
    -- -- console.lzl('building_repair_level', self:GetName(), str)
    DcDelegates:Log(SDK_EVENT.building_repair_level, params)
end

---销毁
function BuildingRepairData:Destroy()
	self:RemoveAllListener()
end


return BuildingRepairData