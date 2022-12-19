require "UI.Bag.BagPanel.BagPanelNotificationEnum"
local BagPanelProxy = require "UI.Bag.BagPanel.Model.BagPanelProxy"

local BagPanelMediator = MVCClass("BagPanelMediator", BaseMediator)

---@type BagPanel
local panel
local proxy

function BagPanelMediator:ctor(...)
    BagPanelMediator.super.ctor(self, ...)
    proxy = BagPanelProxy.new()
end

function BagPanelMediator:onRegister()
end

function BagPanelMediator:onAfterSetViewComponent()
    panel = self:getViewComponent()
    panel:setProxy(proxy)
end

function BagPanelMediator:listNotificationInterests()
    return {
        --insertNotificationNames
        BagPanelNotificationEnum.Close,
        BagPanelNotificationEnum.OpenTip,
    }
end

function BagPanelMediator:handleNotification(notification)
    local name = notification:getName()
    -- local type = notification:getType() -- uncomment if need by yourself
    local body = notification:getBody() --message data  uncomment if need by yourself
    --insertHandleNotificationNames
    if (name == BagPanelNotificationEnum.Close) then
        self:closePanel()
    elseif (name == BagPanelNotificationEnum.OpenTip) then
        if body then
            panel:ShowItemTip(body)
        end
    end
end

-- function BagPanelMediator:onBeforeLoadAssets()
--  -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
-- 	-- Send Request To Server
-- 	local extraAssetsNeedLoad = {}
-- 	table.insert(extraAssetsNeedLoad, "extraAssetName")
-- 	self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
-- end

-- function BagPanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

-- function BagPanelMediator:onBeforeShowPanel()
-- 	--在第一次显示之前，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function BagPanelMediator:onAfterShowPanel()
-- 	--在第一次显示之后，此时visible=true。
-- end

-- function BagPanelMediator:onBeforeHidePanel()
-- 	--在被隐藏之前(FadeOut开始前)，此时visible=true。
-- end
-- function BagPanelMediator:onAfterHidePanel()
-- 	--在被隐藏之后(FadeOut完成后)，此时visible=false。
-- end

-- function BagPanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function BagPanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

function BagPanelMediator:onBeforeDestroyPanel()
    --在被销毁之前，此时visible=false。

    panel:Dispose()
end

-- function BagPanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function BagPanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

return BagPanelMediator
