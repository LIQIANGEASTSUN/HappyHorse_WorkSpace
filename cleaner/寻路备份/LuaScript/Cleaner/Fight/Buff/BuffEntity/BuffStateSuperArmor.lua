---@type BuffInfo
local BuffInfo = require "Cleaner.Fight.Buff.BuffInfo"

---@type BuffEffectBase
local BuffEffectBase = require "Cleaner.Fight.Buff.Base.BuffEffectBase"

-- buff 状态：霸体
---@class BuffStateSuperArmor
local BuffStateSuperArmor = class(BuffEffectBase, "BuffStateSuperArmor")

function BuffStateSuperArmor:ctor()
    self.buffType = BuffInfo.BuffType.SuperArmor

    self:Init()
end

function BuffStateSuperArmor:Init()

end

-- 执行
function BuffStateSuperArmor:DoAction(data)
    BuffEffectBase.DoAction(self, data)
end

return BuffStateSuperArmor