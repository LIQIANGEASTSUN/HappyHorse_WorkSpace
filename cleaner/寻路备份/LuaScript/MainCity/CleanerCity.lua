-- require "Maincity.Include"
require "MainCity.Character.CharacterManager"
require "MainCity.Manager.QueueLineManage"
require "MainCity.Manager.PopupManager"
require "ScreenPlays.Include"
local Interaction = require("Maincity.Interaction.Interaction")
local PressSlider = require("MainCity.UI.PressSlider.PressSlider")

local MapManager = require("Maincity.Manager.MapManager")
local ObjectManager = require("Maincity.Manager.ObjectManager")
local Director = require "ScreenPlays.Director"
local HpTipsManager = require "Cleaner.Manager.HpTipsManager"
local EffectManager = require "Cleaner.Effect.EffectManager"
local SuperCls = require "UI.Scene.SceneWithHomeUI"

---@class CleanerCity:SceneWithHomeUI @场景管理类
local CleanerCity = class(SuperCls, "CleanerCity")
local CleanerCityView = require("MainCity.View.CleanerCityView")

function CleanerCity.create()
    local inst = CleanerCity.new()
    return inst
end

function CleanerCity:ctor()
    self.alive = true
    self.sceneMode = SceneMode.exploit
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
    ---@type HpTipsManager
    --self.HpTipsManager = nil

    --打点用
    self.addedItems = {}
    self.slider = PressSlider.new()
end

function CleanerCity:init(params, extraParam)
    self.params = params or {}
    self.extraParam = extraParam or {}

    SuperCls.init(self)

    -- 注册观察者事件
    self:RegisterListener()

    AppServices.NetWorkManager:Init()
    AppServices.UnitManager:Init()
    AppServices.IslandManager:Init()
    AppServices.UnitTipsManager:Init()

    -- Init Map
    do --里面的初始化顺序不要乱动, 设计很精妙0^0
        local ts = CS.System.DateTime.Now
        --1.初始化地图
        self.mapManager = MapManager.new(self.params.sceneId)
        self.mapManager:InitLocal(self.extraParam.msg.sceneInfo or {})

        --2.初始化障碍物
        self.objectManager = ObjectManager.new(self.params.sceneId)

        --3. 根据服务器数据更新障碍物(或创建/或销毁)
        self.objectManager:CreateAgents(self.extraParam.msg.sceneInfo or {})

        --4. 根据服务器数据更新地图
        self.mapManager:InitServer()
        console.warn(nil, "generate scene cost:", (CS.System.DateTime.Now - ts).TotalSeconds) --@DEL
        AppServices.EntityManager:Initialize(nil)

        --self.HpTipsManager = HpTipsManager.Instance()

        AppServices.IslandPathManager:Init()
    end

    -- 主角发光特效开关
    --XGE.EffectExtension.ActorSpotEffect(CONST.RULES.ActorEffectEanbled())

    local min, max = self.mapManager:GetCameraAnchor()
    MoveCameraLogic.Instance(true):Init(nil, min, max)

    CharacterManager.Instance():Init()
    -- self.femalePlayer = CharacterManager.Instance():Get("Femaleplayer")
    -- self.femalePlayer:SetBeginningPosition()

    self:TryFullyLoaded()

    --打点 记录玩家进入场景时的时间点
    self.enterSceneTime = TimeUtil.ServerTime()

    SceneServices.GridRationalityIndicator:Init()
    self.slider:Init()

end

function CleanerCity:EnableUI()
    Util.BlockAll(0, "main_city_first_enter")
    self.uiEnabled = true
end

function CleanerCity:TryFullyLoaded()
    self.fullyLoadedCounter = self.fullyLoadedCounter + 1
    if self.fullyLoadedCounter >= 3 then
        --过场拉幕动画
        --EnterMatchTranslationManager:Instance():PlayOpenCurtainAnimation()
        local function onTranslationAnimFinished(hasAnimation)
            if hasAnimation then
                Util.BlockAll(0, "main_city_first_enter")
            end
            -- AppServices.MagicalCreatures:Initialize()
        end

        self:OnFullyLoaded()
        self.objectManager.allAgentLoaded = true
        MessageDispatcher:SendMessage(MessageType.Global_After_Scene_Loaded, self.params.sceneId, self.sceneMode)

        local ChangeSceneAnimation = require "Game.Common.ChangeSceneAnimation"
        ChangeSceneAnimation.Instance():PlayOut(onTranslationAnimFinished)

    -- local PopQueueCtor = require("CleanerCity.Helper.PopQueueCtor")
    -- PopQueueCtor.Init(self)
    end
end

function CleanerCity:OnFullyLoaded()
    -- local pos = self:GetCurrentBornPos()
    AppServices.EventDispatcher:dispatchEvent(GlobalEvents.MAIN_CITY_FULLY_LOADED)

    -- if RuntimeContext.FIRST_ENTER_GAME then
    --     -- 第一次登录游戏结束
    --     RuntimeContext.FIRST_ENTER_GAME = nil
    -- end
end

function CleanerCity:Awake()
    SuperCls.Awake(self)

    local canvas = self.noticeCanvas:GetComponent(typeof(Canvas))
    canvas.planeDistance = -40
    canvas.sortingOrder = 256

    self.BGCanvas:GetComponent(typeof(Canvas)).worldCamera = self.mainCamera

    self:TryFullyLoaded()
    BCore.SetTargetFrameRate(false)

    self.interaction:RegisterListeners()

    self:TryFullyLoaded()

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

function CleanerCity:GetSceneCamer()
    if Runtime.CSValid(self.SceneCamera) then
        return self.SceneCamera
    end

    self.SceneCamera = self.mainCamera:FindComponentInChildren("SceneCamera", typeof(Camera))
    return self.SceneCamera
end

function CleanerCity:InitSceneCamera()
    self.renderTexture = CS.UnityEngine.RenderTexture(Screen.width, Screen.height, -1)
    self:GetSceneCamer()
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

function CleanerCity:SceneCameraCapture()
    self.sceneCameraCapture.enabled = true
    self.SceneCamera.targetTexture = self.renderTexture
    self.SceneCamera:Render()
    self.SceneCamera.targetTexture = nil
    self.sceneCameraCapture.texture = self.renderTexture
end

function CleanerCity:RegisterListener()
    MessageDispatcher:AddMessageListener(MessageType.Global_After_ChangeScene, self.RecordLastSceneName, self)
end

function CleanerCity:RemoveListener()
    MessageDispatcher:RemoveMessageListener(MessageType.Global_After_ChangeScene, self.RecordLastSceneName, self)
end

function CleanerCity:InitUI()
    self.view = CleanerCityView:Create(self)
    self.view:Init()
end

function CleanerCity:Update(dt)
    if self.isDestroyed then
        return
    end
    self.director:Update(dt)
end

function CleanerCity:LateUpdate(dt)
    self.super.LateUpdate(self)

    if not App.screenPlayActive and self.interaction then
        self.interaction:Update()
    end
    CharacterManager.Instance():LateUpdate(dt)
    AppServices.EntityManager:LateUpdate()

    AppServices.UnitManager:LateUpdate()
    EffectManager:LateUpdate()
    AppServices.UnitTipsManager:LateUpdate()
    AppServices.IslandPathManager:LateUpdate()
end

function CleanerCity:AddFrameAction(act)
    self.director:AppendFrameAction(act)
end

function CleanerCity:BeforeUnload()
    SuperCls.BeforeUnload(self)

    -- AppServices.MagicalCreatures:LeaveScene()
    self.view:BeforeUnload()
    ActivityServices.Parkour:QuitActivityScene()
    -- 移除所有监听
    self:RemoveListener()

    App.audioManager:ClearAudio(CONST.AUDIO.Music_MainCity)

    MessageDispatcher:SendMessage(MessageType.Global_Before_Scene_Unload, self.params.sceneId, self.sceneMode)
end

function CleanerCity:OnPause()
    self.super.OnPause(self)
    self:RecordLastSceneName()
end

function CleanerCity:DrawGizmos()
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

function CleanerCity:RecordLastSceneName()
    local sceneId = self:GetCurrentSceneId()
    local cfg = AppServices.Meta:GetSceneCfg()[sceneId] or {}
    -- 遗迹场景不存这个
    if not cfg or (cfg.type == SceneType.Remains or cfg.type == SceneType.Maze) then
        return
    end
    AppServices.User.Default:SetKeyValue(UserDefaultKeys.KeyLastSceneName, sceneId, true)
end

function CleanerCity:ChangeGameState(state)
    --[[
    /// <summary>
    /// 游戏状态
    /// </summary>
    public enum GameState
    {
        None = 0,
        Ready = 1,
        Playing = 2,
        Pause = 3,
        Resume = 4,
        GameFailed = 5,
        GameSuccess = 6
    }
--]]
end

function CleanerCity:ShowMask()
    self.layout:HideTopCenter()
    self.layout:HideTopCenter2()
    self.layout:HideBottomCenter()
    self.layout:HideRight()
    self.layout:HideLeftTop()
    self.layout:HideBottomLeft()
    self.layout:HideRightTop()
    self.layout:HideBottomRight()
    self.view:HideBottomIcons()
end

function CleanerCity:HideMask()
    self.layout:ShowTopCenter()
    self.layout:ShowTopCenter2()
    self.layout:ShowLeftTop()
    self.layout:ShowBottomCenter()
    self.layout:ShowBottomLeft()
    self.layout:ShowRight()
    self.layout:ShowRightTop()
    self.layout:ShowBottomRight()
    self.view:ShowBottomIcons()
end

function CleanerCity:AcceptMessage(msg)
    BeginAcceptMessage()
    if msg:getName() == "PlayScreenplay" then
        App:setScreenPlayActive(true)
    end
end

function CleanerCity:AddEndMessageToLastAction(msg)
    EndAcceptMessage()
end

function CleanerCity:Quit()
end

function CleanerCity:Destroy()
    SuperCls.Destroy(self)
    console.systrace("CleanerCity.Destroy") --@DEL
    if self.interaction then
        self.interaction:Destroy()
        self.interaction = nil
    end

    MoveCameraLogic.Destroy()

    self.view:Destroy()

    self.director:Clear()
    self.director = nil

    Runtime.CSDestroy(self.BGCanvas)
    self.BGCanvas = nil

    AppServices.EventDispatcher:removeObserver(self, GlobalEvents.SWITCH_SCENECAMERA)

    SceneServices:OnDestroy()
    self.mapManager:OnDestroy()
    self.objectManager:OnDestroy()

    AppServices.NetWorkManager:Release()
    AppServices.IslandManager:Release()
    AppServices.IslandPathManager:Release()
    AppServices.UnitTipsManager:Release()
end

return CleanerCity
