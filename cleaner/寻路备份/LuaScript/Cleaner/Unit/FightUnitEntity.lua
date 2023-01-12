--@type FightUnitBase
local FightUnitBase = require "Cleaner.Unit.FightUnitBase"

---@class FightUnitEntity
local FightUnitEntity = class(FightUnitBase, "FightUnitEntity")

function FightUnitEntity:ctor()
    self.entity = nil
end

function FightUnitEntity:SetEntity(entity)
    self.entity = entity
end

function FightUnitEntity:GetPosition()
    return self.entity:GetPosition()
end

function FightUnitEntity:GetTransform()
    return self.entity:GetGameObject().transform
end

function FightUnitEntity:IsAlive()
    return self.entity:IsAlive()
end

function FightUnitEntity:PlayAnimation(animation)
    if animation and animation ~= "" then
        self.entity:PlayAnimation(animation)
    end
end

function FightUnitEntity:GetAnimationLength(animation)
    return self.entity:GetAnimationLength(animation)
end

function FightUnitEntity:Damage(damage)
    self.entity:Damage(damage)
    self:NotifyHp(damage * -1, self.damageHpType, true)
end

-- 治疗
function FightUnitEntity:Cure(value)
    self.entity:Cure(value)
    self:NotifyHp(value, self.damageHpType, true)
end

function FightUnitEntity:GetMaxHp()
    return self.entity:GetMaxHp()
end

function FightUnitEntity:GetHp()
    return self.entity:GetHp()
end

function FightUnitEntity:GetLevel()
    return self.entity.data.meta.level
end

function FightUnitEntity:GetAttribute()
    return self.entity.data:GetAtrribute()
end

function FightUnitEntity:EnableAttack()
    if not self:IsAlive() then
        return false
    end
    return true
end

function FightUnitEntity:GetSearchDistance()
    return self.entity:GetSearchDistance()
end

return FightUnitEntity