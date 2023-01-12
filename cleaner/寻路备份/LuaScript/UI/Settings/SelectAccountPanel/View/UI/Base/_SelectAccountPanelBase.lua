--insertRequire

local _SelectAccountPanelBase = class(BasePanel)

function _SelectAccountPanelBase:ctor()
	self.gameObject = nil
	self.proxy = nil
	--insertCtor
	self.img_title = nil
	self.btn_close = nil
	self.onClick_btn_close = nil
end

function _SelectAccountPanelBase:setProxy(proxy)
	self.proxy = proxy
	--setProxy
end

function _SelectAccountPanelBase:bindView()

	if(self.gameObject ~= nil) then
		--insertInit
		--选择面板
		self.select_left_button = self.gameObject:FindGameObject("left/btn_choose"):GetComponent(typeof(Button))
		self.select_right_button = self.gameObject:FindGameObject("right/btn_choose"):GetComponent(typeof(Button))

		self.select_close = self.gameObject:FindGameObject("btn_close"):GetComponent(typeof(Button))

		Runtime.Localize(self.gameObject:FindGameObject("txt_title"), "ui_chooseprogress_title")
		Runtime.Localize(self.gameObject:FindGameObject("left/txt_save"), "ui_chooseprogress_device")
		Runtime.Localize(self.gameObject:FindGameObject("left/lastLogin/Text"), "ui_chooseprogress_time")
		Runtime.Localize(self.gameObject:FindGameObject("left/btn_choose/Text"), "ui_chooseprogress_choose")
		Runtime.Localize(self.gameObject:FindGameObject("right/txt_save"), "ui_chooseprogress_server")
		Runtime.Localize(self.gameObject:FindGameObject("right/lastLogin/Text"), "ui_chooseprogress_time")
		Runtime.Localize(self.gameObject:FindGameObject("right/btn_choose/Text"), "ui_chooseprogress_choose")

		local function OnClick_btn_select_left(go)
			sendNotification(SelectAccountPanelNotificationEnum.Click_btn_choose,1)
		end

		local function OnClick_btn_select_right(go)
			sendNotification(SelectAccountPanelNotificationEnum.Click_btn_choose,2)
		end

		local function OnClick_btn_close(go)
			sendNotification(SelectAccountPanelNotificationEnum.Click_btn_close)
		end

		Util.UGUI_AddButtonListener(self.select_left_button.gameObject, OnClick_btn_select_left)
		Util.UGUI_AddButtonListener(self.select_right_button.gameObject, OnClick_btn_select_right)
		Util.UGUI_AddButtonListener(self.select_close.gameObject, OnClick_btn_close)

	end

end

--insertSetTxt

return _SelectAccountPanelBase
