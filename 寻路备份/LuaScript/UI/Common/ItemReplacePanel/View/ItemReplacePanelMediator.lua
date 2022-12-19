require "UI.Common.ItemReplacePanel.ItemReplacePanelNotificationEnum"
local ItemReplacePanelProxy = require "UI.Common.ItemReplacePanel.Model.ItemReplacePanelProxy"

local ItemReplacePanelMediator = MVCClass("ItemReplacePanelMediator", BaseMediator)

---@type ItemReplacePanel
local panel
local proxy

function ItemReplacePanelMediator:ctor(...)
    ItemReplacePanelMediator.super.ctor(self, ...)
    proxy = ItemReplacePanelProxy.new()
end

function ItemReplacePanelMediator:onRegister()
end

function ItemReplacePanelMediator:onAfterSetViewComponent()
    panel = self:getViewComponent()
    panel:setProxy(proxy)
end

function ItemReplacePanelMediator:listNotificationInterests()
    return {}
end

function ItemReplacePanelMediator:handleNotification(notification)
    -- local name = notification:getName()
    -- local type = notification:getType() -- uncomment if need by yourself
    -- local body = notification:getBody() --message data  uncomment if need by yourself
    --insertHandleNotificationNames
end

-- function ItemReplacePanelMediator:onBeforeLoadAssets()
--  -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
-- 	-- Send Request To Server
-- 	local extraAssetsNeedLoad = {}
-- 	table.insert(extraAssetsNeedLoad, "extraAssetName")
-- 	self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
-- end

-- function ItemReplacePanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

-- function ItemReplacePanelMediator:onBeforeShowPanel()
-- 	--在第一次显示之前，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function ItemReplacePanelMediator:onAfterShowPanel()
-- 	--在第一次显示之后，此时visible=true。
-- end

-- function ItemReplacePanelMediator:onBeforeHidePanel()
-- 	--在被隐藏之前(FadeOut开始前)，此时visible=true。
-- end
-- function ItemReplacePanelMediator:onAfterHidePanel()
-- 	--在被隐藏之后(FadeOut完成后)，此时visible=false。
-- end

-- function ItemReplacePanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function ItemReplacePanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

-- function ItemReplacePanelMediator:onBeforeDestroyPanel()
-- 	--在被销毁之前，此时visible=false。
-- end

-- function ItemReplacePanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function ItemReplacePanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

return ItemReplacePanelMediator
