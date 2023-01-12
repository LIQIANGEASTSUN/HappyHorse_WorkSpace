---@class ExpLogic
local ExpLogic = {
    exLvl = AppServices.User:GetCurrentLevelId(),
    maxLevel = 1,
    minLevel = 99999,
}

function ExpLogic:RefreshExpValue(level)
    self.exLvl = level
end

function ExpLogic:GetExValue()
    return self.exLvl
end

local levelUpSourceMap = {
    ["order"] = GlobalPanelEnum.OrderTaskPanel,
    ["timeOrder"] = GlobalPanelEnum.TimeOrderPanel,
    ["goldOrder"] = GlobalPanelEnum.GoldOrderPanel,
}

function ExpLogic:StartWait()
    self.isWait = true
    self.waitList = {}
end

function ExpLogic:EndWait()
    self.isWait = false
    for _, value in ipairs(self.waitList) do
        self:LevelUpLogic(value[1],value[2],value[3])
    end
end

function ExpLogic:LevelUpLogic(info, source, showFullLevelUp)
    if table.isEmpty(info) then
        return
    end

    if self.isWait then
        table.insert(self.waitList, {info, source, showFullLevelUp})
        return
    end

    local function finishNode()
        QueueLineManage.Instance():FinishNode()
    end
    local pcb = PanelCallbacks:Create(function()
        finishNode()
    end)
    --handlenode
    --1 关掉面板
    local prePanel = levelUpSourceMap[source]
    if prePanel and not PanelManager.isPanelShowing(prePanel) then
        prePanel = nil
    end
    local hasGuide = false

    local function ShowPanelNode()
        for index, value in ipairs(info) do
            QueueLineManage.Instance():CreateNode("PopShowUI",function()
                local panelEnum = GlobalPanelEnum.LevelUpPanel
                if showFullLevelUp then
                    panelEnum = GlobalPanelEnum.FullLevelUpPanel
                end
                PanelManager.closeAllPanels()
                PanelManager.showPanel(panelEnum, {level = value},pcb)
                self.isShowLvUpPanel = false
                -- AppServices.Notification:CheckOpenNotificationByLevel()
            end)

            --引导
            if App.scene:IsMainCity() and App.mapGuideManager:Checklevelup(value) then
                hasGuide = true
                QueueLineManage.Instance():CreateNode("LevelGuide",function()
                    App.mapGuideManager:LevelUpEvent(value)
                    App.mapGuideManager:SetGuideFinishCallback(finishNode)
                end)
            end
        end
    end

    local function DramaNode()
        local function RegisterDramaOver()
            MessageDispatcher:AddMessageListener(MessageType.Global_Drama_Over, finishNode, self)
        end

        local function RemoveDramaOver()
            MessageDispatcher:RemoveMessageListener(MessageType.Global_Drama_Over, finishNode, self)
            finishNode()
        end
        QueueLineManage.Instance():CreateNode("hasDrama", RegisterDramaOver)
        QueueLineManage.Instance():CreateNode("hasDramaEnd", RemoveDramaOver)
    end

    local function SceneQueueNode()
        local function RegisterQueueEnd()
            MessageDispatcher:AddMessageListener(MessageType.PopupQueue_FINISHED, finishNode, self)
        end

        local function RemoveQueueEnd()
            MessageDispatcher:RemoveMessageListener(MessageType.PopupQueue_FINISHED, finishNode, self)
            finishNode()
        end
        QueueLineManage.Instance():CreateNode("hassceneQueue", RegisterQueueEnd)
        QueueLineManage.Instance():CreateNode("sceneQueueEnd", RemoveQueueEnd)
    end

    local function TaskLevelUpNode()
        QueueLineManage.Instance():CreateNode("checkPassGuide", function()
            for _, level in ipairs(info) do
                AppServices.Task:OnPlayerLevelUp(level)
            end
            finishNode()
        end)
    end

    QueueLineManage.Instance():Start("LevelUpLogic",
        function()
            --如果有剧情先执行剧情
            self.isShowLvUpPanel = true
            if App.screenPlayActive then
                DramaNode()
            end
            if  App.mapGuideManager:HasRunningGuide() then
                QueueLineManage.Instance():CreateNode("hasGuide",function()
                    App.mapGuideManager:SetGuideFinishCallback(finishNode)
                end)
            end

            if not App.popupQueue:IsFinished() then
                SceneQueueNode()
            end

            --打开升级面板
            ShowPanelNode()

            TaskLevelUpNode()

            finishNode()
        end,
        function()
            --如果有关闭的面板则打开面板
            --如果有引导直接不打开
            if prePanel then
                QueueLineManage.Instance():CreateNode("PopShowUI",function()
                    if not hasGuide then
                        PanelManager.showPanel(prePanel, {fromExpLogic = true})
                    end
                    finishNode()
                end)
            end
            finishNode()
        end
    )
end

function ExpLogic:SetFullLevelUI(callback)
    local item = App.scene:GetWidget(CONST.MAINUI.ICONS.Experience)
    if item then
        item:Refresh(callback)
    end
end

return ExpLogic