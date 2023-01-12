require "UI.Common.SingleRewardPanel.SingleRewardPanelNotificationEnum"
local SingleRewardPanelProxy = require "UI.Common.SingleRewardPanel.Model.SingleRewardPanelProxy"

local SingleRewardPanelMediator = MVCClass('SingleRewardPanelMediator', BaseMediator)

---@type SingleRewardPanel
local panel
local proxy

function SingleRewardPanelMediator:ctor(...)
	SingleRewardPanelMediator.super.ctor(self,...)
	proxy = SingleRewardPanelProxy.new()
end

function SingleRewardPanelMediator:onRegister()
end

function SingleRewardPanelMediator:onAfterSetViewComponent()
	panel = self:getViewComponent()
	panel:setProxy(proxy)
end

function SingleRewardPanelMediator:listNotificationInterests()
	return
	{
		--insertNotificationNames
        SingleRewardPanelNotificationEnum.Click_btn_ok
	}
end

function SingleRewardPanelMediator:handleNotification(notification)

	local name = notification:getName()
	-- local type = notification:getType() -- uncomment if need by yourself
	-- local body = notification:getBody() --message data  uncomment if need by yourself
	--insertHandleNotificationNames
    if(name ==SingleRewardPanelNotificationEnum.Click_btn_ok) then
		panel:FlyItem()
		self:closePanel()
    end
end

-- function SingleRewardPanelMediator:onBeforeLoadAssets()
--  -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
-- 	-- Send Request To Server
-- 	local extraAssetsNeedLoad = {}
-- 	table.insert(extraAssetsNeedLoad, "extraAssetName")
-- 	self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
-- end

-- function SingleRewardPanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

-- function SingleRewardPanelMediator:onBeforeShowPanel()
-- 	--在第一次显示之前，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function SingleRewardPanelMediator:onAfterShowPanel()
-- 	--在第一次显示之后，此时visible=true。
-- end

-- function SingleRewardPanelMediator:onBeforeHidePanel()
-- 	--在被隐藏之前(FadeOut开始前)，此时visible=true。
-- end
-- function SingleRewardPanelMediator:onAfterHidePanel()
-- 	--在被隐藏之后(FadeOut完成后)，此时visible=false。
-- end

-- function SingleRewardPanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function SingleRewardPanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

-- function SingleRewardPanelMediator:onBeforeDestroyPanel()
-- 	--在被销毁之前，此时visible=false。
-- end

-- function SingleRewardPanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function SingleRewardPanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

return SingleRewardPanelMediator
