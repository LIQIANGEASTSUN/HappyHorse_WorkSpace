local BaseIconButton = require "UI.Components.BaseIconButton"

---@class RemainsBackButton:BaseIconButton
local RemainsBackButton = class(BaseIconButton)

function RemainsBackButton.Create()
    local gameObject = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_HOMESCENE_REMAINSBACK_BUTTON)
    return RemainsBackButton:CreateWithGameObject(gameObject)
end

function RemainsBackButton:CreateWithGameObject(gameObject)
    local instance = RemainsBackButton.new()
    instance:InitWithGameObject(gameObject)
    return instance
end

function RemainsBackButton:InitWithGameObject(gameObject)
    self.gameObject = gameObject
    self.transform = self.gameObject.transform
    self.arrow = find_component(self.gameObject, "bg/arrow")
    -- self.button = gameObject:GetComponent(typeof(Button))
    self.Interactable = true

    local function OnClick_button(go)
        if not self.Interactable then
            return
        end
        local sceneId = App.scene:GetCurrentSceneId()
        local scenecfg = AppServices.Meta:Category("SceneTemplate")[sceneId]
        AppServices.Jump.changeSceneById(scenecfg.lastScene)
    end
    Util.UGUI_AddButtonListener(self.gameObject, OnClick_button)
end

function RemainsBackButton:SetBtnCallback(callback)
    self.btnCallback = callback
end

function RemainsBackButton:ShowExitAnim(exitImmediate, callback)
    local time = 0.5
    if exitImmediate then
        time = 0
    end
    local tarPos = self:GetOutsideAnchoredPosition()
    local tween = GameUtil.DoAnchorPos(self.rectTransform, tarPos, time)
    if callback then
        tween:OnComplete(callback)
    end
end

function RemainsBackButton:ShowEnterAnim(callback)
    local tarPos = self:GetInsideAnchoredPosition()
    local tween = GameUtil.DoAnchorPos(self.rectTransform, tarPos, 0.5)
    if callback then
        tween:OnComplete(callback)
    end
end

function RemainsBackButton:SetParent(parent)
    self.gameObject.transform:SetParent(parent, false)
    self.rectTransform = self.gameObject:GetComponent(typeof(RectTransform))
end

function RemainsBackButton:SetInteractable(value)
    self.Interactable = value
end

function RemainsBackButton:StopShowTimer()
    if self.showTimer then
        WaitExtension.CancelTimeout(self.showTimer)
        self.showTimer = nil
    end
end

function RemainsBackButton:StartShowTimer()
    self:StopShowTimer()
    self.showTimer =
        WaitExtension.SetTimeout(
        function()
            if Runtime.CSValid(self.arrow) then
                self.showTimer = nil
                self.arrow:SetActive(false)
            end
        end,
        3.5
    )
end

function RemainsBackButton:ShowArrow(val)
    self.arrow:SetActive(val)
    if val then
        self:StartShowTimer()
    else
        self:StopShowTimer()
    end
end

return RemainsBackButton
