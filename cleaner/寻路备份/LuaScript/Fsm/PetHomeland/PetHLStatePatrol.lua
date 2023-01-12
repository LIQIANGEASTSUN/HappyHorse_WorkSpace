---@type PetHLStateBase
local PetHLStateBase = require "Fsm.PetHomeland.PetHLStateBase"

---@class PetHLStateInfo
local PetHLStateInfo = require "Fsm.PetHomeland.PetHLStateInfo"

---@class PetHLStatePatrol
local PetHLStatePatrol = class(PetHLStateBase, "PetHLStatePatrol")

-- 宠物在家园状态：巡逻
function PetHLStatePatrol:ctor()
    self.stateType = PetHLStateInfo.StateType.Patrol
    -- 巡逻多久，切换到 idle 状态
    self.patrolTime = 0
    self:Init()
end

function PetHLStatePatrol:Init()
    PetHLStateBase.Init(self)
    self:SetTransition()
end

function PetHLStatePatrol:OnEnter()
    --console.error("Patrol:"..self.entity.entityId)
    PetHLStateBase.OnEnter(self)
    self.patrolTime = Random.Range(10, 20)
    self.entity:PlayAnimation(EntityAnimationName.Walk)
    self:ResetDestination()
end

function PetHLStatePatrol:OnTick()
    PetHLStateBase.OnTick(self)
    self:Move()
end

function PetHLStatePatrol:OnExit()
    self.toOtherState = 0
end

function PetHLStatePatrol:ResetDestination()
    local pos = self.entity:GetPosition()
    local result, position =  self.entity.unitMove:RandomPosition(pos)
    if result then
        self.entity.unitMove:ChangeDestination(position)
    end
end

function PetHLStatePatrol:Move()
    self.patrolTime = self.patrolTime - Time.deltaTime
    local arrive, pos = self.entity.unitMove:OnTick()
    self.entity:SetPosition(pos)

    if arrive then
        self:ResetDestination()
    end
end

-- 添加状态切换条件
function PetHLStatePatrol:SetTransition()
    self:ToIdleTransition()
end

-- 从 巡逻 到idle 的状态转换
function PetHLStatePatrol:ToIdleTransition()
    local transition = {index = 1}
    transition.CanTransition = function()
        -- 逻辑判断
        local result = (self.patrolTime <= 0)
        return result, PetHLStateInfo.StateType.Idle
    end

    self:AddTransition(transition)
end

return PetHLStatePatrol