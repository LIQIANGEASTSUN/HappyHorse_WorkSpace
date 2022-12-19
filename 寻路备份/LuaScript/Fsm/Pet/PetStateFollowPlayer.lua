local PetStateBase = require "Fsm.Pet.PetStateBase"
---@class PetStateInfo
local PetStateInfo = require "Fsm.Pet.PetStateInfo"
---@type PetFollowPlayer
local PetFollowPlayer = require "Cleaner.Entity.Pet.PetFollowPlayer"

---@class PetStateFollowPlayer
local PetStateFollowPlayer = class(PetStateBase, "PetStateFollowPlayer")
-- 宠物状态：跟随玩家
-- 己方小怪的行为

function PetStateFollowPlayer:ctor()
    self.stateType = PetStateInfo.StateType.FollowPlayer
    self:Init()
end

function PetStateFollowPlayer:Init()
    PetStateBase.Init(self)

    self:AddIntervalExecute(0.1, function() self:ChangeDestination() end)
    self:AddIntervalExecute(1, function() self:SearchAttackTarget() end)
end

function PetStateFollowPlayer:OnEnter()
    --console.error("PetStateFollowPlayer:OnEnter:"..Time.realtimeSinceStartup)
    PetStateBase.OnEnter(self)

    self.entity:PlayAnimation(EntityAnimationName.Walk)
    self.toOtherState = 0
    -- 最少跟随一秒才能切换状态
    self.MIN_Follow_TIME = 1
    self:ChangeDestination()
end

function PetStateFollowPlayer:OnTick()
    PetStateBase.OnTick(self)
    self:Move()
end

function PetStateFollowPlayer:OnExit()
    self.toOtherState = 0
end

function PetStateFollowPlayer:ChangeDestination()
    local result, destination = PetFollowPlayer:GetFollowPos(self.entity)
    if not result then
        return
    end

    self.entity.unitMove:ChangeDestination(destination)
end

function PetStateFollowPlayer:Move()
    local arrive, pos = self.entity.unitMove:OnTick()
    self.entity:SetPosition(pos)
    if not arrive then
        return
    end

    if Time.realtimeSinceStartup - self.enterTime >= self.MIN_Follow_TIME then
        self.toOtherState = PetStateInfo.StateType.Idle
    end
end

return PetStateFollowPlayer
