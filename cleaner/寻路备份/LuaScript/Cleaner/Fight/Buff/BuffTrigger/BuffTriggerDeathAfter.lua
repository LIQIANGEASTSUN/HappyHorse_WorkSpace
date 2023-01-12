---@type BuffInfo
local BuffInfo = require "Cleaner.Fight.Buff.BuffInfo"

---@type BuffTriggerBase
local BuffTriggerBase = require "Cleaner.Fight.Buff.BuffTrigger.Base.BuffTriggerBase"

---@class BuffTriggerDeath
local BuffTriggerDeathAfter = class(BuffTriggerBase, "BuffTriggerDeathAfter")

-- 触发类型：被攻击时

function BuffTriggerDeathAfter:ctor()
    self.triggerType = BuffInfo.TriggerType.DeathAfter
end

function BuffTriggerDeathAfter:Trigger(type)
    if type ~= self.triggerType then
        return false
    end

    return true
end

return BuffTriggerDeathAfter