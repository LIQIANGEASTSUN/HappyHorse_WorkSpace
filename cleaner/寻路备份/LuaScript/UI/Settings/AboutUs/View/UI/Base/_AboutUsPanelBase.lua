--insertRequire

---@class _AboutUsPanelBase:BasePanel
local _AboutUsPanelBase = class(BasePanel)

function _AboutUsPanelBase:ctor()
	self.gameObject = nil
	self.proxy = nil
	--insertCtor
    self.btn_privacy = nil
    self.onClick_btn_privacy = nil
    self.btn_terms = nil
    self.onClick_btn_terms = nil
    self.btn_close = nil
    self.onClick_btn_close = nil
end

function _AboutUsPanelBase:setProxy(proxy)
	self.proxy = proxy
	--setProxy
end

function _AboutUsPanelBase:bindView()

	if(self.gameObject ~= nil) then
	--insertInit
        self.btn_privacy = self.gameObject.transform:Find("btn_privacy").gameObject:GetComponent(typeof(Button))
        self.btn_terms = self.gameObject.transform:Find("btn_terms").gameObject:GetComponent(typeof(Button))
        self.btn_close = self.gameObject.transform:Find("btn_close").gameObject:GetComponent(typeof(Button))
	--insertInitComp
	--insertOnClick


        local function OnClick_btn_privacy(go)
            sendNotification(AboutUsPanelNotificationEnum.Click_btn_privacy)
        end


        local function OnClick_btn_terms(go)
            sendNotification(AboutUsPanelNotificationEnum.Click_btn_terms)
        end


        local function OnClick_btn_close(go)
            sendNotification(AboutUsPanelNotificationEnum.Click_btn_close)
        end
	--insertDeclareBtn
        Util.UGUI_AddButtonListener(self.btn_privacy.gameObject, OnClick_btn_privacy)
        Util.UGUI_AddButtonListener(self.btn_terms.gameObject, OnClick_btn_terms)
        Util.UGUI_AddButtonListener(self.btn_close.gameObject, OnClick_btn_close)

        Runtime.Localize(self.btn_privacy:FindGameObject("Text"), "ui_settings_privacypolicy")
        Runtime.Localize(self.btn_terms:FindGameObject("Text"), "ui_settings_termofuse")
	end
end

--insertSetTxt

return _AboutUsPanelBase
