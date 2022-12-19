local IDelegate = require("Game.Dc.Delegates.IDelegate")

---@class FacebookDelegate:IDelegate
local FacebookDelegate = class(IDelegate)

function FacebookDelegate:InitEvent()
    local events = {}
    for key, value in pairs(events) do
        self:RegisterEvent(value, function(del, params)
            del:OnFacebookLog(value, params)
        end)
    end
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
function FacebookDelegate:OnFacebookLog(eventName, params)
    console.trace("FacebookDelegate:OnFacebookLog", eventName) --@DEL
    if self.delegate then
        params = StrStrDict(params)
        self.delegate:Log(eventName, 1.0, params)
        --App.httpClient:HttpPut("http://www.log_FB.info/?channel=facebook&event=" .. eventName, string.char(0x00)) --@DEL
    end
end

function FacebookDelegate:OnLogPayment(info)
    local usDollarPrice = info.usCentPrice * 0.01
    print("FacebookDelegate:OnLogPayment", info.productId, usDollarPrice) --@DEL
    if self.delegate then
        self.delegate:LogPurchase(info.productId, usDollarPrice)
    end
end

function FacebookDelegate:OnRequestEmail(callback)
    if self.delegate:IsGranted("email") then
        self.delegate:ApiCall("/me?fields=email", function(resultJson)
            if string.isEmpty(resultJson) then
                callback()
            else
                local js = table.deserialize(resultJson)
                if RuntimeContext.VERSION_DEVELOPMENT then
                    print(table.tostring(js)) --@DEL
                end
                if js and js.email then
                    callback(js.email)
                else
                    callback()
                end
            end
        end)
    else
        callback()
    end
end

function FacebookDelegate:ShowLoginPrompt(onSuccess, onFailed)
    if self.delegate then
        self.delegate:ShowLoginPrompt(onSuccess, onFailed)
    else
        Runtime.InvokeCbk(onFailed)
    end
end
function FacebookDelegate:FBLogout(callback)
    if self.delegate then
        self.delegate:Logout(callback)
    end
end

function FacebookDelegate:DeletePermissions(path,callback)
    if self.delegate then
        self.delegate:DeletePermissions(path,callback)
    end
end

return FacebookDelegate
