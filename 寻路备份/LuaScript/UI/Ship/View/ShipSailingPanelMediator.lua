require "UI.Ship.ShipSailingPanelNotificationEnum"
local ShipSailingPanelProxy = require "UI.Ship.Model.ShipSailingPanelProxy"

local ShipSailingPanelMediator = MVCClass('ShipSailingPanelMediator', BaseMediator)

---@type ShipSailingPanel
local panel
local proxy

function ShipSailingPanelMediator:ctor(...)
	ShipSailingPanelMediator.super.ctor(self,...)
	proxy = ShipSailingPanelProxy.new()
end

function ShipSailingPanelMediator:onRegister()
end

function ShipSailingPanelMediator:onAfterSetViewComponent()
	panel = self:getViewComponent()
	panel:setProxy(proxy)
end

function ShipSailingPanelMediator:listNotificationInterests()
	return
	{
		--insertNotificationNames
        ShipSailingPanelNotificationEnum.Click_btn_close,
		ShipSailingPanelNotificationEnum.Click_btn_go,
		ShipSailingPanelNotificationEnum.Click_btn_disable,
		ShipSailingPanelNotificationEnum.Click_btn_reset,
	}
end

function ShipSailingPanelMediator:handleNotification(notification)

	local name = notification:getName()
	-- local type = notification:getType() -- uncomment if need by yourself
	-- local body = notification:getBody() --message data  uncomment if need by yourself
	--insertHandleNotificationNames
    if(name ==ShipSailingPanelNotificationEnum.Click_btn_close) then
		PanelManager.closePanel(GlobalPanelEnum.ShipSailingPanel, nil)
	elseif name == ShipSailingPanelNotificationEnum.Click_btn_go then
		panel:ClickGo()
	elseif name == ShipSailingPanelNotificationEnum.Click_btn_disable then
		panel:ClickGoDisable()
	elseif name == ShipSailingPanelNotificationEnum.Click_btn_reset then
        panel:MapReset()
    end
end

-- function ShipSailingPanelMediator:onBeforeLoadAssets()
--  -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
-- 	-- Send Request To Server
-- 	local extraAssetsNeedLoad = {}
-- 	table.insert(extraAssetsNeedLoad, "extraAssetName")
-- 	self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
-- end

-- function ShipSailingPanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

function ShipSailingPanelMediator:onBeforeShowPanel()
-- 	--在第一次显示之前，此时visible=false。
    panel:SetArguments(self.arguments)
    panel:refreshUI()
end
-- function ShipSailingPanelMediator:onAfterShowPanel()
-- 	--在第一次显示之后，此时visible=true。
-- end

-- function ShipSailingPanelMediator:onBeforeHidePanel()
-- 	--在被隐藏之前(FadeOut开始前)，此时visible=true。
-- end
function ShipSailingPanelMediator:onAfterHidePanel()
    --在被隐藏之后(FadeOut完成后)，此时visible=false。
    panel:Hide()
end

-- function ShipSailingPanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function ShipSailingPanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

-- function ShipSailingPanelMediator:onBeforeDestroyPanel()
-- 	--在被销毁之前，此时visible=false。
-- end

-- function ShipSailingPanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function ShipSailingPanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

return ShipSailingPanelMediator
