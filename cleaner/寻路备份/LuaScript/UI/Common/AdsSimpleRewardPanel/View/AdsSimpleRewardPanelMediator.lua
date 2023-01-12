require "UI.Common.AdsSimpleRewardPanel.AdsSimpleRewardPanelNotificationEnum"
local AdsSimpleRewardPanelProxy = require "UI.Common.AdsSimpleRewardPanel.Model.AdsSimpleRewardPanelProxy"

---@class AdsSimpleRewardPanelMediator:BaseMediator
local AdsSimpleRewardPanelMediator = MVCClass("AdsSimpleRewardPanelMediator", BaseMediator)

---@type AdsSimpleRewardPanel
local panel
local proxy

function AdsSimpleRewardPanelMediator:ctor(...)
    AdsSimpleRewardPanelMediator.super.ctor(self, ...)
    proxy = AdsSimpleRewardPanelProxy.new()
end

function AdsSimpleRewardPanelMediator:onRegister()
end

function AdsSimpleRewardPanelMediator:onAfterSetViewComponent()
    panel = self:getViewComponent()
    panel:setProxy(proxy)
end

function AdsSimpleRewardPanelMediator:listNotificationInterests()
    return {}
end

function AdsSimpleRewardPanelMediator:handleNotification(notification)
    -- local name = notification:getName()
    -- local type = notification:getType() -- uncomment if need by yourself
    -- local body = notification:getBody() --message data  uncomment if need by yourself
    --insertHandleNotificationNames
end

function AdsSimpleRewardPanelMediator:onBeforeLoadAssets()
    --  -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
    -- 	-- Send Request To Server
    local extraAssetsNeedLoad = {}
    table.insert(extraAssetsNeedLoad, CONST.UIEFFECT_ASSETS.FIREWORKS)
    self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
end

-- function AdsSimpleRewardPanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

function AdsSimpleRewardPanelMediator:onBeforeShowPanel()
    --在第一次显示之前，此时visible=false。
    -- panel:refreshUI()
    panel:InitRewards(self.arguments.rewards)
end
function AdsSimpleRewardPanelMediator:onAfterShowPanel()
    --在第一次显示之后，此时visible=true。
    panel:ShowRewards()
    panel:StartFirework()
end

-- function AdsSimpleRewardPanelMediator:onBeforeHidePanel()
-- 	--在被隐藏之前(FadeOut开始前)，此时visible=true。
-- end
-- function AdsSimpleRewardPanelMediator:onAfterHidePanel()
-- 	--在被隐藏之后(FadeOut完成后)，此时visible=false。
-- end

-- function AdsSimpleRewardPanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function AdsSimpleRewardPanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

function AdsSimpleRewardPanelMediator:onBeforeDestroyPanel()
-- 	--在被销毁之前，此时visible=false。
    panel:StopFirework()
end

-- function AdsSimpleRewardPanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function AdsSimpleRewardPanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

return AdsSimpleRewardPanelMediator
