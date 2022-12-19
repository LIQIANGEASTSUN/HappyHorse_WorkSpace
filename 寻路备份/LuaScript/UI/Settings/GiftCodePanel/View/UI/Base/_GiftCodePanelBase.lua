--insertRequire

---@class _GiftCodePanelBase:BasePanel
local _GiftCodePanelBase = class(BasePanel)

function _GiftCodePanelBase:ctor()
	self.gameObject = nil
	self.proxy = nil
	--insertCtor
end

function _GiftCodePanelBase:setProxy(proxy)
	self.proxy = proxy
	--setProxy
end

function _GiftCodePanelBase:bindView()

	if(self.gameObject ~= nil) then
	--insertInit
		self.btn_close = self.gameObject:FindGameObject("bg/btn_close")
		self.btn_confirm = self.gameObject:FindGameObject("confirm/btn_confirm")
		self.InputField = self.gameObject:FindGameObject("confirm/InputField"):GetComponent(typeof(CS.UnityEngine.UI.InputField))
		self.txt_code = self.gameObject:FindGameObject("confirm/InputField/Text"):GetComponent(typeof(Text))
		self.btn_copy = self.gameObject:FindGameObject("confirm/btn_copy")
	--insertInitComp
	--insertOnClick
	--insertDeclareBtn
		Runtime.Localize(self.gameObject:FindGameObject("bg/title"), "UI_CDKEY_title")
		Runtime.Localize(self.gameObject:FindGameObject("confirm/InputField/Placeholder"), "UI_CDKEY_tip")
		Runtime.Localize(self.gameObject:FindGameObject("confirm/btn_confirm/Text"), "UI_CDKEY_button")

		local function OnClick_btn_close(go)
            sendNotification(GiftCodePanelNotificationEnum.Click_btn_close)
        end

		local function OnClick_btn_confirm(go)
            sendNotification(GiftCodePanelNotificationEnum.Click_btn_confirm)
        end

		local function OnClick_btn_copy(go)
			self.InputField.text = CS.UnityEngine.GUIUtility.systemCopyBuffer
		end

		Util.UGUI_AddButtonListener(self.btn_close, OnClick_btn_close)
		Util.UGUI_AddButtonListener(self.btn_confirm, OnClick_btn_confirm)
		Util.UGUI_AddButtonListener(self.btn_copy, OnClick_btn_copy)
	end
end

--insertSetTxt

return _GiftCodePanelBase
