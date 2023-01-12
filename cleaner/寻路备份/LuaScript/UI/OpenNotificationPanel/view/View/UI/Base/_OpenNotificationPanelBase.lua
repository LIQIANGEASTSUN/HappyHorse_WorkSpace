--insertRequire

local _OpenNotificationPanelBase = class(BasePanel)

function _OpenNotificationPanelBase:ctor()
	self.gameObject = nil
	self.proxy = nil
	--insertCtor
	self.img_board = nil
	self.text_title = nil
	self.btn_open = nil
	self.onClick_btn_open = nil
	self.btn_cancel = nil
	self.onClick_btn_cancel = nil
	self.btn_close = nil
	self.onClick_btn_close = nil
	self.text_desc = nil
end

function _OpenNotificationPanelBase:setProxy(proxy)
	self.proxy = proxy
	--setProxy
end

function _OpenNotificationPanelBase:bindView()

	if(self.gameObject ~= nil) then
	--insertInit
		self.img_board = self.gameObject.transform:Find("img_board").gameObject:GetComponent(typeof(Image))
		self.text_title = self.gameObject.transform:Find("text_title").gameObject:GetComponent(typeof(Text))
		self.btn_open = self.gameObject.transform:Find("btn_open").gameObject:GetComponent(typeof(Button))
		self.btn_cancel = self.gameObject.transform:Find("btn_cancel").gameObject:GetComponent(typeof(Button))
		self.btn_close = self.gameObject.transform:Find("btn_close").gameObject:GetComponent(typeof(Button))
		self.text_desc = self.gameObject.transform:Find("text_desc").gameObject:GetComponent(typeof(Text))
	--insertInitComp
	--insertOnClick

		self.onClick_btn_open = function()
			sendNotification(OpenNotificationPanelNotificationEnum.Click_btn_open)
		end

		local function OnClick_btn_open(go)
			if(self.onClick_btn_open ~=  nil) then
				self.onClick_btn_open()
			end
		end

		self.onClick_btn_cancel = function()
			sendNotification(OpenNotificationPanelNotificationEnum.Click_btn_cancel)
		end

		local function OnClick_btn_cancel(go)
			if(self.onClick_btn_cancel ~=  nil) then
				self.onClick_btn_cancel()
			end
		end

		self.onClick_btn_close = function()
			sendNotification(OpenNotificationPanelNotificationEnum.Click_btn_close)
		end

		local function OnClick_btn_close(go)
			if(self.onClick_btn_close ~=  nil) then
				self.onClick_btn_close()
			end
		end
	--insertDeclareBtn
		Util.UGUI_AddButtonListener(self.btn_open.gameObject, OnClick_btn_open)
		Util.UGUI_AddButtonListener(self.btn_cancel.gameObject, OnClick_btn_cancel)
		Util.UGUI_AddButtonListener(self.btn_close.gameObject, OnClick_btn_close)
	end

end

--insertSetTxt

return _OpenNotificationPanelBase
