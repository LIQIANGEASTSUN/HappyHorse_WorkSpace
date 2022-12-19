
RuntimeContext.CACHES = {
    -- 存放一些运行时数据
    TEST_ACCOUNT = nil
}
RuntimeContext.VERSION_DEVELOPMENT = not RuntimeContext.VERSION_DISTRIBUTE
RuntimeContext.KILL_GUIDE = false
RuntimeContext.CURRENT_DATATIME = 0
---当前时区下一次跨天时间
RuntimeContext.CURRENT_TIMEZONE_REFRESHTIME = 0

-- 游戏常量
RuntimeContext.INITIAL_VERSION = "1.0.0"

-- 状态统计
RuntimeContext.ENTERED_GAME = false  -- 是否已使用后端数据初始化UserManager
RuntimeContext.IN_GAME_DURATION = 0
RuntimeContext.FIRST_ENTER_GAME = true
RuntimeContext.IS_NEW_USER = false

RuntimeContext.SERVER_TIME_DIFF = 0

-- 功能开关
RuntimeContext.DISABLE_MAIL_SYSTEM = false
RuntimeContext.DISABLE_ABOUT_US = false

RuntimeContext.LEGACY_DEVICE = false
RuntimeContext.LITE_SCENE = false
RuntimeContext.USE_MERGER_MSG = true
RuntimeContext.GIFT_CODE_ENABLE = false

--RuntimeContext.FAQ_ENABLE = not RuntimeContext.UNITY_ANDROID
RuntimeContext.FAQ_ENABLE = true
RuntimeContext.IAP_ENABLE = CS.Bridge.Core.IsOpen("IAP")

RuntimeContext.PAY_PLATE =  RuntimeContext.UNITY_EDITOR and "Win" or "Mobile"

function RuntimeContext.TRACE_BACK()
    return "RuntimeContext:NoTrace"
end

function RuntimeContext.FUNC_DESC(func)
    if type(func) ~= "function" then
        return "[FUNC_DESC:func is null]"
    end
    local info = debug.getinfo(func, "S")
    return string.format("[FUNC_DESC:%s:%s@%s]", info.linedefined or "",  info.lastlinedefined or "", info.short_src or "src")
end

function RuntimeContext.IS_PAD()
    if RuntimeContext.UNITY_IOS then
        local device = DcDelegates.Legacy:GetDeviceInfo()
        local modelName = device.devicemodel or ""

        return string.match(modelName, "iPad") or string.match(modelName, "ipad")
    end

    if RuntimeContext.UNITY_ANDROID then
        local physicscreen = math.sqrt(Screen.width * Screen.width + Screen.height * Screen.height) / Screen.dpi;
        return physicscreen >= 7
    end

    if RuntimeContext.VERSION_DEVELOPMENT then
        return true
    end

    return false
end

if RuntimeContext.VERSION_DEVELOPMENT then
    if RuntimeContext.UNITY_EDITOR then
        require("System.Debug.LuaPanda.LuaPanda").start("127.0.0.1", 8818)
    else
        -- load online debug strategy
        local host = CS.Bridge.Core.GetConfigParam("ScriptDebuggerUrl")
        if string.len(host) >= 8 then
            print("ScriptDebuggerUrl:" .. host) --@DEL
            require("System.Debug.LuaPanda.LuaPanda").start(host, 8818)
        end
    end

    function RuntimeContext.TRACE_BACK()
        return debug.traceback()
    end

    local launchURL = BCore.StartupArgs
    print("StartupArgs:" ..BCore.StartupArgs)
    if launchURL then
        local UrlParser = include("Utils.UrlParser")
        local res = UrlParser.parseUrlScheme(launchURL)
        if not res.method or string.lower(res.method) ~= "fotoable" then
            return
        end
        if res.para then
            RuntimeContext.ASSET_GROUP = res.para.assetgroup
            RuntimeContext.ENABLE_ASSET_CACHE = res.para.assetcache
            RuntimeContext.PREFETCH_ALL_BUNDLES = res.para.prefetch_all_bundles
        end
    end
end
