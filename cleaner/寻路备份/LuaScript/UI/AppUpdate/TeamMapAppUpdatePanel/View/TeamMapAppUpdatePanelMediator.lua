require "UI.AppUpdate.TeamMapAppUpdatePanel.TeamMapTeamMapAppUpdatePanelNotificationEnum"
local AppUpdatePanelProxy = require "UI.AppUpdate.TeamMapAppUpdatePanel.Model.TeamMapAppUpdatePanelProxy"

local TeamMapAppUpdatePanelMediator = MVCClass("TeamMapAppUpdatePanelMediator", BaseMediator)

local panel
local proxy

function TeamMapAppUpdatePanelMediator:ctor(...)
    TeamMapAppUpdatePanelMediator.super.ctor(self, ...)
    proxy = AppUpdatePanelProxy.new()
end

function TeamMapAppUpdatePanelMediator:onRegister()
end

function TeamMapAppUpdatePanelMediator:onAfterSetViewComponent()
    panel = self:getViewComponent()
    panel:setProxy(proxy)
end

function TeamMapAppUpdatePanelMediator:listNotificationInterests()
    return {
        --insertNotificationNames
        TeamMapAppUpdatePanelNotificationEnum.Click_btn_later,
        TeamMapAppUpdatePanelNotificationEnum.Click_btn_update,
        TeamMapAppUpdatePanelNotificationEnum.Click_btn_force_update
    }
end

function TeamMapAppUpdatePanelMediator:handleNotification(notification)
    local name = notification:getName()
    --local type = notification:getType()
    --local body = notification:getBody() --message data
    --insertHandleNotificationNames
    if (name == "") then
    elseif (name == TeamMapAppUpdatePanelNotificationEnum.Click_btn_later) then
        self:UpdateLater()
    elseif (name == TeamMapAppUpdatePanelNotificationEnum.Click_btn_update) then
        self:GotoUpdateApp()
    elseif (name == TeamMapAppUpdatePanelNotificationEnum.Click_btn_force_update) then
        self:GotoUpdateApp()
    else
    end
end

-- function TeamMapAppUpdatePanelMediator:onBeforeLoadAssets()
--  -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
-- 	-- Send Request To Server
-- 	local extraAssetsNeedLoad = {}
-- 	table.insert(extraAssetsNeedLoad, "extraAssetName")
-- 	self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
-- end

-- function TeamMapAppUpdatePanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

function TeamMapAppUpdatePanelMediator:onBeforeShowPanel()
    panel:ShowButton()
end

function TeamMapAppUpdatePanelMediator:onAfterShowPanel()
    DcDelegates:Log("update_windowNum")
end

-- function TeamMapAppUpdatePanelMediator:onBeforeHidePanel()
-- 	--在被隐藏之前(FadeOut开始前)，此时visible=true。
-- end
function TeamMapAppUpdatePanelMediator:onAfterHidePanel()
    --在被隐藏之后(FadeOut完成后)，此时visible=false。
    Runtime.InvokeCbk(self.arguments.finishCallback)
end

-- function TeamMapAppUpdatePanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function TeamMapAppUpdatePanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

-- function TeamMapAppUpdatePanelMediator:onBeforeDestroyPanel()
-- 	--在被销毁之前，此时visible=false。
-- end

-- function TeamMapAppUpdatePanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function TeamMapAppUpdatePanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

function TeamMapAppUpdatePanelMediator:UpdateLater()
    local isForceUpdate = self.arguments.forceUpdate
    DcDelegates:Log("update_later", {version = RuntimeContext.BUNDLE_VERSION})
    if not isForceUpdate then
        AppUpdateManager:RecordDNDTime()
    end
    self:closePanel()
end

function TeamMapAppUpdatePanelMediator:GotoUpdateApp()
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
        App:Quit({source = "TeamMapAppUpdatePanel"})
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

return TeamMapAppUpdatePanelMediator
