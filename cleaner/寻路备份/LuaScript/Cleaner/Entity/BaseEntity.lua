local FightUnitEntity = require "Cleaner.Unit.FightUnitEntity"

---@type FsmStateMachine
local FsmStateMachine = require "Fsm.StateMachine.FsmStateMachine"

local CSValid = Runtime.CSValid
-- local CSNull = Runtime.CSNull
-- local InvokeCbk = Runtime.InvokeCbk
---实体基类
---@class BaseEntity
local BaseEntity = class(nil, "BaseEntity")
local LEVEL_SIZES = {
    0.7,
    0.8,
    0.9,
    1
}

function BaseEntity:ctor(entityId, meta)
    self.entityId = entityId
    ---@type MagicalCreatureMsg
    self.data = nil
    self.visible = true
    ---@type BuildingAgent
    self.agent = nil
    self.alive = true
    ---@type FsmStateMachine
    self.fsmStateMachine = nil
    self.entityType = 0
    self.campType = CampType.Blue
    ---@type FightUnitBase
    self.fightUnit = nil
end

function BaseEntity:BindView(gameObject)
    self.gameObject = gameObject
    self.transform = gameObject.transform
    self.gameObject.name = tostring(self.entityId)
end

function BaseEntity:InitData(data)
    self.data = data
end

function BaseEntity:SetStrengthData(data)
    self.data.physicalStrength = data.physicalStrength
    self.data.getPhysicalStrengthTime = data.getPhysicalStrengthTime
end

function BaseEntity:SetData(data)
    self.data = data
    --TODO reset entity state or show collected or clear
end

function BaseEntity:SetAvailableTime(ts)
    self.data.availableTime = ts
end

function BaseEntity:Awake()
end

function BaseEntity:GetAttribute(attribute)
    if not self.attr then
        return 0
    end
    local attr = self.attrs[attribute]
    return attr or 0
end

function BaseEntity:SetAttribute(attribute, value)
    if not self.attrs then
        self.attrs = {}
    end
    if not self.attrs[attribute] then
        self.attrs[attribute] = value
        return
    end
    self.attrs[attribute] = value
end

function BaseEntity:SetBirthPos(bornPos)
    self.bornPos = bornPos
end

function BaseEntity:GetBornPos()
    return self.bornPos
end

function BaseEntity:SetPosition(position)
    if not Runtime.CSValid(self.gameObject) then
        return
    end
    self.gameObject:SetPosition(position)
end

function BaseEntity:GetPosition()
    if not Runtime.CSValid(self.gameObject) then
        local pos = Camera.main:ScreenToWorldPoint(Vector3(Screen.width / 2, Screen.height / 2, 0))
        return pos
    end
    return self.gameObject:GetPosition()
end

function BaseEntity:GetGameObject()
    return self.gameObject
end

function BaseEntity:GetSize()
    local level = self.data.meta.level
    return LEVEL_SIZES[level]
end

function BaseEntity:SetForward(forward)
    local rot = Quaternion.LookRotation(forward, Vector3.up)
    self.transform.rotation = rot
end

function BaseEntity:GetVisible()
    return self.visible
end

function BaseEntity:SetVisible(visible)
    if self.visible == visible then
        return
    end
    self.visible = visible
    if CSValid(self.gameObject) then
        self.gameObject:SetActive(visible)
    end
    if Runtime.CSValid(self.shadow) then
        self.shadow:SetActive(visible)
    end
end

function BaseEntity:IsBusy()
    if self.agent then
        return self.agent.alive
    end
    return false
end

function BaseEntity:TriggerEvent(evt, ...)
    if not self.listeners then
        return
    end
    for _, evtCb in pairs(self.listeners) do
        Runtime.InvokeCbk(evtCb[evt], ...)
    end
end

function BaseEntity:RegisterEvent(listener, evt, handler)
    if not self.listeners then
        self.listeners = {}
    end
    if not self.listeners[listener] then
        self.listeners[listener] = {}
    end
    self.listeners[listener][evt] = handler
end

function BaseEntity:UnregisterEvent(listener, evt)
    if not self.listeners then
        return
    end
    if not self.listeners[listener] then
        return
    end
    if evt then
        self.listeners[listener][evt] = nil
    else
        self.listeners[listener] = nil
    end
end

function BaseEntity:GetShadow()
    if Runtime.CSValid(self.shadow) then
        return self.shadow
    end

    self.cloneMask = BResource.InstantiateFromAssetName(CONST.ASSETS.G_CHRACTER_SHADOW)
    if Runtime.CSValid(self.cloneMask) then
        self.cloneMask:SetParent(self.gameObject, false)
        local size = self:GetSize() * 5
        self.cloneMask:SetLocalScale(Vector3(size, size, 0))
        self.shadow = self.cloneMask:AddComponent(typeof(BoneFollower))
        self.shadow.target = self.render
        self.shadow.bone = "Bip001/Bip001 Pelvis/Bip001 Spine"
        self.shadow.distance = -0.5
    end
    return self.shadow
end

function BaseEntity:TweenAlpha(toValue, duration)
    self.alpha = toValue
    if self.alphaTween then
        self.alphaTween:Kill()
    end
    self.tweens = {}
    self.alphaTween = {
        onComplete = nil,
        Kill = function()
            for _, tween in pairs(self.tweens) do
                tween:Kill()
            end
            self.tweens = {}
        end
    }
    local shadow = self:GetShadow()
    if Runtime.CSValid(shadow) then
        local shadowTween = GameUtil.DoFade(shadow, toValue, duration)
        table.insert(self.tweens, shadowTween)
    end
    local skins = self.render:GetComponentsInChildren(typeof(MeshRenderer))
    for i = 1, skins.Length do
        local skin = skins[i - 1]
        local skinTween = GameUtil.DoFade(skin, toValue, duration)
        table.insert(self.tweens, skinTween)
    end
    local tween = GameUtil.DoFade(self.render, toValue, duration)
    table.insert(self.tweens, tween)
    tween.onComplete = function()
        self.tweens = {}
        Runtime.InvokeCbk(self.alphaTween.onComplete)
        self.alphaTween = nil
    end
    return self.alphaTween
end

function BaseEntity:GetEntityType()
    return self.entityType
end

function BaseEntity:GetCampType()
    return self.campType
end

-- FsmStateMachine  -----------------
function BaseEntity:AddState(path)
    if not self.fsmStateMachine then
        -- 创建状态机
        self.fsmStateMachine = FsmStateMachine.new()
    end

    local state = include(path)
    local boatState = state.new(self)
    self.fsmStateMachine:Add(boatState)
end

function BaseEntity:ChangeState(toStateType, transitionData)
    if self.fsmStateMachine then
        self.fsmStateMachine:ChangeState(toStateType, transitionData)
    end
end

function BaseEntity:GetCurrentState()
    if self.fsmStateMachine then
        return self.fsmStateMachine:GetCurrentState()
    end
end

function BaseEntity:CreateFightUnit(camp)
    if not self.fightUnit then
        self.fightUnit = FightUnitEntity.new()
        self.fightUnit:SetEntity(self)
        self.fightUnit:SetCamp(camp)
        AppServices.UnitManager:AddUnit(self.fightUnit)
    end
end

function BaseEntity:PlayAnimation(animation)
    local entityGo = self:GetGameObject()
    entityGo:PlayAnim(animation)
end

function BaseEntity:GetAnimationLength(animation)
    local entityGo = self:GetGameObject()
    local length = entityGo:GetRuntimeClipLength(animation)
    return length
end

function BaseEntity:GetHp()
    if not self.alive then
        return -1
    end
    return self.data:GetHp()
end

function BaseEntity:GetMaxHp()
    if not self.alive then
        return 1
    end
    return self.data:GetMaxHp()
end

function BaseEntity:Damage(value)
    if self.alive then
        self.data:ChangeHp(value * -1)
    end
end

function BaseEntity:Cure(value)
    if self.alive then
        self.data:ChangeHp(value)
    end
end

function BaseEntity:SetDeath()
    self.alive = false
end

function BaseEntity:IsAlive()
    return self.alive
end

function BaseEntity:GetSearchDistance()
    return 0
end

function BaseEntity:ProcessClick()
end

function BaseEntity:NeedLateUpdate()
    return false
end

function BaseEntity:LateUpdate()
    if self.fsmStateMachine then
        self.fsmStateMachine:OnTick()
    end

    if self.alive and self.skillController then
        self.skillController:OnTick()
    end
end

function BaseEntity:Destroy()
    self.alive = nil
    self.data = nil
    if Runtime.CSValid(self.gameObject) then
        Runtime.CSDestroy(self.gameObject)
    end

    AppServices.UnitManager:RemoveUnit(self.fightUnit)
    self.fightUnit = nil

    self.gameObject = nil
    self.cloneMask = nil
    self.shadow = nil
    if self.alphaTween then
        self.alphaTween:Kill()
    end
end

return BaseEntity