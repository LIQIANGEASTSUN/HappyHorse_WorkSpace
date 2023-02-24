---@class UnitMoveBase
local UnitMoveBase = class(nil, "UnitMoveBase")
-- 设置目标点，令角色移动到目标点
function UnitMoveBase:ctor(entity)
    ---@type BaseEntity
    self.entity = entity
    self.moveDir = Vector3(0, 0, 0)
    self.destination = Vector3(0, 0, 0)
    self.isSetDestination = false
    self.patrolRadius = 1.5

    self.rvo2AgentId = self.entity.rvo2AgentId
    self.pathList = {}
    self.hasPath = false

    self.useRVO2 = false
end

function UnitMoveBase:SetSpeed(speed)
    self.speed = speed * 0.8
end

function UnitMoveBase:ChangeDestination(destination)
    self.destination = destination
    self.hasPath = false
end

function UnitMoveBase:OnTick(dt)
    local entityPos = self.entity:GetPosition()
    local value, movePos = self:GetMovePos()
    if not value then
        self:Stop()
        return self.hasPath, entityPos
    end
    local arrive = self:EnableArriveThisFrame(entityPos, movePos, self.speed, self.entity.dt)
    if arrive then
        table.remove(self.pathList, 1)
        if #self.pathList > 0 then
            self:ResetForward()
        else
            self:Stop()
        end
        return #self.pathList <= 0, movePos
    end

    self:ResetForward()
    self.moveDir = (movePos - entityPos).normalized

    if self.useRVO2 then
        local velocity = Vector2(self.moveDir.x * self.speed, self.moveDir.z * self.speed)
        RVO2Controller.Instance:setAgentPrefVelocity(self.rvo2AgentId, velocity)

        local p = RVO2Controller.Instance:getAgentPosition(self.rvo2AgentId)
        return false, Vector3(p.x, 0, p.y)
    else
        local pos = entityPos + self.moveDir * self.entity.dt * self.speed
        return false, pos
    end
end

function UnitMoveBase:GetMovePos()
    return  #self.pathList > 0, self.pathList[1]
end

function UnitMoveBase:ResetForward()
    if #self.pathList <= 0 then
        return
    end
    local entityPos = self.entity:GetPosition()
    local forward = self.pathList[1] - entityPos
    if math.abs(forward.x) >= 0.3 or math.abs(forward.z) >= 0.3 then
        self.entity:SetForward(forward)
    end
end

function UnitMoveBase:RandomPosition(position)
    return false, position
end

function UnitMoveBase:SetPatrolRadius(radius)
    self.patrolRadius = radius
end

function UnitMoveBase:GetPatrolRadius()
    return self.patrolRadius
end

function UnitMoveBase:FindPath()
    return true
end

function UnitMoveBase:EnableArriveThisFrame(position, destination, speed, time)
    local offsetX = (position.x - destination.x)
    local offsetZ = (position.z - destination.z)

    time = time and time or self.entity.dt
    local frameMoveDis = speed * time
    if math.abs(offsetX) <= frameMoveDis and math.abs(offsetZ) <= frameMoveDis then
        return true
    end

    return false
end

function UnitMoveBase:Stop()
    if self.rvo2AgentId then
        RVO2Controller.Instance:setAgentPrefVelocity(self.rvo2AgentId, Vector2(0, 0))
    end
end

return UnitMoveBase