---@type FsmStateBase
local FsmStateBase = require "Fsm.StateMachine.FsmStateBase"

---@class PetHLStateBase:FsmStateBase
local PetHLStateBase = class(FsmStateBase, "PetHLStateBase")
-- 宠物在家园状态：基类

function PetHLStateBase:ctor(entity)
    ---@type PetEntity
    self.entity = entity
    self.stateType = 0
    self.activity = false
    self.toOtherState = 0
end

function PetHLStateBase:Init()
    self:SetCommonTransition()
end

function PetHLStateBase:OnEnter()
    local entityGo = self.entity:GetGameObject()
    self.entity.unitMove:CurrentForward(entityGo.transform.forward)
    self.enterTime = Time.realtimeSinceStartup
end

function PetHLStateBase:OnTick()
    FsmStateBase.OnTick(self)
end

function PetHLStateBase:FightUnit()
    return self.entity.fightUnit
end

-- 所有状态通用的切换条件
function PetHLStateBase:SetCommonTransition()
    self:ToOtherStateTransition()
end

-- 从 当提前状态到其 toOtherState 状态
function PetHLStateBase:ToOtherStateTransition()
    local transition = {index = 1}
    transition.CanTransition = function()
        -- 逻辑判断
        ---@type TargetSearchResult
        local result = self.toOtherState > 0
        return result, self.toOtherState
    end
    self:AddTransition(transition)
end

return PetHLStateBase