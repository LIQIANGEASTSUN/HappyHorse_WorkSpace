require "UI.DynamicUpdatePanel.DynamicUpdatePanelNotificationEnum"
local DynamicUpdatePanelProxy = require "UI.DynamicUpdatePanel.Model.DynamicUpdatePanelProxy"

local DynamicUpdatePanelMediator = MVCClass('DynamicUpdatePanelMediator', BaseMediator)

---@type DynamicUpdatePanel
local panel
local proxy

function DynamicUpdatePanelMediator:ctor(...)
	DynamicUpdatePanelMediator.super.ctor(self,...)
	proxy = DynamicUpdatePanelProxy.new()
end

function DynamicUpdatePanelMediator:onRegister()
end

function DynamicUpdatePanelMediator:onAfterSetViewComponent()
	panel = self:getViewComponent()
	panel:setProxy(proxy)
end

function DynamicUpdatePanelMediator:listNotificationInterests()
	return
	{
		--insertNotificationNames
        DynamicUpdatePanelNotificationEnum.Click_btn_panel,
		DynamicUpdatePanelNotificationEnum.Click_btn_close
	}
end

function DynamicUpdatePanelMediator:handleNotification(notification)
	if Runtime.CSNull(panel.gameObject) then return end
	local name = notification:getName()
	--local type = notification:getType()
	--local body = notification:getBody() --message data
	--insertHandleNotificationNames
    --if(name == "") then
	--local body = notification:getBody() --message data
    if(name == DynamicUpdatePanelNotificationEnum.Click_btn_panel) then
		self:closePanel()
	elseif(name == DynamicUpdatePanelNotificationEnum.Click_btn_close) then
		self:closePanel()
	end
end

-- function DynamicUpdatePanelMediator:onBeforeLoadAssets()
--  -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
-- 	-- Send Request To Server
-- end

-- function DynamicUpdatePanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

function DynamicUpdatePanelMediator:onBeforeShowPanel()
-- 	--在第一次显示之前，此时visible=false。
	panel:refreshUI()
end

function DynamicUpdatePanelMediator:onAfterShowPanel()
	--在第一次显示之后，此时visible=true。
	AppServices.EventDispatcher:addObserver(self, SystemEvent.UPDATING_PROGRESS, function(eventData)
		panel:setProgress(eventData.data.val)
		panel:setInfo(eventData.data.info)
	end)

	AppServices.EventDispatcher:addObserver(self, SystemEvent.UPDATING_FINISHED, function(eventData)
		--panel:setProgress(1.0)
	end)
end

-- function DynamicUpdatePanelMediator:onBeforeHidePanel()
-- 	--在被隐藏之前(FadeOut开始前)，此时visible=true。
-- end
-- function DynamicUpdatePanelMediator:onAfterHidePanel()
-- 	--在被隐藏之后(FadeOut完成后)，此时visible=false。
-- end

-- function DynamicUpdatePanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function DynamicUpdatePanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

function DynamicUpdatePanelMediator:onBeforeDestroyPanel()
-- 	--在被销毁之前，此时visible=false。
	AppServices.EventDispatcher:removeObserver(self, SystemEvent.UPDATING_PROGRESS)
	AppServices.EventDispatcher:removeObserver(self, SystemEvent.UPDATING_FINISHED)
end

-- function DynamicUpdatePanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function DynamicUpdatePanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

return DynamicUpdatePanelMediator
