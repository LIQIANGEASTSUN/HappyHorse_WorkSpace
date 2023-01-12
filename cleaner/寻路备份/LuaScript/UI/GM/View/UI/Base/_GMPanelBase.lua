--insertRequire

---@class _GMPanelBase:BasePanel
local _GMPanelBase = class(BasePanel)

function _GMPanelBase:ctor()
	self.gameObject = nil
	self.proxy = nil
	--insertCtor
    self.btn_close = nil
    self.onClick_btn_close = nil
end

function _GMPanelBase:setProxy(proxy)
	self.proxy = proxy
	--setProxy
end

function _GMPanelBase:bindView()

	if(self.gameObject ~= nil) then
	--insertInit
        self.btn_close = self.gameObject.transform:Find("btn_close").gameObject:GetComponent(typeof(Button))

		self.inputField = self.gameObject.transform:Find("Panel/InputField").gameObject:GetComponent(typeof(CS.UnityEngine.UI.InputField))
		self.btn_run = self.gameObject.transform:Find("Panel/btn_run").gameObject:GetComponent(typeof(Button))
		self.dropdown =  self.gameObject.transform:Find("Panel/Dropdown").gameObject:GetComponent(typeof(CS.UnityEngine.UI.Dropdown))
	--insertInitComp
	--insertOnClick
        local function OnClick_btn_close(go)
            sendNotification(GMPanelNotificationEnum.Click_btn_close)
        end

		local function OnClick_btn_run(go)
			sendNotification(GMPanelNotificationEnum.Click_btn_run)
		end
	--insertDeclareBtn
        Util.UGUI_AddButtonListener(self.btn_close.gameObject, OnClick_btn_close)
		Util.UGUI_AddButtonListener(self.btn_run.gameObject, OnClick_btn_run)
	end

end

--insertSetTxt

return _GMPanelBase
