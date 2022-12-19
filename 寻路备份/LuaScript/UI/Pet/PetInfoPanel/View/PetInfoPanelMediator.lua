require "UI.Pet.PetInfoPanel.PetInfoPanelNotificationEnum"
local PetInfoPanelProxy = require "UI.Pet.PetInfoPanel.Model.PetInfoPanelProxy"

local PetInfoPanelMediator = MVCClass('PetInfoPanelMediator', BaseMediator)

---@type PetInfoPanel
local panel
local proxy

function PetInfoPanelMediator:ctor(...)
	PetInfoPanelMediator.super.ctor(self,...)
	proxy = PetInfoPanelProxy.new()
end

function PetInfoPanelMediator:onRegister()
end

function PetInfoPanelMediator:onAfterSetViewComponent()
	panel = self:getViewComponent()
	panel:setProxy(proxy)
end

function PetInfoPanelMediator:listNotificationInterests()
	return
	{
		--insertNotificationNames
        PetInfoPanelNotificationEnum.Click_btn_close,
		PetInfoPanelNotificationEnum.Type_btn_click
	}
end

function PetInfoPanelMediator:handleNotification(notification)

	local name = notification:getName()
	-- local type = notification:getType() -- uncomment if need by yourself
	-- local body = notification:getBody() --message data  uncomment if need by yourself
	--insertHandleNotificationNames
    if(name ==PetInfoPanelNotificationEnum.Click_btn_close) then
		PanelManager.closePanel(GlobalPanelEnum.PetInfoPanel, nil)
	elseif (name == PetInfoPanelNotificationEnum.Type_btn_click) then
	    local body = notification:getBody() --消息携带数据
		panel:TypeClick(body)
    end
end

-- function PetInfoPanelMediator:onBeforeLoadAssets()
--  -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
-- 	-- Send Request To Server
-- 	local extraAssetsNeedLoad = {}
-- 	table.insert(extraAssetsNeedLoad, "extraAssetName")
-- 	self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
-- end

-- function PetInfoPanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

function PetInfoPanelMediator:onBeforeShowPanel()
	--在第一次显示之前，此时visible=false。
	panel:refreshUI()
end

-- function PetInfoPanelMediator:onAfterShowPanel()
-- 	--在第一次显示之后，此时visible=true。
-- end

-- function PetInfoPanelMediator:onBeforeHidePanel()
-- 	--在被隐藏之前(FadeOut开始前)，此时visible=true。
-- end
function PetInfoPanelMediator:onAfterHidePanel()
	--在被隐藏之后(FadeOut完成后)，此时visible=false。
	panel:Hide()
end

-- function PetInfoPanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function PetInfoPanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

-- function PetInfoPanelMediator:onBeforeDestroyPanel()
-- 	--在被销毁之前，此时visible=false。
-- end

-- function PetInfoPanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function PetInfoPanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

return PetInfoPanelMediator
