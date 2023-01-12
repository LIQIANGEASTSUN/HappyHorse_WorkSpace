---@type SkillBase
local SkillBase = require "Cleaner.Fight.Skill.Base.SkillBase"

---@class SkillGeneral
local SkillGeneral = class(SkillBase, "SkillGeneral")

function SkillGeneral:ctor()
    --console.error("SkillGeneral:ctor:"..skillId)
end

function SkillGeneral:OnTick()
    SkillBase.OnTick(self)
end

function SkillGeneral:Fire(targets)
    SkillBase.Fire(self, targets)
end

function SkillGeneral:SkillEnd()
    SkillBase.SkillEnd(self)
    --self.entity:PlayAnimation(EntityAnimationName.Idle_A)
end

function SkillGeneral:Clear()
    SkillBase.Clear(self)
end

return SkillGeneral