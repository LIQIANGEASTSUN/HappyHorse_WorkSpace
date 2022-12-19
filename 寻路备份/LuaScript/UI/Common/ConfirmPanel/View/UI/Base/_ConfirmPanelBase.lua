--insertRequire

---@class _ConfirmPanelBase:BasePanel
local _ConfirmPanelBase = class(BasePanel)

function _ConfirmPanelBase:ctor()
	self.gameObject = nil
	self.proxy = nil
	--insertCtor
end

function _ConfirmPanelBase:setProxy(proxy)
	self.proxy = proxy
	--setProxy
end

function _ConfirmPanelBase:bindView()

	if(self.gameObject ~= nil) then
		local go = find_component(self.gameObject, "bg")
		self.txtTittle = find_component(go, "m_txtTittle", Text)
		self.txtContent = find_component(go, "m_txtContent", Text)
		self.imgIcon = find_component(go, "m_imgIcon", Image)
		self.btnOk = find_component(go, "layout/btn_ok")
		self.btnCancel = find_component(go, "layout/btn_cancel")
		self.txtBtnOk = find_component(go, "layout/btn_ok/Text", Text)
		self.txtBtnCancel = find_component(go, "layout/btn_cancel/Text", Text)
		self.btnClose = find_component(go, "m_btnClose")
	end

end

--insertSetTxt

return _ConfirmPanelBase
