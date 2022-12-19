require "UI.Base.Utils"

---@class Scene
local Scene = class(nil)

local maskAlpha = 0.6
local InvokeCbk = Runtime.InvokeCbk
local RenderMode = CS.UnityEngine.RenderMode

function Scene:ctor(params)
    self.sceneMode = SceneMode.unknown
    self.params = params or {}

    self.canvas = nil
    self.widgets = {}
    self.__listeners = {}
end

function Scene:Name()
    return self._name
end

function Scene:init()
    self.sceneCanvas = GameUtil.FindOrAddCanvas("SceneCanvas", "SCENE_UI", true)
    self.worldCanvas = GameUtil.CreateWorldCanvas("WorldCanvas", "Default")
    self.canvas = GameUtil.FindOrAddCanvas("RootCanvas", "BASIC_UI", true)
    self.mainCamera = Camera.main

    if self.params.music_bg then
        App.audioManager:PlayMusic(self.params.music_bg)
    end
end

function Scene:Awake()
    console.systrace("Scene:Awake:" .. table.tostring(self._name[1])) --@DEL

    local one = Vector2.one
    local zero = Vector2.zero

    self.panelLayer = GameObject("PanelLayer")
    self.panelLayer:SetParent(self.canvas, false)
    local panelRectTransform = self.panelLayer:AddComponent(typeof(RectTransform))
    panelRectTransform.anchorMin = zero
    panelRectTransform.anchorMax = one
    panelRectTransform.sizeDelta = zero

    self.noticeCanvas = GameUtil.FindOrAddCanvas("NoticeCanvas", "UI_EFFECT", true)
    GameUtil.SetCanvasRenderMode(self.noticeCanvas:GetComponent(typeof(Canvas)), RenderMode.ScreenSpaceOverlay)

    self.BGCanvas = GameUtil.FindOrAddCanvas("BGCanvas", "SCENE_BG", true)
    local bgCanvasScaler = self.BGCanvas:GetComponent(typeof(CanvasScaler))

    self.FlyObjCanvasObj = GameUtil.FindOrAddCanvas("FlyObjCanvas", "UI_EFFECT", true)
    local FlyObjCanvas = self.FlyObjCanvasObj:GetComponent(typeof(Canvas))
    FlyObjCanvas.sortingOrder = 1

    bgCanvasScaler.uiScaleMode = "ScaleWithScreenSize"
    bgCanvasScaler.referenceResolution = Vector2(1280, 960)
    bgCanvasScaler.screenMatchMode = "Shrink"
end

function Scene:AddWidget(eType, widget)
    self.widgets[eType] = widget
    if CONST.MAINUI.ICONS.Anonymous == eType then
        CONST.MAINUI.ICONS.Anonymous = CONST.MAINUI.ICONS.Anonymous + 1
    end
end

function Scene:DelWidget(type)
    self.widgets[type] = nil
end

function Scene:GetWidget(eType, eVal)
    local widget = self.widgets[eType]
    if widget and type(widget.GetView) == "function" then
        return widget:GetView(eVal)
    end
    return widget
end

function Scene:RefreshWidget(eType)
    if not eType then
        return
    end
    local widget = self.widgets[eType]
    if widget and type(widget.ForEach) == "function" then
        widget:ForEach(
            function(k, v)
                Runtime.InvokeCbk(v.Refresh, v)
            end
        )
    else
        local w = self:GetWidget(eType)
        if w then
            Runtime.InvokeCbk(w.Refresh, w)
        end
    end
end

function Scene:IsMainCity()
    return self.sceneMode == SceneMode.home
end

--非使用maincity代码的场景
function Scene:IsNotSameMainCity()
    if self:IsExploitCity() then
        return true
    end

    if self:IsParkourCity() then
        return true
    end

    if self:IsMowCity() then
        return true
    end

    return false
end

function Scene:IsExploitCity()
    local sType = self:GetSceneType()
    return sType == SceneType.Exploit
end

function Scene:IsParkourCity()
    local sType = self:GetSceneType()
    return sType == SceneType.Parkour
end

function Scene:IsMowCity()
    local sType = self:GetSceneType()
    return sType == SceneType.Mow
end

function Scene:IsScene(eMode)
    return self.sceneMode == eMode
end

function Scene:GetSceneType()
    if not self.sceneType then
        local sceneId = self:GetCurrentSceneId()
        local cfg = AppServices.Meta:GetSceneCfg()[sceneId]
        if cfg then
            self.sceneType = cfg.type
        else
            self.sceneType = -1
        end
    end
    return self.sceneType
end

function Scene:GetAttachPanelCanvas(panelLayer)
    if panelLayer == CONST.MAINUI.LAYERS.BASIC_UI then
        return self.panelLayer
    elseif panelLayer == CONST.MAINUI.LAYERS.SCENE_BG then
        return self.BGCanvas
    elseif panelLayer == CONST.MAINUI.LAYERS.SCENE_UI then
        return self.sceneCanvas
    end
end

function Scene:AttachPanel(panel)
    if panel:GetLayer() == CONST.MAINUI.LAYERS.BASIC_UI then
        panel:attach(self.panelLayer)
    elseif panel:GetLayer() == CONST.MAINUI.LAYERS.SCENE_BG then
        panel:attach(self.BGCanvas)
    elseif panel:GetLayer() == CONST.MAINUI.LAYERS.SCENE_UI then
        panel:attach(self.sceneCanvas)
    end
    --panel:attach(self.panelLayer)
    --self.panelLayer.transform:SetAsLastSibling()
end

function Scene:CreatePanelMask(name)
    local maskObject = GameObject(name)
    maskObject:SetParent(self.panelLayer, false)
    local maskComp = maskObject:AddComponent(typeof(Image))
    maskComp.raycastTarget = false
    maskComp.color = Color(0, 0, 0, maskAlpha)

    maskObject:AddComponent(typeof(CS.BetaGame.BaseFader))

    local rectTransform = maskObject:GetComponent(typeof(RectTransform))
    rectTransform.anchorMin = Vector2.zero
    rectTransform.anchorMax = Vector2.one
    rectTransform.sizeDelta = Vector2.zero
    return maskObject
end

function Scene:Update(dt)
end

function Scene:LateUpdate(dt)
    self:Trigger("LateUpdate")
end

function Scene:OnPause(dt)
end

function Scene:Trigger(eventType, args)
    for _, observer in pairs(self.__listeners) do
        local listener = observer[eventType]
        InvokeCbk(listener, args)
    end
end

function Scene:Register(observer, eventType, listener)
    if not self.__listeners[observer] then
        self.__listeners[observer] = {}
    end
    if not self.__listeners[observer][eventType] then
        self.__listeners[observer][eventType] = {}
    end

    self.__listeners[observer][eventType] = listener
end
function Scene:Unregister(observer, eventType)
    if not self.__listeners[observer] then
        return
    end
    if not eventType then
        self.__listeners[observer] = nil
        return
    end
    if not self.__listeners[observer][eventType] then
        return
    end
    self.__listeners[observer][eventType] = nil
end

function Scene:Destroy()
    for _, v in pairs(self.widgets) do
        Runtime.InvokeCbk(v.Dispose, v)
    end
    if self.params.music_bg then
        -- zhukai
        --App.audioManager:ClearAudio(self.params.music_bg)
    end

    PanelManager.ForcePanelNoFade(true)
    PanelManager.closeAllPanels()
    PanelManager.ForcePanelNoFade(false)
    --PanelManager.closeAllPanels()

    if RuntimeContext.VERSION_DEVELOPMENT then
        print("Scene:Destroy:" .. table.tostring(self._name)) --@DEL
    end
end

function Scene:BeforeUnload()
    self.isDestroyed = true
    -- zhukai:这里可能是bug
    --App.audioManager:ClearAll() --test
    self.meta = nil
    self.bornPos = nil
end

function Scene:GetCurrentSceneId()
    return self.params.sceneId
end

function Scene:GetCurrentMeta()
    if not self.meta then
        local sceneId = self:GetCurrentSceneId()
        local cfg = AppServices.Meta:GetSceneCfg()[sceneId]
        if not cfg then
            console.lj("没有找到场景配置" .. sceneId) --@DEL
        end
        self.meta = cfg
    end
    return self.meta
end

function Scene:GetCurrentBornPos()
    if not self.bornPos then
        local cfg = self:GetCurrentMeta() or {}
        local tempPos = cfg.bornPosition or {0, 0, 0}
        self.bornPos = Vector3(tempPos[1], 0, tempPos[3])
    end

    return self.bornPos
end

function Scene:Quit()
end

return Scene
