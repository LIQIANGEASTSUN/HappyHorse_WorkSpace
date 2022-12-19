--insertRequire

---@class _DynamicUpdatePanelBase:BasePanel
local _DynamicUpdatePanelBase = class(BasePanel)

function _DynamicUpdatePanelBase:ctor()
	self.gameObject = nil
	self.proxy = nil
	--insertCtor
    self.btn_panel = nil
    self.onClick_btn_panel = nil
	self.btn_close = nil
	self.btn_confirm = nil
	self.lbInfo = nil
end

function _DynamicUpdatePanelBase:setProxy(proxy)
	self.proxy = proxy
	--setProxy
end

function _DynamicUpdatePanelBase:bindView()

	if(self.gameObject ~= nil) then
	--insertInit
        self.btn_panel = self.gameObject.transform:Find("btn_panel").gameObject:GetComponent(typeof(Button))
	--insertInitComp
	--insertOnClick
		self.btn_close = self.gameObject.transform:Find("btn_close").gameObject:GetComponent(typeof(Button))
		self.btn_confirm = find_component(self.gameObject, "btn_confirm", Button)

		self.slider = find_component(self.gameObject, "slider", typeof(Slider))
		self.lbInfo = find_component(self.gameObject, "slider/info", Text)

		Runtime.Localize(self.gameObject:FindGameObject("title"), "ui_goldpass_finished_title")
		Runtime.Localize(self.gameObject:FindGameObject("descripe"), "UI_download_desc")
		Runtime.Localize(self.gameObject:FindGameObject("btn_confirm/button/Text"), "ui_mail_detail_IKnow")

		local function OnClick_btn_close(go)
            sendNotification(DynamicUpdatePanelNotificationEnum.Click_btn_panel)
        end
        Util.UGUI_AddButtonListener(self.btn_close.gameObject, OnClick_btn_close)

        local function OnClick_btn_panel(go)
            sendNotification(DynamicUpdatePanelNotificationEnum.Click_btn_panel)
        end
        Util.UGUI_AddButtonListener(self.btn_panel.gameObject, OnClick_btn_panel)

		local function OnClick_btn_confirm(go)
            sendNotification(DynamicUpdatePanelNotificationEnum.Click_btn_panel)
        end
        Util.UGUI_AddButtonListener(self.btn_confirm.gameObject, OnClick_btn_confirm)
	end
end

--insertSetTxt

return _DynamicUpdatePanelBase
