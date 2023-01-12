---@type BuffInfo
local BuffInfo = require "Cleaner.Fight.Buff.BuffInfo"

---@type AttributeInfo
local AttributeInfo = require "Cleaner.Fight.AttributeModify.AttributeInfo"

-- 伤害计算控制器
---@class DamageController
local DamageController = {}

function DamageController:Damage(skill, caster, targets)
    targets = targets or {}
    for _, other in pairs(targets) do
        self:DamageTarget(skill, caster, other)
    end
end

function DamageController:DamageNoTarget(skill, caster)
    local skillId = skill:GetSkillId()
    local skillMap = {[skillId] = true}
    local fightSearchOpposed = caster:SearchOpposed()

    local targetResult = fightSearchOpposed:SearchWithFightUnit(skillMap)
    if not targetResult:IsTargetAndSkillValid() or not targetResult:TargetInAttackDistance() then
        return
    end

    self:DamageTarget(skill, caster, targetResult.other)
end

function DamageController:DamageTarget(skill, caster, other)
    local damage = skill:GetAttackPower()
    local data = { skill = skill, buff = nil, other = other}

    -- 技能攻击暂时没有区分：物理攻击、魔法攻击，后续应该得加上

    -- Begin 计算 Caster 身上的 buff 对攻击的影响 ----------------
    do
        local casterAttributeManager = caster:GetAttributeManager()
        local casterAttributeType = AttributeInfo.Type.Attack
        local casterAttributeAttack = casterAttributeManager:GetAttribute(casterAttributeType)
        local casterBuffManager = caster:GetBuffManager()
        local triggerType = BuffInfo.TriggerType.Hit

        -- 初始化攻击力
        casterAttributeAttack:Init(damage)

        -- 主动攻击时触发的buff
        casterBuffManager:Trigger(triggerType, data)
        -- 获取被修改后的攻击力
        damage = casterAttributeAttack:CalculateValue()
    end
    -- End -------------------------------------------------------

    -- Begin 计算被攻击者身上的 buff对攻击的影响 -------------------
    do
        local otherAttributeManager = other:GetAttributeManager()
        local otherAttributeType = AttributeInfo.Type.Shield
        local otherAttributeShield = otherAttributeManager:GetAttribute(otherAttributeType)
        local otherBuffManager = other:GetBuffManager()
        local triggerType = BuffInfo.TriggerType.BeHit

        -- 初始化攻击力
        otherAttributeShield:Init(damage)

        -- 被攻击时触发的buff
        otherBuffManager:Trigger(triggerType, data)
        -- 获取被修改后的攻击力
        damage = otherAttributeShield:CalculateValue()
    end
    -- End -------------------------------------------------------

    other:Damage(damage)
end

-- Buff 恢复血量百分比
function DamageController:BuffRecoverHp(caster, buff, recoverHp, other)
    other:Cure(recoverHp)
end

return DamageController