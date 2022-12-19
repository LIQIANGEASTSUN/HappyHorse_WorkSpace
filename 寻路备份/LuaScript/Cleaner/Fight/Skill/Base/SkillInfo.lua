---@class SkillInfo
local SkillInfo = {}

-- 技能类型
SkillInfo.SkillType = {
    -- 普通攻击
    General = 1,
}

-- 技能配置
SkillInfo.Skills = {
    [SkillInfo.SkillType.General] = "Cleaner.Fight.Skill.SkillGeneral",
}

SkillInfo.GetSkillAlias = function(type)
    local path = SkillInfo.Skills[type]
    local skill = include(path)
    return skill
end

return SkillInfo