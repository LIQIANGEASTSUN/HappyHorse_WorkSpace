local MonsterStateBase = require "Fsm.Monster.MonsterStateBase"
---@class MonsterStateInfo
local MonsterStateInfo = require "Fsm.Monster.MonsterStateInfo"

---@class MonsterStatePatrol
local MonsterStatePatrol = class(MonsterStateBase, "MonsterStatePatrol")

-- 怪物状态：巡逻
-- 怪物巡逻
-- 巡逻过程中附带搜索可以攻击的小怪
function MonsterStatePatrol:ctor()
    self.stateType = MonsterStateInfo.StateType.Patrol
    self.maxOffsetWithBirthPos = 0
    -- 巡逻多久，切换到 idle 状态
    self.patrolTime = 0
    self:Init()
end

function MonsterStatePatrol:Init()
    MonsterStateBase.Init(self)
    local meta = self.entity.data.meta
    -- 巡逻范围平方，为了减少下面计算距离开平方，下面距离也是用平方 sqrMagnitude
    self.maxOffsetWithBirthPos = meta.patrol * meta.patrol
    self:SetTransition()

    self:AddIntervalExecute(1, function() self:SearchAttackTarget() end)
end

function MonsterStatePatrol:OnEnter()
    --console.error("Patrol:"..self.entity.entityId)
    --console.error("MonsterStatePatrol:OnEnter："..Time.realtimeSinceStartup)
    MonsterStateBase.OnEnter(self)
    self.patrolTime = Random.Range(10, 20)

    self.entity:PlayAnimation(EntityAnimationName.Walk)

    self:ResetDestination()
end

function MonsterStatePatrol:OnTick()
    MonsterStateBase.OnTick(self)
    self:Move()
end

function MonsterStatePatrol:OnExit()
    self.toOtherState = 0
end

function MonsterStatePatrol:ResetDestination()
    local pos = self.entity.birthPos
    local result, position =  self.entity.unitMove:RandomPosition(pos)
    if result then
        self.entity.unitMove:ChangeDestination(position)
    end
end

function MonsterStatePatrol:Move()
    self.patrolTime = self.patrolTime - Time.deltaTime
    local arrive, pos = self.entity.unitMove:OnTick()
    self.entity:SetPosition(pos)

    if arrive then
        self:ResetDestination()
    end
end

function MonsterStatePatrol:SearchAttackTarget()
    -- 搜索到能攻击的对象
    ---@type TargetSearchResult
    local result = self:FightSearchOpposed():SearchWithFightUnit()
    if result:IsTargetValid() then
        self.toOtherState = MonsterStateInfo.StateType.Pursuit
    end
end

-- 添加状态切换条件
function MonsterStatePatrol:SetTransition()
    self:ToIdleTransition()
end

-- 从 巡逻 到idle 的状态转换
function MonsterStatePatrol:ToIdleTransition()
    local transition = {index = 1}
    transition.CanTransition = function()
        -- 逻辑判断
        local result = (self.patrolTime <= 0)
        return result, MonsterStateInfo.StateType.Idle
    end

    self:AddTransition(transition)
end

return MonsterStatePatrol