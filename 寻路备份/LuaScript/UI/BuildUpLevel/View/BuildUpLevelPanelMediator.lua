require "UI.BuildUpLevel.BuildUpLevelPanelNotificationEnum"
local BuildUpLevelPanelProxy = require "UI.BuildUpLevel.Model.BuildUpLevelPanelProxy"

local BuildUpLevelPanelMediator = MVCClass('BuildUpLevelPanelMediator', BaseMediator)

---@type BuildUpLevelPanel
local panel
local proxy

function BuildUpLevelPanelMediator:ctor(...)
	BuildUpLevelPanelMediator.super.ctor(self,...)
	proxy = BuildUpLevelPanelProxy.new()
end

function BuildUpLevelPanelMediator:onRegister()
end

function BuildUpLevelPanelMediator:onAfterSetViewComponent()
	panel = self:getViewComponent()
	panel:setProxy(proxy)
end

function BuildUpLevelPanelMediator:listNotificationInterests()
	return
	{
		--insertNotificationNames
		BuildUpLevelPanelNotificationEnum.Click_btn_close
	}
end

function BuildUpLevelPanelMediator:handleNotification(notification)

	local name = notification:getName()
	-- local type = notification:getType() -- uncomment if need by yourself
	-- local body = notification:getBody() --message data  uncomment if need by yourself
	--insertHandleNotificationNames
	if(name ==BuildUpLevelPanelNotificationEnum.Click_btn_close) then
		PanelManager.closePanel(GlobalPanelEnum.BuildUpLevelPanel)
    end
end

-- function BuildUpLevelPanelMediator:onBeforeLoadAssets()
--  -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
-- 	-- Send Request To Server
-- 	local extraAssetsNeedLoad = {}
-- 	table.insert(extraAssetsNeedLoad, "extraAssetName")
-- 	self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
-- end

-- function BuildUpLevelPanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

function BuildUpLevelPanelMediator:onBeforeShowPanel()
	--在第一次显示之前，此时visible=false。
	panel:SetArguments(self.arguments)
	panel:refreshUI()
end
-- function BuildUpLevelPanelMediator:onAfterShowPanel()
-- 	--在第一次显示之后，此时visible=true。
-- end

-- function BuildUpLevelPanelMediator:onBeforeHidePanel()
-- 	--在被隐藏之前(FadeOut开始前)，此时visible=true。
-- end
-- function BuildUpLevelPanelMediator:onAfterHidePanel()
-- 	--在被隐藏之后(FadeOut完成后)，此时visible=false。
-- end

-- function BuildUpLevelPanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function BuildUpLevelPanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

-- function BuildUpLevelPanelMediator:onBeforeDestroyPanel()
-- 	--在被销毁之前，此时visible=false。
-- end

-- function BuildUpLevelPanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function BuildUpLevelPanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

return BuildUpLevelPanelMediator
