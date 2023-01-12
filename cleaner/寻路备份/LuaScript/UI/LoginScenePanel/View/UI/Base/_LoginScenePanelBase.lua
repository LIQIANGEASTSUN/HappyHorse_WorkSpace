--insertRequire

---@class _LoginScenePanelBase:BasePanel
local _LoginScenePanelBase = class(BasePanel)

function _LoginScenePanelBase:ctor()
	self.gameObject = nil
	self.proxy = nil
	--insertCtor
    self.btn_Confirm = nil
    self.onClick_btn_Confirm = nil
    self.btn_FAQ = nil
    self.onClick_btn_FAQ = nil
end

function _LoginScenePanelBase:setProxy(proxy)
	self.proxy = proxy
	--setProxy
end

function _LoginScenePanelBase:bindView()

	if(self.gameObject ~= nil) then
	--insertInit
        self.name_InputField = self.gameObject.transform:Find("name_InputField"):GetComponent(typeof(CS.UnityEngine.UI.InputField))
        self.btn_Confirm = self.gameObject.transform:Find("btn_Confirm").gameObject:GetComponent(typeof(Button))
        self.btn_FAQ = self.gameObject.transform:Find("btn_FAQ").gameObject:GetComponent(typeof(Button))
	--insertInitComp
	--insertOnClick
        local function OnClick_btn_Confirm(go)
            sendNotification(LoginScenePanelNotificationEnum.Click_btn_Confirm)
        end

        local function OnClick_btn_FAQ(go)
            sendNotification(LoginScenePanelNotificationEnum.Click_btn_FAQ)
        end
	--insertDeclareBtn

        Util.UGUI_AddButtonListener(self.btn_Confirm.gameObject, OnClick_btn_Confirm)
        Util.UGUI_AddButtonListener(self.btn_FAQ.gameObject, OnClick_btn_FAQ)

        Runtime.Localize(self.btn_Confirm:FindGameObject("button/Text"), "ui_common_play")
	end

end

--insertSetTxt

return _LoginScenePanelBase
