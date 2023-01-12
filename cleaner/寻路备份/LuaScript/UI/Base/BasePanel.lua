require "UI.Base.Utils"
---@class BasePanel:LuaUiBase
BasePanel = class(LuaUiBase)
local panelState = {
    --1 实例化
    instance = 1,
    --2 绑定界面前
    onBeforeBindView = 2,
    --3 绑定界面
    bindView = 3,
    --4 绑定界面前后
    onAfterBindView = 4,
    --5 播放面板显示动画
    fadeIn = 5,
    --6 播放面板关闭动画
    fadeOut = 6,
    --7 销毁
    destroy = 7
}
function BasePanel:ctor(_panelName)
    self.name = _panelName or "BasePanel"
    self.arguments = nil
    self.panelVO = nil

    --面板默认遮罩
    self.panelMask = nil
    self.hideTopIconType = nil
end

function BasePanel:setArguments(args)
    self.arguments = args or {}
end

function BasePanel:getArguments()
    return self.arguments
end

function BasePanel:initPanel(_panelVO, _initFinishCallBack)
    self.panelVO = _panelVO
    self.initFinishCallBack = _initFinishCallBack
    self:SwithState(panelState.instance)
end
function BasePanel:SwithState(state)
    -- body
    if state ~= self.panelState then
        self.panelState = state
    end

    if state == panelState.instance then
        --脚本加载
        self:InstancePrefab()
    elseif state == panelState.bindView then
        self:BindStart()
    elseif state == panelState.onAfterBindView then
        self:BindEnd()
    elseif state == panelState.fadeIn then
        self:_FadeInStart()
    elseif state == panelState.fadeOut then
        self:_FadeOutStart()
    elseif state == panelState.destroy then
        --self:destroyPanel()
        --如果未完全显示则强制销毁
        self:_destroy()
    end
end

function BasePanel:InstancePrefab()
    if self.panelState ~= panelState.instance then
        return
    end

    if string.isEmpty(self.panelVO.panelPrefabName) then
        console.print(self.panelVO.panelName .. " : panelPrefabName is nil") --@DEL
        return
    end

    self.gameObject = BResource.InstantiateFromAssetName(self.panelVO.panelPrefabName)
    self.transform = self.gameObject.transform
    self.gameObject:SetActive(false)
    self.gameObject.name = self.panelVO.panelName

    self.canvasGroup = self.gameObject:AddComponent(typeof(CanvasGroup))
    self.animator = self.gameObject:GetComponent(typeof(Animator))
    if Runtime.CSNull(self.animator) then
        self.animator = self.gameObject:AddComponent(typeof(Animator))
        self.animator.runtimeAnimatorController = App.commonAssetsManager:GetAsset(CONST.ASSETS.G_ANIMATOR_PANEL)
    end

    self:TriggerPanelEvent("onBeforeBindView")

    self:SwithState(panelState.bindView)
end

function BasePanel:BindStart()
    if self.panelState ~= panelState.bindView then
        return
    end
    self:TriggerPanelEvent("bindView")
    self:TriggerPanelEvent("onAfterBindView")
    local scene = App:getRunningLuaScene()
    local canvas = scene:GetAttachPanelCanvas(self:GetLayer())
    self.gameObject:SetParent(canvas.transform, false)
    GameUtil.SetLocalPositionZero(self.gameObject)
    GameUtil.SetLocalEulerAnglesZero(self.gameObject)

    self:SwithState(panelState.onAfterBindView)
end

function BasePanel:BindEnd()
    if self.panelState ~= panelState.onAfterBindView then
        return
    end

    Runtime.InvokeCbk(self.initFinishCallBack)
    self.initFinishCallBack = nil
end

function BasePanel:_destroy()
    --self:CancelDelayAll()
    self:DisposeCopyComponents()
    self:DisposeLua()

    if self.panelMask then
        self.panelMask:destroy()
        self.panelMask = nil
    end
    self.animator = nil
    self.fadeIn_finishCallBack = nil
    self.fadeOut_finishCallBack = nil
    self.widgetPos = nil

    if Runtime.CSValid(self.gameObject) then
        self.gameObject.transform:DOKill()
    end
    self:DisposeGameObject()
end
function BasePanel:destroy()
    self:SwithState(panelState.destroy)
end

function BasePanel:isActive()
    if Runtime.CSNull(self.gameObject) then
        return false
    end
    return self.gameObject.activeInHierarchy
end

function BasePanel:setActive(active)
    if Runtime.CSNull(self.gameObject) then
        return
    end
    self.gameObject:SetActive(active)
end

function BasePanel:setPosition()
    GameUtil.SetLocalPositionZero(self.gameObject)
    GameUtil.SetLocalEulerAnglesZero(self.gameObject)
end

--local maskColor = Color(0, 0, 0, 0)
function BasePanel:_FadeInStart()
    if self.panelState ~= panelState.fadeIn then
        return
    end

    self.gameObject:SetActive(true)
    self.TriggerPanelEvent("OnActive", true)

    --播放界面展示动画
    --是否指定界面打开时的起始位置和关闭时的终点位置
    self.widgetPos = self:GetWidgetPosition()
    if not self.widgetPos then
        self.animator:Play("PanelIn")
    else
        self.gameObject.transform:SetLocalPosition(self.widgetPos)
        self.gameObject.transform:DOLocalMove(Vector3.zero, 0.33):SetEase(Ease.InOutSine)
        self.animator:Play("PanelIn_move")
    end

    self.animator:Update(0)
    --创建mask 有可能为nil
    if not (self.panelVO.showFlag.showMask == false) then
        if not self.panelMask then
            self.panelMask = require("UI.Base.PanelMask").new()
            self.panelMask:init(self.panelVO, self.gameObject)
        end
    end

    --监控结束状态
    local function _FadeInEnd()
        if self.panelState ~= panelState.fadeIn then
            return
        end
        if self.panelVO.showFlag.stopBgRendering then
            AppServices.EventDispatcher:dispatchEvent(GlobalEvents.SWITCH_SCENECAMERA, {switchOn = false})
        end
        Runtime.InvokeCbk(self.fadeIn_finishCallBack)
        self.fadeIn_finishCallBack = nil
    end

    if PanelManager.CheckNeedFade() then
        _FadeInEnd()
    else
        local delay = self.widgetPos and 0.76 or 0.5
        WaitExtension.SetTimeout(_FadeInEnd, delay)
    end
end

function BasePanel:fadeIn(_finishCallBack)
    if self.panelVO == nil then
        console.warn(nil, "fade in panelVO is nil!!!")
        Runtime.InvokeAsync(_finishCallBack)
        return
    end

    if self.panelState ~= panelState.onAfterBindView then
        return
    end

    self.fadeIn_finishCallBack = _finishCallBack
    self:SwithState(panelState.fadeIn)
end

function BasePanel:_FadeOutStart()
    local function fadeOutFinish()
        if self.panelState ~= panelState.fadeOut then
            return
        end

        if Runtime.CSValid(self.gameObject) then
            self.gameObject:SetActive(false)
        end
        Runtime.InvokeCbk(self.fadeOut_finishCallBack)
        self.fadeOut_finishCallBack = nil
        self.widgetPos = nil
    end
    --关闭动画
    if Runtime.CSValid(self.animator) then
        if not self.widgetPos then
            self.animator:Play("PanelOut")
        else
            self.animator:Play("PanelOut_move")
            self.gameObject.transform:DOLocalMove(self.widgetPos, 0.33):SetDelay(0.433):SetEase(Ease.InOutSine)
        end
    end

    --mask回收
    if self.panelMask then
        self.panelMask:fadeOut()
    end

    --其他
    if self.hideTopIconType then
        if App.scene and App.scene.view then
            App.scene.view:ShowHeadInfoPanel(true)
        end
    end
    if self.panelVO.showFlag.stopBgRendering then
        AppServices.EventDispatcher:dispatchEvent(GlobalEvents.SWITCH_SCENECAMERA, {switchOn = true})
    end

    if PanelManager.CheckNeedFade() then
        fadeOutFinish()
        return
    else
        local delay = self.widgetPos and 0.766 or 0.433
        WaitExtension.SetTimeout(fadeOutFinish, delay)
    end
end
function BasePanel:fadeOut(_finishCallBack)
    if self.panelState > panelState.fadeIn then
        return
    end
    self.fadeOut_finishCallBack = _finishCallBack
    self:SwithState(panelState.fadeOut)
end

function BasePanel:SetHideTopIconType(type)
    self.hideTopIconType = type
end

function BasePanel:GetLayer()
    if self.panelVO.showFlag and self.panelVO.showFlag.layer then
        return self.panelVO.showFlag.layer
    end

    return CONST.MAINUI.LAYERS.BASIC_UI
end

--触发panel事件，由子类panel重写
function BasePanel:TriggerPanelEvent(name, ...)
    Runtime.InvokeCbk(self[name], self, ...)
end

function BasePanel:GetWidgetPosition()
    local widgetType = self.panelVO.widget
    if not widgetType then
        return
    end
    local widget = App.scene:GetWidget(widgetType)
    if not widget then
        return
    end
    local trans = widget.transform
    if not trans then
        trans = widget.gameObject.transform
    end
    if not trans then
        console.warn(nil, "can not get wiget transform: ", widgetType) --@DEL
        return
    end
    local pos = App.scene.layout.transform:InverseTransformPoint(trans.position)
    --自定义偏移量校对位置
    local offset = self.panelVO.widgetOffset
    if offset then
        pos = Vector3(pos[0] + offset[0], pos[1] + offset[1], pos[2] + offset[2])
    end
    return pos
end

return BasePanel
