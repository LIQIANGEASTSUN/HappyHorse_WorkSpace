---@type AttributeInfo
local AttributeInfo = require "Cleaner.Fight.AttributeModify.AttributeInfo"

---@type BuffInfo
local BuffInfo = require "Cleaner.Fight.Buff.BuffInfo"

---@type BuffEffectBase
local BuffEffectBase = require "Cleaner.Fight.Buff.Base.BuffEffectBase"

-- buff 效果：移动速度增加值
---@class BuffEffectMoveSpeedAddValue
local BuffEffectMoveSpeedAddValue = class(BuffEffectBase, "BuffEffectMoveSpeedAddValue")

function BuffEffectMoveSpeedAddValue:ctor()
    self.buffType = BuffInfo.BuffType.MoveSpeedAddValue

    self.isUse = false

    -- 还没有配置，临时值
    self.modifySpeed = 10
end

function BuffEffectMoveSpeedAddValue:GetAttribute()
    local attributeManager = self.owner:GetAttributeManager()
    local attributeBase = attributeManager:GetAttribute(AttributeInfo.Type.MoveSpeed)
    return attributeBase
end

-- buff 移除触发方法
function BuffEffectMoveSpeedAddValue:Remove()
    BuffEffectBase.Remove(self)

    -- 现在要移除 buff 了
    -- 如果这个buff 触发了，并且修改了 移动速度属性了
    -- 对移动速度属性增加值 number 做修改
    -- 通过公式重新计算 移动熟读属性值

    if not self.isUse then
        return
    end

    local attributeBase = self:GetAttribute()
    local value = self.modifySpeed * -1
    attributeBase:AddNumber(value)
end

-- 执行
function BuffEffectMoveSpeedAddValue:DoAction(data)
    BuffEffectBase.DoAction(self)

    -- 现在需要修改 移动速度属性了
    -- 对移动速度属性增加值 number 做修改
    -- 通过公式重新计算 移动熟读属性值

    if self.isUse then
        return
    end

    local attributeBase = self:GetAttribute()
    attributeBase:AddNumber(self.modifySpeed)
end

return BuffEffectMoveSpeedAddValue