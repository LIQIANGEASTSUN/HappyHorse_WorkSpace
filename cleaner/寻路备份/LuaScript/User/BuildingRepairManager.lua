--- @class BuildingRepairManager
local BuildingRepairManager = {
    ---@type dictionary<string, dictionary<string, dictionary<string, int>>>
    listenDatas = {},
    ---@type dictionary<string, dictionary<string, bool>>
    item2AgentIds = {},
    ---修复状态
    ---@type dictionary<string, dictionary<string, BuildingRepairData>>
    _reapirDatas = {},
    _fullLevelAgent = {},
    _shakingRequestAgentIds = {},
}
---@type BuildingRepairData
local BuildingRepairData = require("MainCity.Component.BuildingRepairData")

---获取建筑修复信息
---@return BuildingRepairData
function BuildingRepairManager:GetRepairDate(sceneId, agentId)
    local sceneDatas = self._reapirDatas[sceneId]
    if not sceneDatas then
        sceneDatas = {}
        self._reapirDatas[sceneId] = sceneDatas
    end
    ---@type BuildingRepairData
    local repairData = sceneDatas[agentId]
    if not repairData then
        return
    end
    return repairData
end

function BuildingRepairManager:GetRepairDateByTemplateId(sceneId, templateId)
    local sceneDatas = self._reapirDatas[sceneId]
    if not sceneDatas then
        sceneDatas = {}
        self._reapirDatas[sceneId] = sceneDatas
    end
    local infos = nil
    for _, v in pairs(sceneDatas) do
        if v.templateId == templateId then
            -- return v
            infos = infos or {}
            table.insert(infos, v)
        end
    end
    return infos
end

---删除建筑修复信息
function BuildingRepairManager:RemoveRepairData(sceneId, agentId)
    local sceneDatas = self._reapirDatas[sceneId]
    if not sceneDatas then
        return
    end
    ---@type BuildingRepairData
    local repairData = sceneDatas[agentId]
    if not repairData then
        return
    else
        local widget = App.scene:GetWidget(CONST.MAINUI.ICONS.BuldingRepairBtns)
        if widget then
            widget:RemoveRepairData(repairData)
        end
        repairData:Destroy()
        sceneDatas[agentId] = nil
    end
end

---Agent初始化的同时, 初始化BuildingRepairData
function BuildingRepairManager:InitRepairDataByBuildingMsg(sceneId, agentId, templateId, buildingMsg, otherSceneCheck, isLogin)
    local sceneDatas = self._reapirDatas[sceneId]
    if not sceneDatas then
        sceneDatas = {}
        self._reapirDatas[sceneId] = sceneDatas
    end
    ---@type BuildingRepairData
    local repairData = sceneDatas[agentId]
    if not repairData then
        BuildingRepairData = BuildingRepairData or require("MainCity.Component.BuildingRepairData")
        repairData = BuildingRepairData.new(sceneId, agentId, templateId, buildingMsg)
        sceneDatas[agentId] = repairData
    else
        repairData:UpdateBuildingMsg(buildingMsg)
    end
    if otherSceneCheck then
        repairData:CheckOtherScene(isLogin)
    end
end

function BuildingRepairManager:SetLevelFull(sceneId, agentId, levelmax)
    self._fullLevelAgent[sceneId] = self._fullLevelAgent[sceneId] or {}
    self._fullLevelAgent[sceneId][agentId] = levelmax
end

---获取agent的等级
function BuildingRepairManager:GetLevel(sceneId, agentId, noDefault)
    local repairData = self:GetRepairDate(sceneId, agentId)
    local level = repairData and repairData.level
    if not level then
        if self._fullLevelAgent[sceneId] and self._fullLevelAgent[sceneId][agentId] then
            return self._fullLevelAgent[sceneId][agentId]
        end
        if noDefault then
            return
        else
            return 1
        end
    end
    return level
end

function BuildingRepairManager:SetLevel(sceneId, agentId, level, templateId)
    local repairData = self:GetRepairDate(sceneId, agentId)
    if repairData then
        repairData:UpdateLevel(level)
    else
        if templateId then
            self:InitRepairDataByBuildingMsg(sceneId, agentId, templateId, {level = level, progress = 0})
        end
    end
end

---设置agent的等级
function BuildingRepairManager:BuildingLevelUp(sceneId, agentId, templateId, newLevel, animaOverCallback, noMsg, repairDrawMsg, extParams)
    --local oldLevel = self:GetLevel(sceneId, agentId)
    -- self:SetLevel(sceneId, agentId, newLevel)
    sendNotification(CONST.GLOBAL_NOFITY.BuildRepair_LevelUp_Done, {})
    local repairData = self:GetRepairDate(sceneId, agentId)
    if repairData then
        repairData:LevelUp(newLevel)
    end
    local cfg = AppServices.Meta:GetBuildingRepair(templateId)
    local levelMax = cfg.levelmax
    local levelFull = levelMax == newLevel
    ---@type BaseAgent
    local agent = App.scene.objectManager:GetAgent(agentId)
    if not agent then
        Runtime.InvokeCbk(animaOverCallback)
        Util.BlockAll(0, "BuildingRepairManager")
        if not noMsg then
            self:LvupMessage(agentId, templateId, newLevel)
        end
        return
    end
    PanelManager.closePanel(GlobalPanelEnum.BuildingTaskPanel)
    local cleanDrama = cfg.CleanOnDramaBegin ~= "" and cfg.CleanOnDramaBegin
    if extParams and extParams.noDrama then
        cleanDrama = nil
    end
    local setClean = levelFull and not cleanDrama
    local noAnima = false

    --- drama控制动画
    if cfg.DramaControl and cfg.DramaControl[newLevel - 1] == 1 then
        noAnima = true
        ---需要先解锁, 要不然没法点击drama
        Util.BlockAll(0, "BuildingRepairManager")
    end
    if levelFull and cfg.CleanOnDramaOver and cfg.CleanOnDramaOver ~= "" then
        if setClean then
            setClean = false
        end
        repairData:SetCleanOnDramaOver(repairDrawMsg)
    end
    agent:SetRepaireLevel(newLevel, setClean, animaOverCallback, noMsg, noAnima, repairDrawMsg)
    --满级了, 并且需要在drama开始播放的时候 清理掉这个障碍物
    if levelFull and cleanDrama then
        Util.BlockAll(0, "BuildingRepairManager")
        repairData:SetCleanOnDramaPlay(repairDrawMsg)
    end
end
------------------------------------------

---显示界面
---@param agentId string 实例ID
---@param templateId string 模板ID
function BuildingRepairManager:ShowPanel(agentId)
    local sceneId = App.scene:GetCurrentSceneId()
    local curLevel = self:GetLevel(sceneId, agentId, true)
    local agent = App.scene.objectManager:GetAgent(agentId)
    local templateId = agent:GetTemplateId()
    local levelMax = AppServices.Meta:GetBuildingRepair(templateId).levelmax
    if curLevel >= levelMax then
        return true
    else
        local pos = agent:GetAnchorPosition()
        local startPosition = MoveCameraLogic.Instance():GetCameraFlatPosition()
        local dis = pos:FlatDistance(startPosition)
        if dis > 1.5 then
            Util.BlockAll(2, "BuildingRepairManager:ShowPanel")
            AppServices.Jump.FocusAgentNoTip(
                agent,
                function()
                    Util.BlockAll(0, "BuildingRepairManager:ShowPanel")
                    self:showPanelEx(agentId, templateId, curLevel)
                end
            )
        else
           self:showPanelEx(agentId, templateId, curLevel)
        end
    end
end

function BuildingRepairManager:showPanelEx(agentId, templateId, level)
    local repairKind = self.getRepairKind(templateId, level)
    if repairKind == BuildingRepairKind.AgentClean then
        local cfg = AppServices.Meta:GetBuildingRepair(templateId)
        if not string.isEmpty(cfg.ClickTips) then
            local str = Runtime.Translate(cfg.ClickTips)
            AppServices.UITextTip:Show(str, 2)
        end
    else
        PanelManager.showPanel(GlobalPanelEnum.BuildingTaskPanel, {agentId = agentId, templateId = templateId})
    end
end

function BuildingRepairManager:LevelUp(agentId, templateId, finishCbk)
    local sceneId = App.scene:GetCurrentSceneId()
    local agent = App.scene.objectManager:GetAgent(agentId)
    if not agent then
        console.error("can not find agent", sceneId, agentId)
        Runtime.InvokeCbk(finishCbk, false)
        return
    end

    if templateId ~= agent:GetTemplateId() then
        console.error("can not find agent templateId", sceneId, agentId, templateId, agent:GetTemplateId())
        Runtime.InvokeCbk(finishCbk, false)
        return
    end
    local curLevel = self:GetLevel(sceneId, agentId)
    local metaMgr = AppServices.Meta
    local cfg = metaMgr:GetBuildingRepair(templateId)
    if curLevel >= cfg.levelmax then
        console.error("level max", agentId, templateId, curLevel) --@DEL
        Runtime.InvokeCbk(finishCbk, false)
        return
    end
    local levelItems = self.GetLevelItems(templateId, curLevel)
    local exchangeItems = {}
    local notEnough = false
    local cost = 0
    for _, v in ipairs(levelItems) do
        local itemId, need = v[1], v[2]
        local have = AppServices.User:GetItemAmount(itemId)
        if have < need then
            local id = tostring(itemId)
            local itemType = AppServices.Meta:GetItemType(id)
            local canBuyType = itemType == 2 or itemType == 3 or itemType == 5 --2,3,5表示可购买材料，策划配的
            local price = AppServices.Meta:GetItemPrice(id)
            local canBuy = canBuyType and price > 0
            if not canBuy then
                notEnough = true
            else
                local needNum = need - have
                cost = cost + needNum * price
                table.insert(exchangeItems, {itemId = id, count = needNum})
            end
        end
    end

    if #exchangeItems > 0 then
        local function buyCallback(ret)
            if not ret then
                Runtime.InvokeCbk(finishCbk, false)
                return
            end
            for _, v in pairs(exchangeItems) do
                AppServices.User:AddItem(v.itemId, v.count, ItemGetMethod.supplementTask)
            end
            DcDelegates:Log(
                SDK_EVENT.supplement_task,
                {
                    sceneId = sceneId,
                    buildingId = templateId,
                    diamondCost = tostring(cost),
                    diamondCount = AppServices.User:GetItemAmount(ItemId.DIAMOND),
                    item = CONST.RULES.ConvertLogItem(exchangeItems),
                    type = tostring(2)
                }
            )
            Runtime.InvokeCbk(finishCbk, true)
        end
        PanelManager.showPanel(
            GlobalPanelEnum.BuyItemPanel,
            {
                itemDatas = exchangeItems,
                buyCallback = buyCallback,
                source = BuyItemPanelSourceType.task,
                srcPanelArgs = {agentId = agentId, templateId = templateId},
                sourcePanel = GlobalPanelEnum.BuildingTaskPanel,
                method = ItemGetMethod.supplementTask
            }
        )
        return
    end

    if notEnough then
        local description = Runtime.Translate("errorcode_2001")
        ErrorHandler.ShowErrorMessage(description)
        Runtime.InvokeCbk(finishCbk, false)
        return
    end
    Runtime.InvokeCbk(finishCbk, false)
    self:BuildingLevelUpRequest(sceneId, agentId, templateId)
end

function BuildingRepairManager:CallbackEnergy(agentId, templateId, useEnergy, isLvup, response)
    local repairDrawMsg = Net.Converter.ConvertBuildingRepairDrawMsg(response.repairDrawMsg)
    local agent = App.scene.objectManager:GetAgent(agentId)
    if isLvup then
        agent:UpdateRepairProgress(0)
    else
        local curProgress = agent:GetRepairProgress()
        -- console.lzl('-----CallbackEnergy---useEnergy', useEnergy)
        agent:UpdateRepairProgress(curProgress + useEnergy)
    end
    local sceneId = App.scene:GetCurrentSceneId()
    local curLevel = self:GetLevel(sceneId, agentId)
    if isLvup then
        self:BuildingLevelUp(sceneId, agentId, templateId, curLevel + 1, nil, nil, repairDrawMsg)
    end
end

function BuildingRepairManager:BuildingLevenUpByEnergyRequest(sceneId, agentId, onResponse)
    local agent = App.scene.objectManager:GetAgent(agentId)
    local templateId = agent:GetTemplateId()
    -- local curLevel = self:GetLevel(sceneId, agentId)
    --local newLevel = curLevel + 1
    local cfg = AppServices.Meta:GetBuildingRepair(templateId)
    local levelMax = cfg.levelmax
    local funcSuccessCbk = function(response)
        Runtime.InvokeCbk(onResponse, response)
    end

    local funcFailedCbk = function(errorCode)
        if errorCode == ErrorCodeEnums.BUIDING_TO_MAX_LEVEL then
            local lv = self:GetLevel(sceneId, agentId)
            if lv < levelMax then
                --newLevel = levelMax
                Runtime.InvokeCbk(funcSuccessCbk)
                return
            end
        else
            ErrorHandler.ShowErrorPanel(errorCode)
        end
    end
    local params = {
        sceneId = sceneId,
        plantId = agentId
    }

    Net.Scenemodulemsg_25304_BuildingLevelUp_Request(params, funcFailedCbk, funcSuccessCbk)
end

function BuildingRepairManager:CreateDragonInfoForDrama(_, agentId, templateId, newLevel)
    local cfg = AppServices.Meta:GetBuildingRepair(templateId)
    local dramaName = cfg.dragonWatiDrama
    local dragonDatas = {}
    for _, v in ipairs(cfg.collectrewards) do
        local itemId, _ = v[1], v[2]
        local itemType = AppServices.Meta:GetItemType(itemId)
        if itemType == ItemId.EType.DRAGON_ENTITY then
            table.insert(dragonDatas, {itemId = tostring(itemId)})
        end
    end
    local cbkCount = 0
    for _, v in ipairs(dragonDatas) do
        local addDragnCbk = function(_, dragonData)
            cbkCount = cbkCount + 1
            if not dragonData then
                if cbkCount == #dragonDatas then --所有的龙都创建完成的时候, 触发升级
                    self:LvupMessage(agentId, templateId, newLevel)
                end
                return
            end
            AppServices.MagicalCreatures:AddWaitCreateDragon(dragonData, dramaName)
            self:AddWaitResetDragon(dragonData.creatureId, dramaName)
            if cbkCount == #dragonDatas then --所有的龙都创建完成的时候, 触发升级
                self:LvupMessage(agentId, templateId, newLevel)
            end
        end
        AppServices.MagicalCreatures:AddDragonByItem(v.itemId, EntityState.select, addDragnCbk, true, self.notHaveDragon)
    end
end

function BuildingRepairManager:LvupMessage(agentId, templateId, newLevel)
    MessageDispatcher:SendMessage(MessageType.Global_After_RepaireBuilding, agentId, templateId, newLevel)
    App.mapGuideManager:OnGuideFinishEvent(GuideEvent.CustomEvent, agentId)
    local _, rewardItems = self.GetLevelItems(templateId, newLevel - 1)
    if not table.isEmpty(rewardItems) then
        for _, v in ipairs(rewardItems) do
            local itemId, num = tostring(v[1]), v[2]
            if ItemId.IsExp(itemId) then
                AppServices.User:AddExp(num, "buidingRepaire")
            else
                AppServices.User:AddItem(itemId, num, ItemGetMethod.repairTaskBuilding)
            end
            local eType = ItemId.GetWidgetType(itemId)
            App.scene:RefreshWidget(eType)
        end
    end
end

---增加drama播放完之后的监听
function BuildingRepairManager:AddWaitResetDragon(creatureId, dramaName)
    if not self.waitResetDragons then
        self.waitResetDragons = {}
    end
    self.waitResetDragons[dramaName] = self.waitResetDragons[dramaName] or {}
    table.insertIfNotExist(self.waitResetDragons[dramaName], creatureId)
    if not self._Global_Drama_Over then
        self._Global_Drama_Over = true
        MessageDispatcher:AddMessageListener(MessageType.Global_Drama_Over, self.OnDramaOverClearDragon, self)
    end
end

function BuildingRepairManager:OnDramaOverClearDragon(dramaName)
    if not self.waitResetDragons then
        self:removeDramaListen()
        return
    end
    if not self.waitResetDragons[dramaName] then
        if table.isEmpty(self.waitResetDragons) then
            self:removeDramaListen()
        end
        return
    end
    for _, creatureId in ipairs(self.waitResetDragons[dramaName]) do
        local dragon = AppServices.MagicalCreatures:GetEntity(creatureId)
        if dragon then
            dragon.retainPos = true
            dragon:ChangeAction(EntityState.idle)
        end
    end
    self.waitResetDragons[dramaName] = nil
    if table.isEmpty(self.waitResetDragons) then
        self:removeDramaListen()
    end
end

function BuildingRepairManager:removeDramaListen()
    if self._Global_Drama_Over then
        self._Global_Drama_Over = false
        MessageDispatcher:RemoveMessageListener(MessageType.Global_Drama_Over, self.OnDramaOverClearDragon, self)
    end
end

function BuildingRepairManager:GetBuildingLevelFromNet(sceneId, agentId, templateId, callback)
    local params = {
        sceneId = sceneId,
        plantIds = {agentId}
    }
    local level = 1
    local function funcFailedCbk(errorCode)
        console.error("Scenemodulemsg_25303_FindScenePlants_Request", errorCode) --@DEL
        self:SetLevel(sceneId, agentId, level)
        Runtime.InvokeCbk(callback)
        -- AppServices.TaskIconButtonLogic:ShowBuildingTaskTip(taskId, subIndex, key)
    end
    local function funcSuccessCbk(response)
        if response.buildings and #response.buildings > 0 then
            for _, v in ipairs(response.buildings) do
                self:SetLevel(sceneId, v.plantId, v.level)
                if v.plantId == agentId then
                    level = v.level
                end
            end
        end
        self:SetLevel(sceneId, agentId, level, templateId)
        Runtime.InvokeCbk(callback)
        -- AppServices.TaskIconButtonLogic:ShowBuildingTaskTip(taskId, subIndex, key)
    end
    Net.Scenemodulemsg_25303_FindScenePlants_Request(params, funcFailedCbk, funcSuccessCbk, nil, false)
end

----EVENT---
---添加监听事件
function BuildingRepairManager:RegisterListener()
    if self._registered then
        return
    end
    self._registered = true
    MessageDispatcher:AddMessageListener(MessageType.PopupQueue_FINISHED, self.AfterChangeScene, self)
    MessageDispatcher:AddMessageListener(MessageType.Building_Repair_Done, self.RemoveRepairData, self)
    MessageDispatcher:AddMessageListener(MessageType.Global_OnShake, self.OnShake, self)
end

---场景变化后数据初始化
function BuildingRepairManager:AfterChangeScene()
    local sceneId = App.scene:GetCurrentSceneId()
    local sceneDatas = self._reapirDatas[sceneId]
    if not sceneDatas then
        return
    end
    for agentId, repairData in pairs(sceneDatas) do
        local agent = App.scene.objectManager:GetAgent(agentId)
        if agent then
            -- console.lzl('------before UpdateInfo', agent:GetRepaireLevel(), repairData)--@DEL
            -- repairData:UpdateInfoByAgent(agent, true)
            repairData:CheckBubble()
        end
    end
end

function BuildingRepairManager:InitSceneBuildings(finishCallback)
    local sceneId = App.scene:GetCurrentSceneId()
    local sceneDatas = self._reapirDatas[sceneId]
    if not sceneDatas then
        Runtime.InvokeCbk(finishCallback)
        return
    end
    for agentId, repairData in pairs(sceneDatas) do
        local agent = App.scene.objectManager:GetAgent(agentId)
        if agent then
            repairData:CalState(agent)
            if repairData:CanAutoRepair() and repairData:CanRepaire() then
                local newState = repairData:CalNewState()
                if newState ~= repairData:GetState() then
                    repairData:SetState(newState)
                    self:BuildingLevelUpRequest(repairData.sceneId, repairData.agentId, repairData.templateId, nil, true)
                end
            else
                repairData:CheckStateChange(true, true)
            end
        end
    end
    Runtime.InvokeCbk(finishCallback)
end

function BuildingRepairManager:IsTaskUnlock(agentId)
    local sceneId = App.scene:GetCurrentSceneId()
    local repairData = self:GetRepairDate(sceneId, agentId, true)
    if not repairData or not repairData.taskListenId or AppServices.Task:IsTaskSubmit(repairData.taskListenId) then
        return true
    end
    return false
end

function BuildingRepairManager.getLockTaskId(templateId)
    local cfg = AppServices.Meta:GetBuildingRepair(templateId)
    if cfg.taskunlock and cfg.taskunlock ~= "" then
        return cfg.taskunlock
    end
end

function BuildingRepairManager.PlayBuildingRepaireAnima(templateId, level)
    local agent = App.scene.objectManager:GetAgentByTemplateId(templateId)
    if agent then
        local cfg = AppServices.Meta:GetBuildingRepair(templateId)
        if not cfg then
            return
        end
        local anima = cfg.repairingspine[level - 1]
        local function callback()
            local idleAnima = cfg.levelspine[level - 1]
            agent:UpdateDefaultAnima(idleAnima)
        end
        agent:PlayAnimation(anima, false, callback)
    end
end

function BuildingRepairManager.PlayBuildingRepaireAnimaByAnimaName(templateId, animaName, finishIdle)
    -- console.lzl("PlayBuildingRepaireAnimaByAnimaName", templateId, animaName, finishIdle)
    local agent = App.scene.objectManager:GetAgentByTemplateId(templateId)
    if agent then
        local cfg = AppServices.Meta:GetBuildingRepair(templateId)
        if not cfg then
            return
        end
        local function callback()
            -- console.lzl("PlayBuildingRepaireAnimaByAnimaName callback", templateId, animaName, finishIdle)
            if not string.isEmpty(finishIdle) then
                agent:PlayAnimation(finishIdle, true)
            else
                agent:PlayIdleAnimation()
            end
        end
        agent:PlayAnimation(animaName, false, callback)
    end
end

function BuildingRepairManager.GetShowLevelStr(level, maxLevel)
    local showLv = level - 1
    local showMax = maxLevel - 1
    return Runtime.Translate("ui_taskbuilding_level", {cur = tostring(showLv), total = tostring(showMax)})
end

---获取建筑升级的道具数组
---@param templateId string agent的模板id
---@param level int agent当前修复等级
---@return table,table 升级需要道具, 奖励道具
function BuildingRepairManager.GetLevelItems(templateId, level)
    local meta = AppServices.Meta:GetBuildingRepair(templateId)
    if not meta then
        console.error("障碍物模板id", tostring(templateId), "缺少在excel : TaskBuildingTemplate.xlsx中的配置")--@DEL
    end
    if level >= meta.levelmax then
        return
    end
    local itemsKey = "levelitem" .. level
    local rewardKey = "rewarditem" .. level
    return meta[itemsKey], meta[rewardKey]
end

function BuildingRepairManager:IsEnergyLvUp(templateId, level)
    local lvupItems = self.GetLevelItems(templateId, level)
    if not lvupItems then
        return false
    end
    return #lvupItems == 1 and ItemId.IsEnergy(lvupItems[1][1])
end

---@return BuildingRepairKind
function BuildingRepairManager.getRepairKind(templateId, level)
    local cfg = AppServices.Meta:GetBuildingRepair(templateId)
    local lvupItems = cfg["levelitem"..level]
    local lvupItems1 = lvupItems and lvupItems[1]
    if not lvupItems1 then
        return
    end
    local itemId = lvupItems1[1]
    local rKind = BuildingRepairKind.Normal
    if ItemId.IsEnergy(itemId) then
        rKind = BuildingRepairKind.Energy
    elseif itemId == -1 then
        rKind = BuildingRepairKind.AgentClean
    end
    return rKind
end

function BuildingRepairManager:GetLevelUpCbk(repairKind)
    local kindName = BuildingRepairKindName[repairKind]
    if not kindName then
        return self.NormalCallback
    end
    local funcName = kindName .. 'Callback'
    return self[funcName]
end

function BuildingRepairManager:NormalCallback(sceneId, agentId, templateId, response, onResponse)
    local repairDrawMsg = Net.Converter.ConvertBuildingRepairDrawMsg(response.repairDrawMsg)
    local curLevel = self:GetLevel(sceneId, agentId)
    local cfg = AppServices.Meta:GetBuildingRepair(templateId)
    local newLevel = curLevel + 1
    local levelItems = self.GetLevelItems(templateId, curLevel)
    for _, v in ipairs(levelItems) do
        local itemId, need = v[1], v[2]
        AppServices.User:UseItem(itemId, need, ItemUseMethod.repairTaskBuilding)
    end
    local levelMax = cfg.levelmax
    if agentId == "15806" then
        App.mapGuideManager:StartSeries(GuideConfigName.GuideFactory)
    end
    Util.BlockAll(8, "BuildingRepairManager")
    local levelFull = levelMax == newLevel
    self.notHaveDragon = nil
    ---弹出普通奖励面板
    if levelFull and not table.isEmpty(cfg.collectrewards) then
        local item1Id = tostring(cfg.collectrewards[1][1])
        if ItemId.IsDragon(item1Id) then
            local dragonConfig = AppServices.Meta:GetMagicalCreateuresConfigById(item1Id)
            if AppServices.MagicalCreatures:GetCreaturesCountByType(dragonConfig.type) == 0 then
                self.notHaveDragon = 1
            end
        end

        -- 奖励龙
        if cfg.dragonWatiDrama and cfg.dragonWatiDrama ~= "" then
            local rewardCbk = function()
                Util.BlockAll(0, "BuildingRepairManager")
                self:CreateDragonInfoForDrama(sceneId, agentId, templateId, newLevel)
                Runtime.InvokeCbk(onResponse)
            end
            self:BuildingLevelUp(sceneId, agentId, templateId, newLevel, rewardCbk, true, repairDrawMsg)
        else
            local rewardCbk =  function()
                for _, v in ipairs(cfg.collectrewards) do
                    local itemId, Amount = v[1], v[2]
                    if AppServices.Meta:GetItemType(itemId) == ItemId.EType.DRAGON_ENTITY then
                        for _ = 1, Amount do
                            AppServices.MagicalCreatures:AddDragonByItem(
                                tostring(itemId),
                                EntityState.idle,
                                nil,
                                true,
                                self.notHaveDragon
                            )
                        end
                    end
                end
                self:LvupMessage(agentId, templateId, newLevel)
            end
            local animaOverCallback = function()
                Util.BlockAll(0, "BuildingRepairManager")
                if cfg.CollectInDrama == 1 then
                    Runtime.InvokeCbk(rewardCbk)
                else
                    self:ShowBuildingRepairReward(templateId, rewardCbk)
                end
                Runtime.InvokeCbk(onResponse)
            end
            self:BuildingLevelUp(sceneId, agentId, templateId, newLevel, animaOverCallback, true, repairDrawMsg)
        end
    else
        self:BuildingLevelUp(sceneId, agentId, templateId, newLevel, onResponse, nil, repairDrawMsg)
    end
end

function BuildingRepairManager:EnergyCallback(sceneId, agentId, templateId, response, onResponse, extParams)
    local isLvup, useEnergy = extParams.isLvup, extParams.useEnergy
    local curLevel = self:GetLevel(sceneId, agentId)
    local agent = App.scene.objectManager:GetAgent(agentId)
    local levelItems = self.GetLevelItems(templateId, curLevel)
    local costEnergy = response.costEnergy
    if not agent then
        local repairDrawMsg = Net.Converter.ConvertBuildingRepairDrawMsg(response.repairDrawMsg)
        if isLvup then
            self:BuildingLevelUp(sceneId, agentId, templateId, curLevel + 1, nil, nil, repairDrawMsg)
        end
        return
    end
    local cp = agent:GetRepairProgress()
    local needCost = levelItems[1][2] - cp
    local oldLvup = isLvup
    if costEnergy >= needCost and not isLvup then
        isLvup = true
    end
    if costEnergy ~= useEnergy then
        console.error("修复建筑用的体力, 前后端不一致了", costEnergy, useEnergy, tostring(isLvup), tostring(oldLvup)) --@DEL
    end
    local _, rewards = self.GetLevelItems(templateId, curLevel)
    ---奖励
    local produced = nil
    if isLvup and rewards then
        for _, v in ipairs(rewards) do
            produced = produced or {}
            table.insert(produced, {itemTemplateId = tostring(v[1]), count = v[2]})
        end
    end
    local repairRes = {
        useEnergy = costEnergy,
        produced = produced
    }
    Runtime.InvokeCbk(onResponse, repairRes, function()
        self:CallbackEnergy(agentId, templateId, costEnergy, isLvup, response)
    end)
end

function BuildingRepairManager:AgentCleanCallback(sceneId, agentId, templateId, response, onResponse, extParams)
    local repairDrawMsg = Net.Converter.ConvertBuildingRepairDrawMsg(response.repairDrawMsg)
    local curLevel = self:GetLevel(sceneId, agentId)
    local cfg = AppServices.Meta:GetBuildingRepair(templateId)
    local newLevel = curLevel + 1
    local levelMax = cfg.levelmax
    if agentId == "15806" then
        App.mapGuideManager:StartSeries(GuideConfigName.GuideFactory)
    end
    Util.BlockAll(8, "BuildingRepairManager")
    local levelFull = levelMax == newLevel
    self.notHaveDragon = nil
    ---弹出普通奖励面板
    if levelFull and not table.isEmpty(cfg.collectrewards) then
        local item1Id = tostring(cfg.collectrewards[1][1])
        if ItemId.IsDragon(item1Id) then
            local dragonConfig = AppServices.Meta:GetMagicalCreateuresConfigById(item1Id)
            if AppServices.MagicalCreatures:GetCreaturesCountByType(dragonConfig.type) == 0 then
                self.notHaveDragon = 1
            end
        end

        -- 奖励龙
        if cfg.dragonWatiDrama and cfg.dragonWatiDrama ~= "" then
            local rewardCbk = function()
                Util.BlockAll(0, "BuildingRepairManager")
                self:CreateDragonInfoForDrama(sceneId, agentId, templateId, newLevel)
            end
            self:BuildingLevelUp(sceneId, agentId, templateId, newLevel, rewardCbk, true, repairDrawMsg)
        else
            local rewardCbk =  function()
                for _, v in ipairs(cfg.collectrewards) do
                    local itemId, Amount = v[1], v[2]
                    if AppServices.Meta:GetItemType(itemId) == ItemId.EType.DRAGON_ENTITY then
                        for _ = 1, Amount do
                            AppServices.MagicalCreatures:AddDragonByItem(
                                tostring(itemId),
                                EntityState.idle,
                                nil,
                                true,
                                self.notHaveDragon
                            )
                        end
                    end
                end
                self:LvupMessage(agentId, templateId, newLevel)
            end
            local animaOverCallback = function()
                Util.BlockAll(0, "BuildingRepairManager")
                if cfg.CollectInDrama == 1 then
                    Runtime.InvokeCbk(rewardCbk)
                else
                    self:ShowBuildingRepairReward(templateId, rewardCbk)
                end
            end
            self:BuildingLevelUp(sceneId, agentId, templateId, newLevel, animaOverCallback, true, repairDrawMsg, extParams)
        end
    else
        self:BuildingLevelUp(sceneId, agentId, templateId, newLevel, nil, nil, repairDrawMsg, extParams)
    end
end

function BuildingRepairManager:getExtParamByRepairKind(repairKind, sceneId, agentId, templateId)
    if repairKind == BuildingRepairKind.Energy then

        local agent = App.scene.objectManager:GetAgent(agentId)
        local curLevel = self:GetLevel(sceneId, agentId)
        local curEnergy = AppServices.User:GetItemAmount(ItemId.ENERGY)

        local levelItems = self.GetLevelItems(templateId, curLevel)
        local curProgress = agent:GetRepairProgress()
        local cost = levelItems[1][2] - curProgress
        local useEnergy = cost > curEnergy and curEnergy or cost
        local extParam = {
            isLvup = false,
            useEnergy = useEnergy
        }
        return extParam
    end
end

function BuildingRepairManager:BuildingLevelUpRequest(sceneId, agentId, templateId, onResponse, noDrama)
    local curLevel = self:GetLevel(sceneId, agentId)
    local cfg = AppServices.Meta:GetBuildingRepair(templateId)
    local levelMax = cfg.levelmax
    local repairKind = self.getRepairKind(templateId, curLevel)
    local extParams = self:getExtParamByRepairKind(repairKind, sceneId, agentId, templateId)
    if noDrama then
        extParams = extParams or {}
        extParams.noDrama = true
    end
    local lvupCallback = self:GetLevelUpCbk(repairKind)
    local funcSuccessCbk = function(response)
        Runtime.InvokeCbk(lvupCallback, self, sceneId, agentId, templateId, response, onResponse, extParams)
    end

    local funcFailedCbk = function(errorCode)
        if errorCode == ErrorCodeEnums.BUIDING_TO_MAX_LEVEL then
            local lv = self:GetLevel(sceneId, agentId)
            if lv < levelMax then
                Runtime.InvokeCbk(funcSuccessCbk) -- TODO
                return
            end
        else
            ErrorHandler.ShowErrorPanel(errorCode)
        end
    end

    local params = {
        sceneId = sceneId,
        plantId = agentId
    }
    console.lzl("---send Scenemodulemsg_25304_BuildingLevelUp_Request", sceneId, agentId, self) --@DEL
    Net.Scenemodulemsg_25304_BuildingLevelUp_Request(params, funcFailedCbk, funcSuccessCbk)
end

---@return BuildingRepairData[]
function BuildingRepairManager:GetListenRepaires(onlyCheck)
    if not AppServices.Unlock:IsUnlock("RepairIcon") then
        return
    end
    ---@type TaskEntity[]
    local tasks = AppServices.Task:GetCurOpenTasks(nil, TaskKind.All)
    ---@type BuildingRepairData[]
    local repairDatas
    local usingRepairData = {}
    for _, taskEntity in ipairs(tasks) do
        if not taskEntity:IsFinish() then
            local fullCfg = taskEntity:GetCfg()
            for _, subCfg in ipairs(fullCfg.SubMissions) do
                if subCfg.MissionType == MissionType.Building then
                    --local templateId = subCfg.ObstacleTemplateId
                    local agentId = subCfg.BuildingId
                    local sceneId = subCfg.ZoneId
                    local repairData = self:GetRepairDate(sceneId, agentId, true)
                    if not repairData then
                        -- console.lzl("-----理论上不应该有这样的问题-------")
                    else
                        -- console.lzl('---repairData----', repairData:GetName(), repairData:CanRepaire())
                        if not repairData.levelFull and repairData:CanRepaire() then
                            local cfg = repairData:GetCfg()
                            if cfg.RepairableTips and cfg.RepairableTips ~= 0 then
                                usingRepairData[sceneId] = usingRepairData[sceneId] or {}
                                usingRepairData[sceneId][agentId] = true
                                repairDatas = repairDatas or {}
                                table.insert(repairDatas, repairData)
                            end
                        end
                    end
                end
            end
        end
    end
    for sceneId, rds in pairs(self._reapirDatas) do
        usingRepairData[sceneId] = usingRepairData[sceneId] or {}
        for agentId, repairData in pairs(rds) do
            if not usingRepairData[sceneId][agentId] then
                if not repairData.levelFull and repairData:CanRepaire() and not repairData.taskListenId then
                    local cfg = repairData:GetCfg()
                    if cfg.RepairableTips and cfg.RepairableTips ~= 0 then
                        usingRepairData[sceneId][agentId] = true
                        repairDatas = repairDatas or {}
                        table.insert(repairDatas, repairData)
                    end
                end
            end
        end
    end
    if not onlyCheck then
        self._curShowingRepairDatas = repairDatas
    end
    return repairDatas
end

function BuildingRepairManager.IsInRepaireTask(repairData)
    ---@type TaskEntity[]
    local tasks = AppServices.Task:GetCurOpenTasks(nil, TaskKind.All)
    for _, taskEntity in ipairs(tasks) do
        if not taskEntity:IsFinish() then
            local fullCfg = taskEntity:GetCfg()
            for _, subCfg in ipairs(fullCfg.SubMissions) do
                if subCfg.MissionType == MissionType.Building then
                    if repairData.agentId == subCfg.BuildingId and repairData.sceneId == subCfg.ZoneId then
                        return true
                    end
                elseif subCfg.MissionType == MissionType.BuildingRepairCount then
                    local meta = AppServices.Meta:GetBindingMeta(repairData.templateId)
                    if meta.obstacleType == subCfg.Pickable.Type then
                        return true
                    end
                end
            end
        end
    end
    local sceneId = App.scene:GetCurrentSceneId()
    local sceneCfg = AppServices.Meta:GetSceneCfg(sceneId)
    if sceneCfg.type == SceneType.Activity and not repairData.taskListenId then
        local ins = ActivityServices.ActivityManager:GetInsBySceneId(sceneId)
        if ins then
            local tasks = ins.GetAllTaskEntities and ins:GetAllTaskEntities()
            if tasks then
                for _, taskEntity in pairs(tasks) do
                    local subCfg = taskEntity:GetCfg()
                    if subCfg.MissionType == MissionType.BuildingRepairCount then
                        local meta = AppServices.Meta:GetBindingMeta(repairData.templateId)
                        if meta.obstacleType == subCfg.Pickable.Type then
                            return true
                        end
                    end
                end
            end
        end
    end
end

function BuildingRepairManager:OnTaskStart(taskId, isInit)
    if isInit then
        return
    end
    local fullCfg = AppServices.Task:GetFullConfig(taskId)
    local needCheck = false
    for _, subCfg in ipairs(fullCfg.SubMissions) do
        if subCfg.MissionType == MissionType.Building then
            needCheck = true
            break
        end
    end
    if not needCheck then
        return
    end
    local oldCache = self._curShowingRepairDatas
    local newCache = self:GetListenRepaires(true)
    local needRefresh = false
    if not (not oldCache) == not (not newCache) then --都有或者都没有
        if oldCache then
            if #oldCache ~= #newCache then --数量不一样要刷新
                needRefresh = true
            else
                local tmpOld = {}
                for _, v in ipairs(oldCache) do
                    tmpOld[v] = true
                end
                for _, v in ipairs(newCache) do
                    if not tmpOld[v] then
                        needRefresh = true
                        break
                    end
                end
            end
        end
    else --一个有一个没有就要刷新了
        needRefresh = true
    end
    if needRefresh then
        App.scene:RefreshWidget(CONST.MAINUI.ICONS.BuldingRepairBtns)
    end
end

function BuildingRepairManager:getTidsCacheByItem(itemId)
    itemId = tostring(itemId)
    self._itemId2templateIds = self._itemId2templateIds or {}
    local tids = self._itemId2templateIds[itemId]
    if not tids then
        tids = {}
        local cfgs = AppServices.Meta:Category("TaskBuildingTemplate")
        for templateId, cfg in pairs(cfgs) do
            for level = 1, 3 do
                local keyName = "rewarditem" .. level
                local rewards = cfg[keyName]
                local found = false
                if type(rewards) == 'string' then
                    console.error("TaskBuildingTemplate 表的", templateId, "的字段", keyName, "配置错误") --@DEL
                end
                if not table.isEmpty(rewards) then
                    for _, v in ipairs(rewards) do
                        if tostring(v[1]) == itemId then
                            tids[templateId] = {level = level, sceneId = cfg.sceneid}
                            found = true
                            break
                        end
                    end
                end
                if found then
                    break
                end
            end
        end
        self._itemId2templateIds[itemId] = tids
    end
    return tids
end

function BuildingRepairManager:GetTemplateIdsByReward(itemId)
    local tids = self:getTidsCacheByItem(itemId)
    local buildingInfos = nil
    for templateId, v in pairs(tids) do
        -- local cfg = AppServices.Meta:GetBuildingRepair(templateId)
        local tarLevel = v.level
        local sceneId = v.sceneId
        local repairDatas = self:GetRepairDateByTemplateId(sceneId, templateId)
        if repairDatas then
            for _, repairData in ipairs(repairDatas) do
                if repairData then
                    local curLevel = repairData.level
                    if curLevel <= tarLevel then
                        -- return repairData.agentId, templateId, sceneId
                        buildingInfos = buildingInfos or {}
                        table.insert(buildingInfos, {agentId = repairData.agentId, templateId = templateId, sceneId = sceneId})
                    end
                else
                    console.lzl("-no repairData--", templateId, sceneId) --@DEL
                end
            end
        end
    end
    return buildingInfos
end

function BuildingRepairManager:ShowBuildingRepairReward(templateId, finishCallback)
    local cfg = AppServices.Meta:GetBuildingRepair(templateId)
    local rewards = cfg.collectrewards[1]
    local itemId, itemNum = rewards[1], rewards[2]
    local rwds = {{ItemId = itemId, Amount = itemNum}}
    local notHaveDragon = self.notHaveDragon
    -- self.notHaveDragon = nil
    PanelManager.showPanel(GlobalPanelEnum.CommonRewardPanel, {
            rewards = rwds,
            isEntity=true,
            shouDragonCount = true,
            notHaveDragon = notHaveDragon,
            FlyToDragonFlyTarget = true
        }, PanelCallbacks:Create(finishCallback))
end

function BuildingRepairManager:OnShake()
    if not self._onShakeAgentIds then
        return
    end

    local plantIds = nil
    local objMgr = App.scene.objectManager
    for agentId in pairs(self._onShakeAgentIds) do
        local agent = objMgr:GetAgent(agentId)
        if agent and agent:HasProduct() and not self._shakingRequestAgentIds[agentId] then
            self._shakingRequestAgentIds[agentId] = true
            plantIds = plantIds or {}
            table.insert(plantIds, agentId)
        end
    end

    if not plantIds then
        return
    end

    local params = {
        sceneId = App.scene:GetCurrentSceneId(),
        plantIds = plantIds
    }

    local function funcSuccessCbk(response)
        local rets = Net.Converter.ConvertArray(response.rewards, Net.Converter.ConvertBuildingHangUpRewardMsg)
        local objMgr = App.scene.objectManager
        for i, agentId in ipairs(plantIds) do
            self._shakingRequestAgentIds[agentId] = nil
            local agent = objMgr:GetAgent(agentId)
            if agent then
                agent:OnShakeReponse(rets[i])
            end
        end
    end

    local function funcFailedCbk(errorCode)
        for _, agentId in ipairs(plantIds) do
            self._shakingRequestAgentIds[agentId] = nil
        end
        console.error("HangUpAgent:RewardRequest", App.scene:GetCurrentSceneId(), table.serialize(plantIds), "errorCode", errorCode) --@DEL
    end
    Net.Scenemodulemsg_25318_BuildingHangUpReward_Request(params, funcFailedCbk, funcSuccessCbk)
end

function BuildingRepairManager:RegistShakeAgent(agentId)
    self._onShakeAgentIds = self._onShakeAgentIds or {}
    self._onShakeAgentIds[agentId] = true
end

function BuildingRepairManager:UnRegistShakeAgent(agentId)
    if not self._onShakeAgentIds then
        return
    end
    self._onShakeAgentIds[agentId] = nil
end

function BuildingRepairManager:ClearRegistShakeAgent()
    self._onShakeAgentIds = {}
end

return BuildingRepairManager
