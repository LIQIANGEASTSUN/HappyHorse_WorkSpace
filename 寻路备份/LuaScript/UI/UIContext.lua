local Context = class()

function Context:ctor()
    self.screenLocks = {}
    self.stacks = {}
end

function Context:LockScreen(caller, locked)
    if locked then
        self.screenLocks[caller] = true
        self.stacks[caller] = RuntimeContext.TRACE_BACK()
    else
        if caller == "*" then
            self.screenLocks = {}
        else
            self.screenLocks[caller] = nil
        end
    end
end

function Context:IsScreenLocked()
    for k,v in pairs(self.screenLocks) do
        if v then return true end
    end
    return false
end

function Context:ScreenLockedReason()
    local reason = ""
    for k,v in pairs(self.screenLocks) do
        if v then
            reason = reason .. k .. (self.stacks[k] or "")
        end
    end
    return reason
end

UI.Context = Context.new()