---@type BuffInfo
local BuffInfo = require "Cleaner.Fight.Buff.BuffInfo"

---@type BuffEffectBase
local BuffEffectBase = require "Cleaner.Fight.Buff.Base.BuffEffectBase"

-- buff 效果：净化
---@class BuffEffectPurify
local BuffEffectPurify = class(BuffEffectBase, "BuffEffectPurify")

function BuffEffectPurify:ctor()
    self.buffType = BuffInfo.BuffType.Purify
end

-- 执行
function BuffEffectPurify:DoAction(data)
    BuffEffectBase.DoAction(self)

    self.buffManager:RemoveAllHarmfulBuff()
end

return BuffEffectPurify