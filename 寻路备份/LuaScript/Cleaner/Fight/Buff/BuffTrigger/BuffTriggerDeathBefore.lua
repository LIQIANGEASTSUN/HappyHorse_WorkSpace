---@type BuffInfo
local BuffInfo = require "Cleaner.Fight.Buff.BuffInfo"

---@type BuffTriggerBase
local BuffTriggerBase = require "Cleaner.Fight.Buff.BuffTrigger.Base.BuffTriggerBase"

---@class BuffTriggerDeath
local BuffTriggerDeathBefore = class(BuffTriggerBase, "BuffTriggerDeathBefore")

-- 触发类型：被攻击时

function BuffTriggerDeathBefore:ctor()
    self.triggerType = BuffInfo.TriggerType.DeathBefore
end

function BuffTriggerDeathBefore:Trigger(type)
    if type ~= self.triggerType then
        return false
    end

    return true
end

return BuffTriggerDeathBefore