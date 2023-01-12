WaitDelay = class()

function WaitDelay.Create()
    local inst = WaitDelay.new()
    return inst
end

function WaitDelay:ctor()
    self.jobList = {}
end
function WaitDelay:SetDelay(callback, delay,unscale)
    local id = WaitExtension.SetTimeout(function ()
        local key = table.indexOf(self.jobList, callback)
        if key then
            Runtime.InvokeCbk(callback, key)
        end
    end, delay, unscale)
    self.jobList[id] = callback
    return id
end

function WaitDelay:SetRepeating(callback, delay,interval)
    local id = WaitExtension.InvokeRepeating(function ()
        local key = table.indexOf(self.jobList, callback)
        if key then
            Runtime.InvokeCbk(callback, key)
        end
    end, delay, interval)
    self.jobList[id] = callback
    return id
end

function WaitDelay:CancelWait(id)
    if self.jobList[id] then
        WaitExtension.CancelTimeout(id)
        self.jobList[id] = nil
    end
end

function WaitDelay:CancelAllWait()
    if not self.jobList then
        return
    end
    for id, callback in pairs(self.jobList) do
        WaitExtension.CancelTimeout(id)
    end
    self.jobList = {}
end