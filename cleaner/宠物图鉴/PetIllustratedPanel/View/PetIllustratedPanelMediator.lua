require "UI.Pet.PetIllustratedPanel.PetIllustratedPanelNotificationEnum"
local PetIllustratedPanelProxy = require "UI.Pet.PetIllustratedPanel.Model.PetIllustratedPanelProxy"

local PetIllustratedPanelMediator = MVCClass('PetIllustratedPanelMediator', BaseMediator)

---@type PetIllustratedPanel
local panel
local proxy

function PetIllustratedPanelMediator:ctor(...)
	PetIllustratedPanelMediator.super.ctor(self,...)
	proxy = PetIllustratedPanelProxy.new()
end

function PetIllustratedPanelMediator:onRegister()
end

function PetIllustratedPanelMediator:onAfterSetViewComponent()
	panel = self:getViewComponent()
	panel:setProxy(proxy)
end

function PetIllustratedPanelMediator:listNotificationInterests()
	return
	{
		--insertNotificationNames
        PetIllustratedPanelNotificationEnum.Click_btn_close
	}
end

function PetIllustratedPanelMediator:handleNotification(notification)

	local name = notification:getName()
	-- local type = notification:getType() -- uncomment if need by yourself
	-- local body = notification:getBody() --message data  uncomment if need by yourself
	--insertHandleNotificationNames
    if(name ==PetIllustratedPanelNotificationEnum.Click_btn_close) then
		panel:CloseBtnClick()
    end
end

-- function PetIllustratedPanelMediator:onBeforeLoadAssets()
--  -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
-- 	-- Send Request To Server
-- 	local extraAssetsNeedLoad = {}
-- 	table.insert(extraAssetsNeedLoad, "extraAssetName")
-- 	self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
-- end

-- function PetIllustratedPanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

function PetIllustratedPanelMediator:onBeforeShowPanel()
	--在第一次显示之前，此时visible=false。
	panel:SetArguments(self.arguments)
	panel:refreshUI()
end
-- function PetIllustratedPanelMediator:onAfterShowPanel()
-- 	--在第一次显示之后，此时visible=true。
-- end

-- function PetIllustratedPanelMediator:onBeforeHidePanel()
-- 	--在被隐藏之前(FadeOut开始前)，此时visible=true。
-- end
function PetIllustratedPanelMediator:onAfterHidePanel()
	--在被隐藏之后(FadeOut完成后)，此时visible=false。
	panel:Hide()
end

-- function PetIllustratedPanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function PetIllustratedPanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

-- function PetIllustratedPanelMediator:onBeforeDestroyPanel()
-- 	--在被销毁之前，此时visible=false。
-- end

-- function PetIllustratedPanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function PetIllustratedPanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

return PetIllustratedPanelMediator
