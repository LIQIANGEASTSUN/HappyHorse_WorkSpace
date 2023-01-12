local FactoryUnitBase = require "Cleaner.Unit.FactoryUnitBase"

---@type FoodFactoryUnit
local FoodFactoryUnit = class(FactoryUnitBase, "FoodFactoryUnit")

function FoodFactoryUnit:ctor(agent)
    self:SetUnitType(UnitType.FoodFactoryUnit)
end

function FoodFactoryUnit:ClickMoveCameraFinish()
    local arguments = {id = self.id, sn = self.data.meta.sn}
    PanelManager.showPanel(GlobalPanelEnum.FoodFactoryPanel, arguments)
end

function FoodFactoryUnit:StateChangeToNone()
    FactoryUnitBase.StateChangeToNone(self)
    AppServices.UnitTipsManager:RemoveTipsAll(self.instanceId)
end

function FoodFactoryUnit:StateChangeToDoing()
    FactoryUnitBase.StateChangeToDoing(self)
    AppServices.UnitTipsManager:ShowTips(self.instanceId, TipsType.UnitProductDoingTips)
end

function FoodFactoryUnit:StateChangeToFinish()
    FactoryUnitBase.StateChangeToFinish(self)
    AppServices.UnitTipsManager:ShowTips(self.instanceId, TipsType.UnitProductFinishTips)
end

function FoodFactoryUnit:Remove()
    FactoryUnitBase.Remove(self)
    AppServices.UnitTipsManager:RemoveTipsAll(self.instanceId)
end

return FoodFactoryUnit