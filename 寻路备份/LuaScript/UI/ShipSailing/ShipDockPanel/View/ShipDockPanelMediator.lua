require "UI.ShipSailing.ShipDockPanel.ShipDockPanelNotificationEnum"
local ShipDockPanelProxy = require "UI.ShipSailing.ShipDockPanel.Model.ShipDockPanelProxy"

local ShipDockPanelMediator = MVCClass('ShipDockPanelMediator', BaseMediator)

---@type ShipDockPanel
local panel
local proxy

function ShipDockPanelMediator:ctor(...)
	ShipDockPanelMediator.super.ctor(self,...)
	proxy = ShipDockPanelProxy.new()
end

function ShipDockPanelMediator:onRegister()
end

function ShipDockPanelMediator:onAfterSetViewComponent()
	panel = self:getViewComponent()
	panel:setProxy(proxy)
end

function ShipDockPanelMediator:listNotificationInterests()
	return
	{
		--insertNotificationNames
		ShipDockPanelNotificationEnum.Click_btn_close,
		ShipDockPanelNotificationEnum.Click_btn_upLevel,
	}
end

function ShipDockPanelMediator:handleNotification(notification)

	local name = notification:getName()
	-- local type = notification:getType() -- uncomment if need by yourself
	-- local body = notification:getBody() --message data  uncomment if need by yourself
	--insertHandleNotificationNames

	if(name ==ShipDockPanelNotificationEnum.Click_btn_close) then
		PanelManager.closePanel(GlobalPanelEnum.ShipDockPanel)
	elseif (name == ShipDockPanelNotificationEnum.Click_btn_upLevel) then
        panel:UpLevelClick()
    end
end

-- function ShipDockPanelMediator:onBeforeLoadAssets()
--  -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
-- 	-- Send Request To Server
-- 	local extraAssetsNeedLoad = {}
-- 	table.insert(extraAssetsNeedLoad, "extraAssetName")
-- 	self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
-- end

-- function ShipDockPanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

function ShipDockPanelMediator:onBeforeShowPanel()
	--在第一次显示之前，此时visible=false。
	panel:SetArguments(self.arguments)
	panel:refreshUI()
end
-- function ShipDockPanelMediator:onAfterShowPanel()
-- 	--在第一次显示之后，此时visible=true。
-- end

function ShipDockPanelMediator:onBeforeHidePanel()
	--在被隐藏之前(FadeOut开始前)，此时visible=true。
	panel:Hide()
end
-- function ShipDockPanelMediator:onAfterHidePanel()
-- 	--在被隐藏之后(FadeOut完成后)，此时visible=false。
-- end

-- function ShipDockPanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function ShipDockPanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

-- function ShipDockPanelMediator:onBeforeDestroyPanel()
-- 	--在被销毁之前，此时visible=false。
-- end

-- function ShipDockPanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function ShipDockPanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

return ShipDockPanelMediator
