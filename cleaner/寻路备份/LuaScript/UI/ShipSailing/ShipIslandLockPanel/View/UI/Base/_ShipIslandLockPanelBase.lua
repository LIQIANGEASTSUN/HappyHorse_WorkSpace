--insertRequire

---@class _ShipIslandLockPanelBase:BasePanel
local _ShipIslandLockPanelBase = class(BasePanel)

function _ShipIslandLockPanelBase:ctor()
	self.gameObject = nil
	self.proxy = nil
	--insertCtor
end

function _ShipIslandLockPanelBase:setProxy(proxy)
	self.proxy = proxy
	--setProxy
end

function _ShipIslandLockPanelBase:bindView()

	if(self.gameObject ~= nil) then
		--insertInit
		self.btn_close = self.gameObject.transform:Find("BG/btn_close").gameObject:GetComponent(typeof(Button))
		self.txt_title = self.gameObject.transform:Find("BG/txt_title").gameObject:GetComponent(typeof(Text))

		self.itemParent = find_component(self.gameObject,'BG/Layout',Transform)
		self.itemCloneTr = find_component(self.itemParent.gameObject,'Item',Transform)
	--insertInitComp
	--insertOnClick
		local function OnClick_btn_close(go)
			sendNotification(ShipIslandLockPanelNotificationEnum.Click_btn_close)
		end
	--insertDeclareBtn
		Util.UGUI_AddButtonListener(self.btn_close.gameObject, OnClick_btn_close)
	end

end

--insertSetTxt

return _ShipIslandLockPanelBase
