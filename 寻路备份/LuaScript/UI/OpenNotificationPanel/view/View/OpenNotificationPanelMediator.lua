require "UI.OpenNotificationPanel.view.OpenNotificationPanelNotificationEnum"
local OpenNotificationPanelProxy = require "UI.OpenNotificationPanel.view.Model.OpenNotificationPanelProxy"

local OpenNotificationPanelMediator = MVCClass("OpenNotificationPanelMediator", BaseMediator)

local panel
local proxy

function OpenNotificationPanelMediator:ctor(...)
    OpenNotificationPanelMediator.super.ctor(self, ...)
    proxy = OpenNotificationPanelProxy.new()
end

function OpenNotificationPanelMediator:onRegister()
end

function OpenNotificationPanelMediator:onAfterSetViewComponent()
    panel = self:getViewComponent()
    panel:setProxy(proxy)
end

function OpenNotificationPanelMediator:listNotificationInterests()
    return {
        --insertNotificationNames
        OpenNotificationPanelNotificationEnum.Click_btn_open,
        OpenNotificationPanelNotificationEnum.Click_btn_cancel,
        OpenNotificationPanelNotificationEnum.Click_btn_close
    }
end

function OpenNotificationPanelMediator:handleNotification(notification)
    local name = notification:getName()
    -- local type = notification:getType()
    -- local body = notification:getBody() --message data
    --insertHandleNotificationNames
    if (name == OpenNotificationPanelNotificationEnum.Click_btn_open) then
        self:BILog(2)
        self:OnBtnClick(true)
        AppServices.Notification:ResetOpenUITimes()
    elseif (name == OpenNotificationPanelNotificationEnum.Click_btn_cancel) then
        self:BILog(1)
        self:OnBtnClick()
    elseif (name == OpenNotificationPanelNotificationEnum.Click_btn_close) then
        self:BILog(3)
        self:OnBtnClick()
    end
end

function OpenNotificationPanelMediator:OnBtnClick(isAgree)
    if isAgree then
        -- AppServices.PackageDefault:SetKeyValue("notification_open", 1, true)
        AppServices.Notification:RequestOpen()
        AppServices.Notification:OpenSettings()
    -- AppServices.Notification:OpenSettingsURL()
    end

    if self.arguments and self.arguments.finishCallback then
        Runtime.InvokeCbk(self.arguments.finishCallback)
    end
    self:closePanel()
end

function OpenNotificationPanelMediator:BILog(type)
    DcDelegates:Log(SDK_EVENT.push_guide, {buttonName = type, num = AppServices.Notification:GetOpenUITimes()})
end

-- function OpenNotificationPanelMediator:onBeforeLoadAssets()
--  -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
-- 	-- Send Request To Server
-- 	local extraAssetsNeedLoad = {}
-- 	table.insert(extraAssetsNeedLoad, "extraAssetName")
-- 	self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
-- end

-- function OpenNotificationPanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

-- function OpenNotificationPanelMediator:onBeforeShowPanel()
-- 	--在第一次显示之前，此时visible=false。
-- 	panel:refreshUI()
-- end
function OpenNotificationPanelMediator:onAfterShowPanel()
    --在第一次显示之后，此时visible=true。
    AppServices.Notification:IncreaceOpenUITimes()
end

-- function OpenNotificationPanelMediator:onBeforeHidePanel()
-- 	--在被隐藏之前(FadeOut开始前)，此时visible=true。
-- end
-- function OpenNotificationPanelMediator:onAfterHidePanel()
-- 	--在被隐藏之后(FadeOut完成后)，此时visible=false。
-- end

-- function OpenNotificationPanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function OpenNotificationPanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

-- function OpenNotificationPanelMediator:onBeforeDestroyPanel()
-- 	--在被销毁之前，此时visible=false。
-- end

-- function OpenNotificationPanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function OpenNotificationPanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

return OpenNotificationPanelMediator
