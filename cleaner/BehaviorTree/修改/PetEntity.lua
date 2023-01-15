---@type PetTemplateTool
local PetTemplateTool = require "Cleaner.Entity.Pet.PetTemplateTool"

---@type BaseEntity
local BaseEntity = require "Cleaner.Entity.BaseEntity"

---@type PetActionTool
local PetActionTool = require "Cleaner.AIConfig.Pet.PetActionTool"

---@type PetStateInfo
local PetStateInfo = require "Fsm.Pet.PetStateInfo"

---@type BTConstant
local BTConstant = require "Cleaner.BehaviorTree.BTConstant"

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
    --self:CreateState()
    self:CreateBehaviorTree()
    self:AddBuff()

    self:RegisterEvent()
end

function PetEntity:GetType()
    return self.data:GetType()
end

function PetEntity:CreateFightUnit(camp)
    BaseEntity.CreateFightUnit(self, camp)
    local fightUnit = self:GetUnit(UnitType.FightUnit)
    fightUnit:SetEnableAttack(true)
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
    local moveType = AppServices.UnitMoveManager.MoveType.FindPathAlgorithm
    self:ChangeMoveTool(moveType)
end

function PetEntity:ChangeMoveTool(moveType)
    if not self.moveMap then
        self.moveMap = {}
    end

    if self.moveMap[moveType] then
        self.unitMove = self.moveMap[moveType]
    else
        self.unitMove = AppServices.UnitMoveManager:CreateMove(self, moveType)
        self.unitMove:SetSpeed(self.data.speed)
        self.moveMap[moveType] = self.unitMove
    end
end

function PetEntity:CreateBehaviorTree()
    local fightUnit = self:GetUnit(UnitType.FightUnit)
    fightUnit:CreateBehaviorTree("PetIsland")
    ---@type BehaviorTreeEntity
    self.btEntity = fightUnit:BehaviorTreeEntity()
    self:InitBehaviorTree()
    self.petActionTool = PetActionTool.new(fightUnit)
end

function PetEntity:CreateSkill()
    local skills = {self.data.meta.skillId}
    local fightUnit = self:GetUnit(UnitType.FightUnit)
    fightUnit:ClearSkill()
    fightUnit:AddSkill(skills)
    fightUnit:SetDamageHpType(TipsType.UnitPetHpType2Tips)

    fightUnit:NotifyHp(0, TipsType.UnitPetHpType1Tips, true)
end

-- buffId
function PetEntity:AddBuff()
    local fightUnit = self:GetUnit(UnitType.FightUnit)

    local buffId = self.data.meta.buffId
    local casterData= {
        caster = fightUnit,
        casterSkillId = -1,
        casterBuffId = buffId
    }

    local buffManager = fightUnit:GetBuffManager()
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
    if self:IsAlive() then
        local maxHp = self.data:GetMaxHp()
        self:SetHp(maxHp)
    end

    self:CreateSkill()
    self:AddBuff()

    if currentModelName ~= meta.model then
        self:ReLoadGo(sn)
    else
        self:RefreshHp()
    end
end

function PetEntity:SetHp(hp)
    BaseEntity.SetHp(self, hp)
    if self.btEntity then
        self.btEntity:SetFloatParameter(BTConstant.PetHp, hp)
    end
end

function PetEntity:ChangeHp(value)
    BaseEntity.ChangeHp(self, value)
    MessageDispatcher:SendMessage(MessageType.Pet_Hp_Change, self.data:GetType())
end

function PetEntity:InitBehaviorTree()
    if not self.btEntity then
        return
    end
    self.btEntity:SetFloatParameter(BTConstant.DistancePlayer, 100)
    self.btEntity:SetBoolParameter(BTConstant.ArriveFollowPos, false)
    self.btEntity:SetBoolParameter(BTConstant.HasTarget, false)
    self.btEntity:SetBoolParameter(BTConstant.TargetInAttackDistance, false)
end

function PetEntity:ReLoadGo(sn)
    console.error("1 PetEntity:ReLoadGo:"..self.entityId)
    local finish = function(go)
        local position = self:GetPosition()
        GameObject.Destroy(self.gameObject)
        self:BindView(go)
        self:SetPosition(position)
        self:PlayAnimation(EntityAnimationName.Idle_A)
        self:RefreshHp()
    end
    AppServices.EntityManager:CreateEntityGo(tostring(sn), EntityType.Pet, finish)
    console.error("2 PetEntity:ReLoadGo:"..self.entityId)
end

function PetEntity:RefreshHp()
    if not self:IsAlive() then
        return
    end
    local fightUnit = self:GetUnit(UnitType.FightUnit)
    fightUnit:NotifyHp(0, TipsType.UnitPetHpType1Tips, true)
end

function PetEntity:LateUpdate()
    BaseEntity.LateUpdate(self)
end

function PetEntity:NeedLateUpdate()
    return true
end

function PetEntity:PetDownTeam(pet)
    if pet.type == self.data.meta.type then
        AppServices.EntityManager:RemoveEntity(self.entityId)
        AppServices.IslandFightManager:PetDown(self.entityId)
    end
end

function PetEntity:LinkedHomeland(islandId)
    AppServices.EntityManager:RemoveEntity(self.entityId)
end

function PetEntity:PetRecover()
    --console.error("PetEntity:PetRecover")
    self:SetAlive(true)
    local maxHp = self.data:GetMaxHp()
    self:SetHp(maxHp)

    local toStateType = PetStateInfo.StateType.Idle
    self:ChangeState(toStateType, nil)

    self:SetVisible(true)

    MessageDispatcher:SendMessage(MessageType.Pet_Hp_Change, self.data.meta.type)

    -- local state = self:GetCurrentState()
    -- local stateType = state:GetStateType()
    -- console.error("stateType:"..stateType)
end

function PetEntity:RegisterEvent()
    MessageDispatcher:AddMessageListener(MessageType.IslandLinkHomeland, self.LinkedHomeland, self)
    MessageDispatcher:AddMessageListener(MessageType.PetUpLevel, self.ReceiveUpgrade, self)
    MessageDispatcher:AddMessageListener(MessageType.Pet_Down_Team, self.PetDownTeam, self)
    MessageDispatcher:AddMessageListener(MessageType.PetRecover, self.PetRecover, self)
end

function PetEntity:UnRegisterEvent()
    MessageDispatcher:RemoveMessageListener(MessageType.IslandLinkHomeland, self.LinkedHomeland, self)
    MessageDispatcher:RemoveMessageListener(MessageType.PetUpLevel, self.ReceiveUpgrade, self)
    MessageDispatcher:RemoveMessageListener(MessageType.Pet_Down_Team, self.PetDownTeam, self)
    MessageDispatcher:RemoveMessageListener(MessageType.PetRecover, self.PetRecover, self)
end

function PetEntity:Destroy()
    BaseEntity.Destroy(self)
    self:UnRegisterEvent()
end

return PetEntity