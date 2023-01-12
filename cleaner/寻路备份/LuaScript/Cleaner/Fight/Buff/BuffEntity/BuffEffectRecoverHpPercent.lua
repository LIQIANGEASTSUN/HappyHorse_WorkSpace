---@type BuffInfo
local BuffInfo = require "Cleaner.Fight.Buff.BuffInfo"

---@type BuffEffectBase
local BuffEffectBase = require "Cleaner.Fight.Buff.Base.BuffEffectBase"

-- buff 效果：恢复血量百分比
---@class BuffEffectRecoverHpPercent
local BuffEffectRecoverHpPercent = class(BuffEffectBase, "BuffEffectRecoverHpPercent")

function BuffEffectRecoverHpPercent:ctor()
    self.buffType = BuffInfo.BuffType.RecoverHpPercent
end

-- 执行
function BuffEffectRecoverHpPercent:DoAction(data)
    BuffEffectBase.DoAction(self)

    local results = self:SearchCampAttackType(self.buffConfig.range)
    local percent = self.buffConfig.buffValue[1]

    for _, other in pairs(results) do
        local recoverHp = percent * other:GetMaxHp()
        AppServices.DamageController:BuffRecoverHp(self.owner, self, recoverHp, other)
    end
end

function BuffEffectRecoverHpPercent:LateUpdate()
    BuffEffectBase.LateUpdate(self)
end

return BuffEffectRecoverHpPercent