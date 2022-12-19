require "UI.Common.SimpleRewardPanel.SimpleRewardPanelNotificationEnum"
local SimpleRewardPanelProxy = require "UI.Common.SimpleRewardPanel.Model.SimpleRewardPanelProxy"

---@class SimpleRewardPanelMediator:BaseMediator
local SimpleRewardPanelMediator = MVCClass("SimpleRewardPanelMediator", BaseMediator)

---@type SimpleRewardPanel
local panel
local proxy

function SimpleRewardPanelMediator:ctor(...)
    SimpleRewardPanelMediator.super.ctor(self, ...)
    proxy = SimpleRewardPanelProxy.new()
end

function SimpleRewardPanelMediator:onRegister()
end

function SimpleRewardPanelMediator:onAfterSetViewComponent()
    panel = self:getViewComponent()
    panel:setProxy(proxy)
end

function SimpleRewardPanelMediator:listNotificationInterests()
    return {
        SimpleRewardPanelNotificationEnum.Fly_Finish
    }
end

function SimpleRewardPanelMediator:handleNotification(notification)
    local name = notification:getName()
    -- local type = notification:getType()
    -- local body = notification:getBody() --message data
    --insertHandleNotificationNames
    if (name == SimpleRewardPanelNotificationEnum.Fly_Finish) then
        Runtime.InvokeCbk(self.arguments.callback)
        self:closePanel()
    end
end

-- function SimpleRewardPanelMediator:onBeforeLoadAssets()
--  -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
-- 	-- Send Request To Server
-- 	local extraAssetsNeedLoad = {}
-- 	table.insert(extraAssetsNeedLoad, "extraAssetName")
-- 	self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
-- end

-- function SimpleRewardPanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

function SimpleRewardPanelMediator:onBeforeShowPanel()
    -- 	--在第一次显示之前，此时visible=false。
    -- panel:PreventShowButtonsOnClose()
    panel:InitRewards(self.arguments.rewards)
end
function SimpleRewardPanelMediator:onAfterShowPanel()
    -- 	--在第一次显示之后，此时visible=true。
    panel:ShowRewards()
end

-- function SimpleRewardPanelMediator:onBeforeHidePanel()
-- 	--在被隐藏之前(FadeOut开始前)，此时visible=true。
-- end
-- function SimpleRewardPanelMediator:onAfterHidePanel()
-- 	--在被隐藏之后(FadeOut完成后)，此时visible=false。
-- end

-- function SimpleRewardPanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function SimpleRewardPanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

function SimpleRewardPanelMediator:onAfterDestroyPanel()
    -- 	--在被销毁之前，此时visible=false。
    -- if self.arguments and self.arguments.closeCallback then
    --     Runtime.InvokeCbk(self.arguments.closeCallback)
    -- end
end

-- function SimpleRewardPanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function SimpleRewardPanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

return SimpleRewardPanelMediator
