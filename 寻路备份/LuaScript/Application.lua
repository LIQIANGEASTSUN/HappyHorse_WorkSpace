require "Utils.Utils"

require "Game.Dc.DcDelegates"

require "System.Core.MVCFramework"
require "System.Core.Actions"
require "System.Core.IDestroy"
require "System.Core.Data.DataRef"
require "System.Core.Network.ConnectionManager"
require "System.Error.ErrorCodes"
require "System.Error.ErrorHandler"
require "System.Core.PopupJob.PopupQueue"
require "Item.ItemId"
require "UI.UI"

require "Game.Common.Scene"

require "Manager.AppServices"
require "Manager.ActivityServices"
require "Manager.SceneServices"
require "Manager.AssetsManager"
require "Manager.PanelManager"

require "MainCity.Include"

---@class Application
local Application = {}
function Application:ctor()
    -- status
    self.screenPlayActive = false
    ---@type GlobalFlags
    self.globalFlags = include("Game.GlobalFlags")

    RuntimeContext.LEGACY_DEVICE = BCore.IsLowLevelDevice()
    console.trace("LEGACY_DEVICE:", RuntimeContext.LEGACY_DEVICE) --@DEL

    local mapp = CS.BetaGame.MainApplication
    self.firstLaunch = mapp.firstLaunch
    self.httpClient = mapp.httpClient
    self.luaSceneManager = mapp.luaSceneManager
    self.scheduler = mapp.scheduler
    --self.paymentdelegate = mapp.paymentManager
    self.audioManager = mapp.audioManager
    self.FAQDelegate = mapp.faqDelegate
    self.iconsLoader = AssetsManager.new()

    self.comicsTextureLoader = AssetsManager.new()
    self.commonAssetsManager = AssetsManager.new()
    self.uiAssetsManager = AssetsManager.new()
    self.dramaAssetManager = AssetsManager.new()
    ---@class AssetsManager @建筑资源管理器
    self.buildingAssetsManager = AssetsManager.new()

    ---@type MapGuideManager
    local MapGuideManager = include("MapGuide.MapGuideManager")
    self.mapGuideManager = MapGuideManager:Create()
    self.popupQueue = PopupQueue:Create()

    ConnectionManager:reset("VISITOR", -999)
    PanelManager:Init()

    self.dayRefreshList = {}
    self.dayRefreshNoDelayList = {}

    self.localDayRefreshList = {}

    --scene will change listeners
    self.sceneWillChangeListeners = {}

    local NextFrameActions = include("Game.Common.NextFrameActions")
    self.nextFrameActions = NextFrameActions.new()
    self.buttonBlock = false

    --AppServices.ProductManager:Init()

    --允许中断暂停执行监听逻辑
    self.pauseAlive = true
end

function Application:startWaitCoroutine(func, sec)
    local yield_return = (require "System.Core.Glue.cs_coroutine").yield_return
    local co =
        coroutine.create(
        function()
            yield_return(CS.UnityEngine.WaitForSeconds(sec))
            func()
        end
    )
    console.assert(coroutine.resume(co))
end

function Application:Awake()
    console.trace("Application:Awake") --@DEL

    --AppServices.AdsManager:InitAttributeChangeCallback()
    self.attributeString = ""
    DcDelegates.Bi:SetOnAttributeChangeLuaCallback(
        function(str)
            self.attributeString = str
        end
    )

    --AppServices.PaymentManager:Initialize()

    self:initScene("LoadingScene", false)
    self:StartGame()

    --self.TouchEventProcessor = include("Game.Processors.TouchEventProcessor")
    -- 禁止息屏
    --BCore.KeepScreenNeverSleep(true)
end

function Application:StartGame()
    BCore.Track("Application:StartGame BUNDLE_VERSION:" .. RuntimeContext.BUNDLE_VERSION)
    BCore.TrackCustomEvent("bundle_version", RuntimeContext.BUNDLE_VERSION)
    console.trace("Application:StartGame") --@DEL
    registerMediator("ApplicationMediator", self)
end

function Application:OnErrorCode(errorCode, isHttpError, errorStr, url)
    console.trace("ShowErrorPanel", errorCode) --@DEL
    -- 弹报错消息的时候强行解锁
    BCore.Track("Application:OnErrorCode:" .. errorCode or "" .. "content:" .. errorStr or "")

    if isHttpError then
        --local name = "Http错误" .. errorCode
        DcDelegates:Log(SDK_EVENT.show_httpError_code, {errorCode = errorCode, name = errorStr, ip = "", url = url})
    else
        local name = DcDelegates.Legacy:GetErrorCodePrettyName(errorCode)
        DcDelegates:Log(SDK_EVENT.show_error_code, {errorCode = errorCode, name = name, url = url})
    end
    sendNotification(CONST.GLOBAL_NOFITY.Lock_Screen, {false, "*"})
end

-- scene manager -------------------------------------------------------
function Application:Update(dt)
    self.nextFrameActions:Execute()

    if not self.scene.isDestroyed then
        self.scene:Update(dt)
    end
    --self.TouchEventProcessor:Update()
    --AppServices.PaymentManager:Update()
end

function Application:LateUpdate(dt)
    self.scene:LateUpdate(dt)
    self.buttonBlock = false
end

function Application:DrawGizmos()
    if self.scene and type(self.scene.DrawGizmos) == "function" then
        self.scene:DrawGizmos()
    end
end

function Application:OnGUI()
    -- pause editor
    if CS.UnityEngine.Input.GetKeyDown(CS.UnityEngine.KeyCode.F2) then
        self.nextFrameActions:Add(
            function()
                CS.UnityEditor.EditorApplication.isPaused = true
            end
        )
    end
    if self.scene and type(self.scene.OnGUI) == "function" then
        self.scene:OnGUI()
    end
end

function Application:SetPauseAlive(value)
    self.pauseAlive = value
end

function Application:OnPause()
    if not self.pauseAlive then
        return
    end
    if self.appOnPauseCallbacks then
        for _, v in ipairs(self.appOnPauseCallbacks) do
            Runtime.InvokeCbk(v.callback, true)
        end
    end
    if self.scene then
        self.scene:OnPause()
    end
    -- GC
    Runtime.CSCollectGarbage(true)
end

function Application:OnResume()
    if not self.pauseAlive then
        return
    end
    if self.appOnPauseCallbacks then
        for _, v in ipairs(self.appOnPauseCallbacks) do
            Runtime.InvokeCbk(v.callback, false)
        end
    end
end

function Application:OnGameRelease()
    --[[
    if RuntimeContext.UNITY_EDITOR then
        return
    end
    if RuntimeContext.UNITY_ANDROID then
        CS.System.Diagnostics.Process.GetCurrentProcess():Kill()
    end
    ]]
end

function Application:AddAppOnPauseCallback(cb)
    if cb ~= nil then
        self.appOnPauseCallbacks = self.appOnPauseCallbacks or {}
        table.insert(self.appOnPauseCallbacks, {callback = cb})
    end
end

function Application:RemoveAppOnPauseCallback(cb)
    if cb ~= nil and self.appOnPauseCallbacks then
        table.removeIf(
            self.appOnPauseCallbacks,
            function(l)
                return l.callback == cb
            end
        )
    end
end

---@return Scene
function Application:getRunningLuaScene()
    return self.scene
end

function Application:initScene(name, eMode, onFinish)
    console.trace("Application:initScene:" .. name) --@DEL
    local cfg = CONST.RULES.LoadSceneConfig(name)
    local def = require(cfg.class)

    ---@type MainCity|Scene
    self.scene = def:create(cfg.params)
    self.scene._name = cfg.name(RuntimeContext.LITE_SCENE)
    self.scene:Awake()
end

---trigger before anything will change
function Application:AddSceneWillChangeListener(listener, args)
    table.insert(self.sceneWillChangeListeners, {listener = listener, args = args})
end
function Application:RemoveSceneWillChangeListener(listener)
    table.removeIf(
        self.sceneWillChangeListeners,
        function(t)
            return t.listener == listener
        end
    )
end
function Application:TriggerSceneWillChangeEvt(next)
    self.popupQueue:Clear()

    if not self.sceneWillChangeListeners then
        return
    end
    local cbs = self.sceneWillChangeListeners
    self.sceneWillChangeListeners = {}
    for i = 1, #cbs do
        Runtime.InvokeCbk(cbs[i].listener, cbs[i].args, next)
    end
end

function Application:addScreenPlayActivityListener(listener, args, removeAfterTrigger)
    self.screenPlayListeners = self.screenPlayListeners or {}
    table.insert(self.screenPlayListeners, {callback = listener, args = args, remove = removeAfterTrigger})
end

function Application:removeScreenPlayActivityListener(listener)
    if self.screenPlayListeners then
        table.removeIf(
            self.screenPlayListeners,
            function(l)
                return l.callback == listener
            end
        )
    end
end

function Application:IsScreenPlayActive()
    return self.screenPlayActive
end

function Application:setScreenPlayActive(active)
    self.screenPlayActive = active
    if self.screenPlayListeners then
        for _, listener in pairs(self.screenPlayListeners) do
            Runtime.InvokeCbk(listener.callback, listener.args, active)
            if listener.remove then
                table.remove(self.screenPlayListeners, _)
            end
        end
    end
end

function Application:StartIngameDurationCounter()
    local function onTick()
        RuntimeContext.IN_GAME_DURATION = RuntimeContext.IN_GAME_DURATION + 1
        --跨天逻辑, 北京时间19点刷新
        if TimeUtil.ServerTime() - RuntimeContext.CURRENT_DATATIME > TimeUtil._24H_To_Sec + TimeUtil._19H_To_Sec then
            self:StartDayRefresh()
            MessageDispatcher:SendMessage(MessageType.DAY_SPAN)
            RuntimeContext.CURRENT_DATATIME = RuntimeContext.CURRENT_DATATIME + TimeUtil._24H_To_Sec
        end
        -- local timeZoneTime = TimeUtil.GetTimeZoneTime()
        -- if timeZoneTime then
        --     if timeZoneTime >= RuntimeContext.CURRENT_TIMEZONE_REFRESHTIME then
        --         local str1 = TimeUtil.GetTimeString(timeZoneTime) --@DEL
        --         local str2 = TimeUtil.GetTimeString(RuntimeContext.CURRENT_TIMEZONE_REFRESHTIME) --@DEL
        --         -- console.lzl("时区时间", str1) --@DEL
        --         -- console.lzl("刷新时间", str2) --@DEL
        --         RuntimeContext.CURRENT_TIMEZONE_REFRESHTIME =
        --             RuntimeContext.CURRENT_TIMEZONE_REFRESHTIME + TimeUtil._24H_To_Sec
        --         self:StartLocalDayRefresh()
        --     end
        -- end
        if TimeUtil.ServerTime() >= RuntimeContext.CURRENT_TIMEZONE_REFRESHTIME then
            RuntimeContext.CURRENT_TIMEZONE_REFRESHTIME =
                RuntimeContext.CURRENT_TIMEZONE_REFRESHTIME + TimeUtil._24H_To_Sec
            self:StartLocalDayRefresh()
        end
    end
    WaitExtension.InvokeRepeating(onTick, 0, 1)
end

function Application:AddToDayRefreshList(observer)
    table.insertIfNotExist(self.dayRefreshList, observer)
end

--强制0延迟刷新的添加与删除都依赖外部的触发，不会在逻辑中自动添加与取消
--nodelay 标记dayRefreshNoDelayList有事件，pause 标记dayRefreshList有事件
function Application:SetDayRefreshNoDelayOnlyOnce(observer, value)
    observer.noDelay = value
    --先不主动删除取消的注册，常驻可以减少UI频繁打开关闭造成的列表操作，有需求了再打开下面的逻辑
    if value then
        table.insertIfNotExist(self.dayRefreshNoDelayList, observer)
    end
    --[[
    if not value then
        table.removeIfExist(self.dayRefreshNoDelayList, observer)
    else
        if table.indexOf(self.dayRefreshList, observer) then
            if value then
                table.insertIfNotExist(self.dayRefreshNoDelayList, observer)
            end
        end
    end
    ]]
end

--增加0延迟刷新机制，为了应对某些UI在面板中显示倒计时时与每日刷新延迟冲突
function Application:StartDayRefresh()
    print("Application:StartDayRefresh()") --@DEL
    BCore.Track(
        "Application:StartDayRefresh:ServerTime:" .. TimeUtil.ServerTime() .. " LocalTime:" .. TimeUtil.LocalTime()
    )
    local delay = math.random(0, 5)

    for _, observer in ipairs(self.dayRefreshNoDelayList) do
        if observer.noDelay then
            observer.pause = true
            Runtime.InvokeCbk(observer.refreshFunc)
        end
    end

    local refresh = function()
        for _, observer in ipairs(self.dayRefreshList) do
            if not observer.pause then
                Runtime.InvokeCbk(observer.refreshFunc)
            else
                observer.pause = false
            end
        end
    end
    --随机延迟，防止更新瞬间服务器压力太大
    WaitExtension.SetTimeout(refresh, delay)
end

function Application:AddToLocalDayRefreshList(observer)
    table.insertIfNotExist(self.localDayRefreshList, observer)
end

function Application:StartLocalDayRefresh()
    -- -- console.lzl("Application:StartLocalDayRefresh()") --@DEL
    local delay = math.random(0, 5)

    local refresh = function()
        for _, observer in ipairs(self.localDayRefreshList) do
            Runtime.InvokeCbk(observer.refreshFunc)
        end
    end
    --随机延迟，防止更新瞬间服务器压力太大
    WaitExtension.SetTimeout(refresh, delay)
end

function Application:Quit(params)
    if RuntimeContext.UNITY_EDITOR then
        CS.UnityEngine.Debug.LogWarning("Force Exiting : " .. RuntimeContext.TRACE_BACK())
        CS.UnityEditor.EditorApplication.isPlaying = false
    elseif RuntimeContext.UNITY_ANDROID then
        DcDelegates:Log(SDK_EVENT.QuitApplication,params)
        CS.UnityEngine.PlayerPrefs.Save()
        Util.BlockAll(-1, "QuitApplication")
        WaitExtension.SetTimeout(function()
            CS.BetaGame.MainApplication.Instance:GameClientQuit(true)
        end,2
        )
    elseif RuntimeContext.UNITY_IOS then
        DcDelegates:Log(SDK_EVENT.QuitApplication,params)
        CS.BetaGame.MainApplication.Instance:GameClientQuit(false)
    end
end

function Application:OnKeyEvent(vKey)
    if not RuntimeContext.UNITY_IOS then
        local processor = require("Game.Processors.KeyEventProcessor")
        processor:Start(vKey)
    end
end

Application:AddAppOnPauseCallback(
    function(isPause)
        if isPause then
            return
        end
        AppServices.DynamicUpdateManager:Start()
    end
)

if not RuntimeContext.VERSION_DISTRIBUTE then
    Application:AddAppOnPauseCallback(
        function(isPause)
            if isPause then
                return
            end
            require("Game.Debug.Commands").connect()
        end
    )
end

Application:ctor()

return Application
