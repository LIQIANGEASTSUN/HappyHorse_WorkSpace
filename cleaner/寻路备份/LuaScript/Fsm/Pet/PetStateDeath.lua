local PetStateBase = require "Fsm.Pet.PetStateBase"
---@class PetStateInfo
local PetStateInfo = require "Fsm.Pet.PetStateInfo"

---@class PetlyStateDeath
local PetStateDeath = class(PetStateBase, "PetStateDeath")
-- 怪物状态：友方怪物死亡


function PetStateDeath:ctor()
    self.stateType = PetStateInfo.StateType.Death
    self:Init()
    self.deathTime = 0
end

function PetStateDeath:Init()
    PetStateBase.Init(self)
end

function PetStateDeath:OnEnter()
    PetStateBase.OnEnter(self)
    --console.error("PetStateDeath:OnEnter")
    self.entity:PlayAnimation(EntityAnimationName.Death)
    self.entity:SetDeath()
    self.deathTime = Time.realtimeSinceStartup
end

function PetStateDeath:OnTick()
    PetStateBase.OnTick(self)

    if Time.realtimeSinceStartup - self.deathTime >= 5 then
        AppServices.EntityManager:RemoveEntity(self.entity.entityId)
    end
end

function PetStateDeath:OnExit()
    self.toOtherState = 0
end

return PetStateDeath