require "UI.FiveStar.FiveStarPanelNotificationEnum"
local FiveStarPanelProxy = require "UI.FiveStar.Model.FiveStarPanelProxy"

local FiveStarPanelMediator = MVCClass("FiveStarPanelMediator", BaseMediator)

---@type FiveStarPanel
local panel
local proxy

function FiveStarPanelMediator:ctor(...)
    FiveStarPanelMediator.super.ctor(self, ...)
    proxy = FiveStarPanelProxy.new()
end

function FiveStarPanelMediator:onRegister()
end

function FiveStarPanelMediator:onAfterSetViewComponent()
    panel = self:getViewComponent()
    panel:setProxy(proxy)
end

function FiveStarPanelMediator:listNotificationInterests()
    return {
        --insertNotificationNames
        FiveStarPanelNotificationEnum.Click_btn_close
    }
end

function FiveStarPanelMediator:handleNotification(notification)
    local name = notification:getName()
    -- local type = notification:getType()
    -- local body = notification:getBody() --message data
    --insertHandleNotificationNames
    if (name == FiveStarPanelNotificationEnum.Click_btn_close) then
        self:closePanel()
    end
end

-- function FiveStarPanelMediator:onBeforeLoadAssets()
--  -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
-- 	-- Send Request To Server
-- 	local extraAssetsNeedLoad = {}
-- 	table.insert(extraAssetsNeedLoad, "extraAssetName")
-- 	self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
-- end

-- function FiveStarPanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

-- function FiveStarPanelMediator:onBeforeShowPanel()
-- 	--在第一次显示之前，此时visible=false。
-- 	panel:refreshUI()
-- end
function FiveStarPanelMediator:onAfterShowPanel()
    --在第一次显示之后，此时visible=true。
    AppServices.FiveStarManager:ShowCount()
end

-- function FiveStarPanelMediator:onBeforeHidePanel()
-- 	--在被隐藏之前(FadeOut开始前)，此时visible=true。
-- end
-- function FiveStarPanelMediator:onAfterHidePanel()
-- 	--在被隐藏之后(FadeOut完成后)，此时visible=false。
-- end

-- function FiveStarPanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function FiveStarPanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

-- function FiveStarPanelMediator:onBeforeDestroyPanel()
-- 	--在被销毁之前，此时visible=false。
-- end

-- function FiveStarPanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function FiveStarPanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

return FiveStarPanelMediator
