require "UI.DisplaydialogPanel.DisplaydialogPanelNotificationEnum"
local DisplaydialogPanelProxy = require "UI.DisplaydialogPanel.Model.DisplaydialogPanelProxy"

local DisplaydialogPanelMediator = MVCClass('DisplaydialogPanelMediator', BaseMediator)

---@type DisplaydialogPanel
local panel
local proxy

function DisplaydialogPanelMediator:ctor(...)
	DisplaydialogPanelMediator.super.ctor(self,...)
	proxy = DisplaydialogPanelProxy.new()
end

function DisplaydialogPanelMediator:onRegister()
end

function DisplaydialogPanelMediator:onAfterSetViewComponent()
	panel = self:getViewComponent()
	panel:setProxy(proxy)
end

function DisplaydialogPanelMediator:listNotificationInterests()
	return
	{
		--insertNotificationNames
	}
end

function DisplaydialogPanelMediator:handleNotification(notification)
end

-- function DisplaydialogPanelMediator:onBeforeLoadAssets()
--  -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
-- 	-- Send Request To Server
-- 	local extraAssetsNeedLoad = {}
-- 	table.insert(extraAssetsNeedLoad, "extraAssetName")
-- 	self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
-- end

-- function DisplaydialogPanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

-- function DisplaydialogPanelMediator:onBeforeShowPanel()
-- 	--在第一次显示之前，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function DisplaydialogPanelMediator:onAfterShowPanel()
-- 	--在第一次显示之后，此时visible=true。
-- end

-- function DisplaydialogPanelMediator:onBeforeHidePanel()
-- 	--在被隐藏之前(FadeOut开始前)，此时visible=true。
-- end
-- function DisplaydialogPanelMediator:onAfterHidePanel()
-- 	--在被隐藏之后(FadeOut完成后)，此时visible=false。
-- end

-- function DisplaydialogPanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function DisplaydialogPanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

-- function DisplaydialogPanelMediator:onBeforeDestroyPanel()
-- 	--在被销毁之前，此时visible=false。
-- end

-- function DisplaydialogPanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function DisplaydialogPanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

return DisplaydialogPanelMediator
