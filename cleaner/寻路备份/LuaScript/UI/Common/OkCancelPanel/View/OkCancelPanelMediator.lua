require "UI.Common.OkCancelPanel.OkCancelPanelNotificationEnum"
local OkCancelPanelProxy = require "UI.Common.OkCancelPanel.Model.OkCancelPanelProxy"

local OkCancelPanelMediator = MVCClass("OkCancelPanelMediator", BaseMediator)

local panel
local proxy

function OkCancelPanelMediator:ctor(...)
    OkCancelPanelMediator.super.ctor(self, ...)
    proxy = OkCancelPanelProxy.new()
end

function OkCancelPanelMediator:onRegister()
end

function OkCancelPanelMediator:onAfterSetViewComponent()
    panel = self:getViewComponent()
    panel:setProxy(proxy)
end

function OkCancelPanelMediator:listNotificationInterests()
    return {
        --insertNotificationNames
        OkCancelPanelNotificationEnum.Click_btn_close,
        OkCancelPanelNotificationEnum.Click_btn_ok,
        OkCancelPanelNotificationEnum.Click_btn_cancel,
        OkCancelPanelNotificationEnum.RefreshUI,
    }
end

function OkCancelPanelMediator:handleNotification(notification)
    local name = notification:getName()
    -- local type = notification:getType()
    local body = notification:getBody() --message data
    --insertHandleNotificationNames
    if (name == OkCancelPanelNotificationEnum.Click_btn_ok) then
        if not self.arguments.okNotClosePanel then
            PanelManager.closeTopPanel()
        end
        Runtime.InvokeCbk(self.arguments.okCallback)
    elseif (name == OkCancelPanelNotificationEnum.Click_btn_cancel) then
        Runtime.InvokeCbk(self.arguments.cancelCallback)
        PanelManager.closeTopPanel()
    elseif name == OkCancelPanelNotificationEnum.RefreshUI then
        self.arguments = body
        panel:setArguments(self.arguments)
        panel:SetPanelText()
    end
end

-- function OkCancelPanelMediator:onBeforeLoadAssets()
--  -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
-- 	-- Send Request To Server
-- 	local extraAssetsNeedLoad = {}
-- 	table.insert(extraAssetsNeedLoad, "extraAssetName")
-- 	self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
-- end

-- function OkCancelPanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

function OkCancelPanelMediator:onBeforeShowPanel()
    --在第一次显示之前，此时visible=false。
    local config = self.arguments
    panel:SetPanelText()
    self.okCallback = config.okCallback
    self.cancelCallback = config.cancelCallback
    panel:refreshUI()
end
-- function OkCancelPanelMediator:onAfterShowPanel()
-- 	--在第一次显示之后，此时visible=true。
-- end

-- function OkCancelPanelMediator:onBeforeHidePanel()
-- 	--在被隐藏之前(FadeOut开始前)，此时visible=true。
-- end
-- function OkCancelPanelMediator:onAfterHidePanel()
-- 	--在被隐藏之后(FadeOut完成后)，此时visible=false。
-- end

-- function OkCancelPanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function OkCancelPanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

function OkCancelPanelMediator:onBeforeDestroyPanel()
	--在被销毁之前，此时visible=false。
    panel:OnRelease()
end

-- function OkCancelPanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function OkCancelPanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

return OkCancelPanelMediator
