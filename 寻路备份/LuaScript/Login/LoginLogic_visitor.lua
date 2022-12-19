--- 不同渠道配置不同的LoginLogic_visitor，默认针对fb渠道，包括了游客，fb和ios三种登陆模式
---@class LoginLogic_visitor : LoginBase
local LoginLogic_visitor = {}

local PlatType_GUEST = 0

function LoginLogic_visitor:CheckBind()
    return true
end

--准备开始登陆,组装登陆参数
function LoginLogic_visitor:LoginStart(callback)
    local loginParam = {}
    -- loginParam.account = RuntimeContext.DEVICE_ID
    -- --老账号或游客登陆默认游客平台，老逻辑
    -- loginParam.platformType = PlatType_GUEST

    -- local deviceInfo = DcDelegates.Legacy:GetDeviceInfo()
    -- loginParam.type = 0
    -- loginParam.osType = CONST.RULES.GetOsType()
    -- loginParam.idfa = deviceInfo.userid
    -- loginParam.deviceCountry = deviceInfo.devicecountry
    -- loginParam.deviceId = RuntimeContext.DEVICE_ID
    -- loginParam.adsGroup = App.attributeString

    loginParam.channelId = "0"
    loginParam.userIdentity = RuntimeContext.DEVICE_ID
    loginParam.token = ""
    loginParam.deviceId = RuntimeContext.DEVICE_ID
    loginParam.version = RuntimeContext.BUNDLE_VERSION

    Runtime.InvokeCbk(callback, loginParam)
end

return LoginLogic_visitor
