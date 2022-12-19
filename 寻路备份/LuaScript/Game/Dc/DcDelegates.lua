SDK_EVENT =
    setmetatable(
    {},
    {
        __index = function(t, k)
            return k
        end
    }
)

DcItemType = {
    Building = "building",
    Prop = "prop",
    Energy = "energy",
    Coin = "coin",
    Diamond = "diamond",
    Buff = "buff",
    Sakura = "sakura",
    Cash = "cash"
}

DcAcquisitionSource =
    setmetatable(
    {},
    {
        __index = function(t, k)
            return k
        end
    }
)

DcConsumptionSource =
    setmetatable(
    {},
    {
        __index = function(_, k)
            return k
        end
    }
)
--------------------------------------------------------------------
DelegateNames = {
    Facebook = "FB",
    BI = "FTDSdk",
    Firebase = "FirebaseApp",
    Apm = "ApmApp",
    FTAAuth = "FTADelegate",
}

---@class DcDelegates
---@field Ads Ads
DcDelegates =
    setmetatable(
    {
        registers = {}
    },
    {
        __index = function(t, k)
            local inst = include("Game.Dc.Categories." .. k)
            rawset(t, k, inst)
            return inst
        end
    }
)

function DcDelegates:Init()
    local mapp = CS.BetaGame.MainApplication
    if mapp.ftDelegate then
        local FtDelegate = require("Game.Dc.Delegates.FtDelegate")
        self:Add(FtDelegate.new(mapp.ftDelegate, DelegateNames.BI))
    end
    if mapp.firebaseDelegate then
        local FirebaseDelegate = require("Game.Dc.Delegates.FirebaseDelegate")
        self:Add(FirebaseDelegate.new(mapp.firebaseDelegate, DelegateNames.Firebase))
    end
    if mapp.facebook then
        local FacebookDelegate = require("Game.Dc.Delegates.FacebookDelegate")
        self:Add(FacebookDelegate.new(mapp.facebook, DelegateNames.Facebook))
    end

    if mapp.ftaDelegate then
        local FTADelegate = require"Game.Dc.Delegates.FTADelegate"
        self:Add(FTADelegate.new(mapp.ftaDelegate, DelegateNames.FTAAuth))
    end

    local platform = "unity_editor"
    if RuntimeContext.UNITY_IOS then
        platform = "ios"
    elseif RuntimeContext.UNITY_ANDROID then
        platform = "android"
    end
    self.platform = platform
end

function DcDelegates:Add(delegate)
    print("DcDelegates:Add " .. delegate.name) --@DEL
    self.registers[#self.registers + 1] = delegate
end

function DcDelegates:GetDelegate(name)
    for _, register in pairs(self.registers) do
        if register.name == name then
            return register
        end
    end
end

function DcDelegates:AddDefaultParams(params)
    if not params then
        params = {}
    end
    params.platform = params.platform or self.platform
    params.deviceId = params.deviceId or RuntimeContext.DEVICE_ID
    if RuntimeContext.ENTERED_GAME then
        params.playerid = params.playerid or LogicContext.UID
        params.level = params.level or AppServices.User:GetCurrentLevelId()
    end
    if params.playerid == params.deviceId then
        --新用户playerid未产生，调取的是deviceId，需要把playerid设为空
        params.playerid = nil
    end
    params.rss = Time.realtimeSinceStartup
    params.tsl = Time.timeSinceLevelLoad
    params.ts = params.ts or TimeUtil.ServerTime()
    params.version = params.version or RuntimeContext.BUNDLE_VERSION
    return params
end

function DcDelegates:Log(eventName, params)
    params = self:AddDefaultParams(params)
    self:HandleEvent(eventName, params)
end

function DcDelegates:ProbabilityDetection(val)
    if RuntimeContext.VERSION_DEVELOPMENT then
        return true
    end
    return math.random(1, 100) <= val
end

function DcDelegates:LogWithProbability(eventName, params, ratio)
    if not ratio or self:ProbabilityDetection(ratio) then
        self:Log(eventName, params or {})
    end
end

function DcDelegates:HandleEvent(eventName, ...)
    for _, register in pairs(self.registers) do
        if register.HandleEvent then
            register:HandleEvent(eventName, ...)
        end
    end
end

function DcDelegates:LogLogin(channel, params)
    --local channel = "visitor"
    --if isFacebook then
    --    channel = "facebook"
    --end
    for _, register in pairs(self.registers) do
        if register.OnLogLogin then
            register:OnLogLogin(channel, params)
        end
    end
end

function DcDelegates:LogPayment(info)
    for _, register in pairs(self.registers) do
        if register.OnLogPayment then
            register:OnLogPayment(info)
        end
    end
end

function DcDelegates:LogFacebook(eventName,params)
    params = self:AddDefaultParams(params)
    for _, register in pairs(self.registers) do
        if register.OnFacebookLog then
            register:OnFacebookLog(eventName,params)
        end
    end
end

function DcDelegates:LogOnlineTime(params)
    params = Util.AddUserStatsParams(params)
    for _, register in pairs(self.registers) do
        if register.OnLogOnlineTime then
            register:OnLogOnlineTime(params)
        end
    end
end

function DcDelegates:LogInitMessaging()
    for _, register in pairs(self.registers) do
        if register.OnLogInitMessaging then
            register:OnLogInitMessaging()
        end
    end
end

function DcDelegates:LogLoading(step)
    local delegate = self:GetDelegate(DelegateNames.BI)
    if delegate then
        delegate:LogLoading(step)
    end
end

DcDelegates:Init()

return DcDelegates
