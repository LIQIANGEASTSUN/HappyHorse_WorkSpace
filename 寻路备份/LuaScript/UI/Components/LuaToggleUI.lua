---@class LuaToggleUI:LuaUiBase
local LuaToggleUI = class(LuaUiBase,"LuaToggleUI")

function LuaToggleUI:Create(gameObject)
    local instance = LuaToggleUI.new()
    instance:InitFromGameObject(gameObject)
    return instance
end

function LuaToggleUI:InitFromGameObject(gameObject,selectedGo,unSelectedGo)
    self:setGameObject(gameObject)
    if selectedGo then
        self.go_selected = selectedGo
    else
        self.go_selected = self.transform:Find("selected").gameObject
    end

    if unSelectedGo then
        self.go_unSelected = unSelectedGo
    else
        self.go_unSelected = self.transform:Find("unselected").gameObject
    end
    self.selected = false
    self.clickCallback = nil
    local function onClick()
        self:OnClick()
    end
    Util.UGUI_AddButtonListener(self.gameObject,onClick)
end

function LuaToggleUI:OnClick()
    self:SetSelect(not self.selected)
    Runtime.InvokeCbk(self.clickCallback,self.selected)
end

function LuaToggleUI:SetClickCallback(callback)
    self.clickCallback = callback
end

function LuaToggleUI:SetSelect(value)
    self.selected = value
    self.go_selected = self.selected
    self.go_unSelected = not self.selected
end

return LuaToggleUI