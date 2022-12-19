local IDelegate = require("Game.Dc.Delegates.IDelegate")
---@class FtDelegate:IDelegate
local FtDelegate = class(IDelegate)

function FtDelegate:InitEvent()
    -- self:RegisitEvent(SDK_EVENT.FBLogin, self.FacebookLogin)
    -- local events = require("Game.Dc.FTLog.FTLogEvents")
    -- for key, value in pairs(events) do
    --     self:RegisterEvent(value, function(del, params)
    --         del:OnLog(value, params)
    --     end)
    -- end
    -- self:RegisterEvent(SDK_EVENT.LoadingCompleted, self.LogLoadingComplete)
end

local function StrStrDict(params)
    local ret = XGE.LuaType.StringStringDictionary()
    if params then
        for k, v in pairs(params) do
            ret:SetValue(tostring(k), tostring(v))
        end
    end
    return ret
end

local ignoreKey = {
    front_reportItem = "front_reportItem",
    no_plantData = "no_plantData",
    CreateCrop_start = "CreateCrop_start",
    CreateCrop_end = "CreateCrop_end",
    feed = "feed",
    crop = "crop",
    crop_harvest = "crop_harvest",
    push = "push",
    video_ads_show_win = "video_ads_show_win",
    video_ads_entershow = "video_ads_entershow",
    recharge_process = "recharge_process",
}
function FtDelegate:HandleEvent(eventName, params)
    params = StrStrDict(params)
    self.delegate:LogEvent(eventName, params)

    if ignoreKey[eventName] then
        return
    end
    self.delegate:logAppsFlyerCustomEvent(eventName, params)
end

function FtDelegate:OnLogLogin(channel, params)
    local usermgr = AppServices.User
    local topLevelId = tostring(usermgr:GetCurrentLevelId())

    params = StrStrDict(params)
    self.delegate:LogLogin(
        channel,
        usermgr:GetUid(),
        "in",
        os.time(),
        0,
        params,
        topLevelId,
        topLevelId,
        usermgr:GetItemAmount(ItemId.COIN),
        usermgr:GetItemAmount(ItemId.DIAMOND)
    )
end

function FtDelegate:LogLoadingComplete()
    print("FtDelegate:LogLoadingComplete") --@DEL
    --自定义打点
    self.delegate:LogEvent(SDK_EVENT.LoadingCompleted)
    --Bi打点
    self.delegate:LogLoadingComplete(true, nil)
end

function FtDelegate:OnLogPayment(info)
    print("FtDelegate:OnLogPayment", table.tostring(info)) --@DEL
    info.params = Util.AddBiParameters(info.params)
    info.params = StrStrDict(info.params)
    self.delegate:LogPayment(
        info.channel,
        info.productId,
        info.name,
        info.usCentPrice,
        info.priceLocal,
        info.currencyCode,
        info.isTest,
        info.isTrial,
        info.isScalp,
        info.params
    )
end

function FtDelegate:OnLogOnlineTime(params)
    print("FtDelegate:OnLogOnlineTime") --@DEL
    params = StrStrDict(params)
    self.delegate:SetOnlineTimeParams(params)
end

function FtDelegate:GetDeviceInfo()
    return self.delegate:GetDeviceInfo()
end

function FtDelegate:SetOnAttributeChangeLuaCallback(callback)
    self.delegate:SetOnAttributeChangeLuaCallback(callback)
end

function FtDelegate:LogLoading(step)
    self.delegate:LogLoadingEvent(step, 0)
end

return FtDelegate
