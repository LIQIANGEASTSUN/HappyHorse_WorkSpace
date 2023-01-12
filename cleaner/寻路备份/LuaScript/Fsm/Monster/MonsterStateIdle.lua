---@class MonsterStateBase
local MonsterStateBase = require "Fsm.Monster.MonsterStateBase"
---@class MonsterStateInfo
local MonsterStateInfo = require "Fsm.Monster.MonsterStateInfo"

---@class MonsterStateIdle
local MonsterStateIdle = class(MonsterStateBase, "MonsterStateIdle")

function MonsterStateIdle:ctor()
    self.stateType = MonsterStateInfo.StateType.Idle
    -- 休闲多久，切换到 巡逻 状态
    self.idleTime = 0
    self:Init()
end

function MonsterStateIdle:Init()
    MonsterStateBase.Init(self)
    self:SetTransition()
    self:AddIntervalExecute(1, function() self:SearchAttackTarget() end)
end

function MonsterStateIdle:OnEnter()
    --console.error("Idle:"..self.entity.entityId)
    --console.error("MonsterStateIdle:OnEnter："..Time.realtimeSinceStartup)
    MonsterStateBase.OnEnter(self)
    self.idleTime = Random.Range(3, 5)
    self.entity:PlayAnimation(EntityAnimationName.Idle_A)
end

function MonsterStateIdle:OnTick()
    MonsterStateBase.OnTick(self)
    self.idleTime = self.idleTime - Time.deltaTime
end

function MonsterStateIdle:OnExit()
    self.toOtherState = 0
end

function MonsterStateIdle:SearchAttackTarget()
    ---@type TargetSearchResult
    local result = self:FightSearchOpposed():SearchWithFightUnit()
    if result:IsTargetValid() then
        self.toOtherState = MonsterStateInfo.StateType.Pursuit
    end
end

function MonsterStateIdle:SetTransition()
    self:ToPatrolTransition()
end

function MonsterStateIdle:ToPatrolTransition()
    local transition = {index = 1}
    transition.CanTransition = function()
        -- 逻辑判断
        local result = (self.idleTime <= 0)
        return result, MonsterStateInfo.StateType.Patrol
    end
    self:AddTransition(transition)
end

return MonsterStateIdle