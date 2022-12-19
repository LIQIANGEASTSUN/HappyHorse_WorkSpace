require "MapGuide.MapGuideGlobals"

local MapGuideBase = require "MapGuide.MapGuideBase"
---@class MapGuideManager
local MapGuideManager = class()

function MapGuideManager:Create()
    local instance = MapGuideManager.new()
    return instance
end

function MapGuideManager:ctor()
    self.properties = {}
    self.extraParam = {}
    self.data = {completeIds = {}, reusedIds = {}}
    self.configs =
        setmetatable(
        {},
        {
            __mode = "kv",
            __index = function(t, k)
                local data = include("MapGuide.Configs." .. k)
                rawset(t, k, data)
                return data
            end
        }
    )
end

function MapGuideManager:GetConfig(name)
    local config = self.configs[name]
    return config
end

function MapGuideManager:InitFromRequest(finishCbk)
    if self.serverDataOk then
        Runtime.InvokeCbk(finishCbk)
        return
    end
    local function onSuccess(response)
        self.serverDataOk = true
        local data = Net.Converter.ConvertGuideCompleteIdsResponse(response)
        if data then
            local invalidIds = {}--无效垃圾ID处理
            for _, v in ipairs(data) do
                if string.find(v, "_") then
                    if string.match(v, "_(%d+)_") then
                        table.insert(invalidIds, v)
                    else
                        local id, reusedId = string.match(v, "(%w+)_(%w+)")
                        self.data.reusedIds[id] = {reusedId = reusedId, id = id}
                    end
                else
                    if ReusedGuideId[v] then
                        self.data.reusedIds[v] = {id = v}
                    else
                        self.data.completeIds[v] = true
                    end
                end
            end
            if #invalidIds > 0 then
                self:RequestReplaceGuideIds(invalidIds, {})
            end
        end
        if not self.registerEvent then
            self.registerEvent = true
            MessageDispatcher:AddMessageListener(MessageType.Global_OnUnlock, self.UnlockEvent, self)
            MessageDispatcher:AddMessageListener(MessageType.Task_OnTaskFinish, self.MissionFinish, self)
            MessageDispatcher:AddMessageListener(MessageType.Global_After_AddItem, self.AddItemEvent, self)
        end
        self:HandleIdMap()
        -- self:HandleReusedIds()
        MessageDispatcher:SendMessage(MessageType.Global_After_GuideDataReady)
        Runtime.InvokeCbk(finishCbk)
    end
    local function onFailed(ecode)
        ErrorHandler.ShowErrorPanel(ecode)
        Runtime.InvokeCbk(finishCbk)
    end
    Net.Coremodulemsg_1004_GuideCompleteIds_Request({}, onFailed, onSuccess)
end

function MapGuideManager:HandleIdMap()
    for _, v in ipairs(EnterSceneGuideConfigMap) do
        local index = 1
        while v[index] do
            if self:HasComplete(v[index]) then
                table.remove(v, index)
                index = index - 1
            end
            index = index + 1
        end
    end
end

---初始化可复用的引导ID
function MapGuideManager:HandleReusedIds()
    for k,v in pairs(ReusedGuideId) do
        local cof = self.configs[k].seriesConfig[1]
        local reusedId = cof.reusedId and cof.reusedId() or v
        ReusedGuideId[k] = reusedId
    end
end

function MapGuideManager:CheckEnterScenePop(sceneId, params)
    local function CheckSingle(guideName)
        local seriesConfig = self.configs[guideName]
        if not seriesConfig then
            console.assert(seriesConfig) --@DEL
            return false
        end
        for i, v in ipairs(seriesConfig.series) do
            if not self:HasComplete(v) then
                local singleConfig = seriesConfig.seriesConfig[i]
                local checkComplete = singleConfig.forceComplete
                local isFinish = false
                if checkComplete then
                    if checkComplete(params) then
                        isFinish = true
                        self:MarkGuideComplete(v)
                    end
                end
                --如果没有前置判断, 或者前置判断条件满足, 则开始执行引导
                if not isFinish then
                    if not singleConfig.precondition or singleConfig.precondition(params) then
                        return true
                    end
                end
            end
        end
        return false
    end

    if RuntimeContext.KILL_GUIDE then
        return false
    end

    if EnterSceneGuideConfigMap[sceneId] and #EnterSceneGuideConfigMap[sceneId] > 0 then
        for index, value in ipairs(EnterSceneGuideConfigMap[sceneId]) do
            if CheckSingle(value) then
                return true
            end
        end
    end
    if sceneId ~= SceneMode.home.name then
        if EnterSceneGuideConfigMap["explore"] and #EnterSceneGuideConfigMap["explore"] > 0 then
            for index, value in ipairs(EnterSceneGuideConfigMap["explore"]) do
                if CheckSingle(value) then
                    return true
                end
            end
        end
    end

    return false
end

function MapGuideManager:UnlockEvent(key)
    if App.scene:IsMainCity() then
        local cof = UnlockEventGuideConfig[key]
        if cof then
            PanelManager.closePanel(GlobalPanelEnum.TaskPanel)
            self:StartSeries(cof)
        end
    end
end

function MapGuideManager:Checklevelup(level)
    if not self.levelGuideMap then
        self.levelGuideMap = {}
        for key, value in pairs(LevelUpGuideConfig) do
            if level == tonumber(AppServices.Unlock:GetUnlockValue(key)) then
                self.levelGuideMap[level] = value
            end
        end
    end

    return self.levelGuideMap[level]
end
function MapGuideManager:LevelUpEvent(level)
    if App.scene:IsMainCity() then
        local guide = self:Checklevelup(level)
        if guide then
            self:StartSeries(guide)
        end
    end
end

function MapGuideManager:MissionFinish(taskId)
    local cof = TaskGuideConfigDic[taskId]
    if cof then
        self:StartSeries(cof)
    end
end

function MapGuideManager:AddItemEvent(itemId, _)
    local itmType = AppServices.Meta:GetItemType(itemId)
    if not itmType then
        return
    end
    local config = ItemGuideConfigDic[itmType]
    if config then
        self.itemGuideCache = self.itemGuideCache or {}
        if self.itemGuideCache[itmType] then
            return
        end
        self.itemGuideCache[itmType] = true
        PopupManager:CallWhenIdle(
            function()
                self.itemGuideCache[itmType] = nil
                self:StartSeries(config, itemId)
            end
        )
    end
end

function MapGuideManager:EnterScene(sceneId, finishCallback)
    if App:IsScreenPlayActive() then
        --如果有播放drama,则播放完drama后检查场景引导
        if not self.waitDrama then
            self.waitDrama = true
            self.sceneParam = {sceneId, finishCallback}
            MessageDispatcher:AddMessageListener(
                MessageType.Global_Drama_Over,
                self.CheckEnterSceneGuideAfterDrama,
                self
            )
        end
        return false
    end
    if self:HasRunningGuide() then
        return false
    end
    local function checkGuideIds(conf)
        if not conf then
            return false
        end
        for _, v in ipairs(conf) do
            if self:StartSeries(v, "Relogin") then
                self:SetGuideFinishCallback(finishCallback)
                return true
            end
        end
        return false
    end
    local cof = EnterSceneGuideConfigMap[sceneId]
    if checkGuideIds(cof) then
        return true
    end
    if not App.scene:IsMainCity() then
        cof = EnterSceneGuideConfigMap["explore"]
        if checkGuideIds(cof) then
            return true
        end
    end
    return false
end

function MapGuideManager:CheckEnterSceneGuideAfterDrama(dramaName)
    self.waitDrama = false
    MessageDispatcher:RemoveMessageListener(MessageType.Global_Drama_Over, self.CheckEnterSceneGuideAfterDrama, self)
    self:EnterScene(table.unpack(self.sceneParam))
end

function MapGuideManager:CheckIfStartGuideAfterTask(nameId)
    if RuntimeContext.KILL_GUIDE or not nameId then
        return
    end
    local configName = DramaGuideConfigDic[nameId]
    if configName then
        self:StartSeries(configName, nameId)
    end
end

function MapGuideManager:StartSeries(name, params)
    if RuntimeContext.KILL_GUIDE then
        return
    end

    if self:HasRunningGuide() then
        return
    end

    local seriesConfig = self.configs[name]
    if not seriesConfig then
        console.assert(seriesConfig) --@DEL
        return
    end
    if self.currentGuide and self.currentGuide:IsWeakStep() then
        local priority = WeakGuideIdConfig[name]
        if params and params.priority then
            priority = params.priority
        end
        if priority and not self:HasComplete(name) then
            local curId = self.currentGuide.id
            local curPriority = WeakGuideIdConfig[curId]
            if priority > curPriority then
                return
            end
        end
        self:BreakGuide()
    end

    for i, v in ipairs(seriesConfig.series) do
        local singleConfig = seriesConfig.seriesConfig[i]
        local reusedId = singleConfig.reusedId and singleConfig.reusedId(params)
        if not self:HasComplete(v, reusedId) then
            if reusedId then
                ReusedGuideId[v] = reusedId
            end
            local forceCompleteFunc = singleConfig.forceComplete
            local isFinish = nil
            if forceCompleteFunc then
                isFinish = forceCompleteFunc(params)
                if isFinish then
                    self:MarkGuideComplete(v)
                end
            end
            if not isFinish then
                --如果没有前置判断, 或者前置判断条件满足, 则开始执行引导
                if not singleConfig.precondition or singleConfig.precondition(params) then
                    MapGuideBase.Create(singleConfig, i, params):Start()
                    MessageDispatcher:SendMessage(MessageType.Global_Guide_Start, singleConfig.id)
                    if singleConfig.onlyOnce then
                        self:MarkGuideComplete(singleConfig.id)
                    end
                    return true
                else
                    -- 引导不能执行下去，清除flag
                    self:ClearFlags()
                    return false
                end
            end
        end
    end
    console.systrace("all guides are complete in " .. name) --@DEL
    return false, true
end

function MapGuideManager:StartSingleInSeries(seriesName, singleName, params)
    -- 如果你不想看引导，就改这里
    if RuntimeContext.KILL_GUIDE then
        return
    end

    if self:HasRunningGuide() then
        console.systrace("HasRunningGuide ") --@DEL
        return
    end

    console.systrace("StartSingleInSeries", seriesName, singleName) --@DEL
    local seriesConfig = self.configs[seriesName]
    if not seriesConfig then
        console.assert(seriesConfig) --@DEL
        return
    end

    for i, v in ipairs(seriesConfig.series) do
        print(v, singleName) --@DEL
        if v == singleName and not self:HasComplete(v) then
            local singleConfig = seriesConfig.seriesConfig[i]
            if not singleConfig.precondition or singleConfig.precondition(params) then
                print("$$$$$$$$$$$$ start Series ", seriesName, "by", seriesConfig.seriesConfig[i].id) --@DEL
                MapGuideBase.Create(singleConfig, i, params):Start()
                return true
            else
                print("$$$$$$$$$$$$ start Series FAILED by precondition") --@DEL
                -- 引导不能执行下去，清除flag
                self:ClearFlags()
                return false
            end
        end
    end
    return false
end

function MapGuideManager:HasComplete(guideId, reusedId)
    if RuntimeContext.KILL_GUIDE then
        return true
    end
    -- print("$$ hasComplete ", guideId, self.data.completeIds[guideId] == true) --@DEL
    if ReusedGuideId[guideId] then
        reusedId = reusedId or ReusedGuideId[guideId]
    else
        reusedId = nil
    end
    if reusedId then
        reusedId = tostring(reusedId)
        local dt = self.data.reusedIds[guideId]
        if not dt then
            return false
        else
            if dt.reusedId == reusedId then
                return true
            else
                return false
            end
        end
    else
        return self.data.completeIds[guideId] == true
    end
end

function MapGuideManager:HasCompleteSeries(seriesName)
    if RuntimeContext.KILL_GUIDE then
        return true
    end
    local series = self.configs[seriesName]
    if not series then
        return true
    end

    local hasFinished = true
    for k, v in pairs(series.series) do
        if not self:HasComplete(v) then
            hasFinished = false
            break
        end
    end
    return hasFinished
end

function MapGuideManager:FinishCurrentGuide(dontMarkComplete)
    if self.currentGuide then
        if self.currentGuide.waitingStartEvent then
            return
        end
        if dontMarkComplete then
            self.currentGuide.config.dontMarkComplete = true
        end
        self.currentGuide:Finish()
    end
end

function MapGuideManager:MarkGuideComplete(guideId)
    print("MapGuideManager:MarkGuideComplete:", guideId) --@DEL
    if not guideId or self.data.completeIds[guideId] then
        return
    end
    local reusedId = ReusedGuideId[guideId]
    if reusedId then
        local dt = self.data.reusedIds[guideId]
        self.data.reusedIds[guideId] = {id = guideId, reusedId = reusedId}
        guideId = string.format("%s_%s", guideId, reusedId)
        if dt then
            local old = dt.id
            if dt.reusedId then
                old = string.format("%s_%s", old, dt.reusedId)
            end
            self:RequestReplaceGuideIds({old}, {guideId})
            return
        end
    else
        self.data.completeIds[guideId] = true
    end
    self:RequestGuideComplete(guideId)
end

function MapGuideManager:RequestGuideComplete(guideId)
    Util.BlockAll(-1, "GuideRequest")
    local function onSuccess()
        Util.BlockAll(0, "GuideRequest")
        console.print(string.format("request guide complete success,guide id = %s", guideId)) --@DEL
    end
    local function onFailed(ecode)
        Util.BlockAll(0, "GuideRequest")
        if ecode == ErrorCodeEnums.TIMEOUT then
            self:RequestGuideComplete(guideId)
        else
            console.error(string.format("request guide complete error:code = %d,guide id = %s", ecode, guideId)) --@DEL
        end
    end
    Net.Coremodulemsg_1005_GuideComplete_Request({guideId = guideId}, onFailed, onSuccess)
end

function MapGuideManager:RequestReplaceGuideIds(olds, news)
    Util.BlockAll(-1, "GuideRequest")
    local function onSuc()
        Util.BlockAll(0, "GuideRequest")
    end
    local function onFai()
        Util.BlockAll(0, "GuideRequest")
    end
    Net.Coremodulemsg_1030_ReplaceGuideComplete_Request({oldGuideId = olds, guideId = news}, onFai, onSuc)
end

function MapGuideManager:IsSuspendJob()
    return self.suspendJob == true
end

function MapGuideManager:IsUIDisabled()
    return self.uiDisabled == true
end

function MapGuideManager:IsAgentClickDisabled(agentId)
    if self.agentClickDisabled and agentId then
        self:OnGuideFinishEvent(GuideEvent.AgentClick, agentId)
    end
    return self.agentClickDisabled == true
end

function MapGuideManager:IsMapBubbleClickDisabled()
    return self.mapBubbleClickDisabled == true
end
function MapGuideManager:IsScaleScreenDisabled()
    return self.scaleScreenDisabled == true
end

function MapGuideManager:IsDragScreenDisabled()
    return self.dragScreenDisabled == true
end
function MapGuideManager:IsLongPressDisabled()
    return self.longPressDisabled == true
end
function MapGuideManager:IsClickDragonDisabled()
    if self.clickDragonDisabled then
        console.tprint(self, "click dragon is disabled by MapGuideManager") --@DEL
    end
    return self.clickDragonDisabled == true
end
function MapGuideManager:IsDoubleClickDisabled(agentId)
    if self.doubleClickDisable and agentId then
        self:OnGuideFinishEvent(GuideEvent.DoubleClickAgent, agentId)
    end
    return self.doubleClickDisable == true
end
function MapGuideManager:IsDragDragonDisabled()
    if self.dragDragonDisabled then
        console.tprint(self, "drag dragon is disabled by MapGuideManager")
    end
    return self.dragDragonDisabled == true
end

function MapGuideManager:DisableAll()
    self:DisableClickDragon(true)
    self:DisableDragScreen(true)
    self:DisableAgentClick(true)
    self:DisableScaleScreen(true)
    self:DisableMapBubbleClick(true)
    self:DisableDoubleClick(true)
    self:DisableDragDragon(true)
    self:DisableLongPress(true)
    self:DisableUI(true)
end

function MapGuideManager:DisableClickDragon(value)
    self.clickDragonDisabled = value
end

function MapGuideManager:DisableDragScreen(value)
    if value then
        RuntimeContext.TRACE_BACK() ---@DEL
    end
    self.dragScreenDisabled = value
end

function MapGuideManager:DisableAgentClick(value)
    self.agentClickDisabled = value
end

function MapGuideManager:DisableScaleScreen(value)
    self.scaleScreenDisabled = value
end

function MapGuideManager:DisableMapBubbleClick(value)
    MapBubbleManager:DisableBubbleClick(value)
    self.mapBubbleClickDisabled = value
end

function MapGuideManager:DisableDoubleClick(value)
    self.doubleClickDisable = value
end

function MapGuideManager:DisableDragDragon(value)
    self.dragDragonDisabled = value
end

function MapGuideManager:DisableLongPress(value)
    self.longPressDisabled = value
end

function MapGuideManager:DisableUI(value)
    if Runtime.CSValid(App.scene.canvas) then
        local rayCaster = find_component(App.scene.canvas, "", GraphicRaycaster)
        if value == false then
            rayCaster.enabled = true
        else
            rayCaster.enabled = false
        end
        self.uiDisabled = value
    end
end

function MapGuideManager:DisableJop(value)
    self.suspendJob = value
end

function MapGuideManager:ClearFlags()
    console.systrace("MapGuideManager:ClearFlags()") --@DEL
    self.waitingButtonGO = nil
    self.agentClickDisabled = nil
    self.targetMoveToPosition = nil
    self.dragScreenDisabled = nil
    self.scaleScreenDisabled = nil
    self.clickDragonDisabled = nil
    self.mapBubbleClickDisabled = nil
    self.longPressDisabled = nil
    self.suspendJob = nil
    self.doubleClickDisable = nil
    self.dragDragonDisabled = nil
    self:DisableUI(false)
    self:DisableMapBubbleClick(false)
end
---中断引导，不会导致引导完成
function MapGuideManager:BreakGuide()
    self:ClearFlags()
    local id = nil
    if self.currentGuide then
        id = self.currentGuide.id
        self.currentGuide:ClearCurrentStep()
        self.currentGuide = nil
    end
    self:CallGuideFinishCallback()
    MessageDispatcher:SendMessage(MessageType.Global_Guide_Break, id)
end

function MapGuideManager:SetCurrentGuide(guide)
    self.currentGuide = guide
end

function MapGuideManager:GetCurrentGuide()
    return self.currentGuide
end

function MapGuideManager:GetCurrentGuideCanvas()
    if self.currentGuide then
        return self.currentGuide:GetGuideCanvas()
    end
end

function MapGuideManager:SetGuideExtraParam(guideId, param)
    self.extraParam[guideId] = param
end

function MapGuideManager:GetGuideExtraParam(guideId)
    return self.extraParam[guideId]
end

function MapGuideManager:HasRunningGuide(id)
    if self.hasJob then ---是否已经有引导缓存到了PopupManager
        return true
    end
    if self:IsWeakStep() then
        return false
    end
    if not id then
        return self.currentGuide ~= nil
    end

    return self.currentGuide and self.currentGuide.id == id
end
---当前步骤是否为若引导
function MapGuideManager:IsWeakStep()
    if self.currentGuide then
        return self.currentGuide:IsWeakStep()
    end
end

function MapGuideManager:OnGuideFinishEvent(eventName, params)
    if self.currentGuide then
        local status = Runtime.InvokeCbk(self.currentGuide.HandleEvent, self.currentGuide, eventName, params)
        if not status then
            console.warn(nil, "guide error, id = " .. tostring(self.id))
        end
    end
end

function MapGuideManager:SetGuideFinishCallback(callback)
    self.guideFinishCallback = self.guideFinishCallback or {}
    table.insert(self.guideFinishCallback, callback)
end

function MapGuideManager:CallGuideFinishCallback()
    if not self.guideFinishCallback then
        return
    end

    for index, value in ipairs(self.guideFinishCallback) do
        Runtime.InvokeCbk(value)
    end
    self.guideFinishCallback = nil
end

return MapGuideManager
