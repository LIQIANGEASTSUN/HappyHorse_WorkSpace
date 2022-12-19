
---@class UnitBase
local UnitBase = class(nil, "UnitBase")

function UnitBase:ctor()
    self.instanceId = -1
    self.unitType = UnitType.None
    self.useUpdate = false
end

function UnitBase:SetInstanceId(instanceId)
    self.instanceId = instanceId
end

function UnitBase:GetInstanceId()
    return self.instanceId
end

function UnitBase:SetUnitType(unitType)
    self.unitType = unitType
end

function UnitBase:GetUnitType()
    return self.unitType
end

function UnitBase:SetUseUpdate(value)
    self.useUpdate = value
end

function UnitBase:GetUseUpdate()
    return self.useUpdate
end

function UnitBase:GetPosition()
    return Vector3(0, 0, 0)
end

function UnitBase:LateUpdate()

end

function UnitBase:Remove()

end

return UnitBase