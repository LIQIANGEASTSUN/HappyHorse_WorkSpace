


--[[
    ---@type BuffInfo
local BuffInfo = require "Cleaner.Fight.Buff.BuffInfo"

---@class AttributeBase
local AttributeBase = class(nil, "AttributeBase")

function AttributeBase:ctor(owner, attributeType)
    self.owner = owner
    self.attributeType = attributeType

    -- 原始属性值
    self.value = 0
    -- 记录增加数值
    self.numberMap = 0
    -- 记录增加百分比
    self.percentMap = 0
    -- 记录增加倍数
    self.multipleMap = 1
end

function AttributeBase:Init(value)
    self.value = value
    self.numberMap = {}
    self.percentMap = {}
    self.multipleMap = {}

    self.numberOnceMap = {}
    self.percentOnceMap = {}
    self.multipleOnceMap = {}
end

function AttributeBase:GetType()
    return self.attributeType
end

function AttributeBase:AddNumber(sourceKey, type, value)
    if type == BuffInfo.EffectiveType.Always then
        self.numberMap[sourceKey] = value
    elseif type == BuffInfo.EffectiveType.Once then
        self.numberOnceMap[sourceKey] = value
    end
end

function AttributeBase:RemoveNumber(sourceKey, type)
    self:AddNumber(sourceKey, type, nil)
end

function AttributeBase:AddPercent(sourceKey, type, percent)
    if type == BuffInfo.EffectiveType.Always then
        self.percentMap[sourceKey] = percent
    elseif type == BuffInfo.EffectiveType.Once then
        self.percentOnceMap[sourceKey] = percent
    end
end

function AttributeBase:RemovePercent(sourceKey, type)
    self:AddPercent(sourceKey, type, nil)
end

function AttributeBase:AddMultiple(sourceKey, type, multiple)
    if type == BuffInfo.EffectiveType.Always then
        self.multipleMap[sourceKey] = multiple
    elseif type == BuffInfo.EffectiveType.Once then
        self.multipleOnceMap[sourceKey] = multiple
    end
end

function AttributeBase:RemoveMultiple(sourceKey, type)
    self:AddMultiple(sourceKey, type, nil)
end

-- 计算公式
-- 先计算加减
-- 再计算乘百分比
-- 再计算乘倍数
function AttributeBase:CalculateValue()
    local result = self.value
    result =  self:CalculateAdd(result, self.numberMap)
    result =  self:CalculateAdd(result, self.numberOnceMap)
    self.numberOnceMap = {}

    result =  self:CalculatePercent(result, self.percentMap)
    result =  self:CalculatePercent(result, self.percentOnceMap)
    self.percentOnceMap = {}

    result = self:CalculateMultiple(result, self.multipleMap)
    result =  self:CalculateMultiple(result, self.multipleOnceMap)
    self.multipleOnceMap = {}

    return result
end

function AttributeBase:CalculateAdd(retuls, map)
    for _, number in pairs(map) do
        retuls = retuls + number
    end
    return retuls
end

function AttributeBase:CalculatePercent(result, map)
    for _, percent in pairs(map) do
        result = result * (1 + percent)
    end
    return result
end

function AttributeBase:CalculateMultiple(result, map)
    for _, multiple in pairs(map) do
        result = result * multiple
    end
    return result
end

function AttributeBase:Remove()

end

return AttributeBase
]]