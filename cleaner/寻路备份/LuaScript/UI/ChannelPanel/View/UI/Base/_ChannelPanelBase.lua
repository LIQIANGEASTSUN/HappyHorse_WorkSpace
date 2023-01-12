--insertRequire

---@class _ChannelPanelBase:BasePanel
local _ChannelPanelBase = class(BasePanel)

function _ChannelPanelBase:ctor()
	self.gameObject = nil
	self.proxy = nil
	--insertCtor
    self.btn_panel = nil
    self.onClick_btn_panel = nil
	self.btn_close = nil
	self.btn_facebook = nil
	self.btn_apple = nil
end

function _ChannelPanelBase:setProxy(proxy)
	self.proxy = proxy
	--setProxy
end

function _ChannelPanelBase:bindView()

	if(self.gameObject ~= nil) then
	--insertInit
        self.btn_panel = self.gameObject.transform:Find("btn_panel").gameObject:GetComponent(typeof(Button))
	--insertInitComp
	--insertOnClick
		self.btn_close = self.gameObject.transform:Find("btn_close").gameObject:GetComponent(typeof(Button))

		self.btn_facebook = self.gameObject.transform:Find("Connect_platform/fb/btn2").gameObject:GetComponent(typeof(Button))
		self.btn_apple = self.gameObject.transform:Find("Connect_platform/ios/btn2").gameObject:GetComponent(typeof(Button))
		self.c2_firstFbReward = self.btn_facebook.transform:Find("c2_firstFbReward").gameObject

		Runtime.Localize(self.gameObject:FindGameObject("title"), "ui_appleid_signin2")
		Runtime.Localize(self.gameObject:FindGameObject("descripe"), "ui_appleid_signin4")
		Runtime.Localize(self.gameObject:FindGameObject("Connect_platform/fb/btn2/Text"), "ui_appleid_signin3")
		Runtime.Localize(self.gameObject:FindGameObject("Connect_platform/fb/btn3/Text"), "ui_appleid_signin5")
		Runtime.Localize(self.gameObject:FindGameObject("Connect_platform/ios/btn2/Text"), "ui_appleid_signin1")
		Runtime.Localize(self.gameObject:FindGameObject("Connect_platform/ios/btn3/Text"), "ui_appleid_signin5")

		local function OnClick_btn_facebook(go)
            sendNotification(ChannelPanelNotificationEnum.Click_btn_facebook)
        end
	--insertDeclareBtn
        Util.UGUI_AddButtonListener(self.btn_facebook.gameObject, OnClick_btn_facebook)

		local function OnClick_btn_apple(go)
            sendNotification(ChannelPanelNotificationEnum.Click_btn_apple)
        end
	--insertDeclareBtn
        Util.UGUI_AddButtonListener(self.btn_apple.gameObject, OnClick_btn_apple)

		local function OnClick_btn_close(go)
            sendNotification(ChannelPanelNotificationEnum.Click_btn_panel)
        end
	--insertDeclareBtn
        Util.UGUI_AddButtonListener(self.btn_close.gameObject, OnClick_btn_close)

        local function OnClick_btn_panel(go)
            sendNotification(ChannelPanelNotificationEnum.Click_btn_panel)
        end
	--insertDeclareBtn
        Util.UGUI_AddButtonListener(self.btn_panel.gameObject, OnClick_btn_panel)
	end

end

--insertSetTxt

return _ChannelPanelBase
