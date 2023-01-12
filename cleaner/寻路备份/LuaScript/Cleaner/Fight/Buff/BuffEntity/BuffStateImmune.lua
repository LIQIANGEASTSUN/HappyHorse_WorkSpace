---@type BuffInfo
local BuffInfo = require "Cleaner.Fight.Buff.BuffInfo"

---@type BuffEffectBase
local BuffEffectBase = require "Cleaner.Fight.Buff.Base.BuffEffectBase"

-- buff 状态：免疫
---@class BuffStateImmune
local BuffStateImmune = class(BuffEffectBase, "BuffStateImmune")

function BuffStateImmune:ctor()
    self.buffType = BuffInfo.BuffType.SuperArmor

    self:Init()
end

function BuffStateImmune:Init()

end

function BuffStateImmune:EnableAddBuff(buffId)
    local buffConfig = AppServices.Meta:Category("BuffTemplate")[buffId]
    local advantage = buffConfig.advantage
    if advantage == BuffInfo.AdvantageType.Helpful then
        return true
    elseif advantage == BuffInfo.AdvantageType.Harmful then
        return false
    end
    return false
end

-- 执行
function BuffStateImmune:DoAction(data)
    BuffEffectBase.DoAction(self, data)
end

return BuffStateImmune