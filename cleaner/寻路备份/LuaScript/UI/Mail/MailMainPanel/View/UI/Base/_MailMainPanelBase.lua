--insertRequire
---@class _MailMainPanelBase
local _MailMainPanelBase = class(BasePanel)

function _MailMainPanelBase:ctor()
    self.gameObject = nil
    self.proxy = nil
    --insertCtor
    self.btn_remove_all = nil
    self.onClick_btn_remove_all = nil
    self.btn_fetch_all = nil
    self.onClick_btn_fetch_all = nil
end

function _MailMainPanelBase:setProxy(proxy)
    self.proxy = proxy
    --setProxy
end

function _MailMainPanelBase:bindView()
    if (self.gameObject ~= nil) then
        --insertInit
        self.btn_remove_all = find_component(self.gameObject, "buttonRoot/btn_remove_all")
        self.btn_fetch_all = find_component(self.gameObject, "buttonRoot/btn_fetch_all")
        self.btn_close = self.gameObject.transform:Find("btn_close").gameObject:GetComponent(typeof(Button))

        self.scroll_list = find_component(self.gameObject, "list_mail", ScrollListRenderer)
        self.scroll_list_item_parent = find_component(self.gameObject, "list_mail/List")

        self.txt_title = find_component(self.gameObject, "txt_title", Text)
        self.txt_btn_remove_all = find_component(self.btn_remove_all, "BText", Text)
        self.txt_btn_fetch_all = find_component(self.btn_fetch_all, "BText", Text)

        self.txt_noMail = find_component(self.gameObject, "txt_noMail", Text)
        --insertInitComp
        --insertOnClick

        local function OnClick_btn_remove_all(go)
            sendNotification(MailMainPanelNotificationEnum.Click_btn_remove_all)
        end

        local function OnClick_btn_fetch_all(go)
            sendNotification(MailMainPanelNotificationEnum.Click_btn_fetch_all)
        end

        local function OnClick_btn_close(go)
            sendNotification(MailMainPanelNotificationEnum.Click_btn_close)
        end
        --insertDeclareBtn
        Util.UGUI_AddButtonListener(self.btn_remove_all, OnClick_btn_remove_all)
        Util.UGUI_AddButtonListener(self.btn_fetch_all, OnClick_btn_fetch_all)
        Util.UGUI_AddButtonListener(self.btn_close.gameObject, OnClick_btn_close)
    end
end

--insertSetTxt

return _MailMainPanelBase
