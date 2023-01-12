local FactoryUnitBase = require "Cleaner.Unit.FactoryUnitBase"

---@type DecorationFactoryUnit
local DecorationFactoryUnit = class(FactoryUnitBase, "DecorationFactoryUnit")

function DecorationFactoryUnit:ctor(agent)
    self:SetUnitType(UnitType.DecorationFactoryUnit)
end

function DecorationFactoryUnit:ClickMoveCameraFinish()
    local arguments = {id = self.id, sn = self.data.meta.sn}
    PanelManager.showPanel(GlobalPanelEnum.DecorationFactoryPanel, arguments)
end

-- 领取产物
function DecorationFactoryUnit:TakeProduction()
    local data = self:GetProductionData()
    if not data then
        return
    end

    AppServices.User:RemoveProduction(self.id)
    self:StateChangeToNone()

    for _, v in pairs(data.outItem) do
        local buildConfig = AppServices.Meta:Category("BuildingTemplate")[tostring(v.key)]
        if buildConfig then
            local sn = tonumber(v.key)
            AppServices.BuildingModifyManager:CreateAgentAuto(sn)
        end
    end
end

function DecorationFactoryUnit:StateChangeToNone()
    FactoryUnitBase.StateChangeToNone(self)
    AppServices.UnitTipsManager:HideTips(self.instanceId, TipsType.UnitProductFinishTips)
end

function DecorationFactoryUnit:StateChangeToDoing()
    FactoryUnitBase.StateChangeToDoing(self)
    AppServices.UnitTipsManager:ShowTips(self.instanceId, TipsType.UnitProductFinishTips)
end

function DecorationFactoryUnit:StateChangeToFinish()
    FactoryUnitBase.StateChangeToFinish(self)
    AppServices.UnitTipsManager:ShowTips(self.instanceId, TipsType.UnitProductFinishTips)
end

function DecorationFactoryUnit:Remove()
    FactoryUnitBase.Remove(self)
    AppServices.UnitTipsManager:RemoveTips(self.instanceId, TipsType.UnitProductFinishTips)
end

return DecorationFactoryUnit