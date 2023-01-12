local BaseIconButton = require "UI.Components.BaseIconButton"
---@class GMButton:BaseIconButton
local GMButton = class(BaseIconButton)

function GMButton:Create()
    local gameObject = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_HOMESCENE_GM_BUTTON)
    return GMButton:CreateWithGameObject(gameObject)
end

function GMButton:CreateWithGameObject(gameObject)
    local instance = GMButton.new()
    instance:InitWithGameObject(gameObject)
    return instance
end

function GMButton:InitWithGameObject(gameObject)
    self.gameObject = gameObject
    self.transform = self.gameObject.transform
    self.Interactable = true
    self.isEntered = true

    local function OnClick_button()
        PanelManager.showPanel(GlobalPanelEnum.GMPanel)
    end
    Util.UGUI_AddButtonListener(self.gameObject, OnClick_button, {noAudio = true})
end

function GMButton:ShowExitAnim(exitImmediate, callback)

end

function GMButton:ShowEnterAnim(callback, showTime)

end

function GMButton:SetParent(parent)
    self.gameObject.transform:SetParent(parent, false)
    self.rectTransform = self.gameObject:GetComponent(typeof(RectTransform))
end

function GMButton:SetInteractable(value)
    self.Interactable = value
end

function GMButton:GetMainIconGameObject()
    return self.iconGo
end

function GMButton:GetValue()
end

function GMButton:SetValue(value)
end

function GMButton:Refresh()
end

return GMButton
