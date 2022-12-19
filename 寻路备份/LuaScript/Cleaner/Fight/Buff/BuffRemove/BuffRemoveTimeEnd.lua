---@type BuffInfo
local BuffInfo = require "Cleaner.Fight.Buff.BuffInfo"

---@type BuffRemoveBase
local BuffRemoveBase = require "Cleaner.Fight.Buff.BuffRemove.Base.BuffRemoveBase"

---@class BuffRemoveTime
local BuffRemoveTimeEnd = class(BuffRemoveBase, "BuffRemoveTimeEnd")

function BuffRemoveTimeEnd:ctor()
    self.removeType = BuffInfo.RemoveType.TimeEnd

    self:Init()
end

function BuffRemoveTimeEnd:Init()
    local buffConfig = self.buff:GetBuffConfig()
    self.removeValue = buffConfig.removeValue
    self.removeTime = Time.realtimeSinceStartup + self.removeValue
end

function BuffRemoveTimeEnd:LateUpdate()
    if self.removeValue <= 0 then
        return
    end

    if Time.realtimeSinceStartup >= self.removeTime then
        self.buff:BuffNeedRemove()
    end
end

return BuffRemoveTimeEnd