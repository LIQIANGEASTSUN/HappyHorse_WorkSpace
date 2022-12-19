---@type AttributeInfo
local AttributeInfo = require "Cleaner.Fight.AttributeModify.AttributeInfo"

---@class AttributeManager
local AttributeManager = class(nil, "AttributeManager")

function AttributeManager:ctor(owner)
    ---@type FightUnitBase
    self.owner = owner

    self.attributeMap = {}
end

function AttributeManager:Init()
    self:CreateAttribute()
end

function AttributeManager:GetAttribute(type)
    return self.attributeMap[type]
end

function AttributeManager:CreateAttribute()
    local attributes = AttributeInfo.AttributeTypes
    for type, _ in pairs(attributes) do
        local attributeAlias = AttributeInfo.GetAttributeAlias(type)
        local attribute = attributeAlias.new(self.owner)
        attribute:Init()
        self.attributeMap[type] = attribute
    end
end

return AttributeManager