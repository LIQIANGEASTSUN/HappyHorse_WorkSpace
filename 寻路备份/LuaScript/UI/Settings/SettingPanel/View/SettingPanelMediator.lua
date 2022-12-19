require "UI.Settings.SettingPanel.SettingPanelNotificationEnum"
local SettingPanelProxy = require "UI.Settings.SettingPanel.Model.SettingPanelProxy"
---@class SettingPanelMediator
local SettingPanelMediator = MVCClass("SettingPanelMediator", BaseMediator)
---@type SettingPanel
local panel
local proxy

function SettingPanelMediator:ctor(...)
    SettingPanelMediator.super.ctor(self, ...)
    proxy = SettingPanelProxy.new()
end

function SettingPanelMediator:onRegister()
end

function SettingPanelMediator:onAfterSetViewComponent()
    panel = self:getViewComponent()
    panel:setProxy(proxy)
end

function SettingPanelMediator:listNotificationInterests()
    return {
        --insertNotificationNames
        SettingPanelNotificationEnum.Click_btn_music,
        SettingPanelNotificationEnum.Click_btn_sound,
        SettingPanelNotificationEnum.Click_btn_lang,
        SettingPanelNotificationEnum.Click_btn_close,
        SettingPanelNotificationEnum.Click_btn_contact,
        SettingPanelNotificationEnum.Click_btn_aboutus,
        SettingPanelNotificationEnum.Click_btn_diamond,
        SettingPanelNotificationEnum.Click_btn_quality,
        SettingPanelNotificationEnum.Click_btn_delete,
        SettingPanelNotificationEnum.Click_btn_cdKey,

        CONST.GLOBAL_NOFITY.IngameLogin_Result,
        "LoginScenePanelNotificationEnum_Refresh_FAQ_RED",
    }
end

function SettingPanelMediator:handleNotification(notification)
    local name = notification:getName()
    --local type = notification:getType()
    local body = notification:getBody() --message data
    --insertHandleNotificationNames
    if (name == "") then
    elseif (name == SettingPanelNotificationEnum.Click_btn_music) then
        self:getViewComponent():ToggleMusicButton()
    elseif (name == SettingPanelNotificationEnum.Click_btn_sound) then
        self:getViewComponent():ToggleSoundButton()
    elseif (name == SettingPanelNotificationEnum.Click_btn_lang) then
        if self.isInAnim then
            return
        end
        PanelManager.closeTopPanel()
        PanelManager.showPanel(GlobalPanelEnum.ChooseLanguagePanel)
    elseif (name == SettingPanelNotificationEnum.Click_btn_close) then
        if self.isInAnim then
            return
        end
        PanelManager.closeTopPanel()
        if self.appPauseCallback then
            App:RemoveAppOnPauseCallback(self.appPauseCallback)
        end
    elseif (name == SettingPanelNotificationEnum.Click_btn_contact) then
        App.FAQ:ShowFAQ()
        DcDelegates:Log(SDK_EVENT.click_help)
    --监听游戏内绑定账号结果
    elseif (name == CONST.GLOBAL_NOFITY.IngameLogin_Result) then
        if body.channel == "facebook" and body.result then
            if App.loginLogic.PlayerInfo.fbBind then --首次绑定FB刷新头像
                AppServices.Avatar:SetAvatar(CONST.GAME.HEADIMAGE_FACEBOOK_AVATAR_NUM)
            end
            DcDelegates:Log("fb_connect")
            --刷新绑定按钮的红点
            panel:RefreshButton()
        end
    elseif (name == SettingPanelNotificationEnum.Click_btn_aboutus) then
        PanelManager.showPanel(GlobalPanelEnum.AboutUsPanel)
    elseif (name == SettingPanelNotificationEnum.Click_btn_diamond) then
        panel:ToggleDiamondConfirmButton()
    elseif (name == SettingPanelNotificationEnum.Click_btn_quality) then
        panel:ToggleQualityButton()
    elseif name == SettingPanelNotificationEnum.Click_btn_delete then
        PanelManager.closePanel(panel.panelVO)
        PanelManager.showPanel(GlobalPanelEnum.DeleteAccountPanel)
    elseif name == "LoginScenePanelNotificationEnum_Refresh_FAQ_RED" then
        panel:RefreshRed()
    elseif name == SettingPanelNotificationEnum.Click_btn_cdKey then
        PanelManager.showPanel(GlobalPanelEnum.GiftCodePanel)
    end
end

-- function SettingPanelMediator:onBeforeLoadAssets()
--  -- 在资源即在之前，用于进行服务器请求或额外的资源加载。
-- 	-- Send Request To Server
-- 	local extraAssetsNeedLoad = {}
-- 	table.insert(extraAssetsNeedLoad, "extraAssetName")
-- 	self:loadAssetsAndInitPanel(extraAssetsNeedLoad)
-- end

-- function SettingPanelMediator:onLoadAssetsFinish()
-- 	--资源加载完成，在BindView之前。
-- end

function SettingPanelMediator:onBeforeShowPanel()
    --在第一次显示之前，此时visible=false。
    panel:refreshUI()
end

function SettingPanelMediator:onAfterShowPanel()
    --在第一次显示之后，此时visible=true。
    DcDelegates:Log(SDK_EVENT.ShowSettingPanel)
    sendNotification(MainCityNotificationEnum.RefreshRedDot, "settingButton")
end

function SettingPanelMediator:onBeforeHidePanel()
    --在被隐藏之前(FadeOut开始前)，此时visible=true。
    -- AppServices.EventDispatcher:dispatchEvent(GlobalEvents.SWITCH_SCENECAMERA, {switchOn = true})
end

function SettingPanelMediator:onAfterReshowPanel(lastPanelVO)
    --在被重新显示之后(FadeIn完成后)，此时visible=true。
    panel:refreshUI()
end

--function SettingPanelMediator:onBeforeDestroyPanel()
    --在被销毁之前，此时visible=false。
 --   panel:onBeforeDestroy()
--end
return SettingPanelMediator
