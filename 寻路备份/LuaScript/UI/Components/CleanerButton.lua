local BaseIconButton = require "UI.Components.BaseIconButton"
---@class CleanerButton:BaseIconButton
local CleanerButton = class(BaseIconButton)

function CleanerButton:Create()
    local gameObject = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_HOMESCENE_CLEANER)
    return CleanerButton:CreateWithGameObject(gameObject)
end

function CleanerButton:CreateWithGameObject(gameObject)
    local instance = CleanerButton.new()
    instance:InitWithGameObject(gameObject)
    return instance
end

function CleanerButton:InitWithGameObject(gameObject)
    self.gameObject = gameObject
    self.transform = self.gameObject.transform
    self.Interactable = true
    self.isEntered = true

    local function OnClick_button()
        PanelManager.showPanel(GlobalPanelEnum.VaccumCleanerUpgradePanel)
    end
    Util.UGUI_AddButtonListener(self.gameObject, OnClick_button, {noAudio = true})
end

function CleanerButton:ShowExitAnim(exitImmediate, callback)

end

function CleanerButton:ShowEnterAnim(callback, showTime)

end

function CleanerButton:SetParent(parent)
    self.gameObject.transform:SetParent(parent, false)
    self.rectTransform = self.gameObject:GetComponent(typeof(RectTransform))
end

function CleanerButton:SetInteractable(value)
    self.Interactable = value
end

function CleanerButton:GetMainIconGameObject()
    return self.iconGo
end

function CleanerButton:GetValue()
end

function CleanerButton:SetValue(value)
end

function CleanerButton:Refresh()
end

return CleanerButton
