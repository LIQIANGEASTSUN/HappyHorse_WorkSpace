--insertRequire

---@class _BuildUpLevelPanelBase:BasePanel
local _BuildUpLevelPanelBase = class(BasePanel)

function _BuildUpLevelPanelBase:ctor()
	self.gameObject = nil
	self.proxy = nil
	--insertCtor
end

function _BuildUpLevelPanelBase:setProxy(proxy)
	self.proxy = proxy
	--setProxy
end

function _BuildUpLevelPanelBase:bindView()

	if(self.gameObject ~= nil) then
		--insertInit
		self.txt_title = self.gameObject.transform:Find("Panel/UpLevel/txt_title").gameObject:GetComponent(typeof(Text))
		self.icon = self.gameObject.transform:Find("Panel/UpLevel/Icon").gameObject:GetComponent(typeof(Image))
		self.txt_up_info = self.gameObject.transform:Find("Panel/UpLevel/txt_up_info").gameObject:GetComponent(typeof(Text))
		self.btn_close = self.gameObject.transform:Find("Panel/btn_close").gameObject:GetComponent(typeof(Button))
		local function OnClick_btn_close(go)
			sendNotification(BuildUpLevelPanelNotificationEnum.Click_btn_close)
		end
		--insertDeclareBtn
		Util.UGUI_AddButtonListener(self.btn_close.gameObject, OnClick_btn_close)
		--insertInitComp
		--insertOnClick
		--insertDeclareBtn
	end

end

--insertSetTxt

return _BuildUpLevelPanelBase
