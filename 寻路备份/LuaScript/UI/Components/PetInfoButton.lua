local BaseIconButton = require "UI.Components.BaseIconButton"
---@class PetInfoButton:BaseIconButton
local PetInfoButton = class(BaseIconButton)

function PetInfoButton:Create()
    local gameObject = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_HOMESCENE_PET_INFO)
    return PetInfoButton:CreateWithGameObject(gameObject)
end

function PetInfoButton:CreateWithGameObject(gameObject)
    local instance = PetInfoButton.new()
    instance:InitWithGameObject(gameObject)
    return instance
end

function PetInfoButton:InitWithGameObject(gameObject)
    self.gameObject = gameObject
    self.transform = self.gameObject.transform
    self.Interactable = true
    self.isEntered = true

    local function OnClick_button()
        PanelManager.showPanel(GlobalPanelEnum.PetInfoPanel, nil)
        --UITool.ShowConfirmTip("模块开发中...")
    end
    Util.UGUI_AddButtonListener(self.gameObject, OnClick_button, {noAudio = true})
end

function PetInfoButton:ShowExitAnim(exitImmediate, callback)

end

function PetInfoButton:ShowEnterAnim(callback, showTime)

end

function PetInfoButton:SetParent(parent)
    self.gameObject.transform:SetParent(parent, false)
    self.rectTransform = self.gameObject:GetComponent(typeof(RectTransform))
end

function PetInfoButton:SetInteractable(value)
    self.Interactable = value
end

function PetInfoButton:GetMainIconGameObject()
    return self.iconGo
end

function PetInfoButton:GetValue()
end

function PetInfoButton:SetValue(value)
end

function PetInfoButton:Refresh()
end

return PetInfoButton
