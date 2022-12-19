---@type PetTemplateTool
local PetTemplateTool = require "Cleaner.Entity.Pet.PetTemplateTool"

---@type BaseEntity
local BaseEntity = require "Cleaner.Entity.BaseEntity"

---@class PetHLStateInfo
local PetHLStateInfo = require "Fsm.PetHomeland.PetHLStateInfo"

---@class PetHLEntity:BaseEntity 探索岛上宠物
local PetHLEntity = class(BaseEntity, "PetHLEntity")

function PetHLEntity:ctor()
    self.entityType = EntityType.Pet
    self.campType = CampType.Blue
end

function PetHLEntity:BindView(gameObject)
    BaseEntity.BindView(self, gameObject)
end

function PetHLEntity:Init(birthPos)
    self:SetBirthPos(birthPos)
    self:SetPosition(birthPos)
    self:CreateMoveTool()

    self:CreateFightUnit(self.campType)
    self:CreateState()
    self:RegisterEvent()
end

--- 因为状态机会用到一些其他的属性，最后调用这个方法
function PetHLEntity:CreateState()
    for _, path in pairs(PetHLStateInfo.States) do
        self:AddState(path)
    end

    local toStateType = PetHLStateInfo.StateType.Idle
    self:ChangeState(toStateType, nil)
end

function PetHLEntity:CreateMoveTool()
    local moveType = AppServices.UnitMoveManager.MoveType.FindPathAlgorithm
    ---@type UnitMoveFreedom
    self.unitMove = AppServices.UnitMoveManager:CreateMove(self, moveType)
    self.unitMove:SetSpeed(self.data.speed)
end

function PetHLEntity:ReceiveUpgrade(type, level)
    if self.data.meta.type ~= type then
        return
    end

    local currentModelName = self.data.meta.model
    local sn = PetTemplateTool:Getkey(type, level)

    local meta = AppServices.Meta:Category("PetTemplate")[tostring(sn)]
    self.data:ResetMeta(meta)

    if currentModelName ~= meta.model then
        self:ReLoadGo(sn)
    end
end

function PetHLEntity:ReLoadGo(sn)
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

function PetHLEntity:LateUpdate()
    BaseEntity.LateUpdate(self)
end

function PetHLEntity:NeedLateUpdate()
    return true
end

function PetHLEntity:RegisterEvent()
    MessageDispatcher:AddMessageListener(MessageType.PetUpLevel, self.ReceiveUpgrade, self)
end

function PetHLEntity:UnRegisterEvent()
    MessageDispatcher:RemoveMessageListener(MessageType.PetUpLevel, self.ReceiveUpgrade, self)
end

function PetHLEntity:Destroy()
    BaseEntity.Destroy(self)
    self:UnRegisterEvent()
end

return PetHLEntity