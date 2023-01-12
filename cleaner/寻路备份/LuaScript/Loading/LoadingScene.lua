local SuperCls = require "Game.Common.Scene"
local LoadingScene = class(SuperCls, "LoadingScene")

function LoadingScene:create(params)
    local inst = LoadingScene.new(params or {})
    inst:init()
    return inst
end

function LoadingScene:ctor()
    self.sceneMode = SceneMode.loading
end

--@param sceneid number @参数:场景编号
function LoadingScene:init()
    Localization.Instance:LoadFiles(
        {
            -- 同步加载
            "SystemErrorCode",
            "Tips",
            "UI",
            "Dragon"
        },
        {
            -- 分帧加载
            "Dialog",
            "Guide",
            "Pops",
            "Story",
            "AI",
            "Obstacle"
        }
    )

    local viewCfg = require "Loading.View.LoadingPanelCfg"
    self:initView(viewCfg)

    self.sceneMode = SceneMode.loading

    if RuntimeContext.UNITY_EDITOR then
        BResource.LoadBundles(CONST.RULES.GetSceneBundleDeps(), function()
            self:loadCommonRes()
        end)
    else
        self:loadCommonRes()
    end
    self.super.init(self)
    self.maskShowing = true
end

function LoadingScene:initView(cfg)
    if cfg.mediatorPath == nil or cfg.classPath == nil then
        error("PanelManager.showPanel: cfg.mediatorPath shouldn't be nil")
    end

    if not facade:hasMediator(cfg.mediatorPath) then
    --else
        local mediatorClass = require(cfg.mediatorPath)
        facade:registerMediator(mediatorClass.new(cfg.mediatorPath, nil))
    end

    local mediator = facade:retrieveMediator(cfg.mediatorPath)
    if mediator == nil then
        error("PanelManager.showPanel: mediator not exist")
    end

    mediator:setData(cfg, cfg.arguments)
    mediator:preparePanel()
    self.loadingPanelMediator = mediator
end

function LoadingScene:loadCommonRes()
    local prefetchs = require("Loading.LoadingSceneCacheRes")
    local assets = prefetchs.assets
    local assetCount = table.len(assets)
    local numAsset = 0
    local bundlesPercent = 0.1

    local cd = CountDownLatch.Create(2, function()
        sendNotification(LoadingPanelNotificationEnum.UPDATE_LOADING_PROCESS, {val = 100})

        -- try start game,不管是否自动登陆，加载都已经结束了
        AppServices.ItemIcons:Initialize()

        if RuntimeContext.FIRST_ENTER_GAME then
            DcDelegates:Log(SDK_EVENT.loading_complete)
        end

        local LocalDevice = require "User.LocalDevice"
        local musicOn = LocalDevice:GetValue(LocalDevice.Enum.MUSICON)
        if type(musicOn) == "nil" then
            musicOn = true
            LocalDevice:SetValue(LocalDevice.Enum.MUSICON, true, true)
        end
        DcDelegates:LogLoading(5)
        --由是否自动登陆来显示登陆界面，取消本地无SDK时的自动登陆，如果需要在相关SDK中加入，AUTO_LOGIN由SDK控制
        --sendNotification(LoadingPanelNotificationEnum.ShowGameStartButton, {val = true})
        App.loginLogic = require("Login.LoginLogic")
        App.loginLogic:Init()
        AppServices.ProductManager:Init()
        AppUpdateManager:CheckShowUpdatePanel()
    end)

    -- Asset载入
    local function OnAssetsLoadFinish()
        console.trace("OnAssetsLoadFinish") --@DEL
        cd:Done()
    end

    -- 版本检测
    local function OnCheckAppUpdateFinish()
        console.trace("OnCheckAppUpdateFinish") --@DEL
        cd:Done()
    end
    require "User.AppUpdateManager"
    AppUpdateManager:CheckAppUpdate(true, OnCheckAppUpdateFinish)

    -- 预取Bundle资源
    local function OnBundelPrefetchFinished()
        console.trace("OnBundlePrefetchFinished") --@DEL

        local function onLoadAssetsProgress()
            numAsset = numAsset + 1
            local percent = bundlesPercent + (numAsset / assetCount) * (1 - bundlesPercent)
            sendNotification(LoadingPanelNotificationEnum.UPDATE_LOADING_PROCESS, {val = percent})
        end
        App.commonAssetsManager:PrefetchAssets(assets, OnAssetsLoadFinish, onLoadAssetsProgress)
    end

    local inst = require("Manager.BundleManager")
    inst:SetBundlesPersist(prefetchs.bundles(RuntimeContext.PREFETCH_ALL_BUNDLES))

    local numBundle = 0
    local bundles = prefetchs.bundles(RuntimeContext.PREFETCH_ALL_BUNDLES)
    local bundlesCount = table.len(bundles)
    inst:LoadBundles(bundles, OnBundelPrefetchFinished, function()
        numBundle = numBundle + 1
        local percent = (numBundle / bundlesCount) * bundlesPercent
        sendNotification(LoadingPanelNotificationEnum.UPDATE_LOADING_PROCESS, {val = percent})
    end)
end

function LoadingScene:BeforeUnload()
    SuperCls.BeforeUnload(self)
    App.audioManager:ClearAudio(CONST.AUDIO.Music_MainCity)
end

return LoadingScene
