---@class BaseIconButton : LuaUiBase
local BaseIconButton = class(LuaUiBase)

function BaseIconButton:InitWithGameObject(gameObject)
    self.gameObject = gameObject
    self.transform = gameObject.transform
    self.rectTransform = self:GetRectTransform()
    self.img_icon_go = gameObject:FindGameObject("img_icon") or gameObject:FindGameObject("anim/img_icon")
    self.img_icon = self.img_icon_go:GetComponent(typeof(Image))
    self.img_reddot_go = gameObject:FindGameObject("img_reddot") or gameObject:FindGameObject("anim/img_reddot")
    self.img_reddot = self.img_reddot_go:GetComponent(typeof(Image))
    self.btn = gameObject:GetComponent(typeof(Button))
    WaitExtension.InvokeDelay(
        function()
            self.originalAnchoredPosY = self.rectTransform.anchoredPosition.y
            self.originalAnchoredPosX = self.rectTransform.anchoredPosition.x
        end
    )
    self.interactable = true
    local function OnClick_btn(go)
        if not self.interactable then
            return
        end
        self:OnBtnClick()
    end
    Util.UGUI_AddButtonListener(self.btn.gameObject, OnClick_btn, {noAudio = true})
    self.img_reddot_go:SetActive(false)
end

function BaseIconButton:OnBtnClick()
    if not App.globalFlags:CanClick() then
        return
    end
    App.globalFlags:SetClickFlag()

    print("BaseIconButton:OnBtnClick()") --@DEL
    if self.btnCallback then
        self.btnCallback()
    end
end

function BaseIconButton:ShowRedDot(showOrNot)
    self.img_reddot_go:SetActive(showOrNot)
end

function BaseIconButton:SetBtnCallback(callback)
    self.btnCallback = callback
end

function BaseIconButton:ShowExitAnim(instant)
    DOTween.Kill(self.rectTransform)
    local tarPos = self:GetOutsideAnchoredPosition()
    if instant then
        self.rectTransform.anchoredPosition = tarPos
    else
        GameUtil.DoAnchorPos(self.rectTransform, tarPos, 0.5)
    end
end

function BaseIconButton:ShowEnterAnim(instant)
    DOTween.Kill(self.rectTransform, false)
    local tarPos = self:GetInsideAnchoredPosition()
    if instant then
        self.rectTransform.anchoredPosition = tarPos
    else
        GameUtil.DoAnchorPos(self.rectTransform, tarPos, 0.5)
    end
end

function BaseIconButton:SetInteractable(interactable)
    self.interactable = interactable
end

function BaseIconButton:GetMainIconGameObject()
    return self.gameObject
end

function BaseIconButton:GetInsideAnchoredPosition()
    if not self.originalAnchoredPos then
        self.originalLocalPos = self.rectTransform.localPosition
        self.originalAnchoredPos = self.rectTransform.anchoredPosition
    end
    return self.originalAnchoredPos
end
function BaseIconButton:GetOutsideAnchoredPosition()
    if not self.outAnchoredPos then
        local pos = self:GetInsideAnchoredPosition()
        self.outAnchoredPos = Vector2(pos.x, pos.y - 200)
    end
    return self.outAnchoredPos
end
--获取组件显示在屏幕上时的世界坐标位置
function BaseIconButton:GetInsideWorldPosition()
    if self.originalLocalPos then
        local wPos = self.transform.parent:TransformPoint(self.originalLocalPos)
        return wPos
    end
end

-- event section
function BaseIconButton:OnEvent_ShowBottomIcons(isFirstTime)
    self:SetInteractable(true)
    self:ShowEnterAnim()
end
function BaseIconButton:OnEvent_HideBottomIcons(instant)
    self:SetInteractable(false)
    self:ShowExitAnim(instant)
end

function BaseIconButton:SetParent(parent)
    self.gameObject.transform:SetParent(parent, false)
end

return BaseIconButton
