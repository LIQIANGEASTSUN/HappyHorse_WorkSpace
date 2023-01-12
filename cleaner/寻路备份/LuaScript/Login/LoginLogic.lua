--- 不同渠道配置不同的LoginLogic，默认针对fb渠道，包括了游客，fb和ios三种登陆模式
---@class LoginLogic
local LoginLogic = {}

---@type LoginServer
local LoginServer = require "Login.LoginServer"

function LoginLogic:Init()
    --创建渠道逻辑
    self.LoginLogicMap = {}

    local LoginChannel = require "Login.LoginChannelConfig"
    for _, val in pairs(LoginChannel.GetFBChannelMap()) do
        self.LoginLogicMap[val] = require ("Login.LoginLogic_" ..val)
    end
    --初始化登陆配置信息
    self.PlayerInfo = LoginServer.PlayerInfo

    --隐藏loading条
    sendNotification(LoadingPanelNotificationEnum.ShowTitleCartoon)
    --显示登陆界面
    PanelManager.showPanel(GlobalPanelEnum.LoginScenePanel, {withoutAudio = true})

    --检查停服状态
    AppServices.ShutDownServerLogic:Check()
end

--检查渠道账号是否绑定
function LoginLogic:CheckChannelAllBind(type)
    for _, logic in pairs(self.LoginLogicMap) do
        if not logic:CheckBind(type) then
            return false
        end
    end
    return true
end
--登陆使用接口
function LoginLogic:Login_Start(channel, bindpage)
    -- body
    if not self:HasEnteredGame() then
        self:GameLogin_Start(channel, bindpage)
    else
        self:IngameLogin_start(channel, nil,  bindpage)
    end

    WaitExtension.InvokeDelay(
        function()
            AppServices.Connecting:ShowPanel()
        end
    )
end

--开始登陆（生成登陆参数）
function LoginLogic:GameLogin_Start(channel, bindpage)
    self.LoginLogicMap[channel]:LoginStart(function(info)
        info.userIdentity = bindpage.userName
        LoginServer:ConnectServer(info, bindpage)
    end)

    --通知开始登陆
    sendNotification(CONST.GLOBAL_NOFITY.Login_Start)
end

function LoginLogic:IngameLogin_start(channel,callBack, bindpage)
    if not channel then
        channel = self:IsTestMode() and "visitor_test" or "visitor"
    end
    self.LoginLogicMap[channel]:LoginStart(function (info)
        LoginServer:IngameLogin_ConnectServer(info,callBack, bindpage)
    end)
end

------------登陆状态的设置于获取
function LoginLogic:IsLoggedIn()
    return self.isLoggedIn
end

function LoginLogic:SetLoggedIn(value)
    self.isLoggedIn = value
end

function LoginLogic:HasEnteredGame()
    return self.gameEntered
end

function LoginLogic:SetEnteredGame(value)
    self.gameEntered = value
end

function LoginLogic:IsFbAccount()
    local bitOp = require "Utils.bitOp"
    return bitOp.And(AppServices.AccountData:GetLastAccountType(), 1) > 0
end

function LoginLogic:IsIosAccount()
    local bitOp = require "Utils.bitOp"
    return bitOp.And(AppServices.AccountData:GetLastAccountType(), 4) > 0
end

function LoginLogic:IsTestMode()
    return self.isTest
end

function LoginLogic:SetTestMode(value)
    self.isTest = value
end

function LoginLogic:GetLoginChannel()
    return LoginServer:GetLoginChannel()
end

function LoginLogic:ShowLoginReward(finishCallback)
    AppServices.User:SetFbBindReward(0)
    local rwds = {
        {ItemId = ItemId.ENERGY, Amount = AppServices.Meta:GetConfigMetaValueNumber("FBFirstLoginRewardEnergyNum", 99)},
    }
    PanelManager.showPanel(GlobalPanelEnum.CommonRewardPanel, {rewards = rwds, showCongrats = true, closeCallback = function()
        Runtime.InvokeCbk(finishCallback)
    end})
end

return LoginLogic
