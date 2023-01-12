local function StrStrDict(params)
    local ret = XGE.LuaType.StringStringDictionary()
    if params then
        for k, v in pairs(params) do
            ret:SetValue(tostring(k), tostring(v))
        end
    end
    return ret
end

local IDelegate = require("Game.Dc.Delegates.IDelegate")

---@class FirebaseDelegate:IDelegate
local FirebaseDelegate = class(IDelegate)
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
    obstacles_load_cost = "obstacles_load_cost",
}
function FirebaseDelegate:OnLog(eventName, params)
    if ignoreKey[eventName] then
        params = params or {}
        BCore.Track(eventName..table.tostring(params))
        return
    end
    self.delegate:Log(eventName, params)
end

function FirebaseDelegate:HandleEvent(eventName, params)
    if ignoreKey[eventName] then
        params = params or {}
        BCore.Track(eventName..table.tostring(params))
        return
    end
    params = StrStrDict(params)
    self.delegate:Log(eventName, params)
end

function FirebaseDelegate:OnLogInitMessaging()
    --self.delegate:InitMessaging()
end

function FirebaseDelegate:GetAppInstanceId()
    return self.delegate:GetAppInstanceId()
end

return FirebaseDelegate
