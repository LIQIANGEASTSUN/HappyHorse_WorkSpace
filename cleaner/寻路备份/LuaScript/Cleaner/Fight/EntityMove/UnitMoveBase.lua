---@type EntityMoveBase
local EntityMoveBase = class(nil, "EntityMoveBase")
-- 设置目标点，令角色移动到目标点

function EntityMoveBase:ctor(entity)
    self.entity = entity
    self.moveDir = Vector3(0, 0, 0)
    self.destination = Vector3(0, 0, 0)
    self.minDis = 0.1
    self.isSetDestination = false
end

function EntityMoveBase:SetSpeed(speed)
    self.speed = speed
    self.minDis = self.speed * 0.02 * 2
    self.slowDis = 0.9
end

function EntityMoveBase:CurrentForward(forward)
    self.moveDir = forward
    self.entity:SetForward(self.moveDir)
end

function EntityMoveBase:OnTick()
    --self:Rotate()
    return self:Move()
end

function EntityMoveBase:ChangeDestination(destination)
    self.isSetDestination = true
    local entityPos = self.entity:GetPosition()
    if self:DisIsMinEntity(destination) then
        return
    end

    self.destination = destination
    self.moveDir = (self.destination - entityPos).normalized
    self:CurrentForward(self.moveDir)
end

function EntityMoveBase:Move()

end

function EntityMoveBase:RandomPosition(position)
    return false, position
end

function EntityMoveBase:IsInDistance(pos1, pos2, distance)
    local offset = pos1 - pos2

    if distance < self.minDis then
        distance = self.minDis
    end

    local value1 = math.abs(offset.x) <= distance
    local value2 = math.abs(offset.z) <= distance

    return value1 and value2
end

function EntityMoveBase:DisIsMin(pos1, pos2)
    return self:IsInDistance(pos1, pos2, self.minDis)
end

function EntityMoveBase:DisIsMinEntity(pos)
    local entityPos = self.entity:GetPosition()
    local result = self:DisIsMin(entityPos, pos)
    return result
end

function EntityMoveBase:DisIsMinDestination()
    local result = self:DisIsMinEntity(self.destination)
    return result
end

return EntityMoveBase







--[[
function EntityMoveBase:Rotate()
    local isMin = self:DisIsMinDestination()
    if isMin then
        return
    end

    local entityPos = self.entity:GetPosition()
    local desireMoveDir = (self.destination - entityPos).normalized
    local angle, sign = self:Angle(self.moveDir, desireMoveDir)
    if math.abs(angle) <= self.rotateAngleSpeed then
        self.moveDir = desireMoveDir
        self.entity:SetForward(self.moveDir)
        return
    end

    local rotation = Quaternion.AngleAxis(sign * self.rotateAngleSpeed, Vector3.up)
    self.moveDir = rotation * self.moveDir
    self.entity:SetForward(self.moveDir)
end

function EntityMoveBase:Angle(dir1, dir2)
    local cross = Vector3.Cross(dir1, dir2)
    local angle = Vector3.Angle(dir1, dir2)
    local sign = (cross.y > 0) and 1 or -1
    angle = angle * sign
    return angle, sign
end

--]]