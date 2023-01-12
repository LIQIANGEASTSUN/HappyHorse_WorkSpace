---@type AttributeInfo
local AttributeInfo = require "Cleaner.Fight.AttributeModify.AttributeInfo"

---@type AttributeBase
local AttributeBase = require "Cleaner.Fight.AttributeModify.Base.AttributeBase"

-- 属性修改：攻击力属性修改
-- 攻击力属性的特殊性
-- 角色攻击力是跟着使用的技能走的，而不是角色本身有攻击力
-- 当前使用的技能有自己的攻击力
---@class AttributeAttack
local AttributeAttack = class(AttributeBase, "AttributeAttack")

function AttributeAttack:ctor()
    self.attributeType = AttributeInfo.Type.Attack
end

function AttributeAttack:Init(atk)
    -- 攻击力
    AttributeBase.Init(self, atk)
end

return AttributeAttack