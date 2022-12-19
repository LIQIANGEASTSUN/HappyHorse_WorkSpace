--- 不同渠道配置不同的LoginLogic_fb，默认针对fb渠道，包括了游客，fb和ios三种登陆模式
---@class LoginLogic_fb : LoginBase
local LoginLogic_fb = {}

--FB绑定后服务器给的位标记
local AccountType_FACEBOOK = 1
local PlatType_FACEBOOK = 1

function LoginLogic_fb:CheckBind(type)
    type = type or 0
    return (require "Utils.bitOp").And(type,AccountType_FACEBOOK) > 0
end

--请求FB邮箱
function LoginLogic_fb:FB_RequestEmail(callback)
    DcDelegates.Fb:OnRequestEmail(function(email)
        self.sdkLoginInfo.email = email

        --开始请求登陆服务器
        self:BuildLoginPara(callback)
        --fb登陆结束
        DcDelegates:Log(SDK_EVENT.fb_login_connect_result, {success = true, identity = 1})
    end)
end

--打开fb登陆界面
function LoginLogic_fb:LoginStart(callback)
    --登陆Fb成功
    local function onSuccess(userId, accessToken, requestedPermissions, grantedPermissions)
        --保存登陆信息
        self.sdkLoginInfo = {}
        self.sdkLoginInfo.userId = userId
        self.sdkLoginInfo.accessToken = accessToken
        self.sdkLoginInfo.requestedPermissions = requestedPermissions
        self.sdkLoginInfo.grantedPermissions = grantedPermissions
        self.sdkLoginInfo.platformType = PlatType_FACEBOOK
        AppServices.User:SetFbAccessToken(self.sdkLoginInfo.accessToken)
        --请求邮件信息（只为保存在服务器）
        self:FB_RequestEmail(callback)
    end

    --登陆FB失败
    local function onFail(error)
        DcDelegates:Log(SDK_EVENT.fb_login_connect_result, {success = false, error = error, identity = 1})
        --取消提示被写死了，先强转一下吧
        if error == "Login Cancelled" then
            error = Runtime.Translate("ui_settings_logincancelled")
        end
        ErrorHandler.ShowErrorMessage(error)

        sendNotification(CONST.GLOBAL_NOFITY.Login_Fail)
        AppServices.Connecting:ClosePanel()
    end

    DcDelegates.Fb:ShowLoginPrompt(onSuccess, onFail)
    --fb登陆开始
    DcDelegates:Log(SDK_EVENT.fb_login_connect_start, {identity = 1})
end

--准备开始登陆,组装登陆参数
function LoginLogic_fb:BuildLoginPara(callback)
    --是否使用fb或者苹果SDK
    if not self.sdkLoginInfo or not self.sdkLoginInfo.accessToken then
        return
    end

    local loginParam = {}
    loginParam.account = self.sdkLoginInfo.userId
    --平台信息：需要在平台登陆成功后记录
    loginParam.platformType = self.sdkLoginInfo.platformType
    loginParam.inputToken = self.sdkLoginInfo.accessToken
    --访问账号（只有绑定操作时才传该值），此时账号信息为游客账号
    local lastAccount = AppServices.AccountData:GetLastLoginAccount()
    if loginParam.account ~= lastAccount then
        loginParam.visitorAccount = lastAccount
    end
    loginParam.mail = self.sdkLoginInfo.email

    local deviceInfo = DcDelegates.Legacy:GetDeviceInfo()
    loginParam.type = 0
    loginParam.osType = CONST.RULES.GetOsType()
    loginParam.idfa = deviceInfo.userid
    loginParam.deviceCountry = deviceInfo.devicecountry
    loginParam.deviceId = RuntimeContext.DEVICE_ID
    loginParam.adsGroup = App.attributeString

    Runtime.InvokeCbk(callback,loginParam)
end

return LoginLogic_fb
