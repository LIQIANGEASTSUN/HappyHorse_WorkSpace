---@type FsmStateBase
local FsmStateBase = require "Fsm.StateMachine.FsmStateBase"
---@class MonsterStateInfo
local MonsterStateInfo = require "Fsm.Monster.MonsterStateInfo"

---@class MonsterStateBase:FsmStateBase
local MonsterStateBase = class(FsmStateBase, "MonsterStateBase")
-- 怪物状态：基类

function MonsterStateBase:ctor(entity)
    ---@type MonsterEntity
    self.entity = entity
    self.stateType = 0
    self.activity = false
    self.toOtherState = 0
end

function MonsterStateBase:Init()
    self:SetCommonTransition()
end

function MonsterStateBase:OnEnter()
    local entityGo = self.entity:GetGameObject()
    self.entity.unitMove:CurrentForward(entityGo.transform.forward)
end

function MonsterStateBase:OnTick()
    FsmStateBase.OnTick(self)
end

function MonsterStateBase:FightUnit()
    return self.entity.fightUnit
end

function MonsterStateBase:FightSearchOpposed()
    return self.entity.fightUnit:SearchOpposed()
end

function MonsterStateBase:PlayAnimation(animname)
    local entityGo = self.entity:GetGameObject()
    entityGo:PlayAnim(animname)
end

-- 所有状态通用的切换条件
function MonsterStateBase:SetCommonTransition()
    self:ToDeathTransition()
    self:ToOtherStateTransition()
end

-- 血量 <= 0 时 切换到 死亡状态
function MonsterStateBase:ToDeathTransition()
    local transition = {index = 1}
    transition.CanTransition = function()
        -- 逻辑判断血量
        local result = self.entity:GetHp() <= 0
        return result, MonsterStateInfo.StateType.Death
    end
    self:AddTransition(transition)
end

-- 从 当提前状态到其 toOtherState 状态
function MonsterStateBase:ToOtherStateTransition()
    local transition = {index = 1}
    transition.CanTransition = function()
        -- 逻辑判断
        ---@type TargetSearchResult
        local result = self.toOtherState > 0
        return result, self.toOtherState
    end
    self:AddTransition(transition)
end

return MonsterStateBase