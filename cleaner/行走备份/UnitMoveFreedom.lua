---@type UnitMoveBase
local UnitMoveBase = require "Cleaner.Fight.EntityMove.UnitMoveBase"

---@class UnitMoveFreedom:UnitMoveBase
local UnitMoveFreedom = class(UnitMoveBase, "UnitMoveFreedom")

-- 无寻路移动
function UnitMoveFreedom:ctor(entity)
end

function UnitMoveFreedom:ChangeDestination(destination)
    UnitMoveBase.ChangeDestination(self, destination)
    self.hasPath = true
    self.pathList = {destination}
    self:ResetForward()
end

-- function UnitMoveFreedom:OnTick()
--     if not self.isSetDestination then
--         return false, self.entity:GetPosition()
--     end

--     local entityPos = self.entity:GetPosition()
--     local arrive = self:EnableArriveThisFrame(entityPos, self.destination, self.speed, self.entity.dt)
--     -- 是否到达目的地
--     if arrive then
--         self:Stop()
--         return arrive, self.destination
--     end

--     local pos = entityPos + self.moveDir * self.entity.dt * self.speed
--     return false, pos
-- end

function UnitMoveFreedom:RandomPosition(position)
    local angle = Random.Range(0, 360)
    local rad = math.rad(angle)
    local x = math.sin(rad)
    local z = math.cos(rad)
    local dir = Vector3(x, 0, z)
    local dis = Random.Range(0, 100) * 0.01
    local destination = position + dir * self.patrolRadius * dis
    return true, destination
end

return UnitMoveFreedom