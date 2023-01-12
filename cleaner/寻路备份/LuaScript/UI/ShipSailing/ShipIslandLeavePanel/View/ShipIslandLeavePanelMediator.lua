require "UI.ShipSailing.ShipIslandLeavePanel.ShipIslandLeavePanelNotificationEnum"
local ShipIslandLeavePanelProxy = require "UI.ShipSailing.ShipIslandLeavePanel.Model.ShipIslandLeavePanelProxy"

local ShipIslandLeavePanelMediator = MVCClass('ShipIslandLeavePanelMediator', BaseMediator)

---@type ShipIslandLeavePanel
local panel
local proxy

function ShipIslandLeavePanelMediator:ctor(...)
	ShipIslandLeavePanelMediator.super.ctor(self,...)
	proxy = ShipIslandLeavePanelProxy.new()
end

function ShipIslandLeavePanelMediator:onRegister()
end

function ShipIslandLeavePanelMediator:onAfterSetViewComponent()
	panel = self:getViewComponent()
	panel:setProxy(proxy)
end

function ShipIslandLeavePanelMediator:listNotificationInterests()
	return
	{
		--insertNotificationNames
		ShipIslandLeavePanelNotificationEnum.Click_btn_cancel,
		ShipIslandLeavePanelNotificationEnum.Click_btn_confirm
	}
end

function ShipIslandLeavePanelMediator:handleNotification(notification)

	local name = notification:getName()
	-- local type = notification:getType() -- uncomment if need by yourself
	-- local body = notification:getBody() --message data  uncomment if need by yourself
	--insertHandleNotificationNames
	if (name == ShipIslandLeavePanelNotificationEnum.Click_btn_confirm) then
		panel:Leave(true)
	elseif (name == ShipIslandLeavePanelNotificationEnum.Click_btn_cancel) then
		panel:Leave(false)
    end
end

-- function ShipIslandLeavePanelMediator:onBeforeLoadAssets()
--  -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
-- 	-- Send Request To Server
-- 	local extraAssetsNeedLoad = {}
-- 	table.insert(extraAssetsNeedLoad, "extraAssetName")
-- 	self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
-- end

-- function ShipIslandLeavePanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

function ShipIslandLeavePanelMediator:onBeforeShowPanel()
	--在第一次显示之前，此时visible=false。
	panel:refreshUI()
end

-- function ShipIslandLeavePanelMediator:onAfterShowPanel()
-- 	--在第一次显示之后，此时visible=true。
-- end

-- function ShipIslandLeavePanelMediator:onBeforeHidePanel()
-- 	--在被隐藏之前(FadeOut开始前)，此时visible=true。
-- end
-- function ShipIslandLeavePanelMediator:onAfterHidePanel()
-- 	--在被隐藏之后(FadeOut完成后)，此时visible=false。
-- end

-- function ShipIslandLeavePanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function ShipIslandLeavePanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

-- function ShipIslandLeavePanelMediator:onBeforeDestroyPanel()
-- 	--在被销毁之前，此时visible=false。
-- end

-- function ShipIslandLeavePanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function ShipIslandLeavePanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

return ShipIslandLeavePanelMediator
