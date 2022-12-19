--insertRequire
---@class _OkCancelPanelBase
local _OkCancelPanelBase = class(BasePanel)

function _OkCancelPanelBase:ctor()
    self.gameObject = nil
    self.proxy = nil
    --insertCtor
    self.btn_ok = nil
    self.onClick_btn_ok = nil
    self.text_message = nil
    self.btn_cancel = nil
    self.onClick_btn_cancel = nil
end

function _OkCancelPanelBase:setProxy(proxy)
    self.proxy = proxy
    --setProxy
end

function _OkCancelPanelBase:bindView()
    if (self.gameObject ~= nil) then
        local go = self.gameObject

        --insertInit

        --insertInitComp
        --insertOnClick
        self.btn_ok = find_component(go, "layout/btn_ok", Button)
        self.label_ok_green = find_component(self.btn_ok, "label_green", Text)
        self.label_ok_yellow = find_component(self.btn_ok, "label_yellow", Text)
        self.img_ok_green = find_component(self.btn_ok, "img_green", Image)
        self.img_ok_yellow = find_component(self.btn_ok, "img_yellow", Image)
        self.btn_cancel = find_component(go, "layout/btn_cancel", Button)
        self.label_cancel = find_component(self.btn_cancel, "Text", Text)
        self.label_title = find_component(go, "label_title", Text)
        self.btn_close = find_component(go, "btn_close", Button)
        self.text_message = find_component(go, "text_message", Text)
        self.text_message_short = find_component(go, "text_message_short", Text)
        self.text_message_time = find_component(go, "text_message_time", Text)
        self.text_message_short:SetActive(false)
        self.text_message_time:SetActive(false)
        self.onClick_btn_ok = function()
            sendNotification(OkCancelPanelNotificationEnum.Click_btn_ok)
        end

        local function OnClick_btn_ok(go)
            if self.canClick == nil then
                return
            end
            if (self.onClick_btn_ok ~= nil) then
                self.onClick_btn_ok()
            end
        end

        self.onClick_btn_cancel = function()
            sendNotification(OkCancelPanelNotificationEnum.Click_btn_cancel)
        end

        local function OnClick_btn_cancel(go)
            if self.canClick == nil then
                return
            end
            if (self.onClick_btn_cancel ~= nil) then
                self.onClick_btn_cancel()
            end
        end
        --insertDeclareBtn
        UIEventListener.GetButton(self.btn_ok, OnClick_btn_ok)
        UIEventListener.GetButton(self.btn_cancel, OnClick_btn_cancel)
        Util.UGUI_AddButtonListener(
            self.btn_close,
            function()
                sendNotification(OkCancelPanelNotificationEnum.Click_btn_cancel)
            end
        )
    -- Util.UGUI_AddButtonListener(self.btn_ok.gameObject, OnClick_btn_ok)
    -- Util.UGUI_AddButtonListener(self.btn_cancel.gameObject, OnClick_btn_cancel)
    end
end

--insertSetTxt

return _OkCancelPanelBase
