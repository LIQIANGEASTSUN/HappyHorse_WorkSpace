require "UI.LoginScenePanel.LoginScenePanelNotificationEnum"
local LoginScenePanelProxy = require "UI.LoginScenePanel.Model.LoginScenePanelProxy"

local LoginScenePanelMediator = MVCClass('LoginScenePanelMediator', BaseMediator)

---@type LoginScenePanel
local panel
local proxy

function LoginScenePanelMediator:ctor(...)
	LoginScenePanelMediator.super.ctor(self,...)
	proxy = LoginScenePanelProxy.new()
end

function LoginScenePanelMediator:onRegister()
end

function LoginScenePanelMediator:onAfterSetViewComponent()
	panel = self:getViewComponent()
	panel:setProxy(proxy)
end

function LoginScenePanelMediator:listNotificationInterests()
	return
	{
		--insertNotificationNames
        LoginScenePanelNotificationEnum.Click_btn_Confirm,
        LoginScenePanelNotificationEnum.Click_btn_FAQ,
		LoginScenePanelNotificationEnum.Refresh_FAQ_RED,
		LoginScenePanelNotificationEnum.FAQ_INIT_TRUE,
		CONST.GLOBAL_NOFITY.Login_Start,
		CONST.GLOBAL_NOFITY.Login_Fail,
	}
end

function LoginScenePanelMediator:handleNotification(notification)

	local name = notification:getName()
	--local type = notification:getType()
	--local body = notification:getBody() --message data
	--insertHandleNotificationNames
    --if(name == "") then
    if(name == LoginScenePanelNotificationEnum.Click_btn_Confirm) then
		local channel = "visitor"
        if App.loginLogic:IsTestMode() then
            if panel.TestBtn and not panel.TestBtn:CheckAccountConfirm() then
                return
            end
            channel = "visitor_test"
        end
		DcDelegates:LogLoading(6)
		local userName = panel:GetUserName()
		local data = {bindpage = 2, userName = userName}
        App.loginLogic:Login_Start(channel, data)
        panel:HideAll()
    elseif(name == LoginScenePanelNotificationEnum.Click_btn_FAQ) then
		if App.FAQ then
			App.FAQ:ShowFAQ()
		end
	elseif(name == LoginScenePanelNotificationEnum.Refresh_FAQ_RED) then
		panel:refreshFAQRed()
	elseif(name == CONST.GLOBAL_NOFITY.Login_Fail) then
		panel:refreshUI()
	elseif(name == CONST.GLOBAL_NOFITY.Login_Start) then
		panel:HideAll()
	elseif(name == LoginScenePanelNotificationEnum.FAQ_INIT_TRUE) then
		if panel and panel.btn_FAQ then
			panel.btn_FAQ:SetActive(true)
		end
    --else
    end
end

-- function LoginScenePanelMediator:onBeforeLoadAssets()
--  -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
-- 	-- Send Request To Server
-- 	local extraAssetsNeedLoad = {}
-- 	table.insert(extraAssetsNeedLoad, "extraAssetName")
-- 	self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
-- end

-- function LoginScenePanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

-- function LoginScenePanelMediator:onBeforeShowPanel()
-- 	--在第一次显示之前，此时visible=false。
-- 	panel:refreshUI()
-- end
 function LoginScenePanelMediator:onAfterShowPanel()
-- 	--在第一次显示之后，此时visible=true。
	panel:refreshUI()

	local processor = require("Game.Processors.KeyEventProcessor")
    processor.Enable = true
 end

-- function LoginScenePanelMediator:onBeforeHidePanel()
-- 	--在被隐藏之前(FadeOut开始前)，此时visible=true。
-- end
-- function LoginScenePanelMediator:onAfterHidePanel()
-- 	--在被隐藏之后(FadeOut完成后)，此时visible=false。
-- end

-- function LoginScenePanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function LoginScenePanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

-- function LoginScenePanelMediator:onBeforeDestroyPanel()
-- 	--在被销毁之前，此时visible=false。
-- end

-- function LoginScenePanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function LoginScenePanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

return LoginScenePanelMediator
