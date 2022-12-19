require('UI.Base.PanelCallbackEvents')

---@class BaseMediator:Mediator
BaseMediator = MVCClass('BaseMediator', pureMVC.Mediator)
local MediatorMediatorState = {
    --1 脚本加载
    Awake = 1,
    --2 显示开始
    ShowStart = 2,
    --3 显示结束
    ShowEnd = 3,
    --4 面板隐藏开始
    HideStart = 4,
    --5 面板隐藏结束
    HideEnd = 5,
    --5 脚本销魂
    Destroy = 6
}
function BaseMediator:ctor(...)
    BaseMediator.super.ctor(self, ...)
    self.visible = false
    self.panelVO = nil
    self.arguments = nil
    self.panelState = nil
end

function BaseMediator:onRegister()
end

function BaseMediator:onCheckNotify()
    return self.panelState == MediatorMediatorState.ShowStart or self.panelState == MediatorMediatorState.ShowEnd
end

function BaseMediator:setData(_panelVO, _arguments, eventExtension)
    self.panelVO = _panelVO
    self.arguments = _arguments
    --- @type PanelCallbacks
    self.callbacks = eventExtension
end

function BaseMediator:SwithState(state)
    -- body
    if state ~= self.panelState then
        self.panelState = state
    end

    if state == MediatorMediatorState.Awake then
        --脚本加载
        self:initViewComponent()
        --事件通知:预加载资源
        self:onTriggerEvent("onBeforeLoadAssets")
    elseif state == MediatorMediatorState.ShowStart then
        self:initPanel()
        self:showPanel()
    elseif state == MediatorMediatorState.ShowEnd then
        self:fadeOutPanelEnd()
    elseif state == MediatorMediatorState.HideStart then
        self:hidePanel()
    elseif state == MediatorMediatorState.HideEnd then
        self:fadeInPanelEnd()
    elseif state == MediatorMediatorState.Destroy then
        --self:destroyPanel()
        --如果未完全显示则强制销毁
        self:panelCloseFinishLogic()
    end
end

function BaseMediator:closePanel(finishaCB,arg)
    PanelManager.closePanel(self.panelVO, nil, arg)
end
function BaseMediator:_closePanel(arg)
    --销毁状态不在执行其他状态
    if not self.panelState then
        return
    end

    if self.panelState >= MediatorMediatorState.HideStart then
        return
    end

    --self.arguments = arg
    if arg then
        if not self.arguments then
            self.arguments = arg
        else
            table.merge(self.arguments, arg)
        end
    end
    self:SwithState(self.visible and MediatorMediatorState.HideStart or MediatorMediatorState.Destroy)
end
--------------------------------------------------------------------------
function BaseMediator:preparePanel()
    --销毁状态不在执行其他状态
    if self.panelState == MediatorMediatorState.Destroy then
        return
    end

    local viewComponent = self:getViewComponent()
    self:SwithState(viewComponent and MediatorMediatorState.ShowStart or MediatorMediatorState.Awake)
end

-------state：Awake
function BaseMediator:initViewComponent()
    if self:getViewComponent() then
        return
    end

    local panelClass = require(self.panelVO.classPath)
    if panelClass == nil then
        error("BaseMediator:preparePanel: incorrect class path !! ")
    end

    local panel = panelClass.new()
    self:setViewComponent(panel)
    panel:setArguments(self.arguments)

    --事件通知：加载完基本脚本，子类可以加载代理类了
    self:onTriggerEvent("onAfterSetViewComponent")
end

function BaseMediator:loadAssetsAndInitPanel(_loadAssetsTable)
    local loadAssets = {}
    if self.panelVO.prefabNames ~= nil then
        loadAssets = table.clone(self.panelVO.prefabNames or {}, true)
    end

    if _loadAssetsTable ~= nil then
        for i, v in pairs(_loadAssetsTable) do
            if not table.exists(loadAssets, v) then
                table.insert(loadAssets, v)
            end
        end
    end

    local function onLoadFinish()
        --下载期间状态发生变化，则中断执行
        if self.panelState ~= MediatorMediatorState.Awake then
            return
        end

        --事件通知：资源预加载完成
        self:onTriggerEvent("onAfterLoadAssets")
        --切换状态:MediatorMediatorState.ShowStart
        self:SwithState(MediatorMediatorState.ShowStart)
    end
    App.uiAssetsManager:LoadAssets(loadAssets, onLoadFinish, nil, self.panelVO.loadingFlag)
end
-------------state:Show
function BaseMediator:initPanel()
    --如果当前已是显示状态，则不需要再初始化
    if self.visible == true then
        return
    end

    local viewComponent = self:getViewComponent()
    viewComponent:initPanel(self.panelVO)
end
--------------------------------------------------------------------------

function BaseMediator:showPanel()
    local view = self:getViewComponent()
    if not view then
        return
    end

    --事件通知：面板展示前
    self:onTriggerEvent("onBeforeShowPanel")

    --播放主界面ICON退出动画
    if table.count(PanelManager.panelCommondStack) > 0 then
        if App.scene then
            local hideTopIconType = view.hideTopIconType
            Runtime.InvokeCbk(App.scene.ShowMask,App.scene,hideTopIconType)
        end
    end
    --执行面板逻辑：播放面板渐显动画
    view:fadeIn(function ()
        self:SwithState(MediatorMediatorState.ShowEnd)
    end)
end

function BaseMediator:fadeOutPanelEnd()
    if self.panelState ~= MediatorMediatorState.ShowEnd then
        return
    end
    --执行结束回调
    self.visible = true

    --注册暂停和恢复回调
    if self.onBeforePausePanel or self.onAfterResumePanel and (not self.RegistAppOnPause) then
        self.RegistAppOnPause = function (isPause)
            local eventName = isPause and "onBeforePausePanel" or "onAfterResumePanel"
            self:onTriggerEvent(eventName)
        end
        App:AddAppOnPauseCallback(self.RegistAppOnPause)
    end

    --事件通知：面板展示结束
    self:onTriggerEvent("onAfterShowPanel")

    if self.onUpdatePerSecond and not self.updateId then
        self:onTriggerEvent("onUpdatePerSecond")
        self.updateId = WaitExtension.InvokeRepeating(function()
            self:onTriggerEvent("onUpdatePerSecond")
        end, 0, 1)
    end

    if self:getViewComponent() then
     --触发面板通知：onAfterShowPanel
        self:getViewComponent():TriggerPanelEvent("onAfterShowPanel")
        PanelManager.executeShowPanel(self.panelVO, self:getViewComponent())
    end
end
--self.visible:用来记录一个完整的界面开启到关闭的过程，只有完整过程才会发送关闭事件，不完整的过程对于玩家来说是看不到的，无意义
function BaseMediator:hidePanel()
    --事件通知
    self:onTriggerEvent("onBeforeHidePanel")

    --执行面板逻辑：播放隐藏动画
    if self:getViewComponent() then
        self:getViewComponent():fadeOut(function ()
            self:SwithState(MediatorMediatorState.HideEnd)
        end)
    end
end

function BaseMediator:panelCloseFinishLogic()
    if App.scene then
        local view = self:getViewComponent()
        local hideTopIconType = view.hideTopIconType
        local function CheckStack()
            if table.count(PanelManager.panelCommondStack) == 0 then
                return true
            end

            if table.count(PanelManager.panelCommondStack) == 1 and PanelManager.panelCommondStack[self.panelVO.panelName] == false then
                return true
            end

            return false
        end

        if CheckStack() then
            Runtime.InvokeCbk(App.scene.HideMask,App.scene,hideTopIconType)
        end
    end

    PanelManager.executeClosePanel(self.panelVO)
    self:destroyPanel()

    if  self.visible then
        App.mapGuideManager:OnGuideFinishEvent(GuideEvent.PanelCloseFadeFinish, self.panelVO.panelName)
        self.visible = false
    end

    if self.RegistAppOnPause then
        App:RemoveAppOnPauseCallback(self.RegistAppOnPause)
        self.RegistAppOnPause = nil
    end
end

function BaseMediator:fadeInPanelEnd()
    --事件通知
    self:onTriggerEvent("onAfterHidePanel")
    self:panelCloseFinishLogic()

    if self.arguments and self.arguments.closeCallback then
        Runtime.InvokeCbk(self.arguments.closeCallback)
        self.arguments.closeCallback = nil
    end
end

function BaseMediator:destroyPanel()
    if self.onUpdatePerSecond and self.updateId then
        WaitExtension.CancelTimeout(self.updateId)
        self.updateId = nil
    end
    --事件通知
    self:onTriggerEvent("onBeforeDestroyPanel")
    --执行面板逻辑：面板销毁逻辑
    if self:getViewComponent() then
        self:getViewComponent():destroy()
    end
    self:setViewComponent(nil)
    self.panelState = nil

    PanelManager.executeDestroyPanel(self.panelVO)
    self:onTriggerEvent("onAfterDestroyPanel")
end
--[[
function BaseMediator:MarkDestory()
    self._markDestory = true
end

    function BaseMediator:pausePanel()
        self:onBeforePausePanel()
    end

    function BaseMediator:resumePanel()
        self:onAfterResumePanel()
    end


    function BaseMediator:fadeInPanel(fadeInFinishFunc)
        self:getViewComponent():fadeIn(fadeInFinishFunc)
    end

    function BaseMediator:fadeOutPanel(fadeOutFinishFunc)
        self:getViewComponent():fadeOut(fadeOutFinishFunc)
    end
]]
--------------------------------------------------------------------------
function BaseMediator:onBeforeLoadAssets()
    -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
    self:loadAssetsAndInitPanel()
end
--[[
    function BaseMediator:onAfterSetViewComponent()
        -- 此时有Panel的lua类对象了，但没有显示对象。
        self:CallbackEvent("onAfterSetViewComponent")
    end



    function BaseMediator:onLoadAssetsFinish()
        -- 资源加载完成，在BindView之前。
        self:CallbackEvent("onLoadAssetsFinish")
    end

    function BaseMediator:onBeforeShowPanel()
        -- 在第一次显示之前，此时visible=false。
        self:CallbackEvent("onBeforeShowPanel")
    end
    function BaseMediator:onAfterShowPanel()
        -- 在第一次显示之后，此时visible=true。
        self:CallbackEvent("onAfterShowPanel")
    end

    function BaseMediator:onBeforeHidePanel()
        -- 在被隐藏之前(FadeOut开始前)，此时visible=true。
        self:CallbackEvent("onBeforeHidePanel")
    end
    function BaseMediator:onAfterHidePanel()
        -- 在被隐藏之后(FadeOut完成后)，此时visible=false。
        self:CallbackEvent("onAfterHidePanel")
    end

    function BaseMediator:onBeforeReshowPanel(lastPanelVO)
        -- 在被重新显示之前(FadeIn开始前)，此时visible=false。
        self:CallbackEvent("onBeforeReshowPanel")
    end
    function BaseMediator:onAfterReshowPanel(lastPanelVO)
        -- 在被重新显示之后(FadeIn完成后)，此时visible=true。
        self:CallbackEvent("onAfterReshowPanel")
    end

    function BaseMediator:onBeforeDestroyPanel()
        -- 在被销毁之前，此时visible=false。
        self:CallbackEvent("onBeforeDestroyPanel")
    end

    function BaseMediator:onAfterDestroyPanel()
        self:CallbackEvent("onAfterDestroyPanel")
    end

    function BaseMediator:onBeforePausePanel()
        -- 在被Popup面板盖住之前，此时visible=true。
        self:CallbackEvent("onBeforePausePanel")
    end
    function BaseMediator:onAfterResumePanel()
        -- 在Popup面板移除之后，此时visible=true。
        self:CallbackEvent("onAfterResumePanel")
    end
]]

---事件通知预留接口，给子类mediator重写用
function BaseMediator:onTriggerEvent(name)
    if self.callbacks then
        self.callbacks:onEvent(name)
    end
    Runtime.InvokeCbk(self[name], self)
end