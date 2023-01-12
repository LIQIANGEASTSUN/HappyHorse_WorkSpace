---@type AttributeInfo
local AttributeInfo = require "Cleaner.Fight.AttributeModify.AttributeInfo"

---@type AttributeBase
local AttributeBase = require "Cleaner.Fight.AttributeModify.Base.AttributeBase"

-- 属性修改：移动速度属性修改
-- 移动速度属性时角色自身的一个属性值
---@class AttributeMoveSpeed
local AttributeMoveSpeed = class(AttributeBase, "AttributeMoveSpeed")

function AttributeMoveSpeed:ctor()
    self.attributeType = AttributeInfo.Type.MoveSpeed
end

function AttributeMoveSpeed:Init(speed)
    -- 攻击力
    AttributeBase.Init(self, speed)
end

return AttributeMoveSpeed