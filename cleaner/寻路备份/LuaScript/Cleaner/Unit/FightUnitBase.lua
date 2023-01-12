---@type SkillController
local SkillController = require "Cleaner.Fight.Skill.SkillController"

---@type FightSearchOpposed
local FightSearchOpposed = require "Cleaner.Fight.SearchOpposed.FightSearchOpposed"

---@type SkillController
local BuffManager = require "Cleaner.Fight.Buff.BuffManager"

---@type AttributeManager
local AttributeManager =  require "Cleaner.Fight.AttributeModify.AttributeManager"

--@type UnitBase
local UnitBase = require "Cleaner.Unit.Base.UnitBase"

---@class FightUnitBase
local FightUnitBase = class(UnitBase, "FightUnitBase")

function FightUnitBase:ctor()
    ---@type SkillController
    self.skillController = nil
    ---@type FightSearchOpposed
    self.fightSearchOpposed  = nil
    ---@type BuffManager
    self.buffManager = BuffManager.new(self)
    ---@type AttributeManager
    self.attributeManager = AttributeManager.new(self)

    self.damageHpType = 1

    self:SetUnitType(UnitType.FightUnit)
    self:SetUseUpdate(true)
    self:Init()
end

function FightUnitBase:Init()
    self.attributeManager:Init()
end

function FightUnitBase:SetCamp(camp)
    self.camp = camp
end

function FightUnitBase:GetCamp()
    return self.camp
end

function FightUnitBase:SetDamageHpType(hpType)
    self.damageHpType = hpType
end

function FightUnitBase:AddSkill(skills)
    self:SkillController()
    self.skillController:AddSkills(skills)
end

function FightUnitBase:ClearSkill()
    if self.skillController then
        self.skillController:ClearSkill()
    end
end

function FightUnitBase:SearchOpposed()
    if not self.fightSearchOpposed then
        self.fightSearchOpposed = FightSearchOpposed.new(self)
        local searchDistance = self:GetSearchDistance()
        self.fightSearchOpposed:SetSearchDistance(searchDistance)
    end
    return self.fightSearchOpposed
end

function FightUnitBase:SkillController()
    if not self.skillController then
        self.skillController = SkillController.new(self)
    end
    return self.skillController
end

function FightUnitBase:GetBuffManager()
    return self.buffManager
end

function FightUnitBase:ClearBuff()
    self.buffManager:ClearBuff()
end

function FightUnitBase:GetAttributeManager()
    return self.attributeManager
end

function FightUnitBase:GetPosition()
    return Vector3(0, 0, 0)
end

function FightUnitBase:GetTransform()
    return nil
end

function FightUnitBase:IsAlive()
    return true
end

function FightUnitBase:PlayAnimation(animation)

end

function FightUnitBase:GetAnimationLength(animation)
    return 1
end

-- 伤害
function FightUnitBase:Damage(damage)

end

-- 治疗
function FightUnitBase:Cure(value)

end

function FightUnitBase:GetMaxHp()
    return 1
end

function FightUnitBase:GetHp()
    return 1
end

function FightUnitBase:GetLevel()
    return 1
end

function FightUnitBase:GetAttribute()
    return -1
end

function FightUnitBase:GetSearchDistance()
    return 0
end

function FightUnitBase:EnableAttack()
    return true
end

function FightUnitBase:NotifyHp(changeValue, type, show)
    local data = {
        changeValue = changeValue,
    }

    local instanceId = self:GetInstanceId()
    if not self:IsAlive() then
        AppServices.UnitTipsManager:RemoveTipsAll(instanceId)
        return
    end

    -- AppServices.EventDispatcher:dispatchEvent(HP_INFO_EVENT.HP_INFO, data)
    if show then
        AppServices.UnitTipsManager:ShowTips(instanceId, type, data)
    else
        AppServices.UnitTipsManager:HideTips(instanceId, type)
    end
end

function FightUnitBase:LateUpdate()
    if not self:IsAlive() then
        return
    end

    if self.skillController then
        self.skillController:OnTick()
    end

    if self.buffManager then
        self.buffManager:LateUpdate()
    end
end

function FightUnitBase:Remove()
    --AppServices.EventDispatcher:dispatchEvent(HP_INFO_EVENT.HP_DESTROY, self.instanceId)

    local instanceId = self:GetInstanceId()
    AppServices.UnitTipsManager:RemoveTipsAll(instanceId)
end

return FightUnitBase