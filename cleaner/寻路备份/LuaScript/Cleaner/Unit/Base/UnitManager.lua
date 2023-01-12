---@type UnitManager
local UnitManager = {
    instanceId = 0,
    ---@type Dictionary<int, UnitBase> int:instanceId
    unitMap = {},
    ---@type Dictionary<int, List<UnitBase>> int:unitType
    unitTypeMap = {},
}

function UnitManager:Init()
    self:RegisterEvents()
end

function UnitManager:AddUnit(unitBase)
    if not unitBase then
        return
    end
    local instanceId = self:NewInstanceId()
    unitBase:SetInstanceId(instanceId)

    self.unitMap[instanceId] = unitBase
    local unitType = unitBase:GetUnitType()

    local typeList = self.unitTypeMap[unitType]
    if not typeList then
        typeList = {}
        self.unitTypeMap[unitType] = typeList
    end
    typeList[instanceId] = unitBase
end

function UnitManager:RemoveUnit(unitBase)
    if not unitBase then
        return
    end
    local instanceId = unitBase:GetInstanceId()
    self:RemoveUnitWithId(instanceId)
end

function UnitManager:RemoveUnitWithId(instanceId)
    local unitBase = self:GetUnit(instanceId)
    local unitType = UnitType.None
    if unitBase then
        unitType = unitBase:GetUnitType()
        unitBase:Remove()
    end
    self.unitMap[instanceId] = nil
    local typeList = self.unitTypeMap[unitType]
    if typeList then
        typeList[instanceId] = nil
    end
end

function UnitManager:GetUnit(instanceId)
    return self.unitMap[instanceId]
end

function UnitManager:GetUnitWithType(unitType)
    local typeList = self.unitTypeMap[unitType]
    typeList = typeList or {}
    return typeList
end

function UnitManager:NewInstanceId()
    self.instanceId = self.instanceId + 1
    return self.instanceId
end

function UnitManager:LateUpdate()
    for _, unit in pairs(self.unitMap) do
        if unit:GetUseUpdate() then
            unit:LateUpdate()
        end
    end
end

function UnitManager:RegisterEvents()
end

function UnitManager:UnRegisterEvent()
end

function UnitManager:Release()
    self:UnregisterEvents()
end

return UnitManager