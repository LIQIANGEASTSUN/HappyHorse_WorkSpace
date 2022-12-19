---@type BuffInfo
local BuffInfo = require "Cleaner.Fight.Buff.BuffInfo"

---@type BuffTriggerBase
local BuffTriggerBase = require "Cleaner.Fight.Buff.BuffTrigger.Base.BuffTriggerBase"

---@class BuffTriggerTimeInterval
local BuffTriggerTimeInterval = class(BuffTriggerBase, "BuffTriggerTimeInterval")

-- 触发类型：时间间隔

function BuffTriggerTimeInterval:ctor()
    self.triggerType = BuffInfo.TriggerType.TimeInterval
    self.triggerTime = -1

    self:Init()
end

function BuffTriggerTimeInterval:Init()
    local buffConfig = self.buff:GetBuffConfig()
    local dotValue = buffConfig.dotValue
    self.excuteInZeroTime = dotValue[1]
    self.interval = dotValue[2]
end

function BuffTriggerTimeInterval:Trigger(type)
    if type ~= self.triggerType then
        return false
    end

    local value = (Time.realtimeSinceStartup - self.triggerTime) >= self.interval
    if value then
        self.triggerTime = Time.realtimeSinceStartup
    end
    return value
end

function BuffTriggerTimeInterval:LateUpdate()

end

return BuffTriggerTimeInterval