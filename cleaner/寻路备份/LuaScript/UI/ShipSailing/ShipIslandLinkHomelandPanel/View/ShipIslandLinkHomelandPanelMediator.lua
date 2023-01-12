require "UI.ShipSailing.ShipIslandLinkHomelandPanel.ShipIslandLinkHomelandPanelNotificationEnum"
local ShipIslandLinkHomelandPanelProxy = require "UI.ShipSailing.ShipIslandLinkHomelandPanel.Model.ShipIslandLinkHomelandPanelProxy"

local ShipIslandLinkHomelandPanelMediator = MVCClass('ShipIslandLinkHomelandPanelMediator', BaseMediator)

---@type ShipIslandLinkHomelandPanel
local panel
local proxy

function ShipIslandLinkHomelandPanelMediator:ctor(...)
	ShipIslandLinkHomelandPanelMediator.super.ctor(self,...)
	proxy = ShipIslandLinkHomelandPanelProxy.new()
end

function ShipIslandLinkHomelandPanelMediator:onRegister()
end

function ShipIslandLinkHomelandPanelMediator:onAfterSetViewComponent()
	panel = self:getViewComponent()
	panel:setProxy(proxy)
end

function ShipIslandLinkHomelandPanelMediator:listNotificationInterests()
	return
	{
		--insertNotificationNames
		ShipIslandLinkHomelandPanelNotificationEnum.Click_btn_confirm,
	}
end

function ShipIslandLinkHomelandPanelMediator:handleNotification(notification)

	local name = notification:getName()

	-- local type = notification:getType() -- uncomment if need by yourself
	-- local body = notification:getBody() --message data  uncomment if need by yourself
	--insertHandleNotificationNames
	if (name == ShipIslandLinkHomelandPanelNotificationEnum.Click_btn_confirm) then
		MessageDispatcher:SendMessage(MessageType.GoToHomeland)
		PanelManager.closePanel(GlobalPanelEnum.ShipIslandLinkHomelandPanel)
    end
end

-- function ShipIslandLinkHomelandPanelMediator:onBeforeLoadAssets()
--  -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
-- 	-- Send Request To Server
-- 	local extraAssetsNeedLoad = {}
-- 	table.insert(extraAssetsNeedLoad, "extraAssetName")
-- 	self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
-- end

-- function ShipIslandLinkHomelandPanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

function ShipIslandLinkHomelandPanelMediator:onBeforeShowPanel()
	--在第一次显示之前，此时visible=false。
	panel:refreshUI()
end
-- function ShipIslandLinkHomelandPanelMediator:onAfterShowPanel()
-- 	--在第一次显示之后，此时visible=true。
-- end

-- function ShipIslandLinkHomelandPanelMediator:onBeforeHidePanel()
-- 	--在被隐藏之前(FadeOut开始前)，此时visible=true。
-- end
-- function ShipIslandLinkHomelandPanelMediator:onAfterHidePanel()
-- 	--在被隐藏之后(FadeOut完成后)，此时visible=false。
-- end

-- function ShipIslandLinkHomelandPanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function ShipIslandLinkHomelandPanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

-- function ShipIslandLinkHomelandPanelMediator:onBeforeDestroyPanel()
-- 	--在被销毁之前，此时visible=false。
-- end

-- function ShipIslandLinkHomelandPanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function ShipIslandLinkHomelandPanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

return ShipIslandLinkHomelandPanelMediator
