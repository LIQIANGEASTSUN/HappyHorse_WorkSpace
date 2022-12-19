local _register = {
    GridRationalityIndicator = "Cleaner.Render.GridRationalityIndicator",
    EnergyProductManager = "MainCity.Manager.EnergyProductManager",
    EnergyDiscountBuffManager = "MainCity.Manager.EnergyDiscountBuffManager",
    BreedManager = "MainCity.Manager.BreedManager",
    BindingTip = "MainCity.Manager.BindingTipManager",
    PathTip = "MainCity.Manager.PathTipManager",
    ChestTip = "MainCity.Component.ChestTip",
    GiftIconManager = "UI.GiftIcon.GiftIconManager",
    LabManager = "MainCity.Manager.LabManager",
    MapCursor = "Game.System.MapCursor.MapCursor",
    AgentTip = "MainCity.Manager.AgentTipManager",
    RuinsSceneManager = "MainCity.Manager.RuinsSceneManager",
    DecorationFactory = "Cleaner.Order.DecorationFactory",
}

local mt = {
    __index = function(t, k)
        local path = _register[k] or "Manager." .. k .. "Manager"
        local inst = include(path)
        rawset(t, k, inst)
        return inst
    end
}

---@class SceneServices
SceneServices = {
    ---@type GridRationalityIndicator
    GridRationalityIndicator = nil,
    ---@type EnergyProductManager
    EnergyProductManager = nil,
    ---@type EnergyDiscountBuffManager
    EnergyDiscountBuffManager = nil,
    ---@type BreedManager
    BreedManager = nil,
    ---@type BindingTipManager
    BindingTip = nil,
    ---@type PathTipManager
    PathTip = nil,
    ---@type ChestTip
    ChestTip = nil,
    ---@type GiftIconManager
    GiftIconManager = nil,
    ---@type LabManager
    LabManager = nil,
    ---@type MapCursor
    MapCursor = nil,
    ---@type AgentTipManager
    AgentTip = nil,
    ---@type RuinsSceneManager
    RuinsSceneManager = nil,
    ---@type DecorationFactory
    DecorationFactory = nil,
}
setmetatable(SceneServices, mt)

function SceneServices:OnDestroy()
    for k, v in pairs(self) do
        if k ~= "OnDestroy" then
            Runtime.InvokeCbk(v.OnDestroy, v)
            self[k] = nil
        end
    end
end

return SceneServices
