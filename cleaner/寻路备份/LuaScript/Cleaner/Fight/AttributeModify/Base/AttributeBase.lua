---@type AttributeInfo
local AttributeInfo = require "Cleaner.Fight.AttributeModify.AttributeInfo"

---@class AttributeBase
local AttributeBase = class(nil, "AttributeBase")

function AttributeBase:ctor(owner)
    self.owner = owner
    self.attributeType = AttributeInfo.Type.None

    -- 原始属性值
    self.value = 0
    -- 记录增加数值
    self.number = 0
    -- 记录增加百分比
    self.percent = 0
    -- 记录增加倍数
    self.multiple = 1

    -- 公式计算出来的结果
    self.result = self.value
end

function AttributeBase:Init(value)
    self.value = value
    self.number = 0
    self.percent = 0
    self.multiple = 1
end

function AttributeBase:GetType()
    return self.attributeType
end

function AttributeBase:AddNumber(value)
    self.number = self.number + value
    self:CalculateValue()
end

function AttributeBase:AddPercent(percent)
    self.percent = self.percent + percent
    self:CalculateValue()
end

function AttributeBase:AddMultiple(multiple)
    self.multiple = self.multiple * multiple
    self:CalculateValue()
end

function AttributeBase:GetResult()
    return self.result
end

-- 计算公式
function AttributeBase:CalculateValue()
    self.result = self.value
    self.result = self.result + self.number
    self.result = self.result + self.result * self.percent
    self.result = self.result * self.multiple

    return self.result
end

return AttributeBase