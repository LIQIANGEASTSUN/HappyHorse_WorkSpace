---@type UnitMoveBase
local UnitMoveBase = require "Cleaner.Fight.EntityMove.UnitMoveBase"

---@class UnitMoveFreedom
local UnitMoveFreedom = class(UnitMoveBase, "UnitMoveFreedom")
-- 设置目标点，令角色移动到目标点

function UnitMoveFreedom:ctor(entity)

end

function UnitMoveFreedom:Move()
    if not self.isSetDestination then
        return false, self.entity:GetPosition()
    end
    -- 是否到达目的地，x、y 方向上的偏移都小于 self.minDis
    local arrive = self:DisIsMinDestination()
    if arrive then
        return arrive, self.destination
    end

    local entityPos = self.entity:GetPosition()
    local offset = self.destination - entityPos
    local speed = self.speed
    if math.abs(offset.x) <= self.slowDis and math.abs(offset.z) <= self.slowDis then
        local magnitude = offset.magnitude
        if magnitude < self.slowDis then
            speed = speed * (0.1 + magnitude)
        end
    end

    self.moveDir = (self.destination - entityPos).normalized
    local pos = entityPos + self.moveDir * Time.deltaTime * speed
    arrive = self:DisIsMinDestination()
    return arrive, pos
end

function UnitMoveFreedom:RandomPosition(pos)
    local angle = Random.Range(0, 360)
    local rad = math.rad(angle)
    local x = math.sin(rad)
    local z = math.cos(rad)
    local dir = Vector3(x, 0, z)
    local meta = self.entity.meta
    local dis = Random.Range(0, 100) * 0.01
    local destination = pos + dir * meta.patrol * dis
    return true, destination
end

return UnitMoveFreedom