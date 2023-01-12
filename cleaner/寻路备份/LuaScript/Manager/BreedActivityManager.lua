local ActivityBase = require("Game.Activities.ActivityBase")
---@class BreedActivityManager:ActivityBase
local BreedActivityManager = class(ActivityBase, "BreedActivityManager")

function BreedActivityManager:ctor()
    MessageDispatcher:AddMessageListener(MessageType.DAY_SPAN, self.OnDaySpan, self)
end

function BreedActivityManager:OnDaySpan()
    if not self:IsInActivityTime() or not self:IsUnlock() then
        return
    end

    local requestCallback = function(result)
        if not result then
            return
        end
        if PanelManager.isPanelShowing(GlobalPanelEnum.BreedActivityPanel) then
            ---@type BreedActivityPanel
            local panel = PanelManager.GetPanel(GlobalPanelEnum.BreedActivityPanel.panelName)
            panel:RefreshDaySpan()
        end
    end

    self:ActivityBreedInfoRequest(requestCallback)
end

function BreedActivityManager:InitTasks(breedTasks)
    if self.taskEntities then
        for _, taskEntity in pairs(self.taskEntities) do
            taskEntity:destory()
        end
    end

    ---@type SubTaskBase[]
    self.taskEntities = {}
    for index, value in ipairs(breedTasks) do
        self.taskEntities[value.taskId] = self:CreateTask(value)
    end
end

function BreedActivityManager:CreateTask(taskData)
    local cfg = AppServices.Meta:Category("BreedTaskTemplate")[taskData.taskId]
    if not cfg then
        console.error("繁育活动任务配置为空：", taskData.taskId)
        return
    end
    local TaskTypes = require("Task.TaskTypes")
    local sub_class = TaskTypes[cfg.MissionType]
    if sub_class then
        local newCfg = TaskTypes.ConverterActivityCfg(cfg.MissionType, cfg)
        local taskEntity = sub_class.new(TaskKind.BreedActivity, taskData.taskId, nil, newCfg, taskData.progress)
        --0 未完成，1完成未提交，2完成并且已提交
        if taskData.status == 2 then
            taskEntity:SetSubmit()
        end
        taskEntity:RegisterListener()
        return taskEntity
    end
end

function BreedActivityManager:HasDoneAndNotSubmitTask()
    if not self.taskEntities then
        return false
    end
    for key, value in pairs(self.taskEntities) do
        if value:IsDone() and not value:IsSubmit() then
            return true
        end
    end
    return false
end

function BreedActivityManager:HasDoneAndUnLockAndNotSubmitTask()
    if not self.taskEntities then
        return false
    end
    for key, value in pairs(self.taskEntities) do
        if value:IsDone() and not value:IsSubmit() and self:IsTaskUnlock(value:GetCfg()) then
            return true
        end
    end
    return false
end

-- function BreedActivityManager:GetTime()
--     return 1638707473000, 1639368913000
-- end

function BreedActivityManager:IsTaskUnlock(taskConfig)
    return taskConfig.unlockTime <= self:GetLastTime() // 3600000
end

function BreedActivityManager:GetLastTime()
    local startTime = self:GetTime() or 0
    return TimeUtil.ServerTimeMilliseconds() - startTime
end

function BreedActivityManager:GetLeftTime()
    local _, endTime = self:GetTime()
    if not endTime then
        return 0
    end
    return endTime - TimeUtil.ServerTimeMilliseconds()
end

function BreedActivityManager.GetTaskCfg(taskTemplateId)
    return AppServices.Meta:Category("BreedTaskTemplate")[taskTemplateId]
end

function BreedActivityManager:GetTaskEntityById(taskId)
    return self.taskEntities[taskId]
end

function BreedActivityManager:CheckCreateButton()
    if not self:IsUnlock() then
        return
    end

    if not App.scene:IsMainCity() and not App.mapGuideManager:HasComplete(GuideIDs.GuideBreedActivity) then
        return
    end

    local btn = App.scene:GetWidget(CONST.MAINUI.ICONS.BreedActivityButton)
    if not btn then
        local BreedActivityButton = require("UI.Components.BreedActivityButton")
        BreedActivityButton:Create()
    end
end

function BreedActivityManager:CheckGuide()
    if App.mapGuideManager:HasComplete(GuideIDs.GuideBreedActivity) then
        return
    end

    if not App.scene:IsMainCity() then
        return
    end

    local function idleDo()
        App.mapGuideManager:StartSeries(GuideIDs.GuideBreedActivity)
    end

    PopupManager:CallWhenIdle(idleDo)
end

function BreedActivityManager:RequestInfo(finishCallback)
    if not self:IsUnlock() then
        Runtime.InvokeCbk(finishCallback)
        return
    end

    local function requestCallback(result, mag)
        if not result then
            Runtime.InvokeCbk(finishCallback)
            return
        end
        self:CheckCreateButton()
        self:CheckGuide()
        Runtime.InvokeCbk(finishCallback)
    end
    self:ActivityBreedInfoRequest(requestCallback)
end

function BreedActivityManager:OnInitActivity(finishCallback)
    self:RequestInfo(finishCallback)
end

function BreedActivityManager:OnUpdateActivityData(finishCallback)
    self:RequestInfo(finishCallback)
end

-- function BreedActivityManager:OnCheckEntrance()
--     self:CheckCreateButton()
--     self:CheckGuide()
-- end

--是否是本组最后一个未提交的任务
function BreedActivityManager:IsLastSubmitInGroup(taskId)
    local meta = AppServices.Meta:Category("BreedTaskTemplate")
    for key, value in pairs(self.taskEntities) do
        if value.taskId ~= taskId and meta[value.taskId].unlockTime == meta[taskId].unlockTime and not value:IsSubmit() then
            return false
        end
    end
    return true
end

function BreedActivityManager:IsAllSubmit()
    for key, value in pairs(self.taskEntities) do
        if not value:IsSubmit() then
            return false
        end
    end
    return true
end

function BreedActivityManager:SetLocalDataUnlockIndex(index)
    self:UnlockProgressRequest(index)
    self.progress = index
end

function BreedActivityManager:GetLocalDataUnlockIndex()
    return self.progress
end

function BreedActivityManager:IsActivityBreed(parent1, parent2)
    local breedActivitySetTemplate = AppServices.Meta:Category("BreedActivitySetTemplate")
    for key, value in pairs(breedActivitySetTemplate) do
        if value.BreedParents[1] == parent1 and value.BreedParents[2] == parent2 then
            return true
        end
    end
    return false
end

function BreedActivityManager:GetDragonConfig()
    if not self:IsValid() then
        return
    end

    if not self.dragonConfig then
        local reward =
            AppServices.Meta:Category("BreedActivitySetTemplate")[ActivityServices.BreedActivity:GetActivityId()].BreedTaskReward
        self.dragonConfig = AppServices.Meta:Category("MagicalCreaturesTemplate")[tostring(reward[1])]
    end
    return self.dragonConfig
end

function BreedActivityManager:Get_breedActivityGetDragonTime()
    local setCfg = AppServices.Meta:Category("BreedActivitySetTemplate")[self.activityId]
    return setCfg["breedActivityGetDragonTime"]
end

function BreedActivityManager:GetBreedCount()
    return self.breedCount or 0
end

function BreedActivityManager:AddBreedCount(delta)
    local maxCount = self:Get_breedActivityGetDragonTime()
    self.breedCount = self.breedCount + delta
    if self.breedCount >= maxCount then
        self.breedCount = self.breedCount - maxCount
    end
end

local function convertActivityTask(msg)
    local progress = Net.Converter.ConvertProtoTypes(msg.params)
    return {
        status = msg.state,
        taskId = msg.taskId,
        progress = progress
    }
end

function BreedActivityManager:ActivityBreedInfoRequest(callback)
    local function onSuccess(msg)
        local breedTasks = Net.Converter.ConvertArray(msg.breedTasks, convertActivityTask)
        self:InitTasks(breedTasks)
        self.breedCount = msg.breedCount
        local maxCount = self:Get_breedActivityGetDragonTime()
        --配置变更导致的异常情况  下次必出龙
        if self.breedCount >= maxCount then
            self.breedCount = maxCount - 1
        end
        --解锁动画进度
        self.progress = msg.progress
        Runtime.InvokeCbk(callback, true, msg)
    end
    local function onFail(errorCode)
        ErrorHandler.ShowErrorPanel(errorCode)
        console.warn(nil, "Try request activity Id:", self:GetActivityId(), "FAILED!") --@DEL
        Runtime.InvokeCbk(callback, false, errorCode)
    end
    Net.Activitybreedmodulemsg_26101_ActivityBreedInfo_Request({activityId = self.activityId}, onFail, onSuccess)
end

function BreedActivityManager:TakeTaskAwardRequest(callback, taskId)
    local function onSuccess(msg)
        local taskEntity = self:GetTaskEntityById(taskId)
        taskEntity:SetSubmit()
        local cfg = AppServices.Meta:Category("BreedTaskTemplate")[taskId]
        for index, value in ipairs(cfg.taskReward) do
            AppServices.User:AddItem(value[1], value[2], "breed_task_reward")
        end

        local setCfg = AppServices.Meta:Category("BreedActivitySetTemplate")[self.activityId]
        local finalReward
        if self:IsAllSubmit() then
            finalReward = setCfg.BreedTaskReward
            local dragonId = tostring(finalReward[1])
            -- local function addDragonCallback(entity, dragonData)
            --     local dragonConfig = SceneServices.BreedManager:GetCreatureConfig()[dragonId]
            --     if entity then
            --         entity.data.lastCollectHangUpRewardTime =
            --             entity.data.lastCollectHangUpRewardTime - dragonConfig.productivity[2]
            --     elseif dragonData then
            --         dragonData.lastCollectHangUpRewardTime =
            --             dragonData.lastCollectHangUpRewardTime - dragonConfig.productivity[2]
            --     end
            -- end

            if App.scene:IsMainCity() then
                AppServices.MagicalCreatures:AddDragonByItem(dragonId, nil, nil, nil, 2)
            else
                AppServices.MagicalCreatures:AddDragonByItem(dragonId, nil, nil, true)
            end
        end
        Runtime.InvokeCbk(callback, true, cfg.taskReward, finalReward)
    end
    local function onFail(errorCode)
        ErrorHandler.ShowErrorPanel(errorCode)
        Runtime.InvokeCbk(callback, false)
    end
    Net.Activitybreedmodulemsg_26102_TakeTaskAward_Request(
        {activityId = self.activityId, taskId = taskId},
        onFail,
        onSuccess
    )
end

function BreedActivityManager:UnlockProgressRequest(progress)
    local function onSuccess(msg)
    end
    local function onFail(errorCode)
        ErrorHandler.ShowErrorPanel(errorCode)
    end
    Net.Activitybreedmodulemsg_26103_UnlockProgress_Request(
        {activityId = self.activityId, progress = progress},
        onFail,
        onSuccess
    )
end

return BreedActivityManager.new()
