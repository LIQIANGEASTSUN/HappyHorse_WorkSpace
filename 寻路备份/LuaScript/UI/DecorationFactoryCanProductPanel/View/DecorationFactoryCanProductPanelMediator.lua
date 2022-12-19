require "UI.DecorationFactoryCanProductPanel.DecorationFactoryCanProductPanelNotificationEnum"
local DecorationFactoryCanProductPanelProxy = require "UI.DecorationFactoryCanProductPanel.Model.DecorationFactoryCanProductPanelProxy"

local DecorationFactoryCanProductPanelMediator = MVCClass('DecorationFactoryCanProductPanelMediator', BaseMediator)

---@type DecorationFactoryCanProductPanel
local panel
local proxy

function DecorationFactoryCanProductPanelMediator:ctor(...)
	DecorationFactoryCanProductPanelMediator.super.ctor(self,...)
	proxy = DecorationFactoryCanProductPanelProxy.new()
end

function DecorationFactoryCanProductPanelMediator:onRegister()
end

function DecorationFactoryCanProductPanelMediator:onAfterSetViewComponent()
	panel = self:getViewComponent()
	panel:setProxy(proxy)
end

function DecorationFactoryCanProductPanelMediator:listNotificationInterests()
	return
	{
		--insertNotificationNames
        DecorationFactoryCanProductPanelNotificationEnum.Click_btn_close
	}
end

function DecorationFactoryCanProductPanelMediator:handleNotification(notification)

	local name = notification:getName()
	-- local type = notification:getType() -- uncomment if need by yourself
	-- local body = notification:getBody() --message data  uncomment if need by yourself
	--insertHandleNotificationNames
    if(name ==DecorationFactoryCanProductPanelNotificationEnum.Click_btn_close) then
		self:closePanel()
    end
end

-- function DecorationFactoryCanProductPanelMediator:onBeforeLoadAssets()
--  -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
-- 	-- Send Request To Server
-- 	local extraAssetsNeedLoad = {}
-- 	table.insert(extraAssetsNeedLoad, "extraAssetName")
-- 	self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
-- end

-- function DecorationFactoryCanProductPanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

-- function DecorationFactoryCanProductPanelMediator:onBeforeShowPanel()
-- 	--在第一次显示之前，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function DecorationFactoryCanProductPanelMediator:onAfterShowPanel()
-- 	--在第一次显示之后，此时visible=true。
-- end

-- function DecorationFactoryCanProductPanelMediator:onBeforeHidePanel()
-- 	--在被隐藏之前(FadeOut开始前)，此时visible=true。
-- end
-- function DecorationFactoryCanProductPanelMediator:onAfterHidePanel()
-- 	--在被隐藏之后(FadeOut完成后)，此时visible=false。
-- end

-- function DecorationFactoryCanProductPanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function DecorationFactoryCanProductPanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

-- function DecorationFactoryCanProductPanelMediator:onBeforeDestroyPanel()
-- 	--在被销毁之前，此时visible=false。
-- end

-- function DecorationFactoryCanProductPanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function DecorationFactoryCanProductPanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

return DecorationFactoryCanProductPanelMediator
