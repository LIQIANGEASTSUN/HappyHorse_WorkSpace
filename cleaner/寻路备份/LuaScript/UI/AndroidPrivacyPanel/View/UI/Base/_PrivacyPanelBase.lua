--insertRequire

---@class _PrivacyPanelBase:BasePanel
local _PrivacyPanelBase = class(BasePanel)

function _PrivacyPanelBase:ctor()
	self.gameObject = nil
	self.proxy = nil
	--insertCtor
    self.img_lost = nil
end

function _PrivacyPanelBase:setProxy(proxy)
	self.proxy = proxy
	--setProxy
end

function _PrivacyPanelBase:bindView()

	if(self.gameObject ~= nil) then
	--insertInit
        self.img_lost = self.gameObject.transform:Find("img_lost").gameObject:GetComponent(typeof(Image))
	--insertInitComp
	--insertOnClick
	--insertDeclareBtn
		local go = self.gameObject
		self.callback = self.arguments.callback

		go:FindComponentInChildren("lbTitle", typeof(Text)).text = Runtime.Translate('ui_privacy_panel_title')
		go:FindComponentInChildren("lbDesc", typeof(Text)).text = Runtime.Translate('ui_privacy_panel_desc')

		-- 使用条款
		self.btnItems = go:FindGameObject("Connect_platform/btnItems")
		self.btnItems:FindComponentInChildren("Text", typeof(Text)).text = Runtime.Translate('ui_settings_termofuse')
		Util.UGUI_AddEventListener(self.btnItems, "onClick", function()
			CS.UnityEngine.Application.OpenURL("https://privacy.betta-games.net/")
		end)

		-- 隐私政策
		self.btnPolicy = go:FindGameObject("Connect_platform/btnPolicy")
		self.btnPolicy:FindComponentInChildren("Text", typeof(Text)).text = Runtime.Translate('ui_settings_privacypolicy')
		Util.UGUI_AddEventListener(self.btnPolicy, "onClick", function()
			CS.UnityEngine.Application.OpenURL("https://privacy.betta-games.net/")
		end)

		-- 确认
		self.btnConfirm = go:FindGameObject("Connect_platform/btnConfirm")
		self.btnConfirm:FindComponentInChildren("Text", typeof(Text)).text = Runtime.Translate('idleaccelerate_ok')
		Util.UGUI_AddEventListener(self.btnConfirm, "onClick", function()
			Runtime.InvokeCbk(self.callback)
			PanelManager.closePanel(self.panelVO)
		end)
	end

end

--insertSetTxt

return _PrivacyPanelBase
