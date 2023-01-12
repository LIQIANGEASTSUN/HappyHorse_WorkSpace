local PetStateBase = require "Fsm.Pet.PetStateBase"
---@class PetStateInfo
local PetStateInfo = require "Fsm.Pet.PetStateInfo"

---@class PetStateAttack
local PetStateAttack = class(PetStateBase, "PetStateAttack")
-- 宠物状态：跟随玩家
-- 己方小怪的行为

function PetStateAttack:ctor()
    self.stateType = PetStateInfo.StateType.Attack
    self:Init()
end

function PetStateAttack:Init()
    PetStateBase.Init(self)
    self:AddIntervalExecute(1, function() self:Attack() end)
end

function PetStateAttack:OnEnter()
    --console.error("PetStateAttack:OnEnter:"..Time.realtimeSinceStartup)
    PetStateBase.OnEnter(self)
    self.toOtherState = -1
    --console.error("PetStateAttack:OnEnter")

    self:FightUnit():NotifyHp(0, TipsType.UnitPetHpType2Tips, true)
end

function PetStateAttack:OnTick()
    --console.error("MonsterStateAttack:OnTick")
    PetStateBase.OnTick(self)
end

function PetStateAttack:OnExit()
    self.toOtherState = 0
    self:FightUnit():NotifyHp( 0, TipsType.UnitPetHpType1Tips, true)
end

function PetStateAttack:Attack()
    ---@type TargetSearchResult
    local result = self:FightSearchOpposed():SearchWithPlayer()
    if not result:IsTargetAndSkillValid() then
        -- 没有课攻击目标了，切换到 跟随 Player 状态
        self.toOtherState = PetStateInfo.StateType.FollowPlayer
        return
    elseif not result:TargetInAttackDistance() then
        -- 有攻击目标，但是超出攻击范围了，切换到 追踪 状态
        self.toOtherState = PetStateInfo.StateType.Pursuit
        return
    end

    -- 有攻击目标，且在攻击范围内，攻击
    local _, normalized = result:OffsetPosition()
    self.entity:SetForward(normalized)

    -- 释放技能 skill
    ---@type SkillController
    local skillController = self:FightUnit():SkillController()
    if skillController:EnableUse(result.skillId) then
        local targets = {result.other}
        skillController:Fire(result.skillId, targets)
    end
end

return PetStateAttack