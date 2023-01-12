--- 不同渠道配置不同的LoginLogic_visitor_test，默认针对fb渠道，包括了游客，fb和ios三种登陆模式
---@class LoginLogic_visitor_test : LoginBase
local LoginLogic_visitor_test = {}

function LoginLogic_visitor_test:CheckBind()
    return true
end

--准备开始登陆,组装登陆参数
function LoginLogic_visitor_test:LoginStart(callback)
    local loginParam = {}

    loginParam.channelId = "0"
    loginParam.userIdentity = RuntimeContext.CACHES.TEST_ACCOUNT
    loginParam.token = ""
    loginParam.deviceId = RuntimeContext.DEVICE_ID
    loginParam.version = RuntimeContext.BUNDLE_VERSION

    Runtime.InvokeCbk(callback,loginParam)
end

return LoginLogic_visitor_test
