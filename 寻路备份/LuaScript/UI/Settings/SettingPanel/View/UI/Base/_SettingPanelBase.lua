--insertRequire
---@class _SettingPanelBase:BasePanel
local _SettingPanelBase = class(BasePanel)

function _SettingPanelBase:ctor()
    self.gameObject = nil
    self.proxy = nil
    --insertCtor
    self.btn_music = nil
    self.onClick_btn_music = nil
    self.btn_sound = nil
    self.onClick_btn_sound = nil
    self.btn_privacy = nil
    self.onClick_btn_privacy = nil
    self.btn_terms = nil
    self.onClick_btn_terms = nil
    self.btn_lang = nil
    self.onClick_btn_lang = nil
    self.btn_close = nil
    self.onClick_btn_close = nil
end

function _SettingPanelBase:setProxy(proxy)
    self.proxy = proxy
    --setProxy
end

function _SettingPanelBase:bindView()
    if (self.gameObject ~= nil) then
        --insertInit
        self.btn_music = self.gameObject:FindComponentInChildren("btn_music", typeof(NS.ButtonComponent))
        self.btn_sound = self.gameObject:FindComponentInChildren("btn_sound", typeof(NS.ButtonComponent))
        self.btn_lang = self.gameObject:FindGameObject("btn_lang")
        self.btn_close = self.gameObject:FindGameObject("btn_close")
        local layout = self.gameObject:FindGameObject("layout")
        self.btn_contact = layout:FindGameObject("btn_contact")
        self.btn_push = layout:FindGameObject("btn_push")
        self.btn_aboutUs = layout:FindGameObject("btn_about")
        self.btn_ios_disconnect = self.gameObject:FindGameObject("old/btn_ios")
        self.image_fbReddot = self.btn_ios_disconnect:FindGameObject("image_fbReddot")
        self.btn_diamond = self.gameObject:FindComponentInChildren("btn_diamond", typeof(Button))
        self.go_diamond_mark = self.btn_diamond:FindGameObject("go_diamond_mark")
        self.text_diamond = self.btn_diamond:FindComponentInChildren("text_diamond", typeof(Text))
        self.btn_quality = self.gameObject:FindComponentInChildren("btn_quality", typeof(Button))
        self.go_quality_mark = self.btn_quality:FindGameObject("go_quality_mark")
        self.text_quality = self.btn_quality:FindComponentInChildren("text_quality", typeof(Text))
        self.btn_delete = self.gameObject:FindGameObject("btn_delete")
        self.btn_cdKey = self.gameObject:FindGameObject("btn_cdKey")
        --text
        Runtime.Localize(self.gameObject:FindGameObject("title"), "ui_settings")
        Runtime.Localize(self.btn_contact:FindGameObject("Text"), "ui_settings_help")
        Runtime.Localize(self.btn_push:FindGameObject("Text"), "ui.push_title")
        Runtime.Localize(self.btn_ios_disconnect:FindGameObject("Text"), "ui_login_apple_config_title")
        Runtime.Localize(self.text_diamond, "ui_settings_diamondconfirm")
        Runtime.Localize(self.text_quality, "ui_settings_hightquality")
        Runtime.Localize(self.btn_delete:FindGameObject("text_delete"), "UI_Accountcancel_title_button")
        local function OnClick_btn_music(go)
            sendNotification(SettingPanelNotificationEnum.Click_btn_music)
        end

        local function OnClick_btn_sound(go)
            sendNotification(SettingPanelNotificationEnum.Click_btn_sound)
        end

        local function OnClick_btn_lang(go)
            local isSpecialCheck = CS.Bridge.Core.IsOpen("SpecialCheck")
            if (isSpecialCheck) then
                return
            end
            sendNotification(SettingPanelNotificationEnum.Click_btn_lang)
        end

        local function OnClick_btn_close(go)
            sendNotification(SettingPanelNotificationEnum.Click_btn_close)
        end

        local function OnClick_btn_contact(go)
            sendNotification(SettingPanelNotificationEnum.Click_btn_contact)
        end

        local function OnClick_btn_aboutUs(go)
            sendNotification(SettingPanelNotificationEnum.Click_btn_aboutus)
        end

        local function OnClick_btn_showConnectPanel(go)
            sendNotification(SettingPanelNotificationEnum.Click_btn_showConnectPanel)
        end

        local function OnClick_btn_diamond(go)
            sendNotification(SettingPanelNotificationEnum.Click_btn_diamond)
        end

        local function OnClick_btn_quality(go)
            sendNotification(SettingPanelNotificationEnum.Click_btn_quality)
        end

        local function OnClick_btn_delete()
            sendNotification(SettingPanelNotificationEnum.Click_btn_delete)
        end

        local function OnClick_btn_cdKey()
            sendNotification(SettingPanelNotificationEnum.Click_btn_cdKey)
        end

        --insertDeclareBtn
        Util.UGUI_AddButtonListener(self.btn_music, OnClick_btn_music)
        Util.UGUI_AddButtonListener(self.btn_sound, OnClick_btn_sound)
        Util.UGUI_AddButtonListener(self.btn_lang, OnClick_btn_lang)
        Util.UGUI_AddButtonListener(self.btn_close, OnClick_btn_close)
        Util.UGUI_AddButtonListener(self.btn_contact, OnClick_btn_contact)
        Util.UGUI_AddButtonListener(self.btn_aboutUs, OnClick_btn_aboutUs)
        Util.UGUI_AddButtonListener(self.btn_cdKey, OnClick_btn_cdKey)

        Util.UGUI_AddButtonListener(self.btn_ios_disconnect, OnClick_btn_showConnectPanel)
        Util.UGUI_AddButtonListener(self.btn_diamond, OnClick_btn_diamond)
        Util.UGUI_AddButtonListener(self.btn_delete, OnClick_btn_delete)
        Util.UGUI_AddButtonListener(self.btn_quality, OnClick_btn_quality)

        self.btn_delete:SetActive(not RuntimeContext.UNITY_ANDROID)
    --DcDelegates:HandleEvent(SDK_EVENT.gift_code_ui, {gameObject = self.gameObject})
    end
end

return _SettingPanelBase
