---@type FsmStateBase
local FsmStateBase = require "Fsm.StateMachine.FsmStateBase"
---@class PetStateInfo
local PetStateInfo = require "Fsm.Pet.PetStateInfo"

---@class PetStateBase:FsmStateBase
local PetStateBase = class(FsmStateBase, "PetStateBase")
-- 宠物状态：基类

function PetStateBase:ctor(entity)
    ---@type PetEntity
    self.entity = entity
    self.stateType = 0
    self.activity = false
    self.toOtherState = 0
end

function PetStateBase:Init()
    self:SetCommonTransition()
    self:FightUnit():NotifyHp(0, TipsType.UnitPetHpType1Tips, true)
end

function PetStateBase:OnEnter()
    local entityGo = self.entity:GetGameObject()
    self.entity.unitMove:CurrentForward(entityGo.transform.forward)
    self.enterTime = Time.realtimeSinceStartup
end

function PetStateBase:OnTick()
    FsmStateBase.OnTick(self)
end

function PetStateBase:FightUnit()
    return self.entity.fightUnit
end

function PetStateBase:FightSearchOpposed()
    return self.entity.fightUnit:SearchOpposed()
end

function PetStateBase:SearchAttackTarget()
    -- 搜索到能攻击的对象
    ---@type TargetSearchResult
    local result = self:FightSearchOpposed():SearchWithPlayer()
    if not result:IsTargetAndSkillValid() then
        return
    end

    self.toOtherState = PetStateInfo.StateType.Pursuit
end

-- 所有状态通用的切换条件
function PetStateBase:SetCommonTransition()
    self:ToDeathTransition()
    self:ToOtherStateTransition()
end

-- 血量 <= 0 时 切换到 死亡状态
function PetStateBase:ToDeathTransition()
    local transition = {index = 1}
    transition.CanTransition = function()
        -- 逻辑判断血量
        local result = self.entity:GetHp() <= 0
        return result, PetStateInfo.StateType.Death
    end
    self:AddTransition(transition)
end

-- 从 当提前状态到其 toOtherState 状态
function PetStateBase:ToOtherStateTransition()
    local transition = {index = 1}
    transition.CanTransition = function()
        -- 逻辑判断
        ---@type TargetSearchResult
        local result = self.toOtherState > 0
        return result, self.toOtherState
    end
    self:AddTransition(transition)
end

return PetStateBase