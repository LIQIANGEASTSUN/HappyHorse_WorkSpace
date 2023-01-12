require "UI.ShipSailing.ShipIslandLockPanel.ShipIslandLockPanelNotificationEnum"
local ShipIslandLockPanelProxy = require "UI.ShipSailing.ShipIslandLockPanel.Model.ShipIslandLockPanelProxy"

local ShipIslandLockPanelMediator = MVCClass('ShipIslandLockPanelMediator', BaseMediator)

---@type ShipIslandLockPanel
local panel
local proxy

function ShipIslandLockPanelMediator:ctor(...)
	ShipIslandLockPanelMediator.super.ctor(self,...)
	proxy = ShipIslandLockPanelProxy.new()
end

function ShipIslandLockPanelMediator:onRegister()
end

function ShipIslandLockPanelMediator:onAfterSetViewComponent()
	panel = self:getViewComponent()
	panel:setProxy(proxy)
end

function ShipIslandLockPanelMediator:listNotificationInterests()
	return
	{
		--insertNotificationNames
		ShipIslandLockPanelNotificationEnum.Click_btn_close
	}
end

function ShipIslandLockPanelMediator:handleNotification(notification)

	local name = notification:getName()
	-- local type = notification:getType() -- uncomment if need by yourself
	-- local body = notification:getBody() --message data  uncomment if need by yourself
	--insertHandleNotificationNames
	if (name == ShipIslandLockPanelNotificationEnum.Click_btn_close) then
		PanelManager.closePanel(GlobalPanelEnum.ShipIslandLockPanel)
    end
end

-- function ShipIslandLockPanelMediator:onBeforeLoadAssets()
--  -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
-- 	-- Send Request To Server
-- 	local extraAssetsNeedLoad = {}
-- 	table.insert(extraAssetsNeedLoad, "extraAssetName")
-- 	self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
-- end

-- function ShipIslandLockPanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

function ShipIslandLockPanelMediator:onBeforeShowPanel()
	--在第一次显示之前，此时visible=false。
	panel:SetArguments(self.arguments)
	panel:refreshUI()
end

-- function ShipIslandLockPanelMediator:onAfterShowPanel()
-- 	--在第一次显示之后，此时visible=true。
-- end

function ShipIslandLockPanelMediator:onBeforeHidePanel()
	--在被隐藏之前(FadeOut开始前)，此时visible=true。
	panel:Hide()
end
-- function ShipIslandLockPanelMediator:onAfterHidePanel()
-- 	--在被隐藏之后(FadeOut完成后)，此时visible=false。
-- end

-- function ShipIslandLockPanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function ShipIslandLockPanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

-- function ShipIslandLockPanelMediator:onBeforeDestroyPanel()
-- 	--在被销毁之前，此时visible=false。
-- end

-- function ShipIslandLockPanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function ShipIslandLockPanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

return ShipIslandLockPanelMediator
