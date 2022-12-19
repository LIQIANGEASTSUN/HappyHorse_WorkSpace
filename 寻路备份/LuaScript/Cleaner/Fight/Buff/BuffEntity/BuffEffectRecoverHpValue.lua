---@type BuffInfo
local BuffInfo = require "Cleaner.Fight.Buff.BuffInfo"

---@type BuffEffectBase
local BuffEffectBase = require "Cleaner.Fight.Buff.Base.BuffEffectBase"

-- buff 效果：恢复血量固定值
---@class BuffEffectRecoverHpValue
local BuffEffectRecoverHpValue = class(BuffEffectBase, "BuffEffectRecoverHpValue")

function BuffEffectRecoverHpValue:ctor()
    self.buffType = BuffInfo.BuffType.RecoverHpValue
end

-- 执行
function BuffEffectRecoverHpValue:DoAction(data)
    BuffEffectBase.DoAction(self)

    local results = self:SearchCampAttackType(self.buffConfig.range)
    local addValue = self.buffConfig.buffValue[1]
    for _, other in pairs(results) do
        AppServices.DamageController:BuffRecoverHp(self.owner, self, addValue, other)
    end
end

function BuffEffectRecoverHpValue:LateUpdate()
    BuffEffectBase.LateUpdate(self)
end

return BuffEffectRecoverHpValue