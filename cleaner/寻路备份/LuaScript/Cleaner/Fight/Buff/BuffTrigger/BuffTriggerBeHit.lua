---@type BuffInfo
local BuffInfo = require "Cleaner.Fight.Buff.BuffInfo"

---@type BuffTriggerBase
local BuffTriggerBase = require "Cleaner.Fight.Buff.BuffTrigger.Base.BuffTriggerBase"

---@class BuffTriggerBeHit
local BuffTriggerBeHit = class(BuffTriggerBase, "BuffTriggerBeHit")

-- 触发类型：被攻击时

function BuffTriggerBeHit:ctor()
    self.triggerType = BuffInfo.TriggerType.BeHit
end

function BuffTriggerBeHit:Trigger(type)
    if type ~= self.triggerType then
        return false
    end

    return true
end

return BuffTriggerBeHit