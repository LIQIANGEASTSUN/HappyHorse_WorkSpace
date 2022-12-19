require "UI.AndroidPrivacyPanel.PrivacyPanelNotificationEnum"
local PrivacyPanelProxy = require "UI.AndroidPrivacyPanel.Model.PrivacyPanelProxy"

local PrivacyPanelMediator = MVCClass("PrivacyPanelMediator", BaseMediator)

---@type PrivacyPanel
local panel
local proxy

function PrivacyPanelMediator:ctor(...)
    PrivacyPanelMediator.super.ctor(self, ...)
    proxy = PrivacyPanelProxy.new()
end

function PrivacyPanelMediator:onRegister()
end

function PrivacyPanelMediator:onAfterSetViewComponent()
    panel = self:getViewComponent()
    panel:setProxy(proxy)
end

function PrivacyPanelMediator:listNotificationInterests()
    return {}
end

function PrivacyPanelMediator:handleNotification(notification)
end

-- function PrivacyPanelMediator:onBeforeLoadAssets()
--  -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
-- 	-- Send Request To Server
-- 	local extraAssetsNeedLoad = {}
-- 	table.insert(extraAssetsNeedLoad, "extraAssetName")
-- 	self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
-- end

-- function PrivacyPanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

-- function PrivacyPanelMediator:onBeforeShowPanel()
-- 	--在第一次显示之前，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function PrivacyPanelMediator:onAfterShowPanel()
-- 	--在第一次显示之后，此时visible=true。
-- end

-- function PrivacyPanelMediator:onBeforeHidePanel()
-- 	--在被隐藏之前(FadeOut开始前)，此时visible=true。
-- end
-- function PrivacyPanelMediator:onAfterHidePanel()
-- 	--在被隐藏之后(FadeOut完成后)，此时visible=false。
-- end

-- function PrivacyPanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function PrivacyPanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

-- function PrivacyPanelMediator:onBeforeDestroyPanel()
-- 	--在被销毁之前，此时visible=false。
-- end

-- function PrivacyPanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function PrivacyPanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

return PrivacyPanelMediator
