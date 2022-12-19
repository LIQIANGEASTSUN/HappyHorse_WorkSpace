---@class console
---@field datui function
console = {}

-- print
local function TraceBack(msg)
    local data = debug.traceback(msg, 3)
    data = string.gsub(data, "/Users/townest.-/LuaScript", "")
    return data
end

console.trace = function(...)
    local str = "Time[" .. tostring(os.time()) .. "]:"
    for _, v in ipairs({...}) do
        str = str .. " [message]: " .. tostring(v)
    end
    XDebug.LogTrace(str)
end

console.systrace = console.trace

-- print
function console.print(...)
    local str = ""
    for _, v in ipairs({...}) do
        str = str .. " " .. tostring(v)
    end
    XDebug.LogInfo(str, XDebug.CHANNEL_LUA, true)
end

-- stack print
function console.sprint(...)
    local str = ""
    for _, v in ipairs({...}) do
        str = str .. " " .. tostring(v)
    end
    str = TraceBack(str)
    XDebug.LogInfo(str, XDebug.CHANNEL_LUA, true)
end

-- color print
function console.cprint(...)
    local str = "<color=#D9209B>"
    for _, v in ipairs({...}) do
        str = str .. " " .. tostring(v)
    end
    str = str .. "</color>"
    XDebug.LogInfo(str, XDebug.CHANNEL_LUA, true)
end

-- type print
function console.tprint(target, ...)
    local str = "<color=#00FFFF>"
    for _, v in ipairs({...}) do
        str = str .. " " .. tostring(v)
    end
    str = string.gsub(str, "\n", "</color>\n<color=#00FFFF>")
    str = str .. "</color>\n" .. TraceBack()
    CS.UnityEngine.Debug.Log(str, target)
end

function console.warn(target, ...)
    local str = "<color=#00FFFF>"
    for _, v in ipairs({...}) do
        str = str .. " " .. tostring(v)
    end
    str = string.gsub(str, "\n", "</color>\n<color=#00FFFF>")
    str = str .. "</color>\n" .. TraceBack()
    CS.UnityEngine.Debug.LogWarning(str, target)
end

-- error
function console.error(...)
    local str = ""
    for _, v in ipairs({...}) do
        str = str .. " " .. tostring(v)
    end
    XDebug.LogError(str, XDebug.CHANNEL_LUA, true)
end

-- typed error
function console.terror(target, ...)
    local str = "<color=#00FFFF>"
    for _, v in ipairs({...}) do
        str = str .. " " .. tostring(v)
    end
    str = string.gsub(str, "\n", "</color>\n<color=#00FFFF>")
    str = str .. "</color>\n" .. TraceBack()
    CS.UnityEngine.Debug.LogError(str, target)
end

function console.assert(...)
    local condition = select(1, ...)
    if not condition then
        local ss = "assert failed: "
        for i = 2, select("#", ...) do
            local s = select(i, ...)
            ss = ss .. tostring(s)

            if type(s) == "number" then
                break
            end
        end
        console.error(ss)
    end
end

local codeFarmers = {
    zk = "FF0000",
    hjs = "F657BE",
    datui = "E77000",
    tyz = "FFFD1F",
    lh = "0077FF",
    lj = "1AFF00",
    lzl = "CB7272",
    dk = "44FAE0",
    jf = "FFFFFF"
}

for name, color in pairs(codeFarmers) do
    if RuntimeContext.VERSION_DISTRIBUTE or _LEAN_PRINT_ then
        console[name] = function()
        end
    else
        console[name] = function(...)
            local str = string.format("<color=#00FF00>%s</color><color=#%s>", name, color)
            for _, v in ipairs({...}) do
                str = str .. " " .. tostring(v)
            end
            str = string.gsub(str, "\n", string.format("</color>\n<color=#%s>", color))
            str = str .. "</color>\n"
            CS.UnityEngine.Debug.Log(str)
        end
    end
end

if RuntimeContext.VERSION_DISTRIBUTE or _LEAN_PRINT_ then
    function print()
    end
    function console.tprint()
    end
    function console.cprint()
    end
    function console.warn()
    end
    function console.sprint()
    end
    --function xprintE() end
    function console.assert()
    end
    function console.print()
    end
    --function console.error() end
    function console.warn()
    end
end

if type(XDebug.SetServiceEndpoint) == "function" then
    XDebug.SetServiceEndpoint()
end
