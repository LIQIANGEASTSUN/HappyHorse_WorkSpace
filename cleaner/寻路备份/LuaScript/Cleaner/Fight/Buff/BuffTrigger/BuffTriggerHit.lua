---@type BuffInfo
local BuffInfo = require "Cleaner.Fight.Buff.BuffInfo"

---@type BuffTriggerBase
local BuffTriggerBase = require "Cleaner.Fight.Buff.BuffTrigger.Base.BuffTriggerBase"

---@class BuffTriggerHit
local BuffTriggerHit = class(BuffTriggerBase, "BuffTriggerHit")

-- 触发类型：主动攻击

function BuffTriggerHit:ctor()
    self.triggerType = BuffInfo.TriggerType.Hit
end

function BuffTriggerHit:Trigger(type)
    if type ~= self.triggerType then
        return false
    end

    return true
end

return BuffTriggerHit