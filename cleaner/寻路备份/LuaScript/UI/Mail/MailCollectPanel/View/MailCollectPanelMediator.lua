require "UI.Mail.MailCollectPanel.MailCollectPanelNotificationEnum"
local MailCollectPanelProxy = require "UI.Mail.MailCollectPanel.Model.MailCollectPanelProxy"

local MailCollectPanelMediator = MVCClass("MailCollectPanelMediator", BaseMediator)
---@type _MailCollectPanelBase
local panel
local proxy

function MailCollectPanelMediator:ctor(...)
    MailCollectPanelMediator.super.ctor(self, ...)
    proxy = MailCollectPanelProxy.new()
end

function MailCollectPanelMediator:onRegister()
end

function MailCollectPanelMediator:onAfterSetViewComponent()
    panel = self:getViewComponent()
    panel:setProxy(proxy)
end

function MailCollectPanelMediator:listNotificationInterests()
    return {
        --insertNotificationNames
        MailCollectPanelNotificationEnum.Click_btn_collect
    }
end

function MailCollectPanelMediator:handleNotification(notification)
    local name = notification:getName()
    -- local type = notification:getType()
    -- local body = notification:getBody() --message data
    --insertHandleNotificationNames
    if (name == "") then
    elseif (name == MailCollectPanelNotificationEnum.Click_btn_collect) then
        self:OnCollect()
    -- else
    end
end

function MailCollectPanelMediator:OnCollect()
    local count = #panel.rewardGos
    if count <= 0 then
        return
    end
    -- local flyRewards = {}
    for index = 1, count do
        local rewardGo = panel.rewardGos[index]
        local rewardData = self.arguments.rewards[index]
        -- local flyReward = {
        --     ItemId = rewardData.itemTemplateId,
        --     Amount = rewardData.count,
        --     position = rewardGo.transform.position
        -- }
        -- flyRewards[index] = flyReward

        UITool.ShowPropsAni(rewardData.itemTemplateId, rewardData.count, rewardGo.transform.position)
    end
    -- local time = 0.5
    -- AppServices.RewardAnimation.FlyReward(flyRewards, nil, 0, 0, time, false, 1, Ease.InCirc)

    WaitExtension.SetTimeout(
        function()
            PanelManager.closePanel(GlobalPanelEnum.MailCollectPanel)
        end,
        1
    )
    Util.BlockAll(1, "MailCollectPanelMediator:OnCollect")
end

function MailCollectPanelMediator:onBeforeShowPanel()
    --在第一次显示之前，此时visible=false。
    panel:refreshUI()
end

return MailCollectPanelMediator
