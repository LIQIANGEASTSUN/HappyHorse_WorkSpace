---@type BuffBase
local BuffBase= require "Cleaner.Fight.Buff.Base.BuffBase"

---@class BuffEffectBase
local BuffStateBase = class(BuffBase, "BuffStateBase")

-- Buff 状态基类
function BuffStateBase:ctor()

end

return BuffStateBase