--insertRequire

local template_noPic = require "UI.Mail.MailDetailPanel.View.UI.Template.MailTemplateNoPic"
-- local template_Pic = require "UI.Mail.MailDetailPanel.View.UI.Template.MailTemplatePic"
---@class _MailDetailPanelBase:BasePanel
local _MailDetailPanelBase = class(BasePanel)

function _MailDetailPanelBase:ctor()
    self.gameObject = nil
    self.proxy = nil
end

function _MailDetailPanelBase:setProxy(proxy)
    self.proxy = proxy
    --setProxy
end

function _MailDetailPanelBase:bindView()
    if (self.gameObject ~= nil) then
        self.tem_pic = find_component(self.gameObject, "pic")
        self.tem_noPic = find_component(self.gameObject, "nopic")

        --insertCtor
        -- ---@type MailTemplatePic
        -- self.ItemPic = template_Pic.new()
        -- self.ItemPic:InitComponent(self.tem_pic)
        ---@type MailTemplateNoPic
        self.ItemNoPic = template_noPic.new()
        self.ItemNoPic:InitComponent(self.tem_noPic)
    end
end

function _MailDetailPanelBase:onAfterBindView()
end
--insertSetTxt

return _MailDetailPanelBase
