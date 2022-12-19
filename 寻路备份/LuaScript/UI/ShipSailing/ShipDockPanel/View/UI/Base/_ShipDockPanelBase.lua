--insertRequire

---@class _ShipDockPanelBase:BasePanel
local _ShipDockPanelBase = class(BasePanel)

function _ShipDockPanelBase:ctor()
	self.gameObject = nil
	self.proxy = nil
	--insertCtor
end

function _ShipDockPanelBase:setProxy(proxy)
	self.proxy = proxy
	--setProxy
end

function _ShipDockPanelBase:bindView()

	if(self.gameObject ~= nil) then
	    --insertInit
		local transform = self.gameObject.transform:Find("Panel/UpLevel")
		self.txt_title = transform:Find("Level/txt_title"):GetComponent(typeof(Text))
		self.txt_level =  transform:Find("Level/txt_level"):GetComponent(typeof(Text))
		self.txt_level_next =  transform:Find("Level/txt_level_next"):GetComponent(typeof(Text))

		self.unlockTr = transform:Find("Unlock"):GetComponent(typeof(Transform))
		self.txt_title_unlock = transform:Find("Unlock/txt_title"):GetComponent(typeof(Text))
		self.itemUnlockParent =  transform:Find("Unlock/Layout"):GetComponent(typeof(Transform))

		self.txt_title_cost = transform:Find("Cost/txt_title"):GetComponent(typeof(Text))
		self.itemCostParent =  transform:Find("Cost/Layout"):GetComponent(typeof(Transform))

		self.btn_up_level = transform:Find("btn_up_level"):GetComponent(typeof(Button))
		self.txt_up_level = transform:Find("btn_up_level/txt_name"):GetComponent(typeof(Text))
		self.btn_disable = transform:Find("btn_disable"):GetComponent(typeof(Button))
		self.txt_name_disable = transform:Find("btn_disable/txt_name"):GetComponent(typeof(Text))

		self.btn_close = self.gameObject.transform:Find("Panel/btn_close"):GetComponent(typeof(Button))

		local function OnClick_btn_uplevel(go)
			sendNotification(ShipDockPanelNotificationEnum.Click_btn_upLevel)
		end

		local function OnClick_btn_close(go)
			sendNotification(ShipDockPanelNotificationEnum.Click_btn_close)
		end
		--insertDeclareBtn
		Util.UGUI_AddButtonListener(self.btn_up_level.gameObject, OnClick_btn_uplevel)
		Util.UGUI_AddButtonListener(self.btn_close.gameObject, OnClick_btn_close)
	--insertInitComp
	--insertOnClick
	--insertDeclareBtn
	end

end

--insertSetTxt

return _ShipDockPanelBase
