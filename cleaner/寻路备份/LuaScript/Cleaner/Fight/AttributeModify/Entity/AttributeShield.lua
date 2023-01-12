---@type AttributeInfo
local AttributeInfo = require "Cleaner.Fight.AttributeModify.AttributeInfo"

---@type AttributeBase
local AttributeBase = require "Cleaner.Fight.AttributeModify.Base.AttributeBase"

-- 属性修改：护盾属性修改
-- 被攻击时削减对方的攻击力
---@class AttributeShield
local AttributeShield = class(AttributeBase, "AttributeShield")

function AttributeShield:ctor()
    self.attributeType = AttributeInfo.Type.Shield
    self.enableAttack = true
end

function AttributeShield:Init(atk)
    -- 攻击力
    AttributeBase.Init(self, atk)
    self.enableAttack = true
end

function AttributeShield:GetType()
    return self.attributeType
end

-- 设置不能攻击
function AttributeShield:SetDisableAttack()
    self.enableAttack = false
end

function AttributeShield:EnableAttack()
    return self.enableAttack
end

-- 计算公式，护盾是减伤
function AttributeShield:CalculateValue()
    self.result = self.value
    self.result = self.result - self.number                 -- 攻击力抵挡固定值
    self.result = self.result - self.result * self.percent  -- 攻击力减少百分比
    self.result = self.result * self.multiple               -- 攻击力减少为多少倍 (如 0.3 倍)

    return self.result
end

return AttributeShield