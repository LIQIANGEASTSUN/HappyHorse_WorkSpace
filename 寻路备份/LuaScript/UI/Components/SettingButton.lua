require "UI.Components.HomeSceneTopIconBase"
---@class SettingButton:HomeSceneTopIconBase
local SettingButton = class(HomeSceneTopIconBase)

function SettingButton:Create()
    local gameObject = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_HOMESCENE_SETTINGBUTTON)
    return SettingButton:CreateWithGameObject(gameObject)
end

function SettingButton:CreateWithGameObject(gameObject)
    local instance = SettingButton.new()
    instance:InitWithGameObject(gameObject)
    return instance
end

function SettingButton:InitWithGameObject(gameObject)
    self.gameObject = gameObject
    self.newMsgGo = self.gameObject.transform:Find("img_new_msg")
    --self:ShowOrHideNewMsgFlag(App.HSSdk:GetHSMsgCount() > 0 and RuntimeContext.FAQ_ENABLE)
    self.Interactable = true
    local function OnClick_btn_add(go)
        self:OnClick()
    end
    Util.UGUI_AddButtonListener(self.gameObject, OnClick_btn_add)

    self:ShowReddot()
end

function SettingButton:OnClick()
    --PanelManager.closeTopPanel()
    if not self.Interactable then
        return
    end
    local widgetsMenu = App.scene:GetWidget(CONST.MAINUI.ICONS.HRWidgetsMenu)
    widgetsMenu:ResetToggle()
    if not App.globalFlags:CanClick() then return end
    App.globalFlags:SetClickFlag()
    PanelManager.showPanel(GlobalPanelEnum.SettingPanel)
    DcDelegates:Log(SDK_EVENT.mainUI_button, {buttonName = "setting"})
end

function SettingButton:SetStarNumber(value)
    self.text_number.text = tostring(value)
end

function SettingButton:SetInteractable(value)
    self.Interactable = value
end

function SettingButton:ShowOrHideNewMsgFlag(isShow)
    if self.newMsgGo  then
        self.newMsgGo:SetActive(isShow == true)
    end
end

function SettingButton:Unload()
    --App.HSSdk:UnregisterMsgCountCallback(self.HSSdkMsgHandler)
    --self.HSSdkMsgHandler = nil
end

--是否显示红点提示
function  SettingButton:ShowReddot()
    if not RuntimeContext.FAQ_ENABLE then
        return
    end
    local isShow =  AppServices.RedDotManage:GetRed("settingButton")
    self.newMsgGo:SetActive(isShow)
end

function SettingButton:InitRedDotInfo()

end

return SettingButton