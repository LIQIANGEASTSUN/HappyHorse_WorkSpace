WaitExtension = {}

function WaitExtension.SetTimeout(func, time, unscale)
    console.assert(type(func) == "function", "the parameter func is NULL or func is not of type: 'function'")
    local traceBack = RuntimeContext.TRACE_BACK() --@DEL

    local id = nil
    local function _ExceptionBlackHole(...)
        local status, info = pcall(func, ...)
        if not status then
            App.scheduler:CancelTimeout(id)
            console.error("SetTimeout:", info, traceBack) --@DEL
        end
    end
    id = App.scheduler:AddTimeout(_ExceptionBlackHole, time or 0, RuntimeContext.TRACE_BACK(), unscale or false)
    return id
end

function WaitExtension.SetTimeoutUnscale(func, time)
    WaitExtension.SetTimeout(func, time, true)
end

function WaitExtension.CancelTimeout(id)
    App.scheduler:CancelTimeout(id, RuntimeContext.TRACE_BACK())
end

function WaitExtension.InvokeRepeating(func, delay, interval)
    console.assert(type(func) == "function", "the parameter func is NULL or func is not of type: 'function'")
    local traceBack = RuntimeContext.TRACE_BACK() --@DEL

    local id = nil
    local function _ExceptionBlackHole(...)
        local status, info = pcall(func, ...)
        if not status then
            App.scheduler:CancelTimeout(id)
            console.error("InvokeRepeating:", info, traceBack) --@DEL
        end
    end
    id = App.scheduler:AddRepeat(_ExceptionBlackHole, delay, interval, traceBack)
    return id
end

function WaitExtension.InvokeRepeatingNextFrame(func, interval)
    console.assert(type(func) == "function", "the parameter func is NULL or func is not of type: 'function'")

    local id = nil
    local traceBack = RuntimeContext.TRACE_BACK() --@DEL
    local function _ExceptionBlackHole(...)
        local status, info = pcall(func, ...)
        if not status then
            App.scheduler:CancelTimeout(id)
            console.error("InvokeRepeatingNextFrame:", info, traceBack) --@DEL
        end
    end
    id = App.scheduler:AddRepeat(_ExceptionBlackHole, 0.1, interval, RuntimeContext.TRACE_BACK())
    return id
end

function WaitExtension.InvokeDelay(func)
    console.assert(type(func) == "function", "the parameter func is NULL or func is not of type: 'function'")

    --[[
    local function _ExceptionBlackHole(...)
        local status, info = pcall(func, ...)
        if not status then
            console.error("SetNextFrame:", info)
        end
    end
    return App.scheduler:AddTimeout(_ExceptionBlackHole, 0, RuntimeContext.TRACE_BACK())
    --]]
    App.nextFrameActions:Add(func)
end
