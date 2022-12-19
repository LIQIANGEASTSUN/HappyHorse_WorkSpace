--- 不同渠道配置不同的LoginServer，默认针对fb渠道，包括了游客，fb和ios三种登陆模式
---@class LoginServer
local LoginServer = {
    loginParam = {},
    PlayerInfo = {}
}

-- require "User.TaskIconButtonLogic"
require "User.HeartManager"

LoginResultType = {
    SUCCESS = 1,
    FAIL = 2,
    ABORT = 3
}
--账号类型（关联账号）
AccountType = {
    GUEST = 0,
    FACEBOOK = 1,
    LEDOU = 2,
    APPLE = 4
}
--平台类型
PlatType = {
    GUEST = 0,
    FACEBOOK = 1,
    LEDOU = 2,
    APPLE = 3
}

function LoginServer:Recieved_SCSPO(msg)
    local result = {
        loginResultType = LoginResultType.SUCCESS,
        loginStatus = 0,
        msg = msg
    }
    --解析登陆信息
    self:OnLoginSuccess(msg)
    sendNotification(CONST.GLOBAL_NOFITY.Login_Suc, result)
end

function LoginServer:InitTime(curTime)
    --同步服务器时间
    local ts = curTime or 0
    RuntimeContext.SERVER_TIME_DIFF = math.floor(ts / 1000) - os.time()
    RuntimeContext.CURRENT_DATATIME = TimeUtil.GetDayStartTs(math.floor(ts / 1000) - TimeUtil._19H_To_Sec)
    local timeZone = response.timeZone
    TimeUtil.SetTimeZone(timeZone)
    RuntimeContext.CURRENT_TIMEZONE_REFRESHTIME = TimeUtil.GetTimeZoneNextDayTime()
end
--longjun 新登陆流程
function LoginServer:ConnectServer(info, bindpage)
    AppServices.Net:Login(
        function()
            AppServices.Net:Send(MsgMap.CSLogin, info)
        end
    )

    AppServices.Net:Recieved(
        MsgMap.SCLogin,
        function(msg)
            console.lj("登陆结果：" .. (msg.resultCode == 0 and "成功" or "失败"))
            App.loginLogic:SetLoggedIn(msg.resultCode == 0)
        end
    )
    AppServices.Net:Recieved(
        MsgMap.SCSPO,
        function(msg)
            self:Recieved_SCSPO(msg)
        end
    )
    AppServices.Net:Recieved(
        MsgMap.SCHint,
        function(msg)
            --TODO 对应上
            local key = tostring(msg.strId)
            local data = AppServices.Meta:Category("Str")[key]
            if data then
                key = data.strContent
            end
            local message = Runtime.Translate(key)
            ErrorHandler.ShowErrorMessage(message)
        end
    )

    -- --连接服务器成功
    -- local function ConnectServer_Success(response)
    --     --检查是否需要选择账号
    --     if response.loginStatus == 2 then
    --         return self:Login_ChooseBindAccount(response.selectPlayerInfos or {}, bindpage)
    --     end

    --     --解析登陆信息
    --     self:OnLoginSuccess(response)
    --     --标记已经是最新版本了
    --     --self:SetForceConnected(true)
    --     --请求进入游戏信息
    --     self:Login_ConnectServer_EnterGame()
    -- end

    -- --连接服务器失败
    -- local function ConnectServer_Fail(errorCode)
    --     local result = {
    --         loginResultType = LoginResultType.FAIL,
    --         loginStatus = self.loginStatus,
    --         errorCode = errorCode
    --     }
    --     self:Login_ConnectServer_Result(result)
    --     --[[检查是否由更新失败导致的错误(现在是走强更和动更逻辑)
    --     self:CheckNeedUpdate(
    --         function(isNeedUpgrade)
    --             local result = {
    --                 loginResultType = isNeedUpgrade and LoginResultType.ABORT or LoginResultType.FAIL,
    --                 loginStatus = self.loginStatus,
    --                 errorCode = errorCode
    --             }
    --             self:Login_ConnectServer_Result(result)
    --         end
    --     )]]
    -- end

    -- self.loginParam = info or {}
    -- local timeZone = TimeUtil.GetLocalTimeZone()
    -- self.loginParam.timeZone = timeZone
    -- self.loginParam.bindpage = bindpage
    -- -- -- console.lzl("-------给服务器的时区----", timeZone)
    -- Net.Coremodulemsg_1001_Login_Request(self.loginParam, ConnectServer_Fail, ConnectServer_Success, nil, false)
end
--账号选择后登陆服务器
function LoginServer:Login_ChooseBindAccount(info, bindpage)
    local selectInfo = {}
    for key, value in ipairs(info) do
        if value.playerId ~= nil then
            table.insert(
                selectInfo,
                {
                    playerId = value.playerId,
                    diamond = value.diamond,
                    level = value.level,
                    time = value.lastLoginMill,
                    name = value.name
                }
            )
        end
    end

    if #selectInfo < 2 then
        return
    end

    local param = {
        commond = function(param)
            self.loginParam.playerId = param.playerId
            self:ConnectServer(self.loginParam, bindpage)
        end,
        selectInfo = selectInfo,
        cancelCB = function()
            --sendNotification(LoadingPanelNotificationEnum.ShowLoadingView, AppServices.AccountData:GetLastAccountType())
            sendNotification(CONST.GLOBAL_NOFITY.Login_Fail)
            self.loginParam = {}
        end
    }
    PanelManager.showPanel(GlobalPanelEnum.SelectAccountPanel, param)
end

function LoginServer:OnLoginSuccess(response)

    -- BuildPlayerInfo
    --登录状态 0.正常登录 1.首次登录 2.需要选择playerid再次登录(8.1.0修改)
    self.loginStatus = response.loginStatus or 0
    --玩家id
    self.PlayerInfo = {}
    self.PlayerInfo.uid = response.playerId
    --是否绑定游客操作( 0.不是新绑定 1.新fb账号绑定 )
    self.PlayerInfo.bindingStatus = response.bindStatus
    self.PlayerInfo.sessionId = response.sessionId
    self.PlayerInfo.sequenceId = response.sequenceId
    --账号类型( 0.游客 1.fb 2.乐逗 4.apple) 按位操作 5表示fb+apple
    self.PlayerInfo.accountType = response.accountType
    --Facebook关注状态（0.未关注，1已关注）
    self.PlayerInfo.fbFollow = response.fbFollow
    --Facebook绑定状态（0.未绑定 1.已绑定）
    self.PlayerInfo.fbBind = response.fbBind
    --登录返回fbAccount 如果有fb的情况 其实主要作用是用来读取fb头像
    self.PlayerInfo.fbAccount = response.fbAccount
    --是否有fb绑定奖励 0：没有 1：有
    self.PlayerInfo.fbBindReward = response.fbBindReward
    --是否已完成首次绑定fb 0:否   1:是 (注意本次有fb绑定奖励或曾经发放过fb绑定奖励时此值为1)
    self.PlayerInfo.fbFirstBind = response.fbFirstBind

    -- UIDLogic
    --屏幕显示
    LogicContext.UID = self.PlayerInfo.uid
    FileUtil.CreateFolder(LogicContext.UID)
    --保存账号信息
    AppServices.AccountData:SetLastAccount(
        self.loginParam.account,
        self.PlayerInfo.uid,
        self.PlayerInfo.accountType,
        nil,
        self.PlayerInfo.fbFirstBind
    )
    --self:MigrateCacheDataIfNeeded(self.PlayerInfo.uid)
    --同步服务器时间
    local ts = response.curTime or 0
    RuntimeContext.SERVER_TIME_DIFF = math.floor(ts / 1000) - os.time()
    RuntimeContext.CURRENT_DATATIME = TimeUtil.GetDayStartTs(math.floor(ts / 1000) - TimeUtil._19H_To_Sec)
    local timeZone = response.timeZone or 0
    TimeUtil.SetTimeZone(timeZone)
    -- local tzTimeDay0 = TimeUtil.GetTimeZoneDay0Time()
    -- -- console.lzl("-------服务器返回的时区----", timeZone, TimeUtil.GetTimeString(tzTimeDay0))
    -- -- console.lzl("-------服务器返回的时区----", timeZone)
    --同步当地时间(玩家所在timezone时间)
    -- if tzTimeDay0 then
    --     RuntimeContext.CURRENT_TIMEZONE_REFRESHTIME = tzTimeDay0 + TimeUtil._24H_To_Sec
    -- end
    RuntimeContext.CURRENT_TIMEZONE_REFRESHTIME = TimeUtil.GetTimeZoneNextDayTime()
    -- --刷新网络模块参数
    -- ConnectionManager:changeUserID(self.PlayerInfo.uid, self.PlayerInfo.sessionId, self.PlayerInfo.sequenceId)
    --存储文件id修改
    AppServices.User:InitFromData({uid = self.PlayerInfo.uid, msg = response})
    AppServices.User:SetFbAccount(self.PlayerInfo.fbAccount)
    AppServices.User:SetFbBindReward(self.PlayerInfo.fbBindReward)
    sendNotification(CONST.GLOBAL_NOFITY.USER_UID_CHANGED, {uid = self.PlayerInfo.uid})

    --首次登陆
    if self.loginStatus == 1 then
        DcDelegates:Log(SDK_EVENT.level_1, {playerid = LogicContext.UID, level = 1})
        DcDelegates:LogFacebook(SDK_EVENT.level_1, {playerid = LogicContext.UID, level = 1})
    end

end

--打点用获取渠道名
function LoginServer:GetLoginChannel()
    local function getChannelByLoginPara()
        if self.loginParam and self.loginParam == 0 then
            return "visitor"
        end

        if self.loginParam.platformType == PlatType.FACEBOOK then
            return "facebook"
        end

        if self.loginParam.platformType == PlatType.APPLE then
            return "ios"
        end

        return "visitor"
    end

    if not self.channel then
        self.channel = getChannelByLoginPara()
    end
    return self.channel
end

--协议1002
function LoginServer:Login_ConnectServer_EnterGame()
    local function OnSuccess(response)
        WaitExtension.InvokeDelay(
            function()
                ConnectionManager:block()
                App.loginLogic:SetLoggedIn(true) --  EnterGame成功才算登录
                self:OnEnterGameSuccess(response)

                local result = {
                    loginResultType = LoginResultType.SUCCESS,
                    loginStatus = self.loginStatus
                }
                self:Login_ConnectServer_Result(result)
                DcDelegates:LogLogin(self:GetLoginChannel())
                ConnectionManager:flush(true)
            end
        )
    end

    local function OnFail(errorCode)
        --ErrorHandler.ShowErrorPanel(errorCode)
        DcDelegates:Log(
            SDK_EVENT.ServerLogin,
            {result = false, isLogin = App.loginLogic:IsLoggedIn(), errorCode = errorCode}
        )
        local result = {
            loginResultType = LoginResultType.FAIL,
            loginStatus = self.loginStatus,
            errorCode = errorCode
        }
        self:Login_ConnectServer_Result(result)
    end
    Net.Coremodulemsg_1002_EnterGame_Request({flag = true}, OnFail, OnSuccess)
end

-----------这几个应该优化下-----------
--[[ 就是做了一下是否有过强连的标记，目前没有离线模式了，不需要了，版本跟新也走升级流程
function LoginServer:GetForceConnectCheckKey()
    local version_numbers = string.split(RuntimeContext.BUNDLE_VERSION or "1.0.0", ".")
    local checkVersion = tostring(version_numbers[1]) .. "_" .. tostring(version_numbers[2]) .. "_force_connected"
    return checkVersion
end

function LoginServer:CheckNeedUpdate(callbackWithIsNeedUpgrade)
    if not AppServices.PackageDefault:GetValue(self:GetForceConnectCheckKey(), false) then
        ErrorHandler.ShowErrorMessage(
            Runtime.Translate("force.online.upgrade"),
            function()
                Runtime.InvokeCbk(callbackWithIsNeedUpgrade, false)
            end,
            false
        )
    else
        Runtime.InvokeCbk(callbackWithIsNeedUpgrade, false)
    end
end

function LoginServer:SetForceConnected(newValue)
    local key = self:GetForceConnectCheckKey()
    local value = AppServices.PackageDefault:GetValue(key, false)
    if newValue ~= value then
        AppServices.PackageDefault:SetKeyValue(key, newValue, true)
    end
end
]]
--[[不再有本地数据了，应该只有本地配置和测试配置两种模式了，是否可以简化出来
function LoginServer:MigrateCacheDataIfNeeded(newUId)
    if self.loginStatus == NewUser and self.PlayerInfo.bindingStatus == NoBinding then
        -- 新游客账户创建
        -- 需要把DeviceId目录缓存拷到playerId
        print("新游客账户创建") --@DEL
        self:MigrateVisitorAccountToNewUid(newUId)
        --AppServices.FacebookAccountData:NewUIDClearCache()
    elseif self.loginStatus == OldUser and self.PlayerInfo.bindingStatus == NoBinding then
        -- 联网过的游客账户，或绑定过的fb账户
        -- 直接用playerId访问缓存，不需要拷贝缓存
        print("联网过的游客账户，或未绑定过的fb账户") --@DEL
        --AppServices.FacebookAccountData:NewUIDClearCache()
    elseif self.loginStatus == NewUser and self.PlayerInfo.bindingStatus == NewBinding then
        -- 新的fb账户绑定，绑定的游客账户从未联网
        -- 需要把DeviceId目录缓存拷到playerId
        print("新的fb账户绑定，绑定的游客账户从未联网") --@DEL
        self:MigrateVisitorAccountToNewUid(newUId)
    elseif self.loginStatus == OldUser and self.PlayerInfo.bindingStatus == NewBinding then
        -- 新的fb账户绑定，绑定的游客账户已经联网
        -- playerId就是老的游客playerId，不需要拷贝缓存
        print("新的fb账户绑定，绑定的游客账户已经联网") --@DEL
    end
end

function LoginServer:MigrateVisitorAccountToNewUid(newPlayerId)
    console.trace("MigrateVisitorAccountToNewUid", RuntimeContext.DEVICE_ID, newPlayerId) --@DEL
    LuaHelper.CopyFolder(RuntimeContext.DEVICE_ID, tostring(newPlayerId), true)
end
]]
--------------------------------------------------

--登陆流程结束
function LoginServer:Login_ConnectServer_Result(info)
    local function OnRetryLogin()
        sendNotification(CONST.GLOBAL_NOFITY.Login_Fail)
    end

    local resultType = info.loginResultType
    if resultType == LoginResultType.FAIL then
        ErrorHandler.ShowErrorMessage(Runtime.Translate("ui_systemerror") .. info.errorCode, OnRetryLogin)
    else
        sendNotification(CONST.GLOBAL_NOFITY.Login_Suc, info)
    end
end

---class 1002登陆游戏成功反馈
function LoginServer:OnEnterGameSuccess(response)
    --XDebug.BegMetric("OnEnterGameSuccess") --@APM
    App.response = response -- 重构代码，先把未解析的消息缓存下来
    local resourceMsg = response.resourceMsg

    --上传SDK
    local nickName = resourceMsg.nickName
    local sex = resourceMsg.sex
    local diamonds = resourceMsg.diamonds
    local material = resourceMsg.material
    local energyValue = resourceMsg.energyValue
    -- local icon = resourceMsg.icon
    -- local unlockAvatars = response.playerInfoResp.unlockAvatars
    -- local frame = response.playerInfoResp.frame
    -- local unlockFrames = response.playerInfoResp.unlockFrames
    local level = resourceMsg.level
    local energyValueTime = math.floor((resourceMsg.energyValueTime or 0) / 1000)
    local starValue = resourceMsg.starNum
    local alterNameCnt = resourceMsg.alterNameCnt
    local createTime = resourceMsg.createTime
    local payCount = resourceMsg.payPlayer
    local registVersion = resourceMsg.registVersion
    local infiniteHeartTime = math.floor((resourceMsg.infiniteEnergy or 0) / 1000)
    local updateTime = math.floor((resourceMsg.levelUpdateTime or 0) / 1000)
    local compensateState = resourceMsg.compensateState or 0
    local openMagicNum = resourceMsg.openMagicNum or 0
    local previousEnterTime = resourceMsg.previousEnterTime or 0 --上次登录时间
    local totalRecharge = resourceMsg.totalRecharge or 0
    local timeZone = resourceMsg.timeZone or nil
    AppServices.TeamManager.SetTeamId(resourceMsg.teamId or "")
    AppServices.TeamManager.Set_joinTeamCdStart(
        resourceMsg.joinTeamCdStart and resourceMsg.joinTeamCdStart // 1000 or 0
    )
    print("!!!   User Create Time: ", createTime) --@DEL
    --[[
    local shopMsg = nil
    if response.shopMsg then
        shopMsg = {}
        for _, value in ipairs(response.shopMsg) do
            local t = {}
            t.shopId = value.shopId
            t.first = value.first
            shopMsg[t.shopId] = t
        end
    end
]]
    local data = {
        uid = self.PlayerInfo.uid,
        nickName = nickName,
        sex = sex,
        -- headImage = icon,
        -- unlockAvatars = unlockAvatars,
        -- avatarFrame = frame,
        -- unlockFrames = unlockFrames,
        diamondNumber = diamonds,
        coinNumber = material,
        level = level,
        heartNumber = energyValue,
        heartStartTime = energyValueTime,
        starNumber = starValue,
        itemList = Net.Converter.ConvertDictionary(
            response.itemList.items,
            "itemId",
            Net.Converter.ConvertItemMsgItemId
        ),
        alterNameCnt = alterNameCnt,
        createTime = createTime,
        payCount = payCount,
        registVersion = registVersion,
        infiniteHeartTime = infiniteHeartTime,
        updateTime = updateTime,
        compensateState = compensateState,
        openMagicNum = openMagicNum,
        --shopInfo = shopMsg,
        previousEnterTime = previousEnterTime,
        totalRecharge = totalRecharge,
        exp = resourceMsg.exp,
        usedItems = {
            [ItemId.ENERGY] = resourceMsg.consumeEnergyCnt
        },
        lastRechargeTime = resourceMsg.lastRechargeTime,
        timeZone = timeZone,
        backReward = response.backReward
    }

    AppServices.User:SyncData(data)
    RuntimeContext.ENTERED_GAME = true
    console.systrace("UserManager.SyncData:", table.tostring(data)) --@DEL

    AppServices.User:SetLimiteTimeProduct(response.limitedTimeProducts)
    --local dayRewardInfo = response.dayRewardInfo
    --AppServices.DayRewardManager:Initialize(dayRewardInfo)
    --AppServices.ProductManager:Init()
    -- App.mapGuideManager:InitFromRequest()
    --初始化皮肤数据 玩家个人信息：头像、框、皮肤等
    AppServices.SkinLogic:Init(response.playerInfoResp)
    AppServices.AvatarFrame:Init(response.playerInfoResp)
    AppServices.Avatar:Init(response.playerInfoResp)

    AppServices.Task:InitMissionProgress(response.taskList)
    --XDebug.PeekMetric("beforeactivity", "OnEnterGameSuccess", "code", "timecost") --@APM

    App.loginLogic:SetEnteredGame(true)

    AppServices.EventDispatcher:dispatchEvent(GlobalEvents.LoginIn, {lastLoginTime = previousEnterTime})
    ---注册修复建筑的监听
    AppServices.BuildingRepair:RegisterListener()
    ---初始化道具收藏系统
    AppServices.CollectionItem:Init()

    AppServices.GiftManager:GiftInfoRequest()

    --登陆成功后清空登陆数据，保留玩家数据
    self.loginParam = {}

    HeartManager:Init(energyValueTime)
    AppServices.Unlock:LoginCheck(response.systemOpenInfo.systemIds)

    AppServices.BagDot:ProcessUser()
    AppServices.ActivityCalendar:Awake()

    --AppServices.ProductManager:InitSubscribe(response.subscribeInfos)

    local missionNames = AppServices.Task:GetLogTaskName()
    DcDelegates:Log(
        SDK_EVENT.game_enter,
        {
            level = AppServices.User:GetCurrentLevelId(),
            diamondCount = AppServices.User:GetItemAmount(ItemId.DIAMOND),
            energyCount = AppServices.User:GetItemAmount(ItemId.ENERGY),
            goldCount = AppServices.User:GetItemAmount(ItemId.COIN),
            fbConnected = self.accountType == FACEBOOK,
            currentMissions = missionNames
        }
    )
    --XDebug.EndMetric("OnEnterGameSuccess", "code", "timecost") --@APM
    AppServices.AdsManager:CheckCached()
    -- 初始化完成后加入bi参数
    DcDelegates:LogOnlineTime()

    if AppServices.User.Default:GetKeyValue(UserDefaultKeys.KeyLogLanguage, true) then
        AppServices.User.Default:SetKeyValue(UserDefaultKeys.KeyLogLanguage, false)
        --console.error(AppServices.User:GetLanguage(), LogicContext:GetDefaultLanguage())
        DcDelegates:Log(
            SDK_EVENT.user_language,
            {osLanguage = LogicContext:GetDefaultLanguage(), language = AppServices.User:GetLanguage(), type = 1}
        )
    end

    Util.RequestAFReportHistoryList()
end

--游戏内登录（callback原则上都可以用消息传递出去，注册接收就行,不确定主体）
function LoginServer:IngameLogin_ConnectServer(info, callback, bindpage)
    --连接服务器成功
    local function ConnectServer_Success(response)
        DcDelegates:Log(
            "ingame_login_result",
            {success = true, identity = self.loginParam.platformType, osType = self.loginParam.osType}
        )

        --检查是否需要选择账号
        if response.loginStatus == 2 then
            local selectInfo = {}
            for key, value in ipairs(response.selectPlayerInfos) do
                if value.playerId ~= nil then
                    table.insert(
                        selectInfo,
                        {
                            playerId = value.playerId,
                            diamond = value.diamond,
                            level = value.level,
                            time = value.lastLoginMill,
                            name = value.name,
                            callback = callback
                        }
                    )
                end
            end

            if not table.isEmpty(selectInfo) then
                PanelManager.showPanel(
                    GlobalPanelEnum.SelectAccountPanel,
                    {
                        commond = function(param)
                            self:IngameLogin_ChooseBindAccount(param, bindpage)
                        end,
                        selectInfo = selectInfo,
                        cancelCB = function()
                            Runtime.InvokeCbk(callback, false)
                            self.loginParam = {}
                        end
                    }
                )
            end
            return
        end

        local function UIDLogic()
            --屏幕显示
            LogicContext.UID = self.PlayerInfo.uid
            AppServices.AccountData:SetLastAccount(
                self.loginParam.account,
                self.PlayerInfo.uid,
                self.PlayerInfo.accountType,
                nil,
                self.PlayerInfo.fbFirstBind
            )
            --self:MigrateCacheDataIfNeeded(self.PlayerInfo.uid)
            AppServices.User:SetUid(self.PlayerInfo.uid)
            ConnectionManager:changeUserID(self.PlayerInfo.uid, self.PlayerInfo.sessionId, self.PlayerInfo.sequenceId)
            AppServices.User:SetFbAccount(self.PlayerInfo.fbAccount)
            AppServices.User:SetFbBindReward(self.PlayerInfo.fbBindReward)
            --AppServices.FacebookAccountData:SetFacebookBindStatus(self.PlayerInfo.fbBind == 1)
            sendNotification(CONST.GLOBAL_NOFITY.USER_UID_CHANGED, {uid = self.PlayerInfo.uid})
        end

        local function BuildPlayerInfo(responseInfo)
            --登录状态 0.正常登录 1.首次登录 2.需要选择playerid再次登录(8.1.0修改)
            self.loginStatus = responseInfo.loginStatus or 0
            --玩家id
            self.PlayerInfo.uid = responseInfo.playerId
            --是否绑定游客操作( 0.不是新绑定 1.新fb账号绑定 )
            self.PlayerInfo.bindingStatus = responseInfo.bindStatus
            -- 绑定sessionId
            self.PlayerInfo.sessionId = responseInfo.sessionId
            self.PlayerInfo.sequenceId = responseInfo.sequenceId
            --账号类型( 0.游客 1.fb 2.乐逗 4.apple) 按位操作 5表示fb+apple
            self.PlayerInfo.accountType = responseInfo.accountType

            --if self.PlayerInfo.fbBind == 0 and responseInfo.fbBind == 1 then
            --AppServices.FacebookAccountData:SetFbBindEnd(true)
            --end
            --Facebook绑定状态（0.未绑定 1.已绑定）
            self.PlayerInfo.fbBind = responseInfo.fbBind
            --登录返回fbAccount 如果有fb的情况 其实主要作用是用来读取fb头像
            self.PlayerInfo.fbAccount = responseInfo.fbAccount
            --是否有fb绑定奖励 0：没有 1：有
            self.PlayerInfo.fbBindReward = response.fbBindReward
            --是否已完成首次绑定fb 0:否   1:是 (注意本次有fb绑定奖励或曾经发放过fb绑定奖励时此值为1)
            self.PlayerInfo.fbFirstBind = response.fbFirstBind
        end

        self.channel = nil
        BuildPlayerInfo(response)

        local localAccountUid = AppServices.User:GetUid()
        local needReenter =
            (self.loginStatus == 0 and localAccountUid == RuntimeContext.DEVICE_ID) or
            (localAccountUid ~= RuntimeContext.DEVICE_ID and localAccountUid ~= self.PlayerInfo.uid)

        self.isLoggedIn = true
        UIDLogic()
        Runtime.InvokeCbk(callback, true)

        local resultParam = {
            channel = self:GetLoginChannel(),
            result = true
        }
        sendNotification(CONST.GLOBAL_NOFITY.IngameLogin_Result, resultParam)
        self.loginParam = {}
        if self.PlayerInfo.fbBindReward == 1 then
            PopupManager:CallWhenIdle(
                function()
                    AppServices.User:AddItem(
                        ItemId.ENERGY,
                        AppServices.Meta:GetConfigMetaValueNumber("FBFirstLoginRewardEnergyNum", 99),
                        ItemGetMethod.fb_bind_reward
                    )
                    App.loginLogic:ShowLoginReward()
                end
            )
        end
        if needReenter then
            ErrorHandler.ShowErrorMessage(
                Runtime.Translate("ui_login_apple_linksuccess_desc"),
                function()
                    --ReenterGame(true)
                    App:Quit({source = "IngameLogin"})
                end
            )
        end
    end

    --连接服务器失败
    local function ConnectServer_Fail(errorCode)
        AppServices.Connecting:ClosePanel()

        DcDelegates:Log(
            "ingame_login_result",
            {
                success = false,
                error = errorCode,
                identity = self.loginParam.platformType,
                osType = self.loginParam.osType
            }
        )
        ErrorHandler.ShowErrorPanel(errorCode)
        Runtime.InvokeCbk(callback, false)
        local resultParam = {
            channel = self:GetLoginChannel(),
            result = false
        }
        sendNotification(CONST.GLOBAL_NOFITY.IngameLogin_Result, resultParam)
    end

    self.loginParam = info or {}
    self.loginParam.bindpage = bindpage
    Net.Coremodulemsg_1001_Login_Request(self.loginParam, ConnectServer_Fail, ConnectServer_Success, nil, false)
    DcDelegates:Log("ingame_login_start", {identity = self.loginParam.platformType, osType = self.loginParam.osType})
end

function LoginServer:IngameLogin_ChooseBindAccount(info, bindpage)
    self.loginParam.playerId = info.playerId
    self:IngameLogin_ConnectServer(self.loginParam, info.callback, bindpage)
end

return LoginServer
