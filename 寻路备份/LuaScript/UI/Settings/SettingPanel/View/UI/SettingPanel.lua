local _SettingPanelBase = require "UI.Settings.SettingPanel.View.UI.Base._SettingPanelBase"
---@class SettingPanel:_SettingPanelBase
local SettingPanel = class(_SettingPanelBase)

function SettingPanel:onAfterBindView()
    self.soundGrayGO = self.btn_sound:FindGameObject("img_sound_gray")
    self.musicGrayGO = self.btn_music:FindGameObject("btn_music_grey")
    --self.newMsgGo = self.btn_contact:FindGameObject("icon_new_msg")
    --self.newMsgGo:SetActive(App.HSSdk:GetHSMsgCount() > 0)
    self.musicOn = App.audioManager:IsMusicEnable()
    self.soundOn = App.audioManager:IsEffectEnable()

    self.soundGrayGO:SetActive(not self.soundOn)
    self.musicGrayGO:SetActive(not self.musicOn)
    local diamondConfirm = AppServices.User.Default:GetKeyValue(UserDefaultKeys.KeyDiamondConfirm, false)
    self.go_diamond_mark:SetActive(diamondConfirm)
    local highQuality = AppServices.User.Default:GetHighQualityMode()
    self.go_quality_mark:SetActive(highQuality)
    self.btn_cdKey:SetActive(RuntimeContext.GIFT_CODE_ENABLE)

    Util.UGUI_AddButtonListener(
        self.btn_push,
        function()
            if not AppServices.Notification:IsNotificationOpen() then
                PanelManager.showPanel(GlobalPanelEnum.OpenNotificationPanel, {type = 5})
            else
                PanelManager.showPanel(GlobalPanelEnum.PushPanel)
            end
        end
    )

    self.btn_contact:SetActive(RuntimeContext.FAQ_ENABLE)
    self:RefreshRed()
end

function SettingPanel:refreshUI()
    self:RefreshButton()
end

function SettingPanel:RefreshRed()
    if RuntimeContext.FAQ_ENABLE then
        if not self.faqRed then
            self.faqRed = self.btn_contact:FindGameObject("icon_new_msg")
        end
        local isShow = AppServices.RedDotManage:GetRed("FAQ")
        self.faqRed:SetActive(isShow)
    end
end

function SettingPanel:ToggleSoundButton()
    self.soundOn = not self.soundOn
    self.soundGrayGO:SetActive(not self.soundOn)
    App.audioManager:SetEffectEnable(self.soundOn)
    AppServices.User.Default:SetKeyValue(UserDefaultKeys.KeySoundOn, self.soundOn, true)
    local status = self.soundOn and 1 or 0
    self.SoundBtnLog(1, status)
end

function SettingPanel:ToggleMusicButton()
    self.musicOn = not self.musicOn
    self.musicGrayGO:SetActive(not self.musicOn)
    App.audioManager:SetMusicEnable(self.musicOn)
    AppServices.User.Default:SetKeyValue(UserDefaultKeys.KeyMusicOn, self.musicOn, true)
    local LocalDevice = require "User.LocalDevice"
    LocalDevice:SetValue(LocalDevice.Enum.MUSICON, self.musicOn, true)
    local status = self.musicOn and 1 or 0
    self.SoundBtnLog(2, status)
end

function SettingPanel:ToggleDiamondConfirmButton()
    local diamondConfirm = not AppServices.User.Default:GetKeyValue(UserDefaultKeys.KeyDiamondConfirm, false)
    self.go_diamond_mark:SetActive(diamondConfirm)
    AppServices.User.Default:SetKeyValue(UserDefaultKeys.KeyDiamondConfirm, diamondConfirm, true)
end

function SettingPanel:ToggleQualityButton()
    local highQuality = not AppServices.User.Default:GetHighQualityMode()
    self.go_quality_mark:SetActive(highQuality)
    AppServices.User.Default:SetHighQualityMode(highQuality)
end

function SettingPanel:RefreshButton()
    if not self.ChannelBtn then
        self.ChannelBtn = require "Loading.View.UI.ChannelBtnItem"
        self.ChannelBtn:Create(self.gameObject, "btn_save", GlobalPanelEnum.SettingPanel)
        self.ChannelBtn.gameObject:SetActive(true)
        self.fbRed = self.ChannelBtn.gameObject:FindGameObject("img_reddot")
    end
end

function SettingPanel.SoundBtnLog(btnType, clickstatus)
    local params = {
        buttontype = btnType,
        clickstatus = clickstatus
    }
    DcDelegates:Log(SDK_EVENT.sound_button, params)
end

return SettingPanel
