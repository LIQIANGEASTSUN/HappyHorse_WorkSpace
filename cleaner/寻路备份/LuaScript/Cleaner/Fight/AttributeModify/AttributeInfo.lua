-- FightUnitBase 各种属性
-- 移动速度、攻击距离、搜索距离、攻击力等

---@class AttributeInfo
local AttributeInfo = {}

AttributeInfo.Type = {
    -- 无效值
    None = -1,
    -- 移动速度
    MoveSpeed = 1,
    -- 攻击力
    Attack = 2,
    -- 搜索距离
    SearchDistance = 3,
    -- 护盾属性
    Shield = 4,
}

AttributeInfo.AttributeTypes = {
    [AttributeInfo.Type.Attack] = "Cleaner.Fight.AttributeModify.Entity.AttributeAttack",
    [AttributeInfo.Type.MoveSpeed] = "Cleaner.Fight.AttributeModify.Entity.AttributeMoveSpeed",
    [AttributeInfo.Type.Shield] = "Cleaner.Fight.AttributeModify.Entity.AttributeShield",
}

AttributeInfo.GetAttributeAlias = function(type)
    local path = AttributeInfo.AttributeTypes[type]
    local attribute = include(path)
    return attribute
end

return AttributeInfo