local BaseAction = require "MainCity.Character.AI.Action.PetAction.BaseAction"
---@class Research:BasePetAction
local Research = class(BaseAction)

local enter = "surprise"

local threshold_x = 1
local threshold_z = 1

function Research:OnEnter(targetPosition)
    BaseAction.OnEnter(self)
    self.randPosTs = Time.time
    self.duration = self:GetAnimDuration(enter)
    self:PlayAnimation(enter)

    local dir = targetPosition - self:GetPosition()
    dir = dir:Flat()
    local trans = self.brain.body.transform
    trans.forward = dir
end

function Research:OnTick()
    local curPos = self:GetTargetCurPos()
    local orgPos = self:GetTargetOrgPos()
    if curPos ~= orgPos then
        if math.abs(curPos.x - orgPos.x) > threshold_x then
            return self.brain:ChangeAction("MoveTo")
        end
        if math.abs(curPos.z - orgPos.z) > threshold_z then
            return self.brain:ChangeAction("MoveTo")
        end
    end
    if Time.time - self.randPosTs > self.duration then
        return self.brain:ChangeAction("Idle")
    end
end

return Research
