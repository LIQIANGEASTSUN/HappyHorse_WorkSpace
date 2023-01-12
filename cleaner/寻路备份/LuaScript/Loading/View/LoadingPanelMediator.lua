require "Loading.View.LoadingPanelNotificationEnum"

local LoadingPanelMediator = MVCClass("LoadingPanelMediator", pureMVC.Mediator)

---@type LoadingView
local panel
local proxy

function LoadingPanelMediator:ctor(...)
    LoadingPanelMediator.super.ctor(self, ...)
end

function LoadingPanelMediator:onRegister()
end

function LoadingPanelMediator:setData(_panelVO, _arguments)
    self.panelVO = _panelVO
    self.arguments = _arguments
end

function LoadingPanelMediator:preparePanel()
    if self:getViewComponent() == nil then
        local panelClass = require(self.panelVO.classPath)
        if panelClass == nil then
            error("BaseMediator:preparePanel: incorrect class path !! ")
        end

        local panelInstance = panelClass.new()
        self:setViewComponent(panelInstance)
        panelInstance:setArguments(self.arguments)
        panelInstance:bindView() -- zhukai

        self:onAfterSetViewComponent()
    end
end

function LoadingPanelMediator:onAfterSetViewComponent()
    panel = self:getViewComponent()

    local LoadingPanelProxy = require "Loading.Model.LoadingPanelProxy"
    proxy = LoadingPanelProxy.new()
    panel:setProxy(proxy)
end

function LoadingPanelMediator:listNotificationInterests()
    return {
        LoadingPanelNotificationEnum.UPDATE_LOADING_PROCESS,
        LoadingPanelNotificationEnum.ShowTitleCartoon,
        CONST.GLOBAL_NOFITY.Login_Suc
    }
end

function LoadingPanelMediator:handleNotification(notification)
    local name = notification:getName()
    -- local type = notification:getType()
    local body = notification:getBody() --message data

    panel = self:getViewComponent()

    --local function onLoginFinished(success, loginStatus)
    --    self:OnLoginFinished(success, loginStatus)
    --end

    if (name == LoadingPanelNotificationEnum.UPDATE_LOADING_PROCESS) then
        panel:setProgress(body.val or 0)
    elseif name == CONST.GLOBAL_NOFITY.Login_Suc then
        AppServices.Connecting:ClosePanel()
        self:OnLoginFinished(body)
    elseif name == LoadingPanelNotificationEnum.ShowTitleCartoon then
        panel:ShowTitleCartoon()
    end
end

function LoadingPanelMediator:OnLoginFinished(params)
    if params.loginResultType == LoginResultType.ABORT then
        -- sendNotification(LoadingPanelNotificationEnum.ShowGameButtonOnly, {val = true})
        sendNotification(CONST.GLOBAL_NOFITY.Login_Fail)
        return
    end

    local loadingCanvas
    local cgMask
    local loading
    local maskCanvas
    local logo

    --App.HSSdk:UserLogin(AppServices.User:GetUid())
    App:StartIngameDurationCounter()

    if RuntimeContext.FIRST_ENTER_GAME then
        DcDelegates:Log(SDK_EVENT.Game_enter, Util.AddUserStatsParams({}))
    end

    local function changeSceneComplete(fadeOutTrans, callback)
        local tween = GameUtil.DoFade(fadeOutTrans, 0, 1.6)
        tween:OnComplete(
            function()
                Runtime.CSDestroy(loading)
                Runtime.CSDestroy(loadingCanvas)
                Runtime.CSDestroy(maskCanvas)
                loading = nil
                loadingCanvas = nil
                maskCanvas = nil
                Runtime.InvokeCbk(callback)
            end
        )
        tween:SetEase(Ease.InCirc)
        if Runtime.CSValid(logo) then
            GameUtil.DoFade(logo, 0, 1.6):SetEase(Ease.InCirc)
        end
    end

    loadingCanvas = GameObject.Find("LoadingCanvas")
    GameObject.DontDestroyOnLoad(loadingCanvas)
    maskCanvas = GameObject.Find("UIMaskCanvas")
    GameObject.DontDestroyOnLoad(maskCanvas)

    cgMask = maskCanvas:FindGameObject("CGMask"):GetComponent(typeof(Image))
    loading = loadingCanvas:FindGameObject("Loading")
    local logosctrl = loadingCanvas:FindGameObject("logos"):GetComponent(typeof(CS.LogosContorller))
    if logosctrl then
        logo = logosctrl.logo
    end

    loading:SetActive(true)
    cgMask:SetActive(false)

    local function RegistRefreshTimeWhenResume()
        App:AddAppOnPauseCallback(
            function(isPause)
                if not isPause then
                    local function onSuc(response)
                        if response and response.playerTime then
                            TimeUtil.ServerRefreshTime(response.playerTime)
                        end
                    end

                    Net.Coremodulemsg_1028_Time_Request(nil, nil, onSuc)
                end
            end
        )
    end

    AppServices.EventDispatcher:addObserver(
        self,
        GlobalEvents.MAIN_CITY_FULLY_LOADED,
        function()
            AppServices.EventDispatcher:removeObserver(self, GlobalEvents.MAIN_CITY_FULLY_LOADED)
            changeSceneComplete(
                loading,
                function()
                    Runtime.InvokeCbk(App.scene.EnableUI, App.scene)
                    --RegistRefreshTimeWhenResume()
                end
            )
        end
    )

    -- zhukai:RequestMapDataProcessor 也需要并行请求
    local sceneName = tostring(params.msg.sceneInfo.sceneId)
    -- local sceneName = AppServices.User.Default:GetKeyValue(UserDefaultKeys.KeyLastSceneName, CONST.GAME.SCENE_NAMES[1])
    -- local validators = CONST.RULES.SceneUnlocked
    -- local validatorsSceneType =  CONST.RULES.IsActivityScene
    -- local closeEntries = App.response.sceneCloseTimeResp.closeEntries
    -- local meta = AppServices.Meta:GetSceneCfg()
    -- local cityName = CONST.GAME.SCENE_NAMES[1]
    -- local cfg = meta[sceneName]
    -- if not cfg or cfg.whetherRecordPos == 0 then
    --     sceneName = cityName
    -- end
    -- local isSceneClose = false
    -- for _, v in ipairs(closeEntries) do
    --     if v.sceneId == sceneName and validatorsSceneType(meta[sceneName].type) then
    --         isSceneClose = v.closeTime / 1000 - TimeUtil.ServerTime() <= 0
    --         break
    --     end
    -- end
    -- --如果要进入的场景未开放则加载主城场景(玩家可能回档，回档前的场景可能回档后未开放)
    -- local function GetValidScene(sceneName)
    --     if not validators(sceneName) or isSceneClose then
    --         return cityName
    --     end

    --     if meta[sceneName] and meta[sceneName].type == SceneType.Exploit then
    --         return cityName
    --     end

    --     if meta[sceneName] and meta[sceneName].type == SceneType.Parkour then
    --         return cityName
    --     end

    --     if meta[sceneName] and meta[sceneName].type == SceneType.Mow then
    --         return cityName
    --     end

    --     if meta[sceneName] and meta[sceneName].type == SceneType.GoldPanning then
    --         return cityName
    --     end

    --     return sceneName
    -- end

    -- sceneName = GetValidScene(sceneName)

    -- AppUpdateManager:RequsetAppUpdateRewardInfo(
    --     function()
    --         cd:Done()
    --     end
    -- )

    console.warn(nil, "服务器返回的场景号是" .. sceneName) --@DEL
    local ChangeSceneProcessor = require "Game.Processors.ChangeSceneProcessor"
    ChangeSceneProcessor.Preload(
        sceneName,
        function()
            local ChangeSceneAnimation = require "Game.Common.ChangeSceneAnimation"
            ChangeSceneAnimation.Instance():EnterCityIn(
                function()
                    local extraParam = {}
                    extraParam.IsFromLoading = true
                    extraParam.startTime = TimeUtil.ServerTime()
                    extraParam.msg = params.msg
                    local processor = require "Game.Processors.ChangeSceneProcessor"
                    processor.Change(sceneName, nil, extraParam)
                end
            )
        end
    )
end

return LoadingPanelMediator
