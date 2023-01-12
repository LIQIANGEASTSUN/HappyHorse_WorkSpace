--insertRequire

local _AppUpdatePanelBase = class(BasePanel)

function _AppUpdatePanelBase:ctor()
	self.gameObject = nil
	self.proxy = nil
	--insertCtor
	self.text_title = nil
	self.text_content = nil
	self.text_award_desc = nil
	self.text_prop_count = nil
	self.btn_later = nil
	self.onClick_btn_later = nil
	self.btn_update = nil
	self.onClick_btn_update = nil
	self.btn_force_update = nil
	self.onClick_btn_force_update = nil
end

function _AppUpdatePanelBase:setProxy(proxy)
	self.proxy = proxy
	--setProxy
end

function _AppUpdatePanelBase:bindView()

	if(self.gameObject ~= nil) then
	--insertInit
		self.text_title = self.gameObject.transform:Find("text_title").gameObject:GetComponent(typeof(Text))
		self.text_content = self.gameObject.transform:Find("text_content").gameObject:GetComponent(typeof(Text))
		self.text_award_desc = self.gameObject.transform:Find("text_award_desc").gameObject:GetComponent(typeof(Text))
		self.btn_later = self.gameObject.transform:Find("btn_later").gameObject:GetComponent(typeof(Button))
		self.btn_update = self.gameObject.transform:Find("btn_update").gameObject:GetComponent(typeof(Button))
		self.btn_force_update = self.gameObject.transform:Find("btn_force_update").gameObject:GetComponent(typeof(Button))
	--insertInitComp
	--insertOnClick

		self.onClick_btn_later = function()
			sendNotification(AppUpdatePanelNotificationEnum.Click_btn_later)
		end

		local function OnClick_btn_later(go)
			if(self.onClick_btn_later ~=  nil) then
				self.onClick_btn_later()
			end
		end

		self.onClick_btn_update = function()
			sendNotification(AppUpdatePanelNotificationEnum.Click_btn_update)
		end

		local function OnClick_btn_update(go)
			if(self.onClick_btn_update ~=  nil) then
				self.onClick_btn_update()
			end
		end

		self.onClick_btn_force_update = function()
			sendNotification(AppUpdatePanelNotificationEnum.Click_btn_force_update)
		end

		local function OnClick_btn_force_update(go)
			if(self.onClick_btn_force_update ~=  nil) then
				self.onClick_btn_force_update()
			end
		end
	--insertDeclareBtn
		Util.UGUI_AddButtonListener(self.btn_later.gameObject, OnClick_btn_later)
		Util.UGUI_AddButtonListener(self.btn_update.gameObject, OnClick_btn_update)
		Util.UGUI_AddButtonListener(self.btn_force_update.gameObject, OnClick_btn_force_update)
	end

end

--insertSetTxt

return _AppUpdatePanelBase
