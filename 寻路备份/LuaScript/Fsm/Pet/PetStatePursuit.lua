local PetStateBase = require "Fsm.Pet.PetStateBase"
---@class PetStateInfo
local PetStateInfo = require "Fsm.Pet.PetStateInfo"

---@class PetStatePursuit
local PetStatePursuit = class(PetStateBase, "PetStatePursuit")
-- 宠物状态：追击
-- 怪物搜索到可以攻击的小怪，去追击
-- 用于敌方怪物

function PetStatePursuit:ctor()
    self.stateType = PetStateInfo.StateType.Pursuit
    self:Init()
end

function PetStatePursuit:Init()
    PetStateBase.Init(self)
    self.toOtherState = -1
    self:AddIntervalExecute(0.1, function() self:ChangeDestination() end)
end

function PetStatePursuit:OnEnter()
    --console.error("PetStatePursuit:OnEnter:"..Time.realtimeSinceStartup)
    PetStateBase.OnEnter(self)

    self.entity:PlayAnimation(EntityAnimationName.Walk)
    self.toOtherState = -1
    self:ChangeDestination()
end

function PetStatePursuit:OnTick()
    PetStateBase.OnTick(self)
    self:Pursuit()
end

function PetStatePursuit:OnExit()
    self.toOtherState = 0
end

function PetStatePursuit:Pursuit()
    local arrive, pos = self.entity.unitMove:OnTick()
    self.entity:SetPosition(pos)

    if arrive then
        -- 追踪到能攻击对方的地方了，切换到攻击
        self.toOtherState = PetStateInfo.StateType.Attack
    end
end

function PetStatePursuit:ChangeDestination()
    ---@type TargetSearchResult
    local result = self:FightSearchOpposed():SearchWithPlayer()
    if not result:IsTargetAndSkillValid() then
        -- 没有课攻击对象，转换为 idle
        self.toOtherState = PetStateInfo.StateType.Idle
        return
    end

    local destination =  result:NearestAttackPosition()
    self.entity.unitMove:ChangeDestination(destination)
end

return PetStatePursuit