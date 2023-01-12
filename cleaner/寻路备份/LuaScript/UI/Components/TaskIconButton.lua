local BaseIconButton = require "UI.Components.BaseIconButton"

---@class TaskIconButton:BaseIconButton
local TaskIconButton = class(BaseIconButton, "TaskIconButton")

function TaskIconButton:Create()
    local gameObject = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_HOMESCENE_Task_BUTTON)
    return TaskIconButton:CreateWithGameObject(gameObject)
end

function TaskIconButton:CreateWithGameObject(gameObject)
    local instance = TaskIconButton.new()
    instance:InitWithGameObject(gameObject)
    return instance
end

function TaskIconButton:InitWithGameObject(gameObject)
    -- BaseIconButton.InitWithGameObject(self, gameObject)
    self.gameObject = gameObject
    self.transform = gameObject.transform
    self.rectTransform = self:GetRectTransform()
    self.img_icon_idle_go = gameObject:FindGameObject("bg/img_icon_idle")
    self.img_icon_done_go = gameObject:FindGameObject("bg/img_icon_done")
    self.poptips_go = gameObject:FindGameObject("mask/poptips")
    self.go_pop_done = self.poptips_go:FindGameObject("img_pop_done")
    self.go_pop_progress = self.poptips_go:FindGameObject("img_pop_progress")
    -- self.img_icon = self.img_icon_go:GetComponent(typeof(Image))
    self.label_done = find_component(self.go_pop_done, "label_done", Text)
    self.label_progress = find_component(self.go_pop_progress, "label_progress", Text)
    self.img_reddot_go = gameObject:FindGameObject("img_reddot")
    self.img_unlockTip_go = gameObject:FindGameObject("img_unlockTip")
    self.label_unlockTip = find_component(self.img_unlockTip_go, "Text", Text)
    self.img_reddot = self.img_reddot_go:GetComponent(typeof(Image))
    self.btn = gameObject:GetComponent(typeof(Button))
    self.arrow = gameObject:FindGameObject("arrow")
    self.arrowImg = self.arrow:GetComponent(typeof(Image))
    self.originalAnchoredPosY = self.rectTransform.anchoredPosition.y
    self.originalAnchoredPosX = self.rectTransform.anchoredPosition.x
    self.interactable = true
    local function OnClick_btn(go)
        if not self.interactable then
            return
        end
        self:OnBtnClick()
        DcDelegates:Log(SDK_EVENT.mainUI_button, {buttonName = "Task"})
    end

    -- Runtime.Localize(self.label_done, 'ui_task_completed')
    -- Runtime.Localize(self.label_progress, 'ui_task_progress')
    Util.UGUI_AddButtonListener(self.btn.gameObject, OnClick_btn)
    local sceneId = App.scene:GetCurrentSceneId()
    local pos_x = self.transform.position[0]
    if sceneId == "city" then
        self.gameObject:SetLocalPosition(Vector3(pos_x, 189, 0))
    else
        self.gameObject:SetLocalPosition(Vector3(pos_x, 180, 0))
    end
    self.img_reddot_go:SetActive(false)
    self.guideCallback = nil
    self.clickEnabled = true
    self.showRedDot = nil
    local unlock = AppServices.Unlock:IsUnlock("TaskIcon")
    if not unlock then
        MessageDispatcher:AddMessageListener(MessageType.Global_OnUnlock, self.UnlockButton, self)
        self.img_reddot_go:SetActive(false)
        self.gameObject:SetActive(false)
    end
    ---@type WeakGuide
    self.WeakGuide = nil
    self.isEnter = true
    self:StartWeakGuide()
    App.scene:Register(
        self,
        "OnLanguageChanged",
        function()
            self:OnLanguageChanged()
        end
    )
end

function TaskIconButton:OnLanguageChanged()
    Runtime.Localize(self.label_unlockTip, "ui_common_new")
end

function TaskIconButton:GetGuideDelayTime()
    return AppServices.Task:IsTaskSubmit("MIssion1_002FindSendmap") and 5 or 3
end

function TaskIconButton:NeedWeakGuide()
    local agent = App.scene.objectManager:GetAgent("18607")
    if agent and agent:GetState() == CleanState.clearing then
        return false
    end

    local taskId = AppServices.Meta:GetConfigMetaValue("missionGuideEnd")
    --error(taskId)
    if not AppServices.Task:IsTaskSubmit(taskId) then
        return true
    end
    --[[local taskId = taskIds[#taskIds]
    --taskId = "MIssion1_003GetFamiliarWithDragon"
    if AppServices.Task:IsTaskSubmit(taskId) then
        return false
    end
    if AppServices.Task:IsTaskFinish(taskId) then
        return true
    end
    local taskEntity = AppServices.Task:GetTaskProgress(taskId)
    if taskEntity then
        return not taskEntity:IsSubmit()
    end--]]
    return false
end

function TaskIconButton:StartWeakGuide()
    if self.isEnter and self:NeedWeakGuide() then
        if self.WeakGuide == nil then
            self.WeakGuide = include("Task.WeakGuide")
        end
        self.WeakGuide:Start(self:GetGuideDelayTime())
        self:SetArrowShow(self.WeakGuide:IsShow())
    else
        self:SetArrowShow(false)
    end
end

function TaskIconButton:EndWeakGuide()
    if self.WeakGuide ~= nil then
        self.WeakGuide:End()
        if not self:NeedWeakGuide() then
            self.WeakGuide = nil
        end
    end
    self:SetArrowShow(false)
end

function TaskIconButton:UnlockButton(key)
    if key == "TaskIcon" then
        MessageDispatcher:RemoveMessageListener(MessageType.Global_OnUnlock, self.UnlockButton, self)
        self.gameObject:SetActive(true)
    end
end

function TaskIconButton:EnableClick(value)
    self.clickEnabled = value
end

function TaskIconButton:OnBtnClick()
    if not self.clickEnabled then
        -- console.lzl("不能点") --@DEL
        return
    end
    if not App.globalFlags:CanClick() then
        return
    end
    App.globalFlags:SetClickFlag()

    self:PopUpPanel()
    self:UpdateRedDot()
    if self.guideCallback then
        self.guideCallback()
        self.guideCallback = nil
    end
end

function TaskIconButton:PopUpPanel()
    local params = {taskKind = TaskKind.Task}
    if self.unlockSysTaskId then
        params.unlockSysTaskId = self.unlockSysTaskId
        self.unlockSysTaskId = nil
    end
    PanelManager.showPanel(GlobalPanelEnum.TaskPanel, params)
end

function TaskIconButton:ShowRedDot()
    local value = AppServices.RedDotManage:GetRed("Task_Main")
    local unlockSysTaskId = AppServices.Task:IsHaveUnlockSysTask()
    if unlockSysTaskId then
        self.showRedDot = false
        self.img_reddot_go:SetActive(false)
        self.img_unlockTip_go:SetActive(true)
        Runtime.Localize(self.label_unlockTip, "ui_common_new")
        self.unlockSysTaskId = unlockSysTaskId
        return
    else
        self.unlockSysTaskId = nil
        self.img_unlockTip_go:SetActive(false)
    end

    if self.showRedDot == value then
        return
    end
    self.showRedDot = value
    self.img_reddot_go:SetActive(value)
end

--只在解锁时调用，暂时处理红点显示，其他地方禁用
function TaskIconButton:SetShowRedDotValue(val)
    self.showRedDot = val
end

function TaskIconButton:ShowFinishIcon()
    local needShowFinish = AppServices.RedDotManage:GetRed("Task_Finish_Main")
    if self.showFinishIcon == needShowFinish then
        return
    end
    self.showFinishIcon = needShowFinish
    self.img_icon_idle_go:SetActive(not needShowFinish)
    self.img_icon_done_go:SetActive(needShowFinish)
end

function TaskIconButton:UpdateRedDot()
    local needShow = AppServices.RedDotManage:GetRed("Task_Main")
    self:ShowRedDot(needShow)
end

-- 根据是否完成任务显示哪个弹出的条
function TaskIconButton:switchPopBarShow(isDone)
    self.go_pop_done:SetActive(isDone)
    self.go_pop_progress:SetActive(not isDone)
end

function TaskIconButton:ShowPopBar(isDone)
    isDone = not (not isDone)
    if self.isBarMoving then
        -- 正在弹出的时候, 如果是正在弹出黄色条, 则替换成绿色
        if isDone ~= self.showBarState and isDone then
            self:switchPopBarShow(isDone)
            self.showBarState = isDone
        end
        return
    else
        self:switchPopBarShow(isDone)
        self.showBarState = isDone
    end
    local trans = self.poptips_go.transform
    self.isBarMoving = true
    Runtime.Localize(self.label_done, "ui_task_completed")
    Runtime.Localize(self.label_progress, "ui_task_progress")
    GameUtil.DoAnchorPosX(
        trans,
        0,
        0.8,
        function()
            self._hideTimer =
                WaitExtension.SetTimeout(
                function()
                    self._hideTimer = nil
                    self:HidePopBar()
                end,
                1.5
            )
        end
    )
end

function TaskIconButton:HidePopBar()
    local trans = self.poptips_go.transform
    GameUtil.DoAnchorPosX(
        trans,
        -trans.sizeDelta.x,
        0.8,
        function()
            self.isBarMoving = false
            self.showBarState = nil
        end
    )
end

function TaskIconButton:AddGuideCallback(callback)
    self.guideCallback = callback
end

local _offsetX = 300
function TaskIconButton:ShowExitAnim(instant)
    self:EnableClick(false)
    self.isEnter = false
    DOTween.Kill(self.rectTransform, false)
    if instant then
        self.rectTransform.anchoredPosition =
            Vector2(self.originalAnchoredPosX - _offsetX, self.rectTransform.anchoredPosition.y)
    else
        GameUtil.DoAnchorPosX(self.rectTransform, self.originalAnchoredPosX - _offsetX, 0.5)
    end
    self.poptips_go:SetActive(false)
    self:EndWeakGuide()
end

function TaskIconButton:ShowEnterAnim(instant)
    self:EnableClick(true)
    self.isEnter = true
    DOTween.Kill(self.rectTransform, false)
    if instant then
        self.rectTransform.anchoredPosition = Vector2(self.originalAnchoredPosX, self.rectTransform.anchoredPosition.y)
    else
        GameUtil.DoAnchorPosX(self.rectTransform, self.originalAnchoredPosX, 0.2)
    end
    self.poptips_go:SetActive(true)
    self:StartWeakGuide()
end

function TaskIconButton:SetArrowShow(show)
    if show then
        self.arrow:SetActive(show)
        self.arrow.transform.localScale = Vector3(0.5, 0.5, 0.5)
        self.arrowImg.color = Color(1, 1, 1, 0.5)
        self.arrow.transform:DOScale(1, 0.2)
        self.arrowImg:DOFade(1, 0.2)
    else
        self.arrow.transform:DOScale(1, 0.1)
        self.arrowImg:DOFade(1, 0.1).onComplete = function()
            if Runtime.CSValid(self.arrow) then
                self.arrow:SetActive(show)
            end
        end
    end
end

function TaskIconButton:SetWeakGuideActive(active)
    if active then
        self:StartWeakGuide()
    else
        self:EndWeakGuide()
    end
end

function TaskIconButton:GetIdleGo()
    return self.img_icon_idle_go
end

function TaskIconButton:GetRedDotGo()
    return self.img_reddot_go
end

function TaskIconButton:Dispose()
    -- console.lzl("Dispose TaskIconButton")
    if self._hideTimer then
        WaitExtension.CancelTimeout(self._hideTimer)
        self._hideTimer = nil
    end
    if self.WeakGuide ~= nil then
        self.WeakGuide:End()
        self.WeakGuide = nil
    end
    self.arrowImg:DOKill()
    BaseIconButton.Dispose(self)
end

return TaskIconButton
