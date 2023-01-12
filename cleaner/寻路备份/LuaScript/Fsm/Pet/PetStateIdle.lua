local PetStateBase = require "Fsm.Pet.PetStateBase"
---@class PetStateInfo
local PetStateInfo = require "Fsm.Pet.PetStateInfo"
---@type PetFollowPlayer
local PetFollowPlayer = require "Cleaner.Entity.Pet.PetFollowPlayer"

---@class PetStateIdle
local PetStateIdle = class(PetStateBase, "PetStateIdle")
-- 宠物状态：Idle
-- 己方小怪的行为

function PetStateIdle:ctor()
    self.stateType = PetStateInfo.StateType.Idle
    self:Init()

    self:AddIntervalExecute(1, function() self:CheckDistance() end)
    self:AddIntervalExecute(0.5, function() self:SearchAttackTarget() end)
end

function PetStateIdle:Init()
    self.toOtherState = 0
    PetStateBase.Init(self)
end

function PetStateIdle:OnEnter()
    --console.error("PetStateIdle:OnEnter:"..Time.realtimeSinceStartup)
    PetStateBase.OnEnter(self)

    self.entity:PlayAnimation(EntityAnimationName.Idle_A)
    self.toOtherState = 0
end

function PetStateIdle:OnTick()
    PetStateBase.OnTick(self)
    self:CheckDistance()
end

function PetStateIdle:OnExit()
    self.toOtherState = 0
end

function PetStateIdle:CheckDistance()
    local result, destination = PetFollowPlayer:GetFollowPos(self.entity)
    if not result then
        return
    end

    local pos = self.entity:GetPosition()
    local inDistance = self.entity.unitMove:IsInDistance(pos, destination, 1)
    if not inDistance then
        self.toOtherState = PetStateInfo.StateType.FollowPlayer
    end
end

return PetStateIdle