--insertRequire

local _TeamMapAppUpdatePanelBase = class(BasePanel)

function _TeamMapAppUpdatePanelBase:ctor()
    self.gameObject = nil
    self.proxy = nil
    --insertCtor
    self.text_title = nil
    self.text_content = nil
    self.text_award_desc = nil
    self.text_prop_count = nil
    self.btn_cancel = nil
    self.onClick_btn_cancel = nil
    self.btn_update = nil
    self.onClick_btn_update = nil
end

function _TeamMapAppUpdatePanelBase:setProxy(proxy)
    self.proxy = proxy
    --setProxy
end

function _TeamMapAppUpdatePanelBase:bindView()
    if (self.gameObject ~= nil) then
        --insertInit
        self.text_title = self.gameObject.transform:Find("text_title").gameObject:GetComponent(typeof(Text))
        self.text_content = self.gameObject.transform:Find("text_content").gameObject:GetComponent(typeof(Text))
        self.btn_cancel = self.gameObject.transform:Find("btn_cancel").gameObject:GetComponent(typeof(Button))
        self.btn_update = self.gameObject.transform:Find("btn_update").gameObject:GetComponent(typeof(Button))
        --insertInitComp
        --insertOnClick

        local function OnClick_btn_cancel(go)
            sendNotification(TeamMapAppUpdatePanelNotificationEnum.Click_btn_cancel)
        end

        local function OnClick_btn_update(go)
            sendNotification(TeamMapAppUpdatePanelNotificationEnum.Click_btn_update)
        end
        --insertDeclareBtn
        Util.UGUI_AddButtonListener(self.btn_cancel.gameObject, OnClick_btn_cancel)
        Util.UGUI_AddButtonListener(self.btn_update.gameObject, OnClick_btn_update)
    end
end

--insertSetTxt

return _TeamMapAppUpdatePanelBase
