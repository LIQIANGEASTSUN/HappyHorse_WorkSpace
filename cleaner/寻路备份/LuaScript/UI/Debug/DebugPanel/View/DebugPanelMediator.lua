require "UI.Debug.DebugPanel.DebugPanelNotificationEnum"
local DebugPanelProxy = require "UI.Debug.DebugPanel.Model.DebugPanelProxy"

local DebugPanelMediator = MVCClass("DebugPanelMediator", BaseMediator)

local panel
local proxy

function DebugPanelMediator:ctor(...)
    DebugPanelMediator.super.ctor(self, ...)
    proxy = DebugPanelProxy.new()
end

function DebugPanelMediator:onRegister()
end

function DebugPanelMediator:onAfterSetViewComponent()
    panel = self:getViewComponent()
    panel:setProxy(proxy)
end

function DebugPanelMediator:listNotificationInterests()
    return {
        --insertNotificationNames
        DebugPanelNotificationEnum.Click_btn_level,
        DebugPanelNotificationEnum.Click_btn_mission,
        DebugPanelNotificationEnum.Click_btn_unlockallmap,
        DebugPanelNotificationEnum.Click_btn_gc,
        DebugPanelNotificationEnum.Click_btn_close,
        DebugPanelNotificationEnum.Click_ClearDynamicResource,
        DebugPanelNotificationEnum.Click_btnCrashlyticsTester,
        DebugPanelNotificationEnum.Click_btnRestart,
        DebugPanelNotificationEnum.Click_btn_orderTask,
        DebugPanelNotificationEnum.Click_btn_CollectionItem,
        DebugPanelNotificationEnum.Click_btn_NoDrama,
        DebugPanelNotificationEnum.Click_btn_TimeOrder,
        DebugPanelNotificationEnum.Click_btn_autodig,
    }
end

function DebugPanelMediator:handleNotification(notification)
    local name = notification:getName()
    -- local type = notification:getType()
    -- local body = notification:getBody() --message data
    --insertHandleNotificationNames
    local panel = self:getViewComponent()
    if (name == DebugPanelNotificationEnum.Click_btn_level) then
        self:closePanel()
        local func = include("Configs.GuideTest") --@DEL
        Runtime.InvokeCbk(func) --@DEL
    elseif (name == DebugPanelNotificationEnum.Click_btn_mission) then
        self:closePanel()

        local taskId = tostring(panel.mission_text.text)
        if taskId then
            if not AppServices.Task:HaveTask(taskId) then
                AppServices.UITextTip:Show('无此任务' .. taskId)
            else
                local DebugHelper = require "System.Debug.DebugHelper"
                DebugHelper.PassMissionTo(taskId)
            end
        end
    elseif name == DebugPanelNotificationEnum.Click_btn_unlockallmap then
        local DebugHelper = require "System.Debug.DebugHelper"
        DebugHelper.UnlocalAllMap()
        self:closePanel()
    elseif name == DebugPanelNotificationEnum.Click_btn_autodig then
        local digDis = tonumber(panel.digdis_text.text) or 3
        local DebugHelper = require "System.Debug.DebugHelper"
        DebugHelper.AutoDig(digDis)
        self:closePanel()
    elseif name == DebugPanelNotificationEnum.Click_btn_close then
        self:closePanel()
    elseif name == DebugPanelNotificationEnum.Click_btn_gc then
        -- GC
        Runtime.CSCollectGarbage(true)
    elseif name == DebugPanelNotificationEnum.Click_btnCrashlyticsTester then
        panel.gameObject:AddComponent(typeof(CS.CrashlyticsTester))
    elseif name == DebugPanelNotificationEnum.Click_btnRestart then
        --[[
        local processor = require "Game.Processors.ChangeSceneProcessor"
        local extraParam = {}
        extraParam.IsFromLoading = false
        extraParam.startTime = TimeUtil.ServerTime()
        processor.Change("LoadingScene", nil, extraParam)
        ]]
        ReenterGame()
    elseif name == DebugPanelNotificationEnum.Click_btn_orderTask then
        AppServices.OrderTask:ShowPanel()
        self:closePanel()
    elseif name == DebugPanelNotificationEnum.Click_btn_CollectionItem then
        -- PanelManager.showPanel(GlobalPanelEnum.CollectionItemPanel)
        self.arguments = self.arguments or {}
        self.arguments.closeCallback = function()
            App.scene.interaction:OnShake()
        end
        self:closePanel()
    elseif name == DebugPanelNotificationEnum.Click_btn_NoDrama then
        local isNoDrama = AppServices.Task:SwitchNoDrama()
        panel:SwitchNoDrama(isNoDrama)
    elseif name == DebugPanelNotificationEnum.Click_btn_TimeOrder then
        self:closePanel()
        AppServices.TimeOrder:ShowPanel()
    elseif name == DebugPanelNotificationEnum.Click_ClearDynamicResource then
        CS.Bridge.Debug.ClearDynamicCache()
    end
end

-- function DebugPanelMediator:onBeforeLoadAssets()
--  -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
-- 	-- Send Request To Server
-- 	local extraAssetsNeedLoad = {}
-- 	table.insert(extraAssetsNeedLoad, "extraAssetName")
-- 	self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
-- end

-- function DebugPanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

-- function DebugPanelMediator:onBeforeShowPanel()
-- 	--在第一次显示之前，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function DebugPanelMediator:onAfterShowPanel()
-- 	--在第一次显示之后，此时visible=true。
-- end

-- function DebugPanelMediator:onBeforeHidePanel()
-- 	--在被隐藏之前(FadeOut开始前)，此时visible=true。
-- end
-- function DebugPanelMediator:onAfterHidePanel()
-- 	--在被隐藏之后(FadeOut完成后)，此时visible=false。
-- end

-- function DebugPanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function DebugPanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

-- function DebugPanelMediator:onBeforeDestroyPanel()
-- 	--在被销毁之前，此时visible=false。
-- end

-- function DebugPanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function DebugPanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

return DebugPanelMediator
