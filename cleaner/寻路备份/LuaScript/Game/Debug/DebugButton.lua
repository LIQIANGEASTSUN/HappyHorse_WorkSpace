local SuperCls = require "UI.Components.BaseIconButton"

local DebugButton = class(SuperCls)

function DebugButton:CreateWithGameObject(gameObject, text, callback)
    local instance = DebugButton.new()
    instance.callback = callback
    instance:InitWithGameObject(gameObject)
    instance:SetText(text)
    return instance
end

function DebugButton:SetText(text)
    self.gameObject:FindComponentInChildren("text", typeof(Text)).text = text
end

function DebugButton:OnBtnClick()
    Runtime.InvokeCbk(self.callback)
end

function DebugButton:SetParent(parent)
    self.gameObject:SetParent(parent, false)
end

function DebugButton:SetOriginalLocalPosition()
    local parent = self.gameObject:GetParent()
    local position = self.gameObject:GetPosition()
    self.originalLocalPosition = GameUtil.WorldToUISpace(parent.transform, App.scene.mainCamera, position)
end

function DebugButton:ShowEnterAnim()
end

function DebugButton:ShowExitAnim()
end

return DebugButton