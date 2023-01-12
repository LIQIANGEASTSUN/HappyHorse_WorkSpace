require "UI.AppUpdate.AppUpdatePanel.AppUpdatePanelNotificationEnum"
local AppUpdatePanelProxy = require "UI.AppUpdate.AppUpdatePanel.Model.AppUpdatePanelProxy"

local AppUpdatePanelMediator = MVCClass("AppUpdatePanelMediator", BaseMediator)

local panel
local proxy

function AppUpdatePanelMediator:ctor(...)
    AppUpdatePanelMediator.super.ctor(self, ...)
    proxy = AppUpdatePanelProxy.new()
end

function AppUpdatePanelMediator:onRegister()
end

function AppUpdatePanelMediator:onAfterSetViewComponent()
    panel = self:getViewComponent()
    panel:setProxy(proxy)
end

function AppUpdatePanelMediator:listNotificationInterests()
    return {
        --insertNotificationNames
        AppUpdatePanelNotificationEnum.Click_btn_later,
        AppUpdatePanelNotificationEnum.Click_btn_update,
        AppUpdatePanelNotificationEnum.Click_btn_force_update
    }
end

function AppUpdatePanelMediator:handleNotification(notification)
    local name = notification:getName()
    --local type = notification:getType()
    --local body = notification:getBody() --message data
    --insertHandleNotificationNames
    if (name == "") then
    elseif (name == AppUpdatePanelNotificationEnum.Click_btn_later) then
        self:UpdateLater()
    elseif (name == AppUpdatePanelNotificationEnum.Click_btn_update) then
        self:GotoUpdateApp()
    elseif (name == AppUpdatePanelNotificationEnum.Click_btn_force_update) then
        self:GotoUpdateApp()
    else
    end
end

-- function AppUpdatePanelMediator:onBeforeLoadAssets()
--  -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
-- 	-- Send Request To Server
-- 	local extraAssetsNeedLoad = {}
-- 	table.insert(extraAssetsNeedLoad, "extraAssetName")
-- 	self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
-- end

-- function AppUpdatePanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

function AppUpdatePanelMediator:onBeforeShowPanel()
    local isForceUpdate = self.arguments.forceUpdate
    local rewards = self.arguments.rewards
    panel:ShowButton(isForceUpdate)
    panel:SetRewards(rewards)
end

function AppUpdatePanelMediator:onAfterShowPanel()
    DcDelegates:Log("update_windowNum")
end

-- function AppUpdatePanelMediator:onBeforeHidePanel()
-- 	--在被隐藏之前(FadeOut开始前)，此时visible=true。
-- end
function AppUpdatePanelMediator:onAfterHidePanel()
    --在被隐藏之后(FadeOut完成后)，此时visible=false。
    Runtime.InvokeCbk(self.arguments.finishCallback)
    local forceUpdate = self.arguments.forceUpdate
    if not forceUpdate and self.jumpInfo then
        WaitExtension.SetTimeout(
            function()
                CS.UnityEngine.Application.OpenURL(self.jumpInfo.url)
            end,
            0.1
        )
    end
end

-- function AppUpdatePanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function AppUpdatePanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

-- function AppUpdatePanelMediator:onBeforeDestroyPanel()
-- 	--在被销毁之前，此时visible=false。
-- end

-- function AppUpdatePanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function AppUpdatePanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

function AppUpdatePanelMediator:UpdateLater()
    local isForceUpdate = self.arguments.forceUpdate
    DcDelegates:Log("update_later", {version = RuntimeContext.BUNDLE_VERSION})
    if not isForceUpdate then
        AppUpdateManager:RecordDNDTime()
    end
    self:closePanel()
end

function AppUpdatePanelMediator:GotoUpdateApp()
    local url = ""
    local jump = false
    local forceUpdate = self.arguments.forceUpdate
    local key = "update_agree"
    if forceUpdate then
        key = "forceUpdate_agree"
    end
    DcDelegates:Log(key, {version = RuntimeContext.BUNDLE_VERSION})
    if RuntimeContext.PLATFORM_NAME == "iOS" then
        jump = true
        url = NetworkConfig.appStoreUrl_iOS
    elseif RuntimeContext.PLATFORM_NAME == "Android" then
        jump = true
        url = NetworkConfig.appStoreUrl_android
    else
        App:Quit({source = "AppUpdatePanel"})
    end
    if jump then
        if forceUpdate then
            CS.UnityEngine.Application.OpenURL(url)
        else
            self.jumpInfo = {
                url = url
            }
        end
    end
    if not forceUpdate then
        self:closePanel()
    end
end

return AppUpdatePanelMediator
