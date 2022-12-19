---@type BaseEntity
local BaseEntity = require "Cleaner.Entity.BaseEntity"

---@class MonsterStateInfo
local MonsterStateInfo = require "Fsm.Monster.MonsterStateInfo"

local MonsterEntity = class(BaseEntity, "MonsterEntity")
-- local UE = CS.UnityEngine
-- local CapsuleCollider = typeof(UE.CapsuleCollider)

function MonsterEntity:ctor()
    self.entityType = EntityType.Monster
    self.campType = CampType.Red
end

function MonsterEntity:BindView(gameObject)
    BaseEntity.BindView(self, gameObject)
end

function MonsterEntity:Init(birthPos)
    self:SetBirthPos(birthPos)
    self:SetPosition(birthPos)
    self:CreateMoveTool()

    self:CreateFightUnit(self.campType)
    self:CreateSkill()
    self:CreateState()
    self:CheckBoss()
end

--- 因为状态机会用到一些其他的属性，最后调用这个方法
function MonsterEntity:CreateState()
    for _, path in pairs(MonsterStateInfo.States) do
        BaseEntity.AddState(self, path)
    end

    local toStateType = MonsterStateInfo.StateType.Idle
    BaseEntity.ChangeState(self, toStateType, nil)
end

function MonsterEntity:CreateMoveTool()
    local moveType = AppServices.UnitMoveManager.MoveType.FindPathAlgorithm
    ---@type UnitMoveFreedom
    self.unitMove = AppServices.UnitMoveManager:CreateMove(self, moveType)
    self.unitMove:SetSpeed(self.data.meta.speed)
end

function MonsterEntity:CreateSkill()
    local skills = {self.data.meta.skillId}
    self.fightUnit:AddSkill(skills)
    self.fightUnit:SetDamageHpType(TipsType.UnitMonsterHpTips)
end

function MonsterEntity:GetSearchDistance()
    return self.data.meta.search
end

function MonsterEntity:CheckBoss()
    local isBoss = self.data:IsBoss()
    if not isBoss then
        return
    end

    self.gameObject:SetLocalScale(2, 2, 2)

    local instanceId = self.fightUnit:GetInstanceId()
    AppServices.UnitTipsManager:ShowTips(instanceId, TipsType.UnitBoss)
end

function MonsterEntity:LateUpdate()
    BaseEntity.LateUpdate(self)
end

function MonsterEntity:NeedLateUpdate()
    return true
end

return MonsterEntity