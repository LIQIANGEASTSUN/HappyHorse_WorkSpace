require "UI.VaccumCleanerUpgradePanel.VaccumCleanerUpgradePanelNotificationEnum"
local VaccumCleanerUpgradePanelProxy = require "UI.VaccumCleanerUpgradePanel.Model.VaccumCleanerUpgradePanelProxy"

local VaccumCleanerUpgradePanelMediator = MVCClass('VaccumCleanerUpgradePanelMediator', BaseMediator)

---@type VaccumCleanerUpgradePanel
local panel
local proxy

function VaccumCleanerUpgradePanelMediator:ctor(...)
	VaccumCleanerUpgradePanelMediator.super.ctor(self,...)
	proxy = VaccumCleanerUpgradePanelProxy.new()
end

function VaccumCleanerUpgradePanelMediator:onRegister()
end

function VaccumCleanerUpgradePanelMediator:onAfterSetViewComponent()
	panel = self:getViewComponent()
	panel:setProxy(proxy)
end

function VaccumCleanerUpgradePanelMediator:listNotificationInterests()
	return
	{
		--insertNotificationNames
		VaccumCleanerUpgradePanelNotificationEnum.VaccumCleanerUpgradePanel_OnClose
	}
end

function VaccumCleanerUpgradePanelMediator:handleNotification(notification)

	local name = notification:getName()
	-- local type = notification:getType() -- uncomment if need by yourself
	-- local body = notification:getBody() --message data  uncomment if need by yourself
	--insertHandleNotificationNames
	if name == VaccumCleanerUpgradePanelNotificationEnum.VaccumCleanerUpgradePanel_OnClose then
		self:closePanel()
	end
end

-- function VaccumCleanerUpgradePanelMediator:onBeforeLoadAssets()
--  -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
-- 	-- Send Request To Server
-- 	local extraAssetsNeedLoad = {}
-- 	table.insert(extraAssetsNeedLoad, "extraAssetName")
-- 	self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
-- end

-- function VaccumCleanerUpgradePanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

-- function VaccumCleanerUpgradePanelMediator:onBeforeShowPanel()
-- 	--在第一次显示之前，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function VaccumCleanerUpgradePanelMediator:onAfterShowPanel()
-- 	--在第一次显示之后，此时visible=true。
-- end

-- function VaccumCleanerUpgradePanelMediator:onBeforeHidePanel()
-- 	--在被隐藏之前(FadeOut开始前)，此时visible=true。
-- end
-- function VaccumCleanerUpgradePanelMediator:onAfterHidePanel()
-- 	--在被隐藏之后(FadeOut完成后)，此时visible=false。
-- end

-- function VaccumCleanerUpgradePanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function VaccumCleanerUpgradePanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

-- function VaccumCleanerUpgradePanelMediator:onBeforeDestroyPanel()
-- 	--在被销毁之前，此时visible=false。
-- end

-- function VaccumCleanerUpgradePanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function VaccumCleanerUpgradePanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

return VaccumCleanerUpgradePanelMediator
