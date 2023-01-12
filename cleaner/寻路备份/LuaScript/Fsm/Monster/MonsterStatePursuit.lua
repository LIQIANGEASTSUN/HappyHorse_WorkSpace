local MonsterStateBase = require "Fsm.Monster.MonsterStateBase"

---@class MonsterStateInfo
local MonsterStateInfo = require "Fsm.Monster.MonsterStateInfo"

---@class MonsterStatePursuit
local MonsterStatePursuit = class(MonsterStateBase, "MonsterStatePursuit")
-- 怪物状态：追击
-- 怪物搜索到可以攻击的小怪，去追击
-- 用于敌方怪物

function MonsterStatePursuit:ctor()
    self.stateType = MonsterStateInfo.StateType.Pursuit
    self:Init()
end

function MonsterStatePursuit:Init()
    MonsterStateBase.Init(self)
    local meta = self.entity.data.meta
    -- 巡逻范围平方，为了减少下面计算距离开平方，下面距离也是用平方 sqrMagnitude
    self.maxOffsetWithBirthPos = meta.patrol * meta.patrol
    self.sqrtrack = meta.track * meta.track

    self:AddIntervalExecute(1, function() self:ChangeDestination() end)
end

function MonsterStatePursuit:OnEnter()
    --console.error("MonsterStatePursuit:OnEnter："..Time.realtimeSinceStartup)
    MonsterStateBase.OnEnter(self)

    self.entity:PlayAnimation(EntityAnimationName.Walk)
    self.toOtherState = -1
    self:ChangeDestination()
end

function MonsterStatePursuit:OnTick()
    MonsterStateBase.OnTick(self)
    self:Pursuit()
end

function MonsterStatePursuit:OnExit()
    self.toOtherState = 0
end

function MonsterStatePursuit:Pursuit()
    if self.toOtherState > 0 then
        return
    end
    local arrive, pos = self.entity.unitMove:OnTick()
    local birthPos = self.entity:GetBornPos()
    local offset = pos - birthPos
    if offset.sqrMagnitude < self.sqrtrack then
        -- 在追踪范围内
        self.entity:SetPosition(pos)
    else
        -- 超出追踪范围了，回到出生点
        self.entity:SetPosition(birthPos)
        self.toOtherState = MonsterStateInfo.StateType.Idle
    end

    if arrive then
        -- 追踪到能攻击对方的地方了，切换到攻击
        self.toOtherState = MonsterStateInfo.StateType.Attack
    end
end

function MonsterStatePursuit:ChangeDestination()
    ---@type TargetSearchResult
    local result = self:FightSearchOpposed():SearchWithFightUnit()
    if not result:IsTargetAndSkillValid() then
        -- 没有课攻击对象，转换为 idle
        self.toOtherState = MonsterStateInfo.StateType.Idle
    else
        local destination =  result:NearestAttackPosition()
        self.entity.unitMove:ChangeDestination(destination)
    end
end

return MonsterStatePursuit