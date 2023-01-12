require "UI.Settings.SelectAccountPanel.SelectAccountPanelNotificationEnum"
local SelectAccountPanelProxy = require "UI.Settings.SelectAccountPanel.Model.SelectAccountPanelProxy"

local SelectAccountPanelMediator = MVCClass('SelectAccountPanelMediator', BaseMediator)

local panel
local proxy

function SelectAccountPanelMediator:ctor(...)
	SelectAccountPanelMediator.super.ctor(self,...)
	proxy = SelectAccountPanelProxy.new()
end

function SelectAccountPanelMediator:onRegister()
end

function SelectAccountPanelMediator:onAfterSetViewComponent()
	panel = self:getViewComponent()
	panel:setProxy(proxy)
end

function SelectAccountPanelMediator:listNotificationInterests()
	return
	{
		--insertNotificationNames
		SelectAccountPanelNotificationEnum.Click_btn_close,
		SelectAccountPanelNotificationEnum.Click_btn_choose,
	}
end

function SelectAccountPanelMediator:handleNotification(notification)

	local name = notification:getName()
	--local type = notification:getType()
	local body = notification:getBody() --message data
	--insertHandleNotificationNames
	if(name == "") then
	elseif(name == SelectAccountPanelNotificationEnum.Click_btn_close) then
		Runtime.InvokeCbk(self.arguments.cancelCB)
		self:closePanel()
	elseif name == SelectAccountPanelNotificationEnum.Click_btn_choose then
		--[[
		local function continue()
			self:closePanel()
			Runtime.InvokeCbk(self.arguments.commond,self.arguments.selectInfo[body])
        end
		local function cancel()
        end
        ErrorHandler.ShowOkCancel({
            desc = Runtime.Translate("ui_login_synchronous_verifytext"),
			showOk = true,
			showCancel = true,
			label_cancel = Runtime.Translate("ui_common_cancel"),
            okCallback = continue,
			cancelCallback = cancel
		})
		]]
		self:closePanel()
		Runtime.InvokeCbk(self.arguments.commond,self.arguments.selectInfo[body])
	end
end

-- function SelectAccountPanelMediator:onBeforeLoadAssets()
--  -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
-- 	-- Send Request To Server
-- 	local extraAssetsNeedLoad = {}
-- 	table.insert(extraAssetsNeedLoad, "extraAssetName")
-- 	self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
-- end

-- function SelectAccountPanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

-- function SelectAccountPanelMediator:onBeforeShowPanel()
-- 	--在第一次显示之前，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function SelectAccountPanelMediator:onAfterShowPanel()
-- 	--在第一次显示之后，此时visible=true。
-- end

-- function SelectAccountPanelMediator:onBeforeHidePanel()
-- 	--在被隐藏之前(FadeOut开始前)，此时visible=true。
-- end
-- function SelectAccountPanelMediator:onAfterHidePanel()
-- 	--在被隐藏之后(FadeOut完成后)，此时visible=false。
-- end

-- function SelectAccountPanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function SelectAccountPanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

-- function SelectAccountPanelMediator:onBeforeDestroyPanel()
-- 	--在被销毁之前，此时visible=false。
-- end

-- function SelectAccountPanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function SelectAccountPanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

return SelectAccountPanelMediator
