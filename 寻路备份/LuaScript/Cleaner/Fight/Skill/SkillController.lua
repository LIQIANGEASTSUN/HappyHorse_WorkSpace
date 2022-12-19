---@type SkillInfo
local SkillInfo = require "Cleaner.Fight.Skill.Base.SkillInfo"

---@class SkillController
local SkillController = class(nil, "SkillController")

function SkillController:ctor(fightUnit)
    ---@type Dictionary<int, SkillBase>
    self.skills = {}
    self.fightUnit = fightUnit
end

function SkillController:AddSkill(skillId)
    local skillAlias = SkillInfo.GetSkillAlias(SkillInfo.SkillType.General)
    local skillInstance = skillAlias.new(skillId, self.fightUnit)
    self.skills[skillId] = skillInstance
end

function SkillController:AddSkills(skillIds)
    for _, skillId in pairs(skillIds) do
        self:AddSkill(skillId)
    end
end

function SkillController:ClearSkill()
    for _, skill in pairs(self.skills) do
        skill:Clear()
    end
    self.skills = {}
end

function SkillController:GetSkill(skillId)
    return self.skills[skillId]
end

function SkillController:GetAllSkillID()
    local list = {}
    for _, skill in pairs(self.skills) do
        local skillId = skill:GetSkillId()
        table.insert(list, skillId)
    end
    return list
end

function SkillController:IsValidCampRelation(other)
    local list = {}
    for _, skill in pairs(self.skills) do
        local result = skill:IsValidCampRelation(other)
        if result then
            local skillId = skill:GetSkillId()
            table.insert(list, skillId)
        end
    end
    return list
end

function SkillController:EnableUse(skillId)
    local skill = self:GetSkill(skillId)
    return skill:EnableUse()
end

function SkillController:OnTick()
    for _, skill in pairs(self.skills) do
        skill:OnTick()
    end
end

function SkillController:Fire(skillId, targets)
    local skill = self:GetSkill(skillId)
    skill:Fire(targets)
end

function SkillController:FireNoTarget(skillId)
    local skill = self:GetSkill(skillId)
    skill:FireNoTarget()
end

return SkillController