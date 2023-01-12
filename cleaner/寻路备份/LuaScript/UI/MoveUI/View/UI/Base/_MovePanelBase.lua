--insertRequire

---@class _MovePanelBase:BasePanel
local _MovePanelBase = class(BasePanel)

function _MovePanelBase:ctor()
    self.gameObject = nil
    self.proxy = nil
    --insertCtor
    self.btn_confirm = nil
    self.btn_cancel = nil
end

function _MovePanelBase:setProxy(proxy)
    self.proxy = proxy
    --setProxy
end

function _MovePanelBase:bindView()
    if (self.gameObject ~= nil) then
        --insertInit
        self.btn_confirm = find_component(self.gameObject, "bottomPart/Buttons/btnConfirm", NS.ButtonComponent)
        -- self.img_confirm_green = find_component(self.gameObject, "BG/btn_confirm/green", Image)
        -- self.img_confirm_grey = find_component(self.gameObject, "BG/btn_confirm/grey", Image)
        self.btn_cancel = find_component(self.gameObject, "bottomPart/Buttons/btnCancel", Button)
        --insertInitComp
        --insertOnClick

        local function OnClick_btn_confirm(go)
            sendNotification(MovePanelNotificationEnum.Click_btn_confirm)
        end

        local function OnClick_btn_cancel(go)
            sendNotification(MovePanelNotificationEnum.Click_btn_cancel)
        end
        --insertDeclareBtn
        Util.UGUI_AddButtonListener(self.btn_confirm.gameObject, OnClick_btn_confirm)
        Util.UGUI_AddButtonListener(self.btn_cancel.gameObject, OnClick_btn_cancel)
    end
end

--insertSetTxt

return _MovePanelBase
