require "UI.RecyclePanel.RecyclePanelNotificationEnum"
local RecyclePanelProxy = require "UI.RecyclePanel.Model.RecyclePanelProxy"

local RecyclePanelMediator = MVCClass('RecyclePanelMediator', BaseMediator)

---@type RecyclePanel
local panel
local proxy

function RecyclePanelMediator:ctor(...)
	RecyclePanelMediator.super.ctor(self,...)
	proxy = RecyclePanelProxy.new()
end

function RecyclePanelMediator:onRegister()
end

function RecyclePanelMediator:onAfterSetViewComponent()
	panel = self:getViewComponent()
	panel:setProxy(proxy)
end

function RecyclePanelMediator:listNotificationInterests()
	return
	{
		--insertNotificationNames
		RecyclePanelNotificationEnum.RecyclePanelNotificationEnum_Close,
		RecyclePanelNotificationEnum.RecyclePanelNotificationEnum_SellAll
	}
end

function RecyclePanelMediator:SellAll()
	panel:SellAll()
end

function RecyclePanelMediator:handleNotification(notification)

	local name = notification:getName()
	-- local type = notification:getType() -- uncomment if need by yourself
	-- local body = notification:getBody() --message data  uncomment if need by yourself
	--insertHandleNotificationNames
	if name == RecyclePanelNotificationEnum.RecyclePanelNotificationEnum_Close then
		self:closePanel()
	elseif name == RecyclePanelNotificationEnum.RecyclePanelNotificationEnum_SellAll then
		self:SellAll()
	end
end

-- function RecyclePanelMediator:onBeforeLoadAssets()
--  -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
-- 	-- Send Request To Server
-- 	local extraAssetsNeedLoad = {}
-- 	table.insert(extraAssetsNeedLoad, "extraAssetName")
-- 	self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
-- end

-- function RecyclePanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

-- function RecyclePanelMediator:onBeforeShowPanel()
-- 	--在第一次显示之前，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function RecyclePanelMediator:onAfterShowPanel()
-- 	--在第一次显示之后，此时visible=true。
-- end

-- function RecyclePanelMediator:onBeforeHidePanel()
-- 	--在被隐藏之前(FadeOut开始前)，此时visible=true。
-- end
-- function RecyclePanelMediator:onAfterHidePanel()
-- 	--在被隐藏之后(FadeOut完成后)，此时visible=false。
-- end

-- function RecyclePanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function RecyclePanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

-- function RecyclePanelMediator:onBeforeDestroyPanel()
-- 	--在被销毁之前，此时visible=false。
-- end

-- function RecyclePanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function RecyclePanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

return RecyclePanelMediator
