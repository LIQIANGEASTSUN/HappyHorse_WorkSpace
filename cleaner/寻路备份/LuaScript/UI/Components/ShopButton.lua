local BaseIconButton = require "UI.Components.BaseIconButton"
---@class ShopButton:BaseIconButton
local ShopButton = class(BaseIconButton)

function ShopButton:Create()
    local gameObject = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_HOMESCENE_SHOP)
    return ShopButton:CreateWithGameObject(gameObject)
end

function ShopButton:CreateWithGameObject(gameObject)
    local instance = ShopButton.new()
    instance:InitWithGameObject(gameObject)
    return instance
end

function ShopButton:InitWithGameObject(gameObject)
    self.gameObject = gameObject
    self.transform = self.gameObject.transform
    self.Interactable = true
    self.isEntered = true

    local function OnClick_button()
        UITool.ShowConfirmTip("模块开发中...")
    end
    Util.UGUI_AddButtonListener(self.gameObject, OnClick_button, {noAudio = true})
end

function ShopButton:ShowExitAnim(exitImmediate, callback)

end

function ShopButton:ShowEnterAnim(callback, showTime)

end

function ShopButton:SetParent(parent)
    self.gameObject.transform:SetParent(parent, false)
    self.rectTransform = self.gameObject:GetComponent(typeof(RectTransform))
end

function ShopButton:SetInteractable(value)
    self.Interactable = value
end

function ShopButton:GetMainIconGameObject()
    return self.iconGo
end

function ShopButton:GetValue()
end

function ShopButton:SetValue(value)
end

function ShopButton:Refresh()
end

return ShopButton
