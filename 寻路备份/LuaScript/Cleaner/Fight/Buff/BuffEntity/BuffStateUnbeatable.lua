---@type AttributeInfo
local AttributeInfo = require "Cleaner.Fight.AttributeModify.AttributeInfo"

---@type BuffInfo
local BuffInfo = require "Cleaner.Fight.Buff.BuffInfo"

---@type BuffEffectBase
local BuffEffectBase = require "Cleaner.Fight.Buff.Base.BuffEffectBase"

-- buff 状态：无敌
---@class BuffStateUnbeatable
local BuffStateUnbeatable = class(BuffEffectBase, "BuffStateUnbeatable")

function BuffStateUnbeatable:ctor()
    self.buffType = BuffInfo.BuffType.Unbeatable
end

function BuffStateUnbeatable:GetAttribute()
    local attributeManager = self.owner:GetAttributeManager()
    local attributeBase = attributeManager:GetAttribute(AttributeInfo.Type.Shield)
    return attributeBase
end

-- buff 移除触发方法
function BuffStateUnbeatable:Remove()
    BuffEffectBase.Remove(self)
end

-- 执行
function BuffStateUnbeatable:DoAction(data)
    BuffEffectBase.DoAction(self)

    local attributeBase = self:GetAttribute()
    attributeBase:SetDisableAttack()
end

return BuffStateUnbeatable