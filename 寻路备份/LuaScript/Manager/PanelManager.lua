PanelManager = {}

function PanelManager:Init()
    --当前显示的面板（有层级顺序）
    --不再HIDE界面后不需要再缓存已隐藏的但可以激活的面板
    self.historyPanelVOStack = {}
    --显示面板的map
    self.showingPanelVOTable = {}
    --self.preparePanelVO = nil
    --self.popupPanelDepth = 100

    --发起的开关面板命令（开关指令匹配）
    self.panelCommondStack = {}
    self.noFade = false
end

PanelManager:Init()
--private 面板命令管理
function PanelManager.CheckCommondStack(panelName,value)
    if value and PanelManager.panelCommondStack[panelName] then
        console.lj("警告：当前想打开一个已经打开的界面，检查是否逻辑错误"..panelName)--@DEL
        return true
    end

    if not value and (not PanelManager.panelCommondStack[panelName]) then
       console.lj("警告：当前想关闭一个不存在的界面，检查是否逻辑错误"..panelName)--@DEL
       return true
    end
    PanelManager.panelCommondStack[panelName] = value
end

--接口：显示UI命令
function PanelManager.showPanel(_panelVO, arguments, callbacks)
    --数据层检查（显示阶段前重复触发同一个）
    if PanelManager.CheckCommondStack(_panelVO.panelName,true) then
        console.lj("警告：当前打开界面操作已被过滤".._panelVO.panelName)--@DEL
        return
    end

    --显示中检查（不能显示已显示的界面，只能通过刷新接口重置数据）
    print(nil, "PanelManager.showPanel:" .. _panelVO.panelName or "nil") --@DEL
    if PanelManager.isPanelShowing(_panelVO) then
        console.warn(nil, "panel is in stack:", _panelVO.panelName) --@DEL
        return
    end

    BCore.Track("showpanel:" .. _panelVO.panelName or "")

    --触发命令则不让触发其他UI指令
    Util.BlockAll(-1, _panelVO.panelName)
    --设置UI数据
    if not facade:hasMediator(_panelVO.mediatorPath) then
        local mediatorClass = require(_panelVO.mediatorPath)
        facade:registerMediator(mediatorClass.new(_panelVO.mediatorPath, nil))
    end

    --PanelManager.preparePanelVO = _panelVO
    ---@type BaseMediator
    local mediator = facade:retrieveMediator(_panelVO.mediatorPath)
    mediator:setData(_panelVO, arguments, callbacks)
    mediator:preparePanel()

    --外部功能：音效
    local disableSound = _panelVO.showFlag and _panelVO.showFlag.withoutAudio
    disableSound = disableSound or (arguments and arguments.withoutAudio)
    if disableSound then
        console.print("no audio") --@DEL
    else
        App.audioManager:PlayEffectAudio(CONST.AUDIO.Interface_sound_ui_interface)
    end

    table.insert(PanelManager.historyPanelVOStack, _panelVO)
    PanelManager.showingPanelVOTable[_panelVO.panelName] = _panelVO

    --发送显示事件（有点早）
    MessageDispatcher:SendMessage(MessageType.Global_After_Show_Panel, _panelVO)
end

--private 显示结束后的面板管理
function PanelManager.executeShowPanel(_panelVO, _panel)
    console.assert(_panelVO and _panel)
    ---@type BaseMediator
    local showMediator = facade:retrieveMediator(_panelVO.mediatorPath)
    if showMediator == nil then
        return
    end
    sendNotification(CONST.GLOBAL_NOFITY.Lock_Camera, _panelVO.panelName)

    local panelName = _panelVO.panelName

    --推送消息：界面显示（只用作于引导监听，实用性太窄，而且不是每一个面板都想要监听，为什么不加到需要监听的界面里来触发）
    _panel.gameObject:SetTimeOut(function()
        App.mapGuideManager:OnGuideFinishEvent(GuideEvent.PanelPoppedOut, panelName)
    end, 1.0/60)
    Util.BlockAll(0, panelName)
    --PanelManager.preparePanelVO = nil
end

--接口：获取当前显示的最上层面板
function PanelManager.GetTopPanel()
    local topPanelVO = PanelManager.getTopPanelVO()
    if not topPanelVO then
        return
    end
    ---@type BaseMediator
    local mediator = facade:retrieveMediator(topPanelVO.mediatorPath)
    if not mediator then
        return
    end
    return mediator:getViewComponent()
end

--接口：获取当前已显示的面板
function PanelManager.GetPanel(panelName)
    local _panelVO = PanelManager.showingPanelVOTable[panelName]
    if not _panelVO then
        return
    end
    ---@type BaseMediator
    local mediator = facade:retrieveMediator(_panelVO.mediatorPath)
    if mediator then
        return mediator:getViewComponent()
    end

    --[[
    for k, v in pairs(PanelManager.historyPanelVOStack) do
        if v.panelName == panelName then
            local mediator = facade:retrieveMediator(v.mediatorPath)
            if mediator then
                return mediator:getViewComponent()
            end
        end
    end
    return nil
    ]]
end

--接口：隐藏并销毁界面
function PanelManager.closePanel(_panelVO, _notShowStackTop, arg)
    console.systrace("PanelManager.closePanel:" .. _panelVO.panelName or "nil") --@DEL
    if _panelVO == nil then
        return
    end

    if PanelManager.CheckCommondStack(_panelVO.panelName) then
        console.lj("警告：当前关闭界面操作已被过滤".._panelVO.panelName)--@DEL
        return
    end

    local disableSound = _panelVO.showFlag and _panelVO.showFlag.withoutAudio
    disableSound = disableSound or (arg and arg.withoutAudio)
    if disableSound then
        console.print("no audio") --@DEL
    else
        App.audioManager:PlayEffectAudio(CONST.AUDIO.Interface_ClosePanel)
    end

    ---@type BaseMediator
    local mediator = facade:retrieveMediator(_panelVO.mediatorPath)
    if not mediator then
        return
    end

    --[[销毁
    if App.scene then
        local view = mediator:getViewComponent()
        local hideTopIconType = view.hideTopIconType
        if table.count(PanelManager.panelCommondStack) == 0 then
            Runtime.InvokeCbk(App.scene.HideMask,App.scene,hideTopIconType)
        elseif table.count(PanelManager.panelCommondStack) == 1 and PanelManager.panelCommondStack[_panelVO.panelName] == false then
            Runtime.InvokeCbk(App.scene.HideMask,App.scene,hideTopIconType)
        end
    end
    ]]
    Util.BlockAll(-1, _panelVO.panelName)
    mediator:_closePanel(arg)
    BCore.Track("closePanel:" .. _panelVO.panelName or "")
end

--关闭动画结束后的面板管理
function PanelManager.executeClosePanel(_panelVO)
    --发送关闭事件消息
    App.mapGuideManager:OnGuideFinishEvent(GuideEvent.OnPanelClose, _panelVO.panelName)
    MessageDispatcher:SendMessage(MessageType.Global_After_Destroy_Panel, _panelVO)
    AppServices.EventDispatcher:dispatchEvent(GlobalEvents.CLOSING_PANEL, _panelVO)
end

--私有接口：统一销毁当前所有界面(删除界面用closeAllPanel，其他功能不要使用)
function PanelManager.destroyAllPanel()
    local panelStack = PanelManager.historyPanelVOStack
    while #panelStack > 0 do
        local mediatorPath = panelStack[#panelStack].mediatorPath
        if facade:hasMediator(mediatorPath) then
            ---@type BaseMediator
            local mediator = facade:retrieveMediator(mediatorPath)
            mediator:destroyPanel()
        end
    end
    UI.Context:LockScreen("*", false)
    sendNotification(CONST.GLOBAL_NOFITY.Lock_Camera, false)
    PanelManager.historyPanelVOStack = {}
    PanelManager.panelCommondStack = {}
end

--private 销毁面板后的面板管理
function PanelManager.executeDestroyPanel(_panelVO)
    Util.BlockAll(0, _panelVO.panelName)
    if not facade:hasMediator(_panelVO.mediatorPath) then
        return console.warn(nil, "mediator has been removed!!!", _panelVO.panelName)
    end

    --if _panelVO.autoUnload then
        --for _, v in pairs(_panelVO.prefabNames) do
            --App.uiAssetsManager:DestroyAsset(v)
        --end
    --end

    facade:removeMediator(_panelVO.mediatorPath)
    PanelManager.removePanelInStack(_panelVO)
    PanelManager.removePanelInShowingDic(_panelVO)
    sendNotification(CONST.GLOBAL_NOFITY.Lock_Camera, false)
    App.mapGuideManager:OnGuideFinishEvent(GuideEvent.AfterPanelClosed, _panelVO.panelName)
    AppServices.DiamondConfirmUIManager:Release()
end
function PanelManager.ForcePanelNoFade(value)
    PanelManager.noFade = value
end

function PanelManager.CheckNeedFade()
    return  PanelManager.noFade
end
--接口：关闭当前显示的所有面板
function PanelManager.closeAllPanels()
    for _, tempPanelVO in pairs(PanelManager.historyPanelVOStack) do
        if tempPanelVO ~= nil  then
            PanelManager.closePanel(tempPanelVO)
        end
    end
    PanelManager.historyPanelVOStack = {}
    PanelManager.panelCommondStack = {}
end

--接口：查看指定面板是否显示,包含所有生存周期
function PanelManager.isPanelExist(_panelVO)
    local panelVO = PanelManager.showingPanelVOTable[_panelVO.panelName]
    return panelVO ~= nil
end

--接口：查看指定面板实体是否显示，只包含打开动画与动画播完状态
function PanelManager.isPanelShowing(_panelVO)
    local panelVO = PanelManager.showingPanelVOTable[_panelVO.panelName]
    if not panelVO then
        return false
    end
    local mediator = facade:retrieveMediator(panelVO.mediatorPath)
    if mediator then
        return mediator:onCheckNotify()
    end
    return false
end

--接口：查看是否有任意面板显示
function PanelManager.isShowingAnyPanel()
    --if PanelManager.preparePanelVO then
    --    return true
    --end
    if PanelManager.historyPanelVOStack and #PanelManager.historyPanelVOStack > 0 then
        return true
    end
    return false
end

--private ：获取顶层面板
function PanelManager.getTopPanelVO()
    local panelVO = nil
    if PanelManager.historyPanelVOStack ~= nil and #PanelManager.historyPanelVOStack >= 1 then
        panelVO = PanelManager.historyPanelVOStack[#PanelManager.historyPanelVOStack]
    end
    return panelVO
end
--private ：移除historyPanelVOStack
function PanelManager.removePanelInStack(_panelVO)
    if _panelVO == nil then
        return nil
    end

    local removeIndex = -1
    for i = #PanelManager.historyPanelVOStack, 1, -1 do
        local tempPanelVO = PanelManager.historyPanelVOStack[i]
        if tempPanelVO.panelName == _panelVO.panelName then
            removeIndex = i
            break
        end
    end

    if removeIndex > -1 then
        table.remove(PanelManager.historyPanelVOStack, removeIndex)
    end
end

--private：移除showingPanelVOTable
function PanelManager.removePanelInShowingDic(_panelVO)
    if _panelVO == nil then
        return nil
    end

    if PanelManager.showingPanelVOTable[_panelVO.panelName] ~= nil then
        PanelManager.showingPanelVOTable[_panelVO.panelName] = nil
    end
end

--旧接口即将停用
function PanelManager.closeTopPanel()
    --console.warn(nil,"警告：PanelManager.closeTopPanel即将被删除，使用PanelManager.closeAllPanel接口或者PanelManager.closePanel替代")
    local topPanelVO = PanelManager.getTopPanelVO()
    if topPanelVO == nil then
        --error("PanelManager.closeTopPanel: top panel is nil !")
        return
    end
    PanelManager.closePanel(topPanelVO)
end

function PanelManager.getTopPanelVOForNavigation()
    local panelVO = nil
    if PanelManager.historyPanelVOStack ~= nil and #PanelManager.historyPanelVOStack >= 1 then
        panelVO = PanelManager.historyPanelVOStack[#PanelManager.historyPanelVOStack]
        if panelVO.navigation_key_disable then
            return nil
        end
    end
    return panelVO
end