---@type AttributeInfo
local AttributeInfo = require "Cleaner.Fight.AttributeModify.AttributeInfo"

---@type BuffInfo
local BuffInfo = require "Cleaner.Fight.Buff.BuffInfo"

---@type BuffEffectBase
local BuffEffectBase = require "Cleaner.Fight.Buff.Base.BuffEffectBase"

-- buff 效果：属性克制物理伤害倍数
---@class BuffEffectRestraintPhysicsHarmMultiple
local BuffEffectRestraintPhysicsHarmMultiple = class(BuffEffectBase, "BuffEffectRestraintPhysicsHarmMultiple")

function BuffEffectRestraintPhysicsHarmMultiple:ctor()
    self.buffType = BuffInfo.BuffType.RestraintPhysicsHarmMultiple

    self:Init()
end

function BuffEffectRestraintPhysicsHarmMultiple:Init()
    -- 克制属性
    self.restraintProperty = self.buffConfig.buffValue[1]
    -- 伤害倍数
    self.selfharmMultiples = self.buffConfig.buffValue[2]
end

-- 执行
function BuffEffectRestraintPhysicsHarmMultiple:DoAction(data)
    BuffEffectBase.DoAction(self, data)

    local other = data.other
    if not data or not other then
        return
    end

    local campRelation = self.buffConfig.camp

    local selfCamp = self.owner:GetCamp()
    local otherCamp = other:GetCamp()
    local isSelf = self.owner:GetInstanceId() == other:GetInstanceId()
    -- buff 作用的阵营关系
    local value = CampType.IsValidCampRelation(campRelation, selfCamp, otherCamp, isSelf)
    if not value then
        return
    end

    -- 克制的属性
    local otherAttribute = other:GetAttribute()
    if self.restraintProperty ~= otherAttribute then
        return
    end

    local attributeManager = self.owner:GetAttributeManager()
    local attributeBase = attributeManager:GetAttribute(AttributeInfo.Type.Attack)
    if not attributeBase then
        return
    end
    attributeBase:AddMultiple(self.selfharmMultiples)
end

return BuffEffectRestraintPhysicsHarmMultiple