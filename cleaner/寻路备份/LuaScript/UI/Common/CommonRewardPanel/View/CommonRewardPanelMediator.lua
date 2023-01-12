require "UI.Common.CommonRewardPanel.CommonRewardPanelNotificationEnum"
local CommonRewardPanelProxy = require "UI.Common.CommonRewardPanel.Model.CommonRewardPanelProxy"

local CommonRewardPanelMediator = MVCClass("CommonRewardPanelMediator", BaseMediator)
---@type CommonRewardPanel
local panel
local proxy

function CommonRewardPanelMediator:ctor(...)
    CommonRewardPanelMediator.super.ctor(self, ...)
    proxy = CommonRewardPanelProxy.new()
end

function CommonRewardPanelMediator:onRegister()
end

function CommonRewardPanelMediator:onAfterSetViewComponent()
    panel = self:getViewComponent()
    panel:setProxy(proxy)
    self.enabled = false
end

function CommonRewardPanelMediator:listNotificationInterests()
    return {
        --insertNotificationNames
        CommonRewardPanelNotificationEnum.Click_btn_hitLayer,
        CommonRewardPanelNotificationEnum.Click_btn_nextLayer
    }
end

function CommonRewardPanelMediator:handleNotification(notification)
    local name = notification:getName()
    -- local type = notification:getType()
    -- local body = notification:getBody() --message data
    --insertHandleNotificationNames
    if (name == CommonRewardPanelNotificationEnum.Click_btn_hitLayer) then
        if not self.enabled then
            return
        end
        if self.tweeningProsperity then
            return
        end
        self.enabled = false

        panel:StopFirework()
        if self.notFlyRewards then
            self:closePanel()
        else
            panel:SetComponentVisible(panel.btn_hitLayer, false)
            if self.arguments.FlyToDragonFlyTarget then
                local btn = App.scene:GetWidget(CONST.MAINUI.ICONS.DragonFlyTarget)
                if not btn then
                    local DragonFlyTarget = require("UI.Components.DragonFlyTarget")
                    btn = DragonFlyTarget.Create()
                end
                btn:ShowEnterAnim(
                    function()
                        local dragonRewardItem = table.remove(panel.flyItems, 1)
                        btn:SetFlyDragon(dragonRewardItem, self.arguments.flyTime)
                        self:closePanel()
                    end
                )
            end
            panel:FlyRewards(
                function()
                    -- Runtime.InvokeCbk(self.arguments.callBack)
                    if self.arguments.callback then
                        self.arguments.callback()
                    end
                    if self.arguments.dayRewardCbk then
                        Runtime.InvokeCbk(self.arguments.dayRewardCbk)
                    end
                    self:closePanel()
                end
            )
        end
    elseif name == CommonRewardPanelNotificationEnum.Click_btn_nextLayer then
        panel.hideDragon()
    end
end

function CommonRewardPanelMediator:onBeforeLoadAssets()
    -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
    -- Send Request To Server
    local extraAssetsNeedLoad = {}
    if not panel.arguments.onceFirework then
        table.insert(extraAssetsNeedLoad, CONST.UIEFFECT_ASSETS.FIREWORKS)
    else
        table.insert(extraAssetsNeedLoad, CONST.UIEFFECT_ASSETS.FIREWORK)
    end
    self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
end

-- function CommonRewardPanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

function CommonRewardPanelMediator:onBeforeShowPanel()
    --在第一次显示之前，此时visible=false。
    -- panel:InitRewards(self.arguments.rewards)
    self.notFlyRewards = self.arguments.notFlyRewards
    self.forceAddProsperity = self.arguments.forceAddProsperity
    if self.forceAddProsperity == 0 then
        self.forceAddProsperity = nil
    end
end

function CommonRewardPanelMediator:onAfterShowPanel()
    --在第一次显示之后，此时visible=true。
    local rewards = self.arguments.rewards
    if self.arguments.showInSequence and not self.arguments.isEntity then
        panel:InitRewardsInSequence(rewards)
        panel:StartFirework()
        WaitExtension.SetTimeout(
            function()
                self.enabled = true
                panel.text_continue.gameObject:SetActive(true)
            end,
            2
        )
    elseif self.arguments.showInSequence and self.arguments.isEntity then
        --panel:InitDragonRewardsInSequence(rewards)
        panel:InitDragonRewardsInSequence(rewards, function()
            panel:StartFirework()
            self.enabled = true
        end)
        panel:StartFirework()
    else
        panel:InitRewards(rewards)
        panel.text_continue.gameObject:SetActive(true)
        panel:ShowRewards(
            function()
                panel:StartFirework()
                self.enabled = true
            end
        )
    end
    if self.arguments.FlyToDragonFlyTarget then
        local btn = App.scene:GetWidget(CONST.MAINUI.ICONS.DragonFlyTarget)
        if not btn then
            local DragonFlyTarget = require("UI.Components.DragonFlyTarget")
            btn = DragonFlyTarget.Create()
        end
        btn:CloneGo()
    end
end

function CommonRewardPanelMediator:onBeforeHidePanel()
    --在被隐藏之前(FadeOut开始前)，此时visible=true。
    if panel.dragonRewardItems then
        for index, value in ipairs(panel.dragonRewardItems) do
            value:SetActive(false)
        end
    end
end
-- function CommonRewardPanelMediator:onAfterHidePanel()
-- 	--在被隐藏之后(FadeOut完成后)，此时visible=false。
-- end

-- function CommonRewardPanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function CommonRewardPanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

function CommonRewardPanelMediator:onBeforeDestroyPanel()
    --在被销毁之前，此时visible=false。
    panel:StopFirework()
    if self.arguments then
        -- if self.arguments.closeCallback then
        --     Runtime.InvokeCbk(self.arguments.closeCallback)
        -- end
        if self.arguments.dayRewardCbk then
            Runtime.InvokeCbk(self.arguments.dayRewardCbk)
        end
    end
end

-- function CommonRewardPanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function CommonRewardPanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

return CommonRewardPanelMediator
