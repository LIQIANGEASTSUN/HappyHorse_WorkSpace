---@type PetTemplateTool
local PetTemplateTool = require "Cleaner.Entity.Pet.PetTemplateTool"

---@type BaseEntity
local BaseEntity = require "Cleaner.Entity.BaseEntity"
---@class PetStateInfo
local PetStateInfo = require "Fsm.Pet.PetStateInfo"

---@class PetEntity:BaseEntity 探索岛上宠物
local PetEntity = class(BaseEntity, "PetEntity")

function PetEntity:ctor()
    self.entityType = EntityType.Pet
    self.campType = CampType.Blue
end

function PetEntity:BindView(gameObject)
    BaseEntity.BindView(self, gameObject)
end

function PetEntity:Init(birthPos)
    self:SetBirthPos(birthPos)
    self:SetPosition(birthPos)
    self:CreateMoveTool()

    self:CreateFightUnit(self.campType)
    self:CreateSkill()
    self:CreateState()
    self:AddBuff()

    self:RegisterEvent()
end

--- 因为状态机会用到一些其他的属性，最后调用这个方法
function PetEntity:CreateState()
    for _, path in pairs(PetStateInfo.States) do
        self:AddState(path)
    end

    local toStateType = PetStateInfo.StateType.FollowPlayer
    self:ChangeState(toStateType, nil)
end

function PetEntity:CreateMoveTool()
    local moveType = AppServices.UnitMoveManager.MoveType.Freedom
    ---@type UnitMoveFreedom
    self.unitMove = AppServices.UnitMoveManager:CreateMove(self, moveType)
    self.unitMove:SetSpeed(self.data.speed)
end

function PetEntity:CreateSkill()
    local skills = {self.data.meta.skillId}
    self.fightUnit:ClearSkill()
    self.fightUnit:AddSkill(skills)
    self.fightUnit:SetDamageHpType(TipsType.UnitPetHpType2Tips)
end

-- buffId
function PetEntity:AddBuff()
    local buffId = self.data.meta.buffId
    local casterData= {
        caster = self.fightUnit,
        casterSkillId = -1,
        casterBuffId = buffId
    }

    local buffManager = self.fightUnit:GetBuffManager()
    buffManager:ClearBuff()
    buffManager:AddBuff(buffId, casterData)
end

function PetEntity:ReceiveUpgrade(type, level)
    if self.data.meta.type ~= type then
        return
    end

    local currentModelName = self.data.meta.model
    local sn = PetTemplateTool:Getkey(type, level)

    local meta = AppServices.Meta:Category("PetTemplate")[tostring(sn)]
    self.data:ResetMeta(meta)

    self:CreateSkill()
    self:AddBuff()

    if currentModelName ~= meta.model then
        self:ReLoadGo(sn)
    end
end

function PetEntity:ReLoadGo(sn)
    local finish = function(go)
        local position = self:GetPosition()
        GameObject.Destroy(self.gameObject)
        self:BindView(go)
        self:SetPosition(position)

        local instanceId = self.fightUnit:GetInstanceId()
        AppServices.EventDispatcher:dispatchEvent(HP_INFO_EVENT.HP_DESTROY, instanceId)
        self.fightUnit:NotifyHp(0, TipsType.UnitPetHpType1Tips, true)
        self:PlayAnimation(EntityAnimationName.Idle_A)
    end
    AppServices.EntityManager:CreateEntityGo(tostring(sn), EntityType.Pet, finish)
end

function PetEntity:LateUpdate()
    BaseEntity.LateUpdate(self)
end

function PetEntity:NeedLateUpdate()
    return true
end

function PetEntity:RegisterEvent()
    MessageDispatcher:AddMessageListener(MessageType.PetUpLevel, self.ReceiveUpgrade, self)
end

function PetEntity:UnRegisterEvent()
    MessageDispatcher:RemoveMessageListener(MessageType.PetUpLevel, self.ReceiveUpgrade, self)
end

function PetEntity:Destroy()
    BaseEntity.Destroy(self)
    self:UnRegisterEvent()
end

return PetEntity