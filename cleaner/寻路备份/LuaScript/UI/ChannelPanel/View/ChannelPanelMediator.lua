require "UI.ChannelPanel.ChannelPanelNotificationEnum"
local ChannelPanelProxy = require "UI.ChannelPanel.Model.ChannelPanelProxy"

local ChannelPanelMediator = MVCClass('ChannelPanelMediator', BaseMediator)

---@type ChannelPanel
local panel
local proxy

function ChannelPanelMediator:ctor(...)
	ChannelPanelMediator.super.ctor(self,...)
	proxy = ChannelPanelProxy.new()
end

function ChannelPanelMediator:onRegister()
end

function ChannelPanelMediator:onAfterSetViewComponent()
	panel = self:getViewComponent()
	panel:setProxy(proxy)
end

function ChannelPanelMediator:listNotificationInterests()
	return
	{
		--insertNotificationNames
        ChannelPanelNotificationEnum.Click_btn_panel,
		ChannelPanelNotificationEnum.Click_btn_close,
		ChannelPanelNotificationEnum.Click_btn_facebook,
		ChannelPanelNotificationEnum.Click_btn_apple,
	}
end

function ChannelPanelMediator:GetBindPage()
	local bindpage
	if panel.arguments.sourcePanel then
		if panel.arguments.sourcePanel == GlobalPanelEnum.SettingPanel then
			bindpage = 1
		elseif panel.arguments.sourcePanel == GlobalPanelEnum.LoginScenePanel then
			bindpage = 2
		end
	end
	return bindpage
end

function ChannelPanelMediator:handleNotification(notification)

	local name = notification:getName()
	--local type = notification:getType()
	--local body = notification:getBody() --message data
	--insertHandleNotificationNames
    --if(name == "") then
    if(name == ChannelPanelNotificationEnum.Click_btn_panel) then
		self:closePanel()
	elseif(name == ChannelPanelNotificationEnum.Click_btn_close) then
		self:closePanel()
	elseif name == ChannelPanelNotificationEnum.Click_btn_facebook then
		App.loginLogic:Login_Start("fb", self:GetBindPage())
		self:closePanel()
		PanelManager.closePanel(GlobalPanelEnum.SettingPanel)
	elseif name == ChannelPanelNotificationEnum.Click_btn_apple then
		--App.iosSdk = panel:GetSignInWithApple()
		App.loginLogic:Login_Start("ios", self:GetBindPage())
		self:closePanel()
	end
end

-- function ChannelPanelMediator:onBeforeLoadAssets()
--  -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
-- 	-- Send Request To Server
-- end

-- function ChannelPanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

 function ChannelPanelMediator:onBeforeShowPanel()
-- 	--在第一次显示之前，此时visible=false。
	panel:refreshUI()
 end
-- function ChannelPanelMediator:onAfterShowPanel()
-- 	--在第一次显示之后，此时visible=true。
-- end

-- function ChannelPanelMediator:onBeforeHidePanel()
-- 	--在被隐藏之前(FadeOut开始前)，此时visible=true。
-- end
-- function ChannelPanelMediator:onAfterHidePanel()
-- 	--在被隐藏之后(FadeOut完成后)，此时visible=false。
-- end

-- function ChannelPanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function ChannelPanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

-- function ChannelPanelMediator:onBeforeDestroyPanel()
-- 	--在被销毁之前，此时visible=false。
-- end

-- function ChannelPanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function ChannelPanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

return ChannelPanelMediator
