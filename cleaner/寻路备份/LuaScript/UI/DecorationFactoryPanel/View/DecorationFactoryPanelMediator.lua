require "UI.DecorationFactoryPanel.DecorationFactoryPanelNotificationEnum"
local DecorationFactoryPanelProxy = require "UI.DecorationFactoryPanel.Model.DecorationFactoryPanelProxy"

local DecorationFactoryPanelMediator = MVCClass('DecorationFactoryPanelMediator', BaseMediator)

---@type DecorationFactoryPanel
local panel
local proxy

function DecorationFactoryPanelMediator:ctor(...)
	DecorationFactoryPanelMediator.super.ctor(self,...)
	proxy = DecorationFactoryPanelProxy.new()
end

function DecorationFactoryPanelMediator:onRegister()
end

function DecorationFactoryPanelMediator:onAfterSetViewComponent()
	panel = self:getViewComponent()
	panel:setProxy(proxy)
end

function DecorationFactoryPanelMediator:listNotificationInterests()
	return
	{
		--insertNotificationNames
        DecorationFactoryPanelNotificationEnum.Click_btn_close,
		DecorationFactoryPanelNotificationEnum.Click_btn_levelUp,
		DecorationFactoryPanelNotificationEnum.Click_btn_product,
		DecorationFactoryPanelNotificationEnum.Click_btn_canProduct,
	}
end

function DecorationFactoryPanelMediator:handleNotification(notification)

	local name = notification:getName()
	-- local type = notification:getType() -- uncomment if need by yourself
	-- local body = notification:getBody() --message data  uncomment if need by yourself
	--insertHandleNotificationNames
    if(name ==DecorationFactoryPanelNotificationEnum.Click_btn_close) then
		self:closePanel()
	elseif name == DecorationFactoryPanelNotificationEnum.Click_btn_levelUp then
		self:closePanel()
		AppServices.NetBuildingManager:SendBuildLevel(SceneServices.DecorationFactory:GetId())
	elseif name == DecorationFactoryPanelNotificationEnum.Click_btn_canProduct then
		PanelManager.showPanel(GlobalPanelEnum.DecorationFactoryCanProductPanel)
	elseif name == DecorationFactoryPanelNotificationEnum.Click_btn_product then
		SceneServices.DecorationFactory:Product()
    end

end

-- function DecorationFactoryPanelMediator:onBeforeLoadAssets()
--  -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
-- 	-- Send Request To Server
-- 	local extraAssetsNeedLoad = {}
-- 	table.insert(extraAssetsNeedLoad, "extraAssetName")
-- 	self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
-- end

-- function DecorationFactoryPanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

-- function DecorationFactoryPanelMediator:onBeforeShowPanel()
-- 	--在第一次显示之前，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function DecorationFactoryPanelMediator:onAfterShowPanel()
-- 	--在第一次显示之后，此时visible=true。
-- end

-- function DecorationFactoryPanelMediator:onBeforeHidePanel()
-- 	--在被隐藏之前(FadeOut开始前)，此时visible=true。
-- end
-- function DecorationFactoryPanelMediator:onAfterHidePanel()
-- 	--在被隐藏之后(FadeOut完成后)，此时visible=false。
-- end

-- function DecorationFactoryPanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function DecorationFactoryPanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

-- function DecorationFactoryPanelMediator:onBeforeDestroyPanel()
-- 	--在被销毁之前，此时visible=false。
-- end

-- function DecorationFactoryPanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function DecorationFactoryPanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

return DecorationFactoryPanelMediator
