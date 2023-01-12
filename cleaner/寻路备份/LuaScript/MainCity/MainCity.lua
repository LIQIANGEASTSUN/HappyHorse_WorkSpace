-- require "MainCity.Include"
require "MainCity.Character.CharacterManager"

require "ScreenPlays.Include"

require "MainCity.Manager.PopupManager"
require "MainCity.Manager.QueueLineManage"
require "MainCity.Manager.MapBubbleManager"

local Interaction = require("MainCity.Interaction.Interaction")
local Director = require "ScreenPlays.Director"

local MapManager = require("MainCity.Manager.MapManager")
local ObjectManager = require("MainCity.Manager.ObjectManager")

local SuperCls = require "UI.Scene.SceneWithHomeUI"
--local PopQueueCtor = require("MainCity.Helper.PopQueueCtor")

---@class MainCity:SceneWithHomeUI @场景管理类
local MainCity = class(SuperCls, "MainCity")

function MainCity.create()
    local inst = MainCity.new()
    return inst
end

function MainCity:ctor()
    self.alive = true
    self.sceneMode = SceneMode.home
    App.popupQueue:Clear()
    self.sceneDatas = nil
    self.currentSceneData = nil

    self.director = Director.new()
    ---@type Interaction
    self.interaction = Interaction.new()

    self.fullyLoadedCounter = 0
    self.rightBtnLayout = {}
    self.sceneWillChange = nil

    Util.BlockAll(-1, "main_city_first_enter")

    self.showRightIconsCbs = {}
    ---@type ObjectManager
    self.objectManager = nil

    --打点用
    self.addedItems = {}
end

--0 启动全局功能模块（不需要解锁和无条件限定的功能）
--1 加载基础模块
--场景
--摄像机
--角色
--龙
--2 加载数据层和管理器
--3 绘制UI
--4 启动逻辑层
--5 初始化结束
function MainCity:init(params, extraParam)
    SuperCls.init(self)

    self.params = params
    self.extraParam = extraParam

    -- 注册观察者事件
    self:RegisterListener()
    --1 加载基础模块（job 并行运行，需要加载更多模块通过job创建）
    local sequence = LoadCount:GetJob("InitBaseModule")
    sequence:AddJob(
        function(finishCallback)
            self:InitBaseModule(finishCallback)
        end
    )
    sequence:AddJob(
        function(finishCallback)
            self:InitCharacterAndCamera(finishCallback)
        end
    )
    sequence:AppendFinish(
        function()
            --2 加载数据层和管理器
            return self:RequestServerData()
        end
    )
    sequence:DoJob()

    --打点 记录玩家进入场景时的时间点
    self.enterSceneTime = TimeUtil.ServerTime()
end

function MainCity:InitBaseModule(finishCallback)
    --里面的初始化顺序不要乱动, 设计很精妙0^0
    local ts = CS.System.DateTime.Now
    --1.初始化地图
    local layout = CONST.RULES.LoadMapLayout(self.params.sceneId)
    self.mapManager = MapManager.new()
    self.mapManager:InitLocal(layout)

    --2.初始化障碍物
    local objData = CONST.RULES.LoadObjectData(self.params.sceneId)

    self.objectManager = ObjectManager.new(objData)

    --3. 根据服务器数据更新障碍物(或创建/或销毁)
    self.objectManager:CreateAgents(self.extraParam.serverMapData)

    --4. 根据服务器数据更新地图
    self.mapManager:InitServer()
    local delta = CS.System.DateTime.Now - ts
    DcDelegates:Log(
        SDK_EVENT.obstacles_load_cost,
        {
            sceneID = self:GetCurrentSceneId(),
            loadingtime = delta.TotalSeconds
        }
    )
    console.lj("generate scene [" .. self:GetCurrentSceneId() .. "] cost:" .. delta.TotalSeconds) --@DEL

    --加载场景特效
    if self.params.snowEffect then
        local assetPath = "Prefab/UI/HomeScene/Effects/Snow.prefab"
        local function OnLoadFinished()
            BResource.InstantiateFromAssetName(assetPath)
        end
        App.uiAssetsManager:LoadAssets({assetPath}, OnLoadFinished)
    end

    Runtime.InvokeCbk(finishCallback)
end

function MainCity:InitCharacterAndCamera(finishCallback)
    -- 主角发光特效开关
    XGE.EffectExtension.ActorSpotEffect(CONST.RULES.ActorEffectEanbled())

    local min, max = self.mapManager:GetCameraAnchor()
    MoveCameraLogic.Instance(true):Init(nil, min, max)

    CharacterManager.Instance():Init()
    self.femalePlayer = CharacterManager.Instance():Get("Femaleplayer")
    self.femalePlayer:SetBeginningPosition()

    Runtime.InvokeCbk(finishCallback)
end

function MainCity:RequestServerData()
    local sequence = LoadCount:GetJob("FetchServerDate")
    local ts = CS.System.DateTime.Now
    sequence:AddJob(
        function(finishCallback)
            AppServices.MailManager:RequestMailList(finishCallback)
        end
    )
    sequence:AddJob(
        function(finishCallback)
            AppServices.Task:CheckTaskOnChangeScene(finishCallback)
        end
    )
    sequence:AddJob(
        function(finishCallback)
            AppServices.SceneCloseInfo:Request(1, finishCallback)
        end
    )
    sequence:AddJob(
        function(finishCallback)
            AppServices.CollectionItem:CheckBubble(finishCallback)
        end
    )
    sequence:AddJob(
        function(finishCallback)
            ActivityServices.ActivityManager:RequestServerData(finishCallback)
        end
    )
    sequence:AddJob(
        function(finishCallback)
            ActivityServices.LevelMapActivity:RequestServerData(finishCallback)
        end
    )
    sequence:AddJob(
        function(finishCallback)
            AppServices.Scarecrow:ServerDataRequest(finishCallback)
        end
    )
    sequence:AddJob(
        function(finishCallback)
            AppServices.SkinEquipManager:SkinListRequest(finishCallback)
        end
    )
    sequence:AddJob(
        function(finishCallback)
            AppServices.MagicalCreatures:EnterSceneCreateAndStartDriver(
                function()
                    finishCallback()
                    -- self:TryFullyLoaded()
                    if App.scene:IsScene(SceneMode.home) then
                        App.scene.view.dragonBagBtn:CheckShowOrHide()
                        local breedBtn = App.scene:GetWidget(CONST.MAINUI.ICONS.BreedButton)
                        breedBtn:CheckShowOrHide()
                        local mergeBtn = App.scene:GetWidget(CONST.MAINUI.ICONS.MergeButton)
                        mergeBtn:CheckShowOrHide()
                        local labBtn = App.scene:GetWidget(CONST.MAINUI.ICONS.LabButton)
                        labBtn:CheckShowOrHide()
                        local dressBtn = App.scene:GetWidget(CONST.MAINUI.ICONS.DressingHut)
                        dressBtn:CheckShowOrHide()
                        ---@type DragonAssistButton
                    end
                    local dragonAssistBtn = App.scene:GetWidget(CONST.MAINUI.ICONS.DragonAssistBtn)
                    if dragonAssistBtn then
                        dragonAssistBtn:CheckShowOrHide()
                    end
                    if AppServices.Unlock:IsUnlock("RepairIcon") then
                        App.scene:RefreshWidget(CONST.MAINUI.ICONS.BuldingRepairBtns)
                    end
                end
            )
        end
    )
    sequence:AddJob(
        function(finishCallback)
            App.mapGuideManager:InitFromRequest(finishCallback)
        end
    )
    sequence:AddJob(
        function(finishCallback)
            AppServices.BuildingRepair:InitSceneBuildings(finishCallback)
        end
    )

    sequence:AddJob(
        function(finishCallback)
            AppServices.SaveAnimal:RequestServerData(finishCallback)
        end
    )

    sequence:AddJob(
        function(finishCallback)
            AppServices.InviteFriends:RequestServerData(finishCallback)
        end
    )

    if self:IsMainCity() then
        sequence:AddJob(
            function(finishCallback)
                AppServices.RecycleDragon:RecycleDragonInfoRequest(finishCallback)
            end
        )
    end

    sequence:AppendFinish(
        function()
            local delta = CS.System.DateTime.Now - ts
            console.lj("fetch serverdata  cost:" .. delta.TotalSeconds) --@DEL
            return self:InitManager()
        end
    )
    ConnectionManager:block()
    sequence:DoJob()
    ConnectionManager:flush(true)
end

function MainCity:InitManager()
    local function onTranslationAnimFinished(hasAnimation)
        if hasAnimation then
            Util.BlockAll(0, "main_city_first_enter")
        end
    end
    self:OnFullyLoaded()
    self.objectManager.allAgentLoaded = true
    MessageDispatcher:SendMessage(MessageType.Global_After_Scene_Loaded, self.params.sceneId, self.sceneMode)
    --???
    local isShow = AppServices.User.Default:GetKeyValue("ShowTaskListArrow", 0)
    local taskBtn = App.scene:GetWidget(CONST.MAINUI.ICONS.TaskBtn)
    if taskBtn and isShow == 1 then
        AppServices.User.Default:SetKeyValue("ShowTaskListArrow", 0, true)
        taskBtn:ShowListArrow()
    end
    --
    local ChangeSceneAnimation = require "Game.Common.ChangeSceneAnimation"
    ChangeSceneAnimation.Instance():PlayOut(onTranslationAnimFinished)

    App.popupQueue:Init()
end

function MainCity:EnableUI()
    Util.BlockAll(0, "main_city_first_enter")
    self.uiEnabled = true
end

function MainCity:OnFullyLoaded()
    local logicList = {}
    local function RegistOnFullyLoaded(func)
        table.insert(logicList, func)
    end

    if RuntimeContext.IS_NEW_USER then
        RuntimeContext.IS_NEW_USER = false
    end

    if RuntimeContext.FIRST_ENTER_GAME then
        -- 第一次登录游戏结束
        RuntimeContext.FIRST_ENTER_GAME = nil
    end
    RegistOnFullyLoaded(function ()
        MoveCameraLogic.Instance():SetFocusOnPoint(self.femalePlayer:GetPosition(), false, 0, PredefinedCameraSize.Normal)
    end)
    RegistOnFullyLoaded(function ()
        MapBubbleManager:Init()
    end)
    RegistOnFullyLoaded(function ()
        AppServices.FactoryManager:OnSceneLoaded()
    end)
    RegistOnFullyLoaded(function ()
        SceneServices.BreedManager:OnSceneLoaded()
    end)

    RegistOnFullyLoaded(function ()
        SceneServices.LabManager:OnSceneLoaded()
    end)
    RegistOnFullyLoaded(function ()
        AppServices.Notification:OnSceneLoaded()
    end)
    RegistOnFullyLoaded(function ()
        AppServices.AdsEnergyManager:OnSceneLoaded()
    end)
    RegistOnFullyLoaded(function ()
        AppServices.MapGiftManager:OnSceneLoaded()
    end)
    RegistOnFullyLoaded(function ()
        AppServices.AdsRepeatBrushBox:OnSceneLoaded()
    end)
    RegistOnFullyLoaded(function ()
        SceneServices.GiftIconManager:Init()
    end)
    RegistOnFullyLoaded(function ()
        AppServices.GuideArrowManager:OnSceneLoaded()
    end)
    RegistOnFullyLoaded(function ()
        AppServices.HangUpRewardManager:OnSceneLoaded()
    end)

    RegistOnFullyLoaded(function ()
        SceneServices.RuinsSceneManager:Init()
    end)
    --[[RegistOnFullyLoaded(function ()
        AppServices.DragonMaze:OnSceneLoaded()
    end)--]]

    RegistOnFullyLoaded(function ()
        AppServices.TeamManager.OnSceneLoaded()
    end)
    RegistOnFullyLoaded(function ()
        AppServices.DragonNestManager:Init()
        AppServices.DragonNestManager:OnSceneLoaded()
    end)
    RegistOnFullyLoaded(function ()
        ---@type SceneStarButton
        local starButton = App.scene:GetWidget(CONST.MAINUI.ICONS.SceneStarButton)
        if starButton then
            starButton:CheckGuide()
        end
    end)

    RegistOnFullyLoaded(
        function()
            AppServices.EventDispatcher:dispatchEvent(GlobalEvents.MAIN_CITY_FULLY_LOADED)
        end
    )

    --执行
    do
        for index, func in ipairs(logicList) do
            local result = Runtime.InvokeCbk(func)
            if not result then
                console.error("maincityOnFullyLoaded有错误"..index) --DEL
            end
        end
    end
end

function MainCity:AddTickerObserver(observer)
    if not self.ticker then
        self.ticker = require "Utils.SimpleTicker"()
        self.ticker:Start(0, 1)
    end
    self.ticker:AddObserver(observer)
end

function MainCity:RemoveTickerObserver(observer)
    if not self.ticker then
        return
    end
    self.ticker:RemoveObserver(observer)
end

function MainCity:StopTickerObserver(observer)
    if not self.ticker then
        return
    end
    self.ticker:Stop()
    self.ticker = nil
end

--@override
function MainCity:InitUI()
    local CoinItem = require "UI.Components.CoinItem"
    self.coinItem = CoinItem:Create()
    self.coinItem:SetParent(self.layout:Node())
    self:AddWidget(CONST.MAINUI.ICONS.CoinIcon, self.coinItem)
    AppServices.UserCoinLogic:BindView(self.coinItem)

    local HeartItemLite = require "MainCity.View.SubViews.Components.HeartItemLite"
    self.heartItem = HeartItemLite:Create()
    self.heartItem:SetParent(self.layout:Node(), false)
    self:AddWidget(CONST.MAINUI.ICONS.EnergyIcon, self.heartItem)

    local DiamondItemLite = require "MainCity.View.SubViews.Components.DiamondItemLite"
    self.diamondItem = DiamondItemLite:Create()
    self.diamondItem:SetParent(self.layout:Node(), false)
    self:AddWidget(CONST.MAINUI.ICONS.DiamondIcon, self.diamondItem)
    AppServices.DiamondLogic:BindView(self.diamondItem)

    local ExpItemLite = require "MainCity.View.SubViews.Components.ExpItemLite"
    self.expItem = ExpItemLite:Create()
    self.expItem:SetParent(self.layout:Node(), false)
    self:AddWidget(CONST.MAINUI.ICONS.Experience, self.expItem)
end

function MainCity:BindView()
    local MainCityView = require("MainCity.View.MainCityView")
    self.view = MainCityView:Create(self)
end

function MainCity:Awake()
    SuperCls.Awake(self)
    self:BindView()

    local canvas = self.noticeCanvas:GetComponent(typeof(Canvas))
    canvas.planeDistance = -40
    canvas.sortingOrder = 256

    self.BGCanvas:GetComponent(typeof(Canvas)).worldCamera = self.mainCamera

    --self:TryFullyLoaded()
    BCore.SetTargetFrameRate(false)

    self.interaction:RegisterListeners()

    AppServices.TaskIconButtonLogic:BindView(self)

    CharacterManager.Instance():Awake()

    registerMediator("MainCity.Mediator.MainCityMediator", self)

    AppServices.EventDispatcher:addObserver(
        self,
        GlobalEvents.SWITCH_SCENECAMERA,
        function(event)
            if self.SceneCamera == nil then
                self:InitSceneCamera()
            end
            if event.data.switchOn == false and event.data.useCapture == true then
                self:SceneCameraCapture()
            else
                self.sceneCameraCapture.enabled = false
            end
            self.SceneCamera.enabled = event.data.switchOn
        end
    )
    MessageDispatcher:SendMessage(MessageType.Global_After_Scene_Awake, self.params.sceneId)
end

function MainCity:InitSceneCamera()
    self.renderTexture = CS.UnityEngine.RenderTexture(Screen.width, Screen.height, -1)
    self.SceneCamera = self.mainCamera:FindComponentInChildren("SceneCamera", typeof(Camera))
    local one = Vector2.one
    local zero = Vector2.zero
    local go = GameObject("SceneCameraCapture")
    go:SetParent(self.panelLayer, false)
    go.transform:SetAsFirstSibling()
    local captureRectTransform = go:AddComponent(typeof(RectTransform))
    captureRectTransform.anchorMin = zero
    captureRectTransform.anchorMax = one
    captureRectTransform.sizeDelta = zero
    self.sceneCameraCapture = go:AddComponent(typeof(RawImage))
    self.sceneCameraCapture.raycastTarget = false
    self.sceneCameraCapture.enabled = false
end

function MainCity:SceneCameraCapture()
    self.sceneCameraCapture.enabled = true
    self.SceneCamera.targetTexture = self.renderTexture
    self.SceneCamera:Render()
    self.SceneCamera.targetTexture = nil
    self.sceneCameraCapture.texture = self.renderTexture
end

function MainCity:RegisterListener()
    --MessageDispatcher:AddMessageListener(MessageType.FlyItemControlSceneIcons, self.ControlMainUIIcon, self)
    --MessageDispatcher:AddMessageListener(MessageType.RefreshMainUICurrency, self.OnRefreshMainUICurrency, self)
    MessageDispatcher:AddMessageListener(MessageType.Global_After_ChangeScene, self.RecordLastSceneName, self)
    MessageDispatcher:AddMessageListener(MessageType.Global_After_AddItem, self.RecordAddedItems, self)
end

function MainCity:RemoveListener()
    --MessageDispatcher:RemoveMessageListener(MessageType.FlyItemControlSceneIcons, self.ControlMainUIIcon, self)
    --MessageDispatcher:RemoveMessageListener(MessageType.RefreshMainUICurrency, self.OnRefreshMainUICurrency, self)
    MessageDispatcher:RemoveMessageListener(MessageType.Global_After_ChangeScene, self.RecordLastSceneName, self)
    MessageDispatcher:RemoveMessageListener(MessageType.Global_After_AddItem, self.RecordAddedItems, self)
end
--[[
function MainCity:OnRefreshMainUICurrency(iconType, duration, delay, completeCallback)
    local userManager = AppServices.User
    local luaHelper = LuaHelper
    local ceil = math.ceil

    local function refreshCurrency(type)
        local iconItem = self:GetWidget(type)
        local n = 0

        if type == CONST.MAINUI.ICONS.DiamondIcon then
            n = userManager:GetItemAmount(ItemId.DIAMOND)
        elseif type == CONST.MAINUI.ICONS.CoinIcon then
            n = userManager:GetItemAmount(ItemId.COIN)
        elseif type == CONST.MAINUI.ICONS.Experience then
            n = AppServices.User:GetExp()
        else
            console.error("This currency type was not found, iconType = ", iconType) --@DEL
        end

        local v = iconItem:GetValue()
        if n ~= v then
            duration = duration or 0
            delay = delay or 0
            if duration == 0 then
                iconItem:SetValue(n)
            else
                local function onComplete()
                    Runtime.InvokeCbk(completeCallback)
                end
                local function onChangeValue(a)
                    iconItem:SetValue(ceil(a))
                end
                local tween = luaHelper.FloatSmooth(v, n, duration, onChangeValue, onComplete)
                if delay > 0 then
                    tween:SetDelay(delay)
                end
            end
        end
    end

    local list = {}
    if iconType ~= nil then
        table.insert(list, iconType)
    else
        table.insert(list, CONST.MAINUI.ICONS.EnergyIcon)
        table.insert(list, CONST.MAINUI.ICONS.DiamondIcon)
        table.insert(list, CONST.MAINUI.ICONS.CoinIcon)
    end

    for i = 1, #list do
        refreshCurrency(list[i])
    end
end

---飞道具时，控制主UI icon显示
---@param iconType MainUIIconType
---@param isShow bool true 显示，false隐藏
---@param targetCallback func 获取要飞的位置
function MainCity:ControlMainUIIcon(iconType, isShow, targetCallback)
    console.print("control main ui icon, iconType = ", iconType, " isShow = ", isShow) --@DEL
    local iconItem = self:GetWidget(iconType)
    if not iconItem then
        console.error("This is an untreated type, iconType = ", iconType) --@DEL
    end
    if isShow then
        iconItem:ShowEnterAnim(false)
        iconItem:SetInteractable(false)
    else
        -- 返回去的过程中可以点击会导致页面混乱 这样改如果有其他问题 可以等返回动画结束后再设置可点
        -- iconItem:SetInteractable(true)
        iconItem:ShowExitAnim(false)
    end
    Runtime.InvokeCbk(targetCallback, iconItem)
end
]]
function MainCity:ShowAllIcons(isFirstTime)
    self:ShowAllTopIcons(false)
    self:ShowBottomIcons(isFirstTime)
end
function MainCity:HideAllIcons(isFirstTime)
    self:HideAllTopIcons(false)
    self:HideBottomIcons(isFirstTime)
end

---监听界面右侧图标显示(触发后自动清空监听)
function MainCity:RegisterShowRightIconsListener(listener)
    table.insert(self.showRightIconsCbs, listener)
end

function MainCity:ShowAllRightIcons()
    self.layout:ShowRight(
        function()
            if self.showRightIconsCbs then
                local cbs = self.showRightIconsCbs
                self.showRightIconsCbs = {}

                for _, listener in ipairs(cbs) do
                    listener:trigger()
                    if not listener:isOneShot() then
                        table.insert(self.showRightIconsCbs, listener)
                    end
                end
            end
        end
    )
end

function MainCity:HideAllRightIcons()
    self.layout:HideRight()
end

function MainCity:ShowAllLeftIcons()
    self.layout:ShowLeftTop()
    self.layout:ShowLeft()
end

function MainCity:HideAllLeftIcons()
    self.layout:HideLeftTop()
    self.layout:HideLeft()
end

function MainCity:ShowAllTopIcons(instant, interactable)
    SuperCls.ShowAllTopIcons(self, instant, interactable)
    self.view:ShowAllTopIcons(instant, interactable)

    self:ShowAllRightIcons()
    self:ShowAllLeftIcons()
end
function MainCity:HideAllTopIcons(instant, hideType)
    self.view:HideAllTopIcons(instant, hideType)
    SuperCls.HideAllTopIcons(self, instant, hideType)

    self:HideAllRightIcons()
    self:HideAllLeftIcons()
end

function MainCity:ShowBottomIcons(isFirstTime)
    self.view:ShowBottomIcons(isFirstTime)
    self.AllBottomIconHideState = false
    self.layout:ShowBottomLeft()
    self.layout:ShowBottomRight()
end

function MainCity:HideBottomIcons(instant, hideType)
    self.view:HideBottomIcons(instant, hideType)
    self.layout:HideBottomLeft()
    self.layout:HideBottomRight()
end

function MainCity:Update(dt)
    if self.isDestroyed then
        return
    end
    self.director:Update(dt)
end

function MainCity:LateUpdate(dt)
    SuperCls.LateUpdate(self)

    if not App.screenPlayActive and self.interaction then
        self.interaction:Update()
    end
    CharacterManager.Instance():LateUpdate(dt)
end

function MainCity:AcceptMessage(msg)
    BeginAcceptMessage()
    if msg:getName() == "PlayScreenplay" then
        App:setScreenPlayActive(true)
    end
end

function MainCity:AddEndMessageToLastAction(msg)
    EndAcceptMessage()
end

function MainCity:AddFrameAction(act)
    self.director:AppendFrameAction(act)
end

function MainCity:BeforeUnload()
    local logicList = {}
    local function RegistBeforeUnload(func)
        table.insert(logicList, func)
    end

    RegistBeforeUnload(function ()
        App.audioManager:ClearAudio(CONST.AUDIO.Music_MainCity)
    end)
    RegistBeforeUnload(function ()
        SuperCls.BeforeUnload(self)
    end)

    RegistBeforeUnload(function ()
        self.view:BeforeUnload()
    end)
    RegistBeforeUnload(function ()
        -- 移除所有监听
        self:RemoveListener()
    end)
    RegistBeforeUnload(function ()
        AppServices.OrderTask:DestorySceneBoard()
    end)
    RegistBeforeUnload(function ()
        App.mapGuideManager:FinishCurrentGuide(true)
    end)
    RegistBeforeUnload(function ()
        CharacterManager.Destroy()
    end)
    RegistBeforeUnload(function ()
        PopupManager:Stop()
    end)
    RegistBeforeUnload(function ()
        AppServices.MagicalCreatures:LeaveScene()
    end)
    RegistBeforeUnload(function ()
        AppServices.DragonNestManager:LeaveScene()
    end)
    RegistBeforeUnload(function ()
        AppServices.MapGiftManager:BeforeUnload()
    end)
    RegistBeforeUnload(function ()
        AppServices.AdsRepeatBrushBox:BeforeUnload()
    end)
    RegistBeforeUnload(function ()
        AppServices.GuideArrowManager:CloseAll()
    end)
    RegistBeforeUnload(function ()
        MessageDispatcher:SendMessage(MessageType.Global_Before_Scene_Unload, self.params.sceneId, self.sceneMode)
    end)

    RegistBeforeUnload(function ()
        self:StopTickerObserver()
    end)
    RegistBeforeUnload(function ()
        SceneServices.LabManager:OnSceneBeforeUnload()
    end)
    RegistBeforeUnload(function ()
        AppServices.TeamManager.Dispose()
    end)

    --执行
    do
        for index, func in ipairs(logicList) do
            local result = Runtime.InvokeCbk(func)
            if not result then
                console.error("maincity卸载前有错误"..index) --DEL
            end
        end
    end
end

function MainCity:OnPause()
    SuperCls.OnPause(self)
    self:RecordLastSceneName()
end
--[[
function MainCity:OnSceneWillChange(sceneId)
    self.sceneWillChange = true
    if self.interaction and sceneId == SceneMode.gameplay then
        self.interaction:UnRegisterListeners()
    end
end
]]
function MainCity:ShowMask(topIconHideType)
    --SuperCls.ShowMask(self, duration, topIconHideType, "MainCity", opacity)
    self:HideAllTopIcons(false, topIconHideType)
    self:HideBottomIcons(false, topIconHideType)
end

function MainCity:HideMask(duration)
    --SuperCls.HideMask(self, duration, preventShowButtons, "MainCity")
    if not App.screenPlayActive then
        self:ShowAllTopIcons()
        self:ShowBottomIcons()
    end
end

--city界面中的红点控制
function MainCity:RefreshRedDot(buttonName)
    if buttonName == "BuildingCollect" and self.skinButton then
        self.skinButton:RefreshRedDot()
    elseif buttonName == "DiamondItem" and self.diamondItem then
        self.diamondItem:HandleRedDot()
    elseif buttonName == "UserInfo" then
        local headInfoView = App.scene:GetWidget(CONST.MAINUI.ICONS.HeadInfoView)
        if headInfoView then
            headInfoView:HandleRedDot()
        end
    elseif buttonName == "settingButton" then
        local settingButton = App.scene:GetWidget(CONST.MAINUI.ICONS.SettingButton)
        if settingButton then
            settingButton:ShowReddot()
        end
    end
    self.view:RefreshRedDot(buttonName)
end

function MainCity:DrawGizmos()
    if self.mapManager then
        self.mapManager:DrawGizmos()
    end
    if self.objectManager then
        self.objectManager:DrawGizmos()
    end
    if self.interaction then
        self.interaction:DrawGizmos()
    end
end

function MainCity:RecordLastSceneName()
    local sceneId = self:GetCurrentSceneId()
    local cfg = AppServices.Meta:GetSceneCfg(sceneId)
    -- 遗迹场景不存这个
    -- 迷宫(6)也不存
    if cfg.type == SceneType.Remains or cfg.type == SceneType.Maze then
        return
    end
    if cfg.whetherRecordPos == 0 then
        return
    end
    AppServices.User.Default:SetKeyValue(UserDefaultKeys.KeyLastSceneName, sceneId, true)
end

function MainCity:RecordAddedItems(itemId, count)
    if not self.addedItems[itemId] then
        self.addedItems[itemId] = 0
    end
    self.addedItems[itemId] = self.addedItems[itemId] + count
end

function MainCity:GetAddedItems()
    local temp = self.addedItems
    self.addedItems = {}
    return temp
end

function MainCity:Quit()
end

function MainCity:Destroy()
    local logicList = {}
    local function RegistDestroy(func)
        table.insert(logicList, func)
    end

    RegistDestroy(function ()
        XGE.EffectExtension.ActorSpotEffect(false)
        self.alive = nil
    end)

    RegistDestroy(function ()
        AppServices.TaskIconButtonLogic:UnbindView()
    end)
    RegistDestroy(function ()
        SuperCls.Destroy(self)
    end)

    RegistDestroy(function ()
        console.systrace("MainCity.Destroy") --@DEL
        removeMediator("MainCity.Mediator.MainCityMediator")
    end)

    RegistDestroy(function ()
        App.popupQueue:Clear()
        console.trace(nil, "clear app queue") --@DEL
    end)
    RegistDestroy(function ()
        if self.interaction then
            self.interaction:Destroy()
            self.interaction = nil
        end
    end)
    RegistDestroy(function ()
        MoveCameraLogic.Destroy()
    end)
    -- self.buildingComposeUI:Destroy()

    RegistDestroy(function ()
        self.view:Destroy()
    end)
    RegistDestroy(function ()
        if self.director then
            self.director:Clear(true)
        end
        self.director = nil
    end)

    RegistDestroy(function ()
        Runtime.CSDestroy(self.BGCanvas)
        self.BGCanvas = nil
    end)
    RegistDestroy(function ()
        MapBubbleManager:Destroy()
    end)
    RegistDestroy(function ()
        AppServices.FoodContainer:OnDestroy()
    end)
    RegistDestroy(function ()
        AppServices.FarmManager:OnDestroy()
    end)
    RegistDestroy(function ()
        AppServices.EventDispatcher:removeObserver(self, GlobalEvents.SWITCH_SCENECAMERA)
    end)
    RegistDestroy(function ()
        SceneServices:OnDestroy()
    end)
    RegistDestroy(function ()
        self.showRightIconsCbs = {}
    end)
    RegistDestroy(function ()
        self.mapManager:OnDestroy()
    end)
    RegistDestroy(function ()
        self.objectManager:OnDestroy()
    end)

    --执行
    do
        for index, func in ipairs(logicList) do
            local result = Runtime.InvokeCbk(func)
            if not result then
                console.error("maincity销毁有错误"..index) --DEL
            end
        end
    end
end

return MainCity
