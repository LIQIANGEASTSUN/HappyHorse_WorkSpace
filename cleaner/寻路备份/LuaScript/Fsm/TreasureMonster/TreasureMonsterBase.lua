---@type FsmStateBase
local FsmStateBase = require "Fsm.StateMachine.FsmStateBase"
---@class PetStateInfo
local PetStateInfo = require "Fsm.Pet.PetStateInfo"

---@class TreasureMonsterBase:FsmStateBase
local TreasureMonsterBase = class(FsmStateBase, "TreasureMonsterBase")
-- 宝箱怪物状态：基类

function TreasureMonsterBase:ctor(entity)
    ---@type PetEntity
    self.entity = entity
    self.stateType = 0
    self.activity = false
    self.toOtherState = 0
end

function TreasureMonsterBase:Init()
    self:SetCommonTransition()
end

function TreasureMonsterBase:OnEnter()
    local entityGo = self.entity:GetGameObject()
    self.entity.unitMove:CurrentForward(entityGo.transform.forward)
    self.enterTime = Time.realtimeSinceStartup
end

function TreasureMonsterBase:OnTick()
    FsmStateBase.OnTick(self)
end

function TreasureMonsterBase:FightUnit()
    return self.entity.fightUnit
end

function TreasureMonsterBase:FightSearchOpposed()
    return self.entity.fightUnit:SearchOpposed()
end

function TreasureMonsterBase:SearchAttackTarget()
    -- 搜索到能攻击的对象
    ---@type TargetSearchResult
    local result = self:FightSearchOpposed():SearchWithPlayer()
    if not result:IsTargetAndSkillValid() then
        return
    end

    self.toOtherState = PetStateInfo.StateType.Pursuit
end

-- 所有状态通用的切换条件
function TreasureMonsterBase:SetCommonTransition()
    self:ToDeathTransition()
    self:ToOtherStateTransition()
end

-- 血量 <= 0 时 切换到 死亡状态
function TreasureMonsterBase:ToDeathTransition()
    local transition = {index = 1}
    transition.CanTransition = function()
        -- 逻辑判断血量
        local result = self.entity:GetHp() <= 0
        return result, PetStateInfo.StateType.Death
    end
    self:AddTransition(transition)
end

-- 从 当提前状态到其 toOtherState 状态
function TreasureMonsterBase:ToOtherStateTransition()
    local transition = {index = 1}
    transition.CanTransition = function()
        -- 逻辑判断
        ---@type TargetSearchResult
        local result = self.toOtherState > 0
        return result, self.toOtherState
    end
    self:AddTransition(transition)
end

return TreasureMonsterBase