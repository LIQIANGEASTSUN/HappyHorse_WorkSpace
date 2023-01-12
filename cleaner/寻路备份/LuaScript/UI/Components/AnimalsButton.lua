local BaseIconButton = require "UI.Components.BaseIconButton"
---@class AnimalsButton:BaseIconButton
local AnimalsButton = class(BaseIconButton)

function AnimalsButton:Create()
    local gameObject = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_HOMESCENE_ANIMALS)
    return AnimalsButton:CreateWithGameObject(gameObject)
end

function AnimalsButton:CreateWithGameObject(gameObject)
    local instance = AnimalsButton.new()
    instance:InitWithGameObject(gameObject)
    return instance
end

function AnimalsButton:InitWithGameObject(gameObject)
    self.gameObject = gameObject
    self.transform = self.gameObject.transform
    self.Interactable = true
    self.isEntered = true

    local function OnClick_button()
        --UITool.ShowConfirmTip("模块开发中...")
        PanelManager.showPanel(GlobalPanelEnum.PetIllustratedPanel, nil)
    end
    Util.UGUI_AddButtonListener(self.gameObject, OnClick_button, {noAudio = true})
end

function AnimalsButton:ShowExitAnim(exitImmediate, callback)

end

function AnimalsButton:ShowEnterAnim(callback, showTime)

end

function AnimalsButton:SetParent(parent)
    self.gameObject.transform:SetParent(parent, false)
    self.rectTransform = self.gameObject:GetComponent(typeof(RectTransform))
end

function AnimalsButton:SetInteractable(value)
    self.Interactable = value
end

function AnimalsButton:GetMainIconGameObject()
    return self.iconGo
end

function AnimalsButton:GetValue()
end

function AnimalsButton:SetValue(value)
end

function AnimalsButton:Refresh()
end

return AnimalsButton
