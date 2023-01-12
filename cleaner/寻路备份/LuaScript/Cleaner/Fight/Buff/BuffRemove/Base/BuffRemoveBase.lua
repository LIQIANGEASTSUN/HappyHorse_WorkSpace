---@type BuffInfo
local BuffInfo = require "Cleaner.Fight.Buff.BuffInfo"

---@class BuffRemoveBase
local BuffRemoveBase = class(nil, "BuffRemoveBase")

function BuffRemoveBase:ctor(buff)
    self.buff = buff
    self.removeType = BuffInfo.RemoveType.None
end

function BuffRemoveBase:DoAction()

end

function BuffRemoveBase:LateUpdate()

end

return BuffRemoveBase