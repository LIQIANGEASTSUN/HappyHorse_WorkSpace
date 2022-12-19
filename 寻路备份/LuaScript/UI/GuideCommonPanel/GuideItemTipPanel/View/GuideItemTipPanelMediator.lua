require "UI.GuideCommonPanel.GuideItemTipPanel.GuideItemTipPanelNotificationEnum"
local GuideItemTipPanelProxy = require "UI.GuideCommonPanel.GuideItemTipPanel.Model.GuideItemTipPanelProxy"

local GuideItemTipPanelMediator = MVCClass('GuideItemTipPanelMediator', BaseMediator)

---@type GuideItemTipPanel
local panel
local proxy

function GuideItemTipPanelMediator:ctor(...)
	GuideItemTipPanelMediator.super.ctor(self,...)
	proxy = GuideItemTipPanelProxy.new()
end

function GuideItemTipPanelMediator:onRegister()
end

function GuideItemTipPanelMediator:onAfterSetViewComponent()
	panel = self:getViewComponent()
	panel:setProxy(proxy)
end

function GuideItemTipPanelMediator:listNotificationInterests()
	return
	{
		--insertNotificationNames
		GuideItemTipPanelNotificationEnum.Close
	}
end

function GuideItemTipPanelMediator:handleNotification(notification)

	local name = notification:getName()
	if name == GuideItemTipPanelNotificationEnum.Close then
		PanelManager.closePanel(panel.panelVO)
	end
	-- local type = notification:getType() -- uncomment if need by yourself
	-- local body = notification:getBody() --message data  uncomment if need by yourself
	--insertHandleNotificationNames
end

-- function GuideItemTipPanelMediator:onBeforeLoadAssets()
--  -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
-- 	-- Send Request To Server
-- 	local extraAssetsNeedLoad = {}
-- 	table.insert(extraAssetsNeedLoad, "extraAssetName")
-- 	self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
-- end

-- function GuideItemTipPanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

-- function GuideItemTipPanelMediator:onBeforeShowPanel()
-- 	--在第一次显示之前，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function GuideItemTipPanelMediator:onAfterShowPanel()
-- 	--在第一次显示之后，此时visible=true。
-- end

-- function GuideItemTipPanelMediator:onBeforeHidePanel()
-- 	--在被隐藏之前(FadeOut开始前)，此时visible=true。
-- end
-- function GuideItemTipPanelMediator:onAfterHidePanel()
-- 	--在被隐藏之后(FadeOut完成后)，此时visible=false。
-- end

-- function GuideItemTipPanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function GuideItemTipPanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

-- function GuideItemTipPanelMediator:onBeforeDestroyPanel()
-- 	--在被销毁之前，此时visible=false。
-- end

-- function GuideItemTipPanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function GuideItemTipPanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

return GuideItemTipPanelMediator
