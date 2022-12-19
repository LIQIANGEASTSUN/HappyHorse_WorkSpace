---@type BuffInfo
local BuffInfo = require "Cleaner.Fight.Buff.BuffInfo"

---@class BuffTriggerBase
local BuffTriggerBase = class(nil, "BuffTriggerBase")

-- Buff 生效/执行 基类

function BuffTriggerBase:ctor(buff)
    self.buff = buff
    self.triggerType = BuffInfo.TriggerType.None
end

function BuffTriggerBase:GetTriggerType()
    return self.triggerType
end

function BuffTriggerBase:Trigger(type)
    if type ~= self.triggerType then
        return false
    end

    return false
end

return BuffTriggerBase