local BaseIconButton = require "UI.Components.BaseIconButton"
---@class TaskButton:BaseIconButton
local TaskButton = class(BaseIconButton)

function TaskButton:Create()
    local gameObject = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_HOMESCENE_TASK_BUTTON)
    return TaskButton:CreateWithGameObject(gameObject)
end

function TaskButton:CreateWithGameObject(gameObject)
    local instance = TaskButton.new()
    instance:InitWithGameObject(gameObject)
    return instance
end

function TaskButton:InitWithGameObject(go)
    self.gameObject = go
    self.transform = self.gameObject.transform
    self.Interactable = true
    self.isEntered = true
    self.iconGo = self.gameObject

    local go_task = find_component(go, "go_task")
    self.go_task = go_task
    self.img_icon = find_component(go_task, "img_icon", Image)
    self.txt_num = find_component(go_task, "txt_num", Text)
    self.txt_desc = find_component(go_task, "txt_desc", Text)
    self.img_progress = find_component(go_task, "img_progress", Image)
    local go_taskdone = find_component(go, "go_taskdone")
    self.go_taskdone = go_taskdone
    self.txt_reward = find_component(go_taskdone, "txt_reward", Text)
    self.img_iconDone = find_component(go_taskdone, "img_iconDone", Image)


    local function OnClick_button_Task(go)
        if not self.Interactable then
            return
        end
        AppServices.Jump.JumpTask(self:GetTaskSn())
        -- DcDelegates:Log(SDK_EVENT.mainUI_button, {buttonName = "backpack"})
        -- PanelManager.showPanel(GlobalPanelEnum.BagPanel)
    end
    local function OnClick_button_TaskDone(go)
        if not self.Interactable then
            return
        end
        AppServices.Task:TaskFinish(self:GetTaskSn())
        -- DcDelegates:Log(SDK_EVENT.mainUI_button, {buttonName = "backpack"})
        -- PanelManager.showPanel(GlobalPanelEnum.BagPanel)
    end
    Util.UGUI_AddButtonListener(self.go_task, OnClick_button_Task, {noAudio = true})
    Util.UGUI_AddButtonListener(self.go_taskdone, OnClick_button_TaskDone, {noAudio = true})
    self:RegisterListener()
    local sn = AppServices.Task:GetMainTask()
    self:SetTask(sn)
    self:Refresh()
end

function TaskButton:setActive(isShow)
    if Runtime.CSValid(self.gameObject) then
        self.gameObject:SetActive(isShow)
    end
end

function TaskButton:RegisterListener()
    MessageDispatcher:AddMessageListener(MessageType.Task_OnTaskFinish, self.OnTaskFinish, self)
    MessageDispatcher:AddMessageListener(MessageType.Task_OnTaskAddProgress, self.OnTaskAddProgress, self)
    MessageDispatcher:AddMessageListener(MessageType.Task_OnTaskStart, self.OnTaskStart, self)
end

function TaskButton:RemoveListener()
    MessageDispatcher:RemoveMessageListener(MessageType.Task_OnTaskFinish, self.OnTaskFinish, self)
    MessageDispatcher:RemoveMessageListener(MessageType.Task_OnTaskAddProgress, self.OnTaskAddProgress, self)
    MessageDispatcher:RemoveMessageListener(MessageType.Task_OnTaskStart, self.OnTaskStart, self)

end

function TaskButton:OnTaskFinish(taskSn, taskType)
    if taskType ~= TaskType.Main then
        return
    end
    if taskSn == self:GetTaskSn() then
        self:Refresh()
    end
end

function TaskButton:OnTaskAddProgress(taskSn, taskType)
    if taskType ~= TaskType.Main then
        return
    end
    if taskSn == self:GetTaskSn() then
        self:Refresh()
    end
end

function TaskButton:OnTaskStart(taskSn, taskType)
    if taskType ~= TaskType.Main then
        return
    end
    if taskSn ~= self:GetTaskSn() then
        self:SetTask(taskSn)
        self:Refresh()
    end
end

function TaskButton:SetBtnCallback(callback)
    self.btnCallback = callback
end

function TaskButton:ShowExitAnim(exitImmediate, callback)
    self.isEntered = false
    self.isShowing = false
end

function TaskButton:ShowEnterAnim(callback, showTime)
    self.isEntered = true
    self.isShowing = true
end

function TaskButton:OnHit()
    App.audioManager:PlayEffectAudio(CONST.AUDIO.Interface_sound_acquire_resource)
    if self.shaking then
        return
    end
    self.anim:SetTrigger("shake")
    self.shaking = true
    WaitExtension.SetTimeout(
        function()
            self.shaking = false
        end,
        1
    )
end

function TaskButton:RefreshDot()
    -- self.redDot:SetActive(AppServices.BagDot:HasDot())
end

function TaskButton:SetParent(parent)
    self.gameObject.transform:SetParent(parent, false)
    self.rectTransform = self.gameObject:GetComponent(typeof(RectTransform))
end

function TaskButton:SetInteractable(value)
    self.Interactable = value
end

function TaskButton:GetMainIconGameObject()
    return self.iconGo
end

--[==[ 解决使用CommonRewardPanel的时候有道具飞向背包同时CommonRewardPanel的argsument.showTarget = true的时候背包按钮不能点击的问题
function TaskButton:OnEvent_ShowBottomIcons(isFirstTime)
    self:ShowEnterAnim()
end

function TaskButton:OnEvent_HideBottomIcons(instant)
    self:ShowExitAnim()
end
--]==]
function TaskButton:GetValue()
end

function TaskButton:SetValue(value)
end

function TaskButton:SetTask(taskSn)
    self.sn = taskSn
end

function TaskButton:GetTaskSn()
    return self.sn
end

function TaskButton:Refresh()
    local sn = self:GetTaskSn()
    if not sn then
        self:setActive(false)
        return
    end
    self:setActive(true)
    local entity = AppServices.Task:GetTaskEntity(sn)
    local itemIcon = AppServices.ItemIcons
    local cfg = entity:GetConfig()
    local iconName = cfg.taskIcon
    itemIcon:SetTaskIcon(self.img_icon, iconName)
    itemIcon:SetTaskIcon(self.img_iconDone, iconName)
    local total = entity:GetTotal()
    local cur = math.min(total, entity:GetProgress())
    local per = cur / total
    self.img_progress.fillAmount = per
    local isDone = entity:IsDone()
    self.go_task:SetActive(not isDone)
    self.go_taskdone:SetActive(isDone)
    self.txt_num.text = string.format("%d/%d", cur, total)
    local str = entity:GetTasKDesc()
    self.txt_desc.text = str
end

function TaskButton:Dispose()
    self:RemoveListener()
    BaseIconButton.Dispose(self)
end

return TaskButton
