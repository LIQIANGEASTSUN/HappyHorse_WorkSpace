---@type BuffBase
local BuffBase= require "Cleaner.Fight.Buff.Base.BuffBase"

---@class BuffEffectBase
local BuffEffectBase = class(BuffBase, "BuffEffectBase")

-- Buff 效果基类
function BuffEffectBase:ctor()

end

return BuffEffectBase