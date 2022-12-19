local BaseIconButton = require "UI.Components.BaseIconButton"
---@class BagButton:BaseIconButton
local BagButton = class(BaseIconButton)

function BagButton:Create()
    local gameObject = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_HOMESCENE_BAG_BUTTON)
    return BagButton:CreateWithGameObject(gameObject)
end

function BagButton:CreateWithGameObject(gameObject)
    local instance = BagButton.new()
    instance:InitWithGameObject(gameObject)
    return instance
end

function BagButton:InitWithGameObject(gameObject)
    self.gameObject = gameObject
    self.transform = self.gameObject.transform
    -- self.button = gameObject:GetComponent(typeof(Button))
    self.Interactable = true
    self.isEntered = true
    self.iconGo = self.gameObject
    self.redDot = find_component(gameObject, "redDot")
    self.anim = find_component(self.gameObject, "", Animator)
    local function OnClick_button(go)
        if not self.Interactable then
            return
        end
        DcDelegates:Log(SDK_EVENT.mainUI_button, {buttonName = "backpack"})
        PanelManager.showPanel(GlobalPanelEnum.BagPanel)
    end
    Util.UGUI_AddButtonListener(self.gameObject, OnClick_button, {noAudio = true})
    self:RefreshDot()
end

function BagButton:SetBtnCallback(callback)
    self.btnCallback = callback
end

function BagButton:ShowExitAnim(exitImmediate, callback)
    self.isEntered = false
    -- local time = 0.5
    -- if exitImmediate then
    --     time = 0
    -- end
    -- local tarPos = self:GetOutsideAnchoredPosition()
    -- DOTween.Kill(self.rectTransform)
    -- GameUtil.DoAnchorPos(
    --     self.rectTransform,
    --     tarPos,
    --     time,
    --     function()
    --         self.isHided = true
    --         if callback then
    --             Runtime.InvokeCbk(callback)
    --         end
    --     end
    -- )
    self.isShowing = false
end

function BagButton:ShowEnterAnim(callback, showTime)
    self.isEntered = true
    -- showTime = showTime or 0.2
    -- local tarPos = self:GetInsideAnchoredPosition()
    -- DOTween.Kill(self.rectTransform, false)
    -- GameUtil.DoAnchorPos(
    --     self.rectTransform,
    --     tarPos,
    --     showTime,
    --     function()
    --         self.isHided = false
    --         if callback then
    --             Runtime.InvokeCbk(callback)
    --         end
    --     end
    -- )
    self.isShowing = true
end

function BagButton:OnHit()
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

function BagButton:RefreshDot()
    -- self.redDot:SetActive(AppServices.BagDot:HasDot())
end

function BagButton:SetParent(parent)
    self.gameObject.transform:SetParent(parent, false)
    self.rectTransform = self.gameObject:GetComponent(typeof(RectTransform))
end

function BagButton:SetInteractable(value)
    self.Interactable = value
end

function BagButton:GetMainIconGameObject()
    return self.iconGo
end

--[==[ 解决使用CommonRewardPanel的时候有道具飞向背包同时CommonRewardPanel的argsument.showTarget = true的时候背包按钮不能点击的问题
function BagButton:OnEvent_ShowBottomIcons(isFirstTime)
    self:ShowEnterAnim()
end

function BagButton:OnEvent_HideBottomIcons(instant)
    self:ShowExitAnim()
end
--]==]
function BagButton:GetValue()
end

function BagButton:SetValue(value)
end

function BagButton:Refresh()
end

return BagButton
