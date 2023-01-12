local BaseAction = require "MainCity.Character.AI.Action.PetAction.BaseAction"
local animation = "fly"

local baseSpeed = 2
local disChangeMin = 0.1
local disChangeMax = 3
local teleportThreshold = 15 --距离玩家超出数值瞬移

---@class MoveTo : BasePetAction
local MoveTo = class(BaseAction)
function MoveTo:OnEnter(moveTo)
    BaseAction.OnEnter(self)
    self:PlayAnimation(animation)
    self.moveToPos = moveTo
end

function MoveTo:GetSpeed(distance)
    local go = self.brain.body.renderObj
    local lerp = math.inverseLerp(disChangeMin, disChangeMax, distance)
    lerp = math.max(lerp, 0.3)
    local speed = lerp * baseSpeed

    go:SetFloat("fly_speed", speed)
    return speed
end

-- function MoveTo:GetValidPosition()
--     local map = App.scene.mapManager
--     local x, z = map:ToLocal(self:GetTargetCurPos())
-- end

function MoveTo:OnTick()
    local tarPos = self:GetTargetCurPos()
    local curPos = self:GetPosition()
    local dis = curPos:FlatDistance(tarPos)
    local trans = self.brain.body.transform
    if dis > teleportThreshold then
        return self.brain:ChangeAction("Teleport")
    end
    if self.moveToPos then
        tarPos = self.moveToPos
    elseif dis > 0.45 then
        local back = curPos - tarPos
        tarPos = tarPos + back.normalized * 0.45
    end
    dis = curPos:FlatDistance(tarPos)
    if dis > disChangeMin then
        local dir = tarPos - curPos
        dir = dir:Flat()
        trans.forward = dir
        local speed = trans.forward * self:GetSpeed(dis)
        local pos = speed * Time.deltaTime + curPos
        self:SetPosition(pos)
    else
        self.brain:ChangeAction("Idle", true)
    end
end

function MoveTo:OnExit()
    BaseAction.OnExit(self)
    local go = self.brain.body.renderObj
    if Runtime.CSValid(go) then
        go:SetFloat("fly_speed", 1)
    end
end

return MoveTo
