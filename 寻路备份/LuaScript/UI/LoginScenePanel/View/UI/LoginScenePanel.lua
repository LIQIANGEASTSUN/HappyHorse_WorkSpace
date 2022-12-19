--insertWidgetsBegin
--    btn_TestLogin    btn_Confirm    btn_ChannelLogin    btn_FAQ
--insertWidgetsEnd

--insertRequire
local _LoginScenePanelBase = require "UI.LoginScenePanel.View.UI.Base._LoginScenePanelBase"

---@class LoginScenePanel:_LoginScenePanelBase
local LoginScenePanel = class(_LoginScenePanelBase)

function LoginScenePanel:ctor()

end

function LoginScenePanel:onAfterBindView()
    local function InitTestButton()
        if not RuntimeContext.FEATURES_USER_DEFINED_ACCOUNT then
            return
        end
        if self.TestBtn then
            return
        end
        self.TestBtn = require "Loading.View.UI.LoginTestItem"
        self.TestBtn:Create(self.gameObject,"btn_TestLogin")
    end

    local function InitChannelButton()
        if self.ChannelBtn then
            return
        end
        self.ChannelBtn = require "Loading.View.UI.ChannelBtnItem"
        self.ChannelBtn:Create(self.gameObject,"btn_ChannelLogin", GlobalPanelEnum.LoginScenePanel)
    end

    InitTestButton()
    InitChannelButton()
    --检查权限（临时，应该放loginlogic里的）
    --权限访问(之后再改成弹界面)
    local PrivacyLogic = require("Loading.Logics.PrivacyLogic")
    PrivacyLogic:Start(self.gameObject)

    App.FAQ = require("System.FAQ.FAQSDK")
    App.FAQ:Init()
end

function LoginScenePanel:refreshUI()
     self:ShowChannelButton(true)
     self.btn_Confirm:SetActive(true)
     self.btn_FAQ:SetActive(App.FAQ.isInit)
     self:ShowTestlButton(true)
     self:refreshNameInput()
end

function LoginScenePanel:refreshFAQRed()
    if RuntimeContext.FAQ_ENABLE then
        local reddot = self.gameObject.transform:Find("btn_FAQ/button/reddot")
        local hasRed = AppServices.RedDotManage:GetRed("FAQ")
        reddot:SetActive(hasRed)
    end
end

function LoginScenePanel:refreshNameInput()
    local PlayerPrefs = CS.UnityEngine.PlayerPrefs
    local key = "LoginUserName"

    local userName = ""
    if not PlayerPrefs.HasKey(key) then
        for i = 1, 6 do
            local value = math.random(1, 10000) % 10
            userName = userName..value
        end
        PlayerPrefs.SetString(key, userName)
    end
    userName = PlayerPrefs.GetString(key)
    self.name_InputField.text = userName

    self:SaveUserName()
end

function LoginScenePanel:GetUserName()
    local userName = self.name_InputField.text
    return userName
end

function LoginScenePanel:SaveUserName()
    local key = "LoginUserName"
    local userName = self.name_InputField.text
    local PlayerPrefs = CS.UnityEngine.PlayerPrefs
    PlayerPrefs.SetString(key, userName)
end

function LoginScenePanel:ShowChannelButton(defalutValue)
    if not self.ChannelBtn then
        return
    end
    local value = defalutValue and  (not App.loginLogic:CheckChannelAllBind(AppServices.AccountData:GetLastAccountType()))
    self.ChannelBtn.gameObject:SetActive(value)
end

function LoginScenePanel:ShowTestlButton(value)
    if not self.TestBtn then
        return
    end
    self.TestBtn.gameObject:SetActive(value)
end

function LoginScenePanel:HideAll()
    self.btn_Confirm:SetActive(false)
    self.btn_FAQ:SetActive(false)
    self.name_InputField.gameObject:SetActive(false)

    if self.ChannelBtn then
        self.ChannelBtn:Hide()
    end

    if self.TestBtn then
        self.TestBtn:Hide()
    end

    self:SaveUserName()
end

return LoginScenePanel
