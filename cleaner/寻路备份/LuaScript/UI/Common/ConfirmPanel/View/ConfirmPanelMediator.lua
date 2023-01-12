require "UI.Common.ConfirmPanel.ConfirmPanelNotificationEnum"
local ConfirmPanelProxy = require "UI.Common.ConfirmPanel.Model.ConfirmPanelProxy"

local ConfirmPanelMediator = MVCClass('ConfirmPanelMediator', BaseMediator)

---@type ConfirmPanel
local panel
local proxy

function ConfirmPanelMediator:ctor(...)
	ConfirmPanelMediator.super.ctor(self,...)
	proxy = ConfirmPanelProxy.new()
end

function ConfirmPanelMediator:onRegister()
end

function ConfirmPanelMediator:onAfterSetViewComponent()
	panel = self:getViewComponent()
	panel:setProxy(proxy)
end

function ConfirmPanelMediator:listNotificationInterests()
	return
	{
		ConfirmPanelNotificationEnum.ClickOk,
		ConfirmPanelNotificationEnum.ClickCancel,
		ConfirmPanelNotificationEnum.Close
	}
end

function ConfirmPanelMediator:handleNotification(notification)

	local name = notification:getName()
	-- local type = notification:getType()
	local body = notification:getBody() --message data
	--insertHandleNotificationNames
	if name == ConfirmPanelNotificationEnum.Close then

	elseif name == ConfirmPanelNotificationEnum.ClickOk then
		if body then
			body()
		end
	elseif name == ConfirmPanelNotificationEnum.ClickCancel then
		if body then
			body()
		end
    end
	self:closePanel()
end

-- function ConfirmPanelMediator:onBeforeLoadAssets()
--  -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
-- 	-- Send Request To Server
-- 	local extraAssetsNeedLoad = {}
-- 	table.insert(extraAssetsNeedLoad, "extraAssetName")
-- 	self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
-- end

-- function ConfirmPanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

-- function ConfirmPanelMediator:onBeforeShowPanel()
-- 	--在第一次显示之前，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function ConfirmPanelMediator:onAfterShowPanel()
-- 	--在第一次显示之后，此时visible=true。
-- end

-- function ConfirmPanelMediator:onBeforeHidePanel()
-- 	--在被隐藏之前(FadeOut开始前)，此时visible=true。
-- end
-- function ConfirmPanelMediator:onAfterHidePanel()
-- 	--在被隐藏之后(FadeOut完成后)，此时visible=false。
-- end

-- function ConfirmPanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function ConfirmPanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

-- function ConfirmPanelMediator:onBeforeDestroyPanel()
-- 	--在被销毁之前，此时visible=false。
-- end

-- function ConfirmPanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function ConfirmPanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

return ConfirmPanelMediator
