---@type PetHLStateBase
local PetHLStateBase = require "Fsm.PetHomeland.PetHLStateBase"

---@class PetHLStateInfo
local PetHLStateInfo = require "Fsm.PetHomeland.PetHLStateInfo"

---@class PetHLStateIdle
local PetHLStateIdle = class(PetHLStateBase, "PetHLStateIdle")
-- 宠物在家园状态：Idle

function PetHLStateIdle:ctor()
    self.stateType = PetHLStateInfo.StateType.Idle
    -- 休闲多久，切换到 巡逻 状态
    self.idleTime = 0
    self:Init()
end

function PetHLStateIdle:Init()
    PetHLStateBase.Init(self)
    self.toOtherState = 0
    self:SetTransition()
end

function PetHLStateIdle:OnEnter()
    --console.error("PetStateIdle:OnEnter:"..Time.realtimeSinceStartup)
    PetHLStateBase.OnEnter(self)

    self.entity:PlayAnimation(EntityAnimationName.Idle_A)
    self.idleTime = Random.Range(3, 5)
    self.toOtherState = 0
end

function PetHLStateIdle:OnTick()
    PetHLStateBase.OnTick(self)
    self.idleTime = self.idleTime - Time.deltaTime
end

function PetHLStateIdle:OnExit()
    self.toOtherState = 0
end

function PetHLStateIdle:SetTransition()
    self:ToPatrolTransition()
end

function PetHLStateIdle:ToPatrolTransition()
    local transition = {index = 1}
    transition.CanTransition = function()
        -- 逻辑判断
        local result = (self.idleTime <= 0)
        return result, PetHLStateInfo.StateType.Patrol
    end
    self:AddTransition(transition)
end

return PetHLStateIdle