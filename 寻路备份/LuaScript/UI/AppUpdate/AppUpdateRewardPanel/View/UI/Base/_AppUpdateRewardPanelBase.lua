--insertRequire

local _AppUpdateRewardPanelBase = class(BasePanel)

function _AppUpdateRewardPanelBase:ctor()
	self.gameObject = nil
	self.proxy = nil
	--insertCtor
	self.text_title = nil
	self.img_line1 = nil
	self.btn_receive = nil
	self.onClick_btn_receive = nil
end

function _AppUpdateRewardPanelBase:setProxy(proxy)
	self.proxy = proxy
	--setProxy
end

function _AppUpdateRewardPanelBase:bindView()

	if(self.gameObject ~= nil) then
	--insertInit
		self.text_title = self.gameObject.transform:Find("text_title").gameObject:GetComponent(typeof(Text))
		self.text_content = self.gameObject.transform:Find("text_content").gameObject:GetComponent(typeof(Text))
		self.text_award_desc = self.gameObject.transform:Find("text_award_desc").gameObject:GetComponent(typeof(Text))
		self.btn_receive = self.gameObject.transform:Find("btn_receive").gameObject:GetComponent(typeof(Button))
	--insertInitComp
	--insertOnClick

		self.onClick_btn_receive = function()
			sendNotification(AppUpdateRewardPanelNotificationEnum.Click_btn_receive)
		end

		local function OnClick_btn_receive(go)
			if(self.onClick_btn_receive ~=  nil) then
				self.onClick_btn_receive()
			end
		end
	--insertDeclareBtn
		Util.UGUI_AddButtonListener(self.btn_receive.gameObject, OnClick_btn_receive)
	end

end

--insertSetTxt

return _AppUpdateRewardPanelBase
