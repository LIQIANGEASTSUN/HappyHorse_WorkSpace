---@class IDelegate
local IDelegate = class()

local function SafeInvoke(func, ...)
    if type(func) == "function" then
        return func(...)
    end
end

function IDelegate:ctor(delegate, name)
    self.name = name or "unknow"
    self.delegate = delegate
    self.executions = {}
    self.startAppTime = TimeUtil.ServerTime()
    self:InitEvent()
end

function IDelegate:InitEvent()
end

function IDelegate:RegisterEvent(eventName, excution)
    self.executions[eventName] = excution
end

function IDelegate:HandleEvent(eventName, ...)
end

function IDelegate:TriggerEvent(eventName, ...)
    local excution = self.executions[eventName]
    SafeInvoke(excution, self, ...)
end

return IDelegate
