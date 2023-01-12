--- 不同渠道配置不同的LoginLogic_ios，默认针对fb渠道，包括了游客，fb和ios三种登陆模式
---@class LoginLogic_ios : LoginBase
local LoginLogic_ios = {}

--Ios绑定后服务器给的位标记
local AccountType_APPLE = 4

function LoginLogic_ios:CheckBind(type)
    type = type or 0
    return (require "Utils.bitOp").And(type,AccountType_APPLE) > 0
end

function LoginLogic_ios:LoginStart(callback)
    local function result(data)
        if not data or data.error then
            ErrorHandler.ShowErrorMessage(Runtime.Translate("ui_login_apple_faildesc"))
            --if not App.loginLogic:HasEnteredGame() then
            --    sendNotification(LoadingPanelNotificationEnum.ShowLoadingView, AppServices.AccountData:GetLastAccountType())
            --end
            sendNotification(CONST.GLOBAL_NOFITY.Login_Fail)
            AppServices.Connecting:ClosePanel()
            return
        end
        self.sdkLoginInfo = {}
        self.sdkLoginInfo.userId = data.userId
        self.sdkLoginInfo.accessToken = data.idToken
        self.sdkLoginInfo.platformType = PlatType.APPLE
        console.lj("userId :"..data.userId)
        console.lj("idToken :"..data.idToken)
        console.lj("authorizationCode :"..data.authorizationCode)
        --开始登陆服务器
        self:BuildLoginPara(callback)
    end
    if not App.iosSdk then
        return
    end
    console.lj("----------")
    App.iosSdk:Login(result)
end

--准备开始登陆,组装登陆参数
function LoginLogic_ios:BuildLoginPara(callback)
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

    local deviceInfo = DcDelegates.Legacy:GetDeviceInfo()
    loginParam.type = 0
    loginParam.osType = CONST.RULES.GetOsType()
    loginParam.idfa = deviceInfo.userid
    loginParam.deviceCountry = deviceInfo.devicecountry
    loginParam.deviceId = RuntimeContext.DEVICE_ID
    loginParam.adsGroup = App.attributeString

    Runtime.InvokeCbk(callback,loginParam)
end

return LoginLogic_ios
