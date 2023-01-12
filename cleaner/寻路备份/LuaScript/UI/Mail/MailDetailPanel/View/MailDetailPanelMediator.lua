require "UI.Mail.MailDetailPanel.MailDetailPanelNotificationEnum"
local MailDetailPanelProxy = require "UI.Mail.MailDetailPanel.Model.MailDetailPanelProxy"
---@class MailDetailPanelMediator:BaseMediator
local MailDetailPanelMediator = MVCClass("MailDetailPanelMediator", BaseMediator)

---@type MailDetailPanel
local panel
local proxy

function MailDetailPanelMediator:ctor(...)
    MailDetailPanelMediator.super.ctor(self, ...)
    proxy = MailDetailPanelProxy.new()
end

function MailDetailPanelMediator:onRegister()
end

function MailDetailPanelMediator:onAfterSetViewComponent()
    panel = self:getViewComponent()
    panel:setProxy(proxy)
end

function MailDetailPanelMediator:listNotificationInterests()
    return {
        MailDetailPanelNotificationEnum.OnOkButtonClick
    }
end

function MailDetailPanelMediator:handleNotification(notification)
    local name = notification:getName()
    -- local type = notification:getType()
    local body = notification:getBody() --message data
    --insertHandleNotificationNames
    if (name == "") then
    elseif name == MailDetailPanelNotificationEnum.OnOkButtonClick then
        if body.mailStatus and body.mailStatus == 3 then
            self:OnJump(body.data)
        else
            self:OnOk(body.data)
        end
    -- else
    end
end

function MailDetailPanelMediator:OnJump(data)
    local package = AppServices.ProductManager:GetProductMeta(data.productID)
    --通行证
    if package.shopType == 2 then
        local isAvailable = ActivityServices.GoldPass:IsDataNotEmpty()
        if isAvailable then
            PanelManager.closePanel(GlobalPanelEnum.MailDetailPanel)
            PanelManager.closePanel(GlobalPanelEnum.MailMainPanel)
            PanelManager.showPanel(GlobalPanelEnum.GoldPassPanel, {subPanel = 2})
        else
            local description = Runtime.Translate("Activity.Finishied.Tips")
            AppServices.UITextTip:Show(description)
        end
    --月卡
    elseif package.shopType == 7 or package.shopType == 9 then
        --来源补单邮件
        PanelManager.closePanel(GlobalPanelEnum.MailDetailPanel)
        PanelManager.closePanel(GlobalPanelEnum.MailMainPanel)
        AppServices.MonCard:OpenPanel({source = 4})
    elseif package.shopType == 11 then
        PanelManager.closePanel(GlobalPanelEnum.MailDetailPanel)
        PanelManager.closePanel(GlobalPanelEnum.MailMainPanel)
        PanelManager.showPanel(GlobalPanelEnum.GrowthFundPanel)
    --elseif package.shopType == 8 then
        --PanelManager.showPanel(GlobalPanelEnum.CumulativeStarsPanel, extra)
    end
end
---@param mail Mail
function MailDetailPanelMediator:OnOk(mail)
    local backend = function(rewards)
        PanelManager.closePanel(GlobalPanelEnum.MailDetailPanel)
        --todo: 这里只领取了一个，要刷新整个列表吗？
        --sendNotification(MailMainPanelNotificationEnum.RefillMailList)
        panel:FlyRewards(rewards)
        sendNotification(MailMainPanelNotificationEnum.RefillSingleMail, {mail.id})
    end

    if not mail.hasGift then
        Runtime.InvokeCbk(backend)
        return
    end
    AppServices.MailManager:FetchAllMailAttachments(
        {mail.id},
        function(msg, rewards)
            if msg or nil then
                backend(rewards)
            else
                PanelManager.closePanel(GlobalPanelEnum.MailDetailPanel)
            end
        end
    )
end

-- function MailDetailPanelMediator:onBeforeLoadAssets()
--  -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
-- 	-- Send Request To Server
-- 	local extraAssetsNeedLoad = {}
-- 	table.insert(extraAssetsNeedLoad, "extraAssetName")
-- 	self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
-- end

-- function MailDetailPanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

function MailDetailPanelMediator:onBeforeShowPanel()
    --在第一次显示之前，此时visible=false。
    panel:refreshUI()
    panel:SetData(self.arguments.data)
end
-- function MailDetailPanelMediator:onAfterShowPanel()
-- 	--在第一次显示之后，此时visible=true。
-- end

-- function MailDetailPanelMediator:onBeforeHidePanel()
-- 	--在被隐藏之前(FadeOut开始前)，此时visible=true。
-- end
-- function MailDetailPanelMediator:onAfterHidePanel()
-- 	--在被隐藏之后(FadeOut完成后)，此时visible=false。
-- end

-- function MailDetailPanelMediator:onBeforeReshowPanel(lastPanelVO)
-- 	--在被重新显示之前(FadeIn开始前)，此时visible=false。
-- 	panel:refreshUI()
-- end
-- function MailDetailPanelMediator:onAfterReshowPanel(lastPanelVO)
-- 	--在被重新显示之后(FadeIn完成后)，此时visible=true。
-- end

-- function MailDetailPanelMediator:onBeforeDestroyPanel()
-- 	--在被销毁之前，此时visible=false。
-- end

-- function MailDetailPanelMediator:onBeforePausePanel()
-- 	--在被Popup面板盖住之前，此时visible=true。
-- end
-- function MailDetailPanelMediator:onAfterResumePanel()
-- 	--在Popup面板移除之后，此时visible=true。
-- 	panel:refreshUI()
-- end

return MailDetailPanelMediator
