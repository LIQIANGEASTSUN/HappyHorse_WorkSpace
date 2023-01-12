--insertRequire

---@class _ShipIslandLinkHomelandPanelBase:BasePanel
local _ShipIslandLinkHomelandPanelBase = class(BasePanel)

function _ShipIslandLinkHomelandPanelBase:ctor()
	self.gameObject = nil
	self.proxy = nil
	--insertCtor
end

function _ShipIslandLinkHomelandPanelBase:setProxy(proxy)
	self.proxy = proxy
	--setProxy
end

function _ShipIslandLinkHomelandPanelBase:bindView()

	if(self.gameObject ~= nil) then
		--insertInit
		self.btn_confirm = self.gameObject.transform:Find("BG/btn_confirm").gameObject:GetComponent(typeof(Button))
		self.txt_title = self.gameObject.transform:Find("BG/txt_title").gameObject:GetComponent(typeof(Text))
		self.txt_info = self.gameObject.transform:Find("BG/txt_info").gameObject:GetComponent(typeof(Text))

	--insertInitComp
	--insertOnClick
	    local function OnClick_btn_confirm(go)
			sendNotification(ShipIslandLinkHomelandPanelNotificationEnum.Click_btn_confirm)
		end
	--insertDeclareBtn
	    Util.UGUI_AddButtonListener(self.btn_confirm.gameObject, OnClick_btn_confirm)
	end

end

--insertSetTxt

return _ShipIslandLinkHomelandPanelBase
