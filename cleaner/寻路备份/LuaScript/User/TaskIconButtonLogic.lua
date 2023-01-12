---@class TaskIconButtonLogic
local TaskIconButtonLogic = class(nil, "TaskIconButtonLogic")

function TaskIconButtonLogic:ctor()
    self:Init()
end

function TaskIconButtonLogic:Init()
    self:RegisterListener()
end

local function GetTaskKindBySceneId(sceneId)
    local taskKind
    local sceneCfg = AppServices.Meta:GetSceneCfg(sceneId)
    if not sceneCfg then
        return
    end
    local sceneType = sceneCfg.type
    if sceneType == SceneType.Activity then
        local params = table.deserialize(sceneCfg.param)
        local activityId = tostring(params[1])
        taskKind = ActivityKind2TaskKind[activityId]
    elseif sceneType == SceneType.LevelMapActivity then
        local params = table.deserialize(sceneCfg.param)
        local activityId = tostring(params[1])
        taskKind = LevelMapActivityId2TaskKind[activityId]
    elseif sceneType == SceneType.GoldPanning then
        taskKind = TaskKind.GoldPanning
    end

    return taskKind
end

function TaskIconButtonLogic:BindView(rootView)
    if self:NoTaskList() then
        return
    end
    local TaskList = require("UI.Components.TaskList")
    local btn = TaskList:Create()
    btn.gameObject:SetParent(App.scene.layout:LeftLayout(), false)
    btn.gameObject.transform:SetAsLastSibling()
    rootView:AddWidget(CONST.MAINUI.ICONS.TaskBtn, btn)
    self.taskButton = btn
    local taskKind = TaskKind.Task
    local sceneId = App.scene:GetCurrentSceneId()
    local t = GetTaskKindBySceneId(sceneId)
    if t then
        taskKind = t
    end
    btn:SetTaskKind(taskKind)
    self:RefreshRedDot()
end

function TaskIconButtonLogic:ForceRefresh()
    if self:NoTaskList() then
        return
    end
    local view = self:GetView()
    local taskKind
    if view then
        taskKind = view.taskKind
        self:RemoveView(taskKind)
    end
    local TaskList = require("UI.Components.TaskList")
    local btn = TaskList:Create()
    btn.gameObject:SetParent(App.scene.layout:LeftLayout(), false)
    btn.gameObject.transform:SetAsLastSibling()
    App.scene:AddWidget(CONST.MAINUI.ICONS.TaskBtn, btn)
    self.taskButton = btn
    if not taskKind then
        taskKind = TaskKind.Task
        local sceneId = App.scene:GetCurrentSceneId()
        local t = GetTaskKindBySceneId(sceneId)
        if t then
            taskKind = t
        end
    end
    btn:SetTaskKind(taskKind)
    self:RefreshRedDot()
end

function TaskIconButtonLogic:ForceRemoveView()
    local view = self:GetView()
    local taskKind
    if view then
        taskKind = view.taskKind
        self:RemoveView(taskKind)
    end
end

function TaskIconButtonLogic:NoTaskList()
    local sceneId = App.scene:GetCurrentSceneId()
    local sceneCfg = AppServices.Meta:GetSceneCfg(sceneId)
    if sceneCfg.type == SceneType.Maze then
        return true
    end
    if sceneCfg.type == SceneType.TeamMap then
        return true
    end
    if sceneCfg.type == SceneType.TeamDragon then
        return true
    end
    -- if sceneCfg.type == SceneType.GoldPanning then
    --     return true
    -- end
end

function TaskIconButtonLogic:GetView()
    return self.taskButton
end

function TaskIconButtonLogic:RemoveView(taskKind)
    local view = self:GetView()
    if not view or view.taskKind ~= taskKind then
        return
    end
    App.scene:DelWidget(CONST.MAINUI.ICONS.TaskBtn)
    view:Dispose()
    self.taskButton = nil
end

function TaskIconButtonLogic:UnbindView()
    self.taskButton = nil
end

function TaskIconButtonLogic:RegisterListener()
    MessageDispatcher:AddMessageListener(MessageType.Task_OnSubTaskFinish, self.OnSubTaskFinish, self)
    MessageDispatcher:AddMessageListener(MessageType.Task_OnTaskFinish, self.OnTaskFinish, self)
    MessageDispatcher:AddMessageListener(MessageType.Task_After_TaskSubmit, self.OnTaskSubmit, self)
    MessageDispatcher:AddMessageListener(MessageType.Task_OnTaskStart, self.OnTaskStart, self)
    MessageDispatcher:AddMessageListener(MessageType.Task_OnSubTaskAddProgress, self.OnSubTaskAddProgress, self)
    -- MessageDispatcher:AddMessageListener(MessageType.TASK_WAKE_GUIDE, self.SetArrowShow, self)
    MessageDispatcher:AddMessageListener(MessageType.Global_Guide_Start, self.OnGuideStart, self)
    MessageDispatcher:AddMessageListener(MessageType.Global_Guide_Finish, self.OnGuideFinish, self)
    MessageDispatcher:AddMessageListener(MessageType.Global_Drama_Start, self.OnDramaStart, self)
    MessageDispatcher:AddMessageListener(MessageType.Global_Drama_Over, self.OnDramaOver, self)
end

function TaskIconButtonLogic:OnTaskFinish(taskId, autoSubmit, taskKind)
    -- TODO LZL 有活动任务的时候, 判断任务是活动任务还是普通任务
    local taskBtn = self:GetView()
    if taskBtn then
        self:RefreshRedDot(nil, taskKind)
        -- taskBtn:ShowPopBar(true)
        taskBtn:OnTaskFinish(taskId, autoSubmit, taskKind)
        if taskKind == TaskKind.Task then
            -- taskBtn:StartWeakGuide()
        end
    else
        -- console.lzl("1002 No TaskList----------")
    end
end

function TaskIconButtonLogic:OnTaskSubmit(taskId, taskKind)
    local taskBtn = self:GetView()
    if taskBtn then
        taskBtn:OnTaskSubmit(taskId, taskKind)
    end
end

function TaskIconButtonLogic:OnSubTaskFinish(taskKind, taskId)
    local taskBtn = self:GetView()
    if taskBtn then
        taskBtn:OnSubTaskFinish(taskKind, taskId)
    end
end

function TaskIconButtonLogic:OnSubTaskAddProgress(taskKind, taskId, subIndex)
    local taskBtn = self:GetView()
    if taskBtn then
        taskBtn:OnSubTaskAddProgress(taskKind, taskId, subIndex)
    end
end

function TaskIconButtonLogic:OnTaskStart(taskKind, taskId)
    local taskBtn = self:GetView()
    if taskBtn then
        taskBtn:OnTaskStart(taskKind, taskId)
    end
end

function TaskIconButtonLogic:SetArrowShow(show)
    local taskBtn = self:GetView()
    if taskBtn then
        if not show then
            taskBtn:BreakWeakGuide()
        end
    end
end

function TaskIconButtonLogic:OnGuideStart()
    local taskBtn = self:GetView()
    if taskBtn then
        taskBtn:BreakWeakGuide()
    end
end

function TaskIconButtonLogic:OnDramaStart()
    local taskBtn = self:GetView()
    if taskBtn then
        taskBtn:BreakWeakGuide()
    end
end

function TaskIconButtonLogic:OnDramaOver()
    local taskBtn = self:GetView()
    if taskBtn then
        taskBtn:BreakWeakGuide()
    end
end

function TaskIconButtonLogic:OnGuideFinish()
    local taskBtn = self:GetView()
    if taskBtn then
        taskBtn:SetWeakGuideActive(true)
    end
end

function TaskIconButtonLogic:RefreshRedDot(forceShow, taskKind)
    local taskButton = self.taskButton
    if not taskButton then
        return
    end
    if forceShow then
        taskButton:ShowRedDot(true)
        return
    end
    taskButton:ShowRedDot()
    -- if taskKind and not self.taskButtons[taskKind] then
    --     return
    -- end
    -- if not taskKind then
    --     for _, taskButton in pairs(self.taskButtons) do
    --         if forceShow then
    --             taskButton:ShowRedDot(true)
    --         else
    --             taskButton:ShowRedDot()
    --         end
    --     end
    -- else
    --     local taskButton = self.taskButtons[taskKind]
    --     if forceShow then
    --         taskButton:ShowRedDot(true)
    --         return
    --     end
    --     taskButton:ShowRedDot()
    -- end
end

function TaskIconButtonLogic:JumpTask(params)
    local taskBtn = self:GetView()
    if taskBtn then
        taskBtn:JumpTask(params)
    end
end

function TaskIconButtonLogic:ShowBuildingTaskTip(taskId, subIndex, key)
    local taskBtn = self:GetView()
    if taskBtn then
        taskBtn:ShowBuildingTaskTip(taskId, subIndex, key)
    end
    --[==[
            sendNotification(
                TaskPanelNotificationEnum.check_Building_Task_Tip,
                {taskId = taskId, subIndex = subIndex, key = key}
            )
            --]==]
end

return TaskIconButtonLogic.new()