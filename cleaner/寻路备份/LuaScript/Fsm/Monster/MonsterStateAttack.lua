local MonsterStateBase = require "Fsm.Monster.MonsterStateBase"
---@class MonsterStateInfo
local MonsterStateInfo = require "Fsm.Monster.MonsterStateInfo"

---@class MonsterStateAttack
local MonsterStateAttack = class(MonsterStateBase, "MonsterStateAttack")
-- 怪物状态：攻击
-- 己方和敌方怪物的攻击行为相同
-- 攻击在攻击方范围内的对方怪物
-- 所以己方和敌方怪物都使用这个，如果后边攻击行为不同了，可以考虑添加新的攻击行为

function MonsterStateAttack:ctor()
    self.stateType = MonsterStateInfo.StateType.Attack
    self:Init()
end

function MonsterStateAttack:Init()
    MonsterStateBase.Init(self)
    self:AddIntervalExecute(1, function() self:Attack() end)
end

function MonsterStateAttack:OnEnter()
    --console.error("Attack:"..self.entity.entityId)
    --console.error("MonsterStateAttack:OnEnter："..Time.realtimeSinceStartup)
    MonsterStateBase.OnEnter(self)
    self.toOtherState = -1

    self:FightUnit():NotifyHp(0, TipsType.UnitMonsterHpTips, true)
end

function MonsterStateAttack:OnTick()
    MonsterStateBase.OnTick(self)
    --console.error("MonsterStateAttack:OnTick")
end

function MonsterStateAttack:OnExit()
    self.toOtherState = 0
    self:FightUnit():NotifyHp( 0, TipsType.UnitMonsterHpTips, false)
end

function MonsterStateAttack:Attack()
    ---@type TargetSearchResult
    local result = self:FightSearchOpposed():SearchWithFightUnit()
    local v = result:IsTargetAndSkillValid()

    if not v then
        self.toOtherState = MonsterStateInfo.StateType.Idle
        return
    end

    -- 超出攻击范围了，切换到追踪
    if not result:TargetInAttackDistance() then
        self.toOtherState = MonsterStateInfo.StateType.Pursuit
        return
    end

    local _, normalized = result:OffsetPosition()
    self.entity:SetForward(normalized)

    -- 释放技能 skill
    local skillController = self:FightUnit():SkillController()
    if skillController:EnableUse(result.skillId) then
        local targets = {result.other}
        skillController:Fire(result.skillId, targets)
    end
end

return MonsterStateAttack