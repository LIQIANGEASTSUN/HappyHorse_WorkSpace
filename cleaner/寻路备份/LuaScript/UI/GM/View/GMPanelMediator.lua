require "UI.GM.GMPanelNotificationEnum"
local GMPanelProxy = require "UI.GM.Model.GMPanelProxy"

local GMPanelMediator = MVCClass('GMPanelMediator', BaseMediator)

---@type GMPanel
local panel
local proxy

function GMPanelMediator:ctor(...)
	GMPanelMediator.super.ctor(self,...)
	proxy = GMPanelProxy.new()
end

function GMPanelMediator:onRegister()
end

function GMPanelMediator:onAfterSetViewComponent()
	panel = self:getViewComponent()
	panel:setProxy(proxy)
end

function GMPanelMediator:listNotificationInterests()
	return
	{
		--insertNotificationNames
        GMPanelNotificationEnum.Click_btn_close,
        GMPanelNotificationEnum.Click_btn_run
	}
end

function GMPanelMediator:handleNotification(notification)

	local name = notification:getName()
	-- local type = notification:getType() -- uncomment if need by yourself
	-- local body = notification:getBody() --message data  uncomment if need by yourself
	--insertHandleNotificationNames
    if (name ==GMPanelNotificationEnum.Click_btn_close) then
		PanelManager.closePanel(GlobalPanelEnum.GMPanel, nil)
    elseif (name == GMPanelNotificationEnum.Click_btn_run) then
        panel:GmRunClick()
    end
end

-- function GMPanelMediator:onBeforeLoadAssets()
--  -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
-- 	-- Send Request To Server
-- 	local extraAssetsNeedLoad = {}
-- 	table.insert(extraAssetsNeedLoad, "extraAssetName")
-- 	self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
-- end

-- function GMPanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

function GMPanelMediator:onBeforeShowPanel()
	--在第一次显示之前，此时visible=false。
	panel:refreshUI()
end

-- function GMPanelMediator:onAfterShowPanel()
-- 	--在第一次显示之后，此时visible=true。
-- end

-- function GMPanelMediator:onBeforeHidePanel()
-- 	--在被隐藏之前(FadeOut开始前)，此时visible=true。
-- end
-- function GMPanelMediator:onAfterHidePanel()
-- 	--在被隐藏之后(FadeOut完成后)，此时visible=false。
-- end

-- function GMPanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function GMPanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

-- function GMPanelMediator:onBeforeDestroyPanel()
-- 	--在被销毁之前，此时visible=false。
-- end

-- function GMPanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function GMPanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

return GMPanelMediator
