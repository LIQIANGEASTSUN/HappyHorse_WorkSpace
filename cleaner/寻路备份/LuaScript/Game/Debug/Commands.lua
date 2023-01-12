
local Commonds = {}

function Commonds.connect()
    local function OnSuccess(data)
        local cfg = table.deserialize(data)
        local address = cfg.parameters.ScriptDebuggerUrl
        if not address then return end

        console.trace("reset debugger connection to:" ..address)
        local debugger = require("System.Debug.LuaPanda.LuaPanda")
        debugger.resetconnectionfordebugger(address, 8818)
    end
    local function OnFailed(data)
        console.trace("consul:"..data)
    end
    local url = string.format("http://zhukaixy.com:8500/v1/kv/%s/%s/%s?raw", RuntimeContext.APP_NAME, RuntimeContext.APP_VERSION, LogicContext.UID)
    console.trace("consul:"..url)
    App.httpClient:HttpGet(url, OnSuccess, OnFailed)
end

return Commonds