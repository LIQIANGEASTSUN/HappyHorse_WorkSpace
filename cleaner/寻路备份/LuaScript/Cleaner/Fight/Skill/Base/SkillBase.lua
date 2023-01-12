---@type EffectManager
local EffectManager = require "Cleaner.Effect.EffectManager"

---@class SkillBase
local SkillBase = class(nil, "SkillBase")

function SkillBase:ctor(skillId, fightUnit)
    self.skillId = skillId
    self.fightUnit = fightUnit

    local config = AppServices.Meta:Category("SkillTemplate")
    self.meta = config[tostring(self.skillId)]

    -- 技能攻击阵营关系
    self.campRelation = self.meta.camp
    -- 技能时长：临时这么用
    self.skillTime = 0.5 -- self.meta.attackCd
    --console.error("SkillBase:"..skillId)
    -- 正在使用中
    self.activate = false
    -- 记录每次攻击时的时间
    self.fireTime = 0

    self.targetSprites = {}
end

function SkillBase:GetSkillId()
    return self.skillId
end

function SkillBase:GetAttackPower()
    return self.meta.attackPower
end

function SkillBase:GetAttackDistance()
    return self.meta.attackDistance
end

function SkillBase:GetCD()
    return self.meta.attackCd
end

function SkillBase:AttackAnimation()
    return self.meta.attackAni
end

function SkillBase:AttackEffect()
    return self.meta.AttackEffect
end

function SkillBase:IsCollDown()
    local cd = self:GetCD()
    return (Time.realtimeSinceStartup - self.fireTime) < cd
end

function SkillBase:IsValidCampRelation(other)
    local selfCamp = self.fightUnit:GetCamp()
    local otherCamp = other:GetCamp()
    local isSelf = self.fightUnit:GetInstanceId() == other:GetInstanceId()
    return CampType.IsValidCampRelation(self.campRelation, selfCamp, otherCamp, isSelf)
end

function SkillBase:IsActivate()
    return self.activate
end

function SkillBase:EnableUse()
    -- CD 中
    if self:IsCollDown() then
        return false
    end

    -- 正在使用中
    if self:IsActivate() then
        return false
    end

    return true
end

function SkillBase:Fire(targetSprites)
    self.targetSprites = targetSprites
    self.fireTime = Time.realtimeSinceStartup
    self.activate = true
    AppServices.DamageController:Damage(self, self.fightUnit, targetSprites)
    self:PlayEffect()
    self:PlayAnimation()
end

function SkillBase:FireNoTarget()
    local skillId = self:GetSkillId()
    local skillMap = {[skillId] = true}
    local fightSearchOpposed = self.fightUnit:SearchOpposed()

    local targetResult = fightSearchOpposed:SearchWithFightUnit(skillMap)
    if targetResult:IsTargetAndSkillValid() and targetResult:TargetInAttackDistance() then
        local targets = { targetResult.other }
        self:Fire(targets)
    end
end

function SkillBase:OnTick()
    if self:IsActivate() then
        self:CheckSkillTime()
    end
end

function SkillBase:SkillEnd()
    self.activate = false
    self:PlayIdle()
end

function SkillBase:CheckSkillTime()
    if Time.realtimeSinceStartup - self.fireTime > self.skillTime then
        self:SkillEnd()
    end
end

function SkillBase:PlayAnimation()
    local animation = self:AttackAnimation()
    if animation and animation ~= "" then
        self.fightUnit:PlayAnimation(animation, 0.1)
    end
    self.attackAnimationTime = self.fightUnit:GetAnimationLength(animation)
    self.skillTime = self.attackAnimationTime
end

function SkillBase:PlayIdle()
    self.fightUnit:PlayAnimation(EntityAnimationName.Idle_A)
end

function SkillBase:PlayEffect()
    local effectName = self:AttackEffect()

    if not self.targetSprites or #self.targetSprites<= 0 then
        self:PlayTargetEffect(self.fightUnit, effectName)
        return
    end

    for _, other in pairs(self.targetSprites) do
        self:PlayTargetEffect(other, effectName)
    end
end

function SkillBase:PlayTargetEffect(sprite, effectName)
    local position = sprite:GetPosition()
    position.y = position.y + 0.8

    EffectManager:Play(effectName, position)
end

function SkillBase:Clear()

end

return SkillBase