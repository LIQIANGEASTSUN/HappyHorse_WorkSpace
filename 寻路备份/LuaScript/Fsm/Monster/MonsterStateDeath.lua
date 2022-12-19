local MonsterStateBase = require "Fsm.Monster.MonsterStateBase"
---@class MonsterStateInfo
local MonsterStateInfo = require "Fsm.Monster.MonsterStateInfo"

---@class MonsterStateDeath
local MonsterStateDeath = class(MonsterStateBase, "MonsterStateDeath")
-- 怪物状态：敌方怪物死亡

function MonsterStateDeath:ctor()
    self.stateType = MonsterStateInfo.StateType.Death
    self:Init()
    self.deathTime = 0
    local id = tostring(self.entity.data.meta.sn)
    local config = AppServices.Meta:Category("BuildingTemplate")[id]
    self.DEATH_DESTROY_TIME = math.max(config.refreshCd, 5)
end

function MonsterStateDeath:Init()
    MonsterStateBase.Init(self)
end

function MonsterStateDeath:OnEnter()
    --console.error("Death:"..self.entity.entityId)
    MonsterStateBase.OnEnter(self)
    self.activity = true

    self.entity:PlayAnimation(EntityAnimationName.Death)
    self.entity:SetDeath()
    self.deathTime = Time.realtimeSinceStartup

    local sn = self.entity.data.meta.sn
    MessageDispatcher:SendMessage(MessageType.EntityDeath, self.entity.entityId, sn)

    self:FightUnit():NotifyHp(0, TipsType.UnitMonsterHpTips, false)
end

function MonsterStateDeath:OnTick()
    MonsterStateBase.OnTick(self)

    if Time.realtimeSinceStartup - self.deathTime >= self.DEATH_DESTROY_TIME then
        self:NotifyRemove()
    end
end

function MonsterStateDeath:OnExit()
    self.toOtherState = 0
    self.activity = false
end

function MonsterStateDeath:NotifyRemove()
    AppServices.EntityManager:RemoveEntity(self.entity.entityId)
end

return MonsterStateDeath