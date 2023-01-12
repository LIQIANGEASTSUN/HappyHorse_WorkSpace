--insertWidgetsBegin
--    go_scroll    btn_close
--insertWidgetsEnd

--insertRequire
local _DecorationFactoryCanProductPanelBase = require "UI.DecorationFactoryCanProductPanel.View.UI.Base._DecorationFactoryCanProductPanelBase"

---@class DecorationFactoryCanProductPanel:_DecorationFactoryCanProductPanelBase
local DecorationFactoryCanProductPanel = class(_DecorationFactoryCanProductPanelBase)

function DecorationFactoryCanProductPanel:ctor()

end

function DecorationFactoryCanProductPanel:onAfterBindView()
    local allBuildings = SceneServices.DecorationFactory:GetCanProducts()
    self.buildNodes = {}
    -- Assets\HomeLand\LuaScript\UI\DecorationFactoryCanProductPanel\View\UI\BuildingNode.lua
    local BuildingNode = require("UI.DecorationFactoryCanProductPanel.View.UI.BuildingNode")
    local function onCreateItemCallback(key)
        ---@type BuildingNode
        local item = BuildingNode.Create(self)
        self.buildNodes[key] = item
        return item.gameObject
    end
    local function onUpdateInfoCallback(key, index)
        local itemId = allBuildings[index][1]
        self.buildNodes[key]:SetData(itemId)
    end

    self.go_scroll:InitList(#allBuildings, onCreateItemCallback, onUpdateInfoCallback)
end

function DecorationFactoryCanProductPanel:refreshUI()

end

return DecorationFactoryCanProductPanel
