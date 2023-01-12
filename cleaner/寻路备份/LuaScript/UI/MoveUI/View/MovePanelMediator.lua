require "UI.MoveUI.MovePanelNotificationEnum"
local MovePanelProxy = require "UI.MoveUI.Model.MovePanelProxy"

local MovePanelMediator = MVCClass("MovePanelMediator", BaseMediator)

---@type MovePanel
local panel
local proxy

function MovePanelMediator:ctor(...)
    MovePanelMediator.super.ctor(self, ...)
    proxy = MovePanelProxy.new()
end

function MovePanelMediator:onRegister()
end

function MovePanelMediator:onAfterSetViewComponent()
    panel = self:getViewComponent()
    panel:setProxy(proxy)
end

function MovePanelMediator:listNotificationInterests()
    return {
        --insertNotificationNames
        MovePanelNotificationEnum.Click_btn_confirm,
        MovePanelNotificationEnum.Click_btn_cancel
    }
end

function MovePanelMediator:handleNotification(notification)
    local name = notification:getName()
    -- local type = notification:getType()
    -- local body = notification:getBody() --message data
    --insertHandleNotificationNames
    if (name == MovePanelNotificationEnum.Click_btn_confirm) then
        panel:Confirm()
    elseif (name == MovePanelNotificationEnum.Click_btn_cancel) then
        panel:Cancel()
    end
end

-- function MovePanelMediator:onBeforeLoadAssets()
--     -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
--     -- Send Request To Server
-- end

-- function MovePanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

-- function MovePanelMediator:onBeforeShowPanel()
-- 	--在第一次显示之前，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function MovePanelMediator:onAfterShowPanel()
-- 	--在第一次显示之后，此时visible=true。
-- end

-- function MovePanelMediator:onBeforeHidePanel()
-- 	--在被隐藏之前(FadeOut开始前)，此时visible=true。
-- end
-- function MovePanelMediator:onAfterHidePanel()
-- 	--在被隐藏之后(FadeOut完成后)，此时visible=false。
-- end

-- function MovePanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function MovePanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

-- function MovePanelMediator:onBeforeDestroyPanel()
-- 	--在被销毁之前，此时visible=false。
-- end

-- function MovePanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function MovePanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

return MovePanelMediator
