require "UI.FoodFactory.FoodFactoryPanelNotificationEnum"
local FoodFactoryPanelProxy = require "UI.FoodFactory.Model.FoodFactoryPanelProxy"

local FoodFactoryPanelMediator = MVCClass('FoodFactoryPanelMediator', BaseMediator)

---@type FoodFactoryPanel
local panel
local proxy

function FoodFactoryPanelMediator:ctor(...)
	FoodFactoryPanelMediator.super.ctor(self,...)
	proxy = FoodFactoryPanelProxy.new()
end

function FoodFactoryPanelMediator:onRegister()
end

function FoodFactoryPanelMediator:onAfterSetViewComponent()
	panel = self:getViewComponent()
	panel:setProxy(proxy)
end

function FoodFactoryPanelMediator:listNotificationInterests()
	return
	{
		FoodFactoryPanelNotificationEnum.Click_btn_close,
		FoodFactoryPanelNotificationEnum.Type_btn_click
	}
end

function FoodFactoryPanelMediator:handleNotification(notification)

	local name = notification:getName()
	-- local type = notification:getType() -- uncomment if need by yourself
	-- local body = notification:getBody() --message data  uncomment if need by yourself
	--insertHandleNotificationNames
	if(name ==FoodFactoryPanelNotificationEnum.Click_btn_close) then
		PanelManager.closePanel(GlobalPanelEnum.FoodFactoryPanel, nil)
	elseif (name == FoodFactoryPanelNotificationEnum.Type_btn_click) then
	    local body = notification:getBody() --消息携带数据
		panel:TypeClick(body)
    end
end

-- function FoodFactoryPanelMediator:onBeforeLoadAssets()
--  -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
-- 	-- Send Request To Server
-- 	local extraAssetsNeedLoad = {}
-- 	table.insert(extraAssetsNeedLoad, "extraAssetName")
-- 	self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
-- end

-- function FoodFactoryPanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

function FoodFactoryPanelMediator:onBeforeShowPanel()
	panel:SetArguments(self.arguments)
	--在第一次显示之前，此时visible=false。
	panel:refreshUI()
end

-- function FoodFactoryPanelMediator:onAfterShowPanel()
-- 	--在第一次显示之后，此时visible=true。
-- end

function FoodFactoryPanelMediator:onBeforeHidePanel()
	--在被隐藏之前(FadeOut开始前)，此时visible=true。
	panel:Hide()
end
-- function FoodFactoryPanelMediator:onAfterHidePanel()
-- 	--在被隐藏之后(FadeOut完成后)，此时visible=false。
-- end

-- function FoodFactoryPanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function FoodFactoryPanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

-- function FoodFactoryPanelMediator:onBeforeDestroyPanel()
-- 	--在被销毁之前，此时visible=false。
-- end

-- function FoodFactoryPanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function FoodFactoryPanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

return FoodFactoryPanelMediator
