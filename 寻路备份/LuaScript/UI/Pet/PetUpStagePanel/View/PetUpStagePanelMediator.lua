require "UI.Pet.PetUpStagePanel.PetUpStagePanelNotificationEnum"
local PetUpStagePanelProxy = require "UI.Pet.PetUpStagePanel.Model.PetUpStagePanelProxy"

local PetUpStagePanelMediator = MVCClass('PetUpStagePanelMediator', BaseMediator)

---@type PetUpStagePanel
local panel
local proxy

function PetUpStagePanelMediator:ctor(...)
	PetUpStagePanelMediator.super.ctor(self,...)
	proxy = PetUpStagePanelProxy.new()
end

function PetUpStagePanelMediator:onRegister()
end

function PetUpStagePanelMediator:onAfterSetViewComponent()
	panel = self:getViewComponent()
	panel:setProxy(proxy)
end

function PetUpStagePanelMediator:listNotificationInterests()
	return
	{
		--insertNotificationNames
		PetUpStagePanelNotificationEnum.Click_btn_close,
		PetUpStagePanelNotificationEnum.Click_btn_up_stage,
		PetUpStagePanelNotificationEnum.Click_btn_up_disable,
	}
end

function PetUpStagePanelMediator:handleNotification(notification)

	local name = notification:getName()
	-- local type = notification:getType() -- uncomment if need by yourself
	-- local body = notification:getBody() --message data  uncomment if need by yourself
	--insertHandleNotificationNames
	if(name ==PetUpStagePanelNotificationEnum.Click_btn_close) then
		PanelManager.closePanel(GlobalPanelEnum.PetUpStagePanel)
	elseif (name == PetUpStagePanelNotificationEnum.Click_btn_up_stage) then
		panel:UpStageClick()
    elseif (name == PetUpStagePanelNotificationEnum.Click_btn_up_disable) then
		panel:UpDisableClick()
    end
end

-- function PetUpStagePanelMediator:onBeforeLoadAssets()
--  -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
-- 	-- Send Request To Server
-- 	local extraAssetsNeedLoad = {}
-- 	table.insert(extraAssetsNeedLoad, "extraAssetName")
-- 	self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
-- end

-- function PetUpStagePanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

function PetUpStagePanelMediator:onBeforeShowPanel()
	--在第一次显示之前，此时visible=false。
	panel:SetArguments(self.arguments)
	panel:refreshUI()
end

-- function PetUpStagePanelMediator:onAfterShowPanel()
-- 	--在第一次显示之后，此时visible=true。
-- end

function PetUpStagePanelMediator:onBeforeHidePanel()
	--在被隐藏之前(FadeOut开始前)，此时visible=true。
	panel:Hide()
end
-- function PetUpStagePanelMediator:onAfterHidePanel()
-- 	--在被隐藏之后(FadeOut完成后)，此时visible=false。
-- end

-- function PetUpStagePanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function PetUpStagePanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

-- function PetUpStagePanelMediator:onBeforeDestroyPanel()
-- 	--在被销毁之前，此时visible=false。
-- end

-- function PetUpStagePanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function PetUpStagePanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

return PetUpStagePanelMediator
