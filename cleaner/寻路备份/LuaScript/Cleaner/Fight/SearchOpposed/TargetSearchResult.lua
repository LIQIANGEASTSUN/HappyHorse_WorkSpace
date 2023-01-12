---@class TargetSearchResult
local TargetSearchResult = class(nil, "TargetSearchResult")
--- 搜索结果

function TargetSearchResult:ctor(fightUnit)
    -- 己方 FightUnitBase
    ---@type BaseEntity
    self.fightUnit = fightUnit

    -- 搜索到的 FightUnitBase
    ---@type FightUnitBase
    self.other = nil

    -- 根据技能搜索时，可以使用的技能
    self.skillId = 0

    self.spriteDistance = 0
end

function TargetSearchResult:IsTargetValid()
    return nil ~= self.other
end

function TargetSearchResult:IsSkillValie()
    return (self.skillId > 0)
end

function TargetSearchResult:IsTargetAndSkillValid()
    if not self:IsTargetValid() then
        return false
    end

    if not self:IsSkillValie() then
        return false
    end
    return true
end

function TargetSearchResult:GetSkill()
    local skillController = self.fightUnit:SkillController()
    local skill = skillController:GetSkill(self.skillId)
    return skill
end

-- 攻击距离
function TargetSearchResult:GetAttackDistance()
    local skill = self:GetSkill()
    local attackDistance = skill:GetAttackDistance()
    return attackDistance
end

function TargetSearchResult:OffsetPosition()
    local selfPos = self.fightUnit:GetPosition()
    selfPos.y = 0
    local otherPos = self.other:GetPosition()
    otherPos.y = 0
    local offset = otherPos - selfPos

    -- 返回距离
    -- 返回从 self.fightUnit 指向 self.other 坐标的单位向量
    return offset.magnitude, offset.normalized
end

-- 目标在攻击距离范围内
function TargetSearchResult:TargetInAttackDistance()
    if not self:IsTargetValid() or not self:IsSkillValie() then
        return false
    end

    local distance = self:OffsetPosition()
    local attackDistance = self:GetAttackDistance()
    return attackDistance >= distance
end

-- 距离 self.fightUnit 最近的能攻击到 self.other 的坐标
function TargetSearchResult:NearestAttackPosition()
    if not self:IsTargetValid() or not self:IsSkillValie() then
        return self.fightUnit:GetPosition()
    end

    local distance, toOthernormalized = self:OffsetPosition()
    local attackDistance = self:GetAttackDistance()

    local destination = self.fightUnit:GetPosition()
    if attackDistance < distance then
        destination = destination + toOthernormalized * (distance - attackDistance + 0.3)
    end

    return destination
end

return TargetSearchResult