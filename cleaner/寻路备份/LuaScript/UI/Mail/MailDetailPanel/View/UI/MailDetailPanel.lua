local _MailDetailPanelBase = require "UI.Mail.MailDetailPanel.View.UI.Base._MailDetailPanelBase"
---@class MailDetailPanel:_MailDetailPanelBase
local MailDetailPanel = class(_MailDetailPanelBase)

function MailDetailPanel:ctor()
end

function MailDetailPanel:onAfterBindView()
end

function MailDetailPanel:refreshUI()
end

function MailDetailPanel:FlyRewards(rewards)
    -- if not string.isEmpty(self.config.picUrl) then
    --     self.ItemPic:FlyRewards(rewards)
    -- else
    --     self.ItemNoPic:FlyRewards(rewards)
    -- end
    self.ItemNoPic:FlyRewards(rewards)
end

function MailDetailPanel:SetData(data)
    self.config = data
    -- if not string.isEmpty(data.picUrl) then
    --     self.ItemPic:SetData(data)
    --     self.ItemNoPic:Hide()
    -- else
    --     self.ItemNoPic:SetData(data)
    --     self.ItemPic:Hide()
    -- end
    self.ItemNoPic:SetData(data)
    -- self.ItemPic:Hide()
end

function MailDetailPanel:destroy()
    -- self.ItemPic = nil
    self.ItemNoPic = nil
    self.super.destroy(self)
end

return MailDetailPanel
