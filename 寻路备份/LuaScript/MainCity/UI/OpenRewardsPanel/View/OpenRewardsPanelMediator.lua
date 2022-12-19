require "MainCity.UI.OpenRewardsPanel.OpenRewardsPanelNotificationEnum"
local OpenRewardsPanelProxy = require "MainCity.UI.OpenRewardsPanel.Model.OpenRewardsPanelProxy"
---@class OpenRewardsPanelMediator:BaseMediator
local OpenRewardsPanelMediator = MVCClass("OpenRewardsPanelMediator", BaseMediator)
---@type OpenRewardsPanel
local panel
local proxy

function OpenRewardsPanelMediator:ctor(...)
    OpenRewardsPanelMediator.super.ctor(self, ...)
    proxy = OpenRewardsPanelProxy.new()
end

function OpenRewardsPanelMediator:onRegister()
end

function OpenRewardsPanelMediator:onAfterSetViewComponent()
    panel = self:getViewComponent()
    panel:setProxy(proxy)
    self.isInAnim = true
    -- panel:SetHideTopIconType(TopIconHideType.stayDiamondCoinIcon)
end

function OpenRewardsPanelMediator:listNotificationInterests()
    return {
        --insertNotificationNames
        OpenRewardsPanelNotificationEnum.Click_btn_hitLayer
    }
end

function OpenRewardsPanelMediator:handleNotification(notification)
    local name = notification:getName()

    --insertHandleNotificationNames
    if name == OpenRewardsPanelNotificationEnum.Click_btn_hitLayer then
        self:HandleClick()
    end
end

function OpenRewardsPanelMediator:HandleClick()
    if self.isInAnim then
        return
    end
    self.isInAnim = true
    self:getViewComponent():StopFirework()
    panel.animator_ray:SetTrigger("Out")

    self:getViewComponent():FlyRewards(
        function()
            --AppServices.UserCoinLogic:RefreshCoinNumber()
            PanelManager.closePanel(panel.panelVO)
            if self.arguments and self.arguments.Callback then
                self.arguments.Callback()
            end
        end
    )
end

function OpenRewardsPanelMediator:onBeforeLoadAssets()
    -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
    -- Send Request To Server
    local extraAssetsNeedLoad = {CONST.UIEFFECT_ASSETS.FIREWORKS}
    self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
end

-- function OpenRewardsPanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

function OpenRewardsPanelMediator:onBeforeShowPanel()
    --在第一次显示之前，此时visible=false。
    local rewards = self.arguments.RewardItems
    panel:SetRewards(rewards)
end

function OpenRewardsPanelMediator:onAfterShowPanel()
    if not self.arguments.duration or self.arguments.duration <= 0 then
        panel.go_continue:SetActive(true)
    end

    local t = Time.time
    local function autoClose()
        if self.arguments and self.arguments.duration and self.arguments.duration > 0 then
            local duration = self.arguments.duration - (Time.time - t)
            WaitExtension.SetTimeout(
                function()
                    self:HandleClick()
                end,
                duration
            )
        end
    end

    if self:getViewComponent() and not self:getViewComponent().isDisposed then
        self:getViewComponent():ShowRewards(
            function()
                self.isInAnim = false
                autoClose()
            end
        )
    else
        self.isInAnim = false
        autoClose()
    end
end

-- function OpenRewardsPanelMediator:onBeforeHidePanel()
-- 	--在被隐藏之前(FadeOut开始前)，此时visible=true。
-- end
-- function OpenRewardsPanelMediator:onAfterHidePanel()
-- 	--在被隐藏之后(FadeOut完成后)，此时visible=false。
-- end

-- function OpenRewardsPanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function OpenRewardsPanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

function OpenRewardsPanelMediator:onBeforeDestroyPanel()
    --在被销毁之前，此时visible=false。
    self:getViewComponent():StopFirework()
end

-- function OpenRewardsPanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function OpenRewardsPanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

return OpenRewardsPanelMediator
