require "UI.Pet.PetReceivePanel.PetReceivePanelNotificationEnum"
local PetReceivePanelProxy = require "UI.Pet.PetReceivePanel.Model.PetReceivePanelProxy"

local PetReceivePanelMediator = MVCClass('PetReceivePanelMediator', BaseMediator)

---@type PetReceivePanel
local panel
local proxy

function PetReceivePanelMediator:ctor(...)
	PetReceivePanelMediator.super.ctor(self,...)
	proxy = PetReceivePanelProxy.new()
end

function PetReceivePanelMediator:onRegister()
end

function PetReceivePanelMediator:onAfterSetViewComponent()
	panel = self:getViewComponent()
	panel:setProxy(proxy)
end

function PetReceivePanelMediator:listNotificationInterests()
	return
	{
		--insertNotificationNames
        PetReceivePanelNotificationEnum.Click_btn_close,
		PetReceivePanelNotificationEnum.Click_btn_backpack,
		PetReceivePanelNotificationEnum.Click_btn_team,
	}
end

function PetReceivePanelMediator:handleNotification(notification)

	local name = notification:getName()
	-- local type = notification:getType() -- uncomment if need by yourself
	-- local body = notification:getBody() --message data  uncomment if need by yourself
	--insertHandleNotificationNames
    if (name ==PetReceivePanelNotificationEnum.Click_btn_close) then
		PanelManager.closePanel(GlobalPanelEnum.PetReceivePanel, nil)
		if self.arguments and self.arguments.fromPetInfo then
			PanelManager.showPanel(GlobalPanelEnum.PetInfoPanel, nil)
		end
	elseif (name ==PetReceivePanelNotificationEnum.Click_btn_backpack) then
        panel:PetToBackpack()
	elseif (name ==PetReceivePanelNotificationEnum.Click_btn_team) then
        panel:PetToTeam()
    end
end

-- function PetReceivePanelMediator:onBeforeLoadAssets()
--  -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
-- 	-- Send Request To Server
-- 	local extraAssetsNeedLoad = {}
-- 	table.insert(extraAssetsNeedLoad, "extraAssetName")
-- 	self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
-- end

-- function PetReceivePanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

function PetReceivePanelMediator:onBeforeShowPanel()
	--在第一次显示之前，此时visible=false。
	panel:SetArguments(self.arguments)
	panel:refreshUI()
end

-- function PetReceivePanelMediator:onAfterShowPanel()
-- 	--在第一次显示之后，此时visible=true。
-- end

function PetReceivePanelMediator:onBeforeHidePanel()
	--在被隐藏之前(FadeOut开始前)，此时visible=true。
	panel:Hide()
end

-- function PetReceivePanelMediator:onAfterHidePanel()
-- 	--在被隐藏之后(FadeOut完成后)，此时visible=false。
-- end

-- function PetReceivePanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function PetReceivePanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

-- function PetReceivePanelMediator:onBeforeDestroyPanel()
-- 	--在被销毁之前，此时visible=false。
-- end

-- function PetReceivePanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function PetReceivePanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

return PetReceivePanelMediator
