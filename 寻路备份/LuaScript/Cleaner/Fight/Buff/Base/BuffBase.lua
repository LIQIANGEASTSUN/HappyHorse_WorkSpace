---@type EffectManager
local EffectManager = require "Cleaner.Effect.EffectManager"

---@type BuffInfo
local BuffInfo = require "Cleaner.Fight.Buff.BuffInfo"

---@class BuffBase
local BuffBase = class(nil, "BuffBase")

-- Buff 基类
function BuffBase:ctor(instanceId, buffManager, buffId, casterData)
    self.instanceId = instanceId
    self.buffManager = buffManager
    self.buffId = buffId
    -- 是挂在谁身上的
    ---@type FightUnitBase
    self.owner = buffManager:GetOwner()

    -- 施加者
    ---@type FightUnitBase
    self.caster = casterData.caster
    -- 施加者 技能ID
    self.casterSkillId = casterData.casterSkillId
    -- 施加者 buffId
    self.casterBuffId = casterData.casterBuffId

    self.buffType = BuffInfo.BuffType.None

    -- buff 层
    self.layer = 1

    self.buffConfig = AppServices.Meta:Category("BuffTemplate")[self.buffId]

    -- buff 生效触发器
    ---@type BuffTriggerBase
    self.triggerEntity = nil
    -- buff 移除逻辑
    ---@type BuffRemoveBase
    self.buffRemoveEntity = nil

    self:CreateTrigger()
    self:CreateRemoveEntity()
    self:PlayEffect()
end

function BuffBase:GetInstanceId()
    return self.instanceId
end

function BuffBase:GetBuffId()
    return self.buffId
end

function BuffBase:GetBuffConfig()
    return self.buffConfig
end

function BuffBase:GetBuffAdvantage()
    return self.buffConfig.advantage
end

function BuffBase:GetLayer()
    return self.layer
end

function BuffBase:AddLayer(value)
    self.layer = self.layer + value
end

function BuffBase:EnableAddBuff(buffId)
    return true
end

-- 矛盾点，要不要加入到 BuffInfo.TriggerType
-- buff 添加时触发
function BuffBase:Applay()
    self:Trigger(BuffInfo.TriggerType.Apply)
end

-- 矛盾点，要不要加入到 BuffInfo.TriggerType
-- buff 叠加层时触发方法
function BuffBase:Superposition()

end

-- 矛盾点，要不要加入到 BuffInfo.TriggerType
-- buff 移除触发方法
function BuffBase:Remove()
    self:Trigger(BuffInfo.TriggerType.Remove)
end

-- Trigger -------------------------------------
function BuffBase:CreateTrigger()
    local triggerType = self.buffConfig.triggerCondition
    local triggerAlias = BuffInfo.GetTriggerAlias(triggerType)
    self.triggerEntity = triggerAlias.new(self)
end

function BuffBase:CreateRemoveEntity()
    local removeType = self.buffConfig.removeType
    local removeAlias = BuffInfo.GetRemoveAlias(removeType)
    self.buffRemoveEntity = removeAlias.new(self)
end

function BuffBase:Trigger(type, data)
    if not self.triggerEntity or type ~= self.triggerEntity:GetTriggerType() then
        return false
    end

    local result = self.triggerEntity:Trigger(type)
    if result then
        self:DoAction(data)
    end

    return result
end

-- 执行
function BuffBase:DoAction(data)
    self.buffRemoveEntity:DoAction()
end

function BuffBase:LateUpdate()
    self:Trigger(BuffInfo.TriggerType.TimeInterval)
    self.buffRemoveEntity:LateUpdate()
end

function BuffBase:BuffNeedRemove()
    self.buffManager:Remove()
end

function BuffBase:PlayEffect()
    local effectName = self.buffConfig.effect

    local position = self.owner:GetPosition()
    position.y = position.y + 0.1

    EffectManager:Play(effectName, position)
end

function BuffBase:SearchCampAttackType(distance)
    local campRelation = self.buffConfig.camp
    if campRelation == CampType.CampRelation.Self then
        return self.owner
    end

    local searchOpposed = self.owner:SearchOpposed()
    local results = searchOpposed:SearchCamp(campRelation, distance)
    return results
end

return BuffBase