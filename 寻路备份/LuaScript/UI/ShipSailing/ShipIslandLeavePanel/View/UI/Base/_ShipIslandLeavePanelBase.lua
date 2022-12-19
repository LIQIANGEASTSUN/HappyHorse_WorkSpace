--insertRequire

---@class _ShipIslandLeavePanelBase:BasePanel
local _ShipIslandLeavePanelBase = class(BasePanel)

function _ShipIslandLeavePanelBase:ctor()
	self.gameObject = nil
	self.proxy = nil
	--insertCtor
end

function _ShipIslandLeavePanelBase:setProxy(proxy)
	self.proxy = proxy
	--setProxy
end

function _ShipIslandLeavePanelBase:bindView()

	if(self.gameObject ~= nil) then
		--insertInit
		self.btn_confirm = self.gameObject.transform:Find("BG/btn_confirm").gameObject:GetComponent(typeof(Button))
		self.btn_cancel = self.gameObject.transform:Find("BG/btn_cancel").gameObject:GetComponent(typeof(Button))
		self.txt_title = self.gameObject.transform:Find("BG/txt_title").gameObject:GetComponent(typeof(Text))
		self.txt_info = self.gameObject.transform:Find("BG/txt_info").gameObject:GetComponent(typeof(Text))

	--insertInitComp
	--insertOnClick
	    local function OnClick_btn_confirm(go)
			sendNotification(ShipIslandLeavePanelNotificationEnum.Click_btn_confirm)
		end

		local function OnClick_btn_cancel(go)
			sendNotification(ShipIslandLeavePanelNotificationEnum.Click_btn_cancel)
		end
	--insertDeclareBtn
	    Util.UGUI_AddButtonListener(self.btn_confirm.gameObject, OnClick_btn_confirm)
		Util.UGUI_AddButtonListener(self.btn_cancel.gameObject, OnClick_btn_cancel)
	end

end

--insertSetTxt

return _ShipIslandLeavePanelBase
