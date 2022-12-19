---
--- Created by Betta.
--- DateTime: 2021/8/10 16:06
---
require "UI.Settings.UserInfo.UserInfoPanelNotificationEnum"
local UserInfoPanelProxy = require "UI.Settings.UserInfo.Model.UserInfoPanelProxy"
local UserInfoPanelMediator = MVCClass("UserInfoPanelMediator", BaseMediator)
---@type UserInfoPanel
local panel
local proxy

function UserInfoPanelMediator:ctor(...)
    UserInfoPanelMediator.super.ctor(self, ...)
    proxy = UserInfoPanelProxy.new()
end

function UserInfoPanelMediator:onRegister()
end

function UserInfoPanelMediator:onAfterSetViewComponent()
    panel = self:getViewComponent()
    panel:setProxy(proxy)
end

function UserInfoPanelMediator:onBeforeShowPanel()
    --在第一次显示之前，此时visible=false。
    panel:refreshUI()
    MessageDispatcher:AddMessageListener(MessageType.Switch_Avatar_Frame, panel.ChangeAvatarFrame, panel)
    MessageDispatcher:AddMessageListener(MessageType.Switch_Avatar, panel.ChangeAvatar, panel)
end

function UserInfoPanelMediator:onAfterShowPanel()
    if not panel.arguments.targetSkin and AppServices.SkinLogic:IsSkinPurchased("27303") and (App.mapGuideManager:GetCurrentGuide() ==nil or App.mapGuideManager:GetCurrentGuide().id ~= GuideConfigName.GuidePlayerHatSkin) then
        App.mapGuideManager:StartSeries(GuideConfigName.GuidePlayerHatSkin)
    end
    AppServices.EventDispatcher:dispatchEvent(GlobalEvents.SWITCH_SCENECAMERA, {switchOn = false})
end
function UserInfoPanelMediator:onBeforeHidePanel()
	AppServices.EventDispatcher:dispatchEvent(GlobalEvents.SWITCH_SCENECAMERA, {switchOn = true})
end

function UserInfoPanelMediator:onAfterReshowPanel(lastPanelVO)
    --在被重新显示之后(FadeIn完成后)，此时visible=true。
    panel:refreshUI()
end

function UserInfoPanelMediator:listNotificationInterests()
    return {
        --insertNotificationNames
        UserInfoPanelNotificationEnum.Click_btn_edit,
        UserInfoPanelNotificationEnum.Click_btn_changeHead,
        UserInfoPanelNotificationEnum.Click_btn_close,
        UserInfoPanelNotificationEnum.RefreshSkinReddot,
        UserInfoPanelNotificationEnum.ChangePart,
        CONST.GLOBAL_NOFITY.USER_UID_CHANGED,
        "MainCityNotificationEnum_RefreshRedDot",
    }
end

function UserInfoPanelMediator:handleNotification(notification)
    local name = notification:getName()
    -- local type = notification:getType()
    local body = notification:getBody() --message data
    --insertHandleNotificationNames
    if (name == "") then
    elseif (name == UserInfoPanelNotificationEnum.Click_btn_edit) then
        PanelManager.showPanel(GlobalPanelEnum.TownNamePanel,{callback = function ()
            panel.text_name.text = AppServices.User:GetNickName()
        end})
    elseif name == UserInfoPanelNotificationEnum.Click_btn_changeHead then
        --打开修改头像的面板
        PanelManager.showPanel(GlobalPanelEnum.ModifyHeadImagePanel)
        --[[
        if panel.hasReddot then
            AppServices.User.Default:SetKeyValue("AvatarReddot", false,true)
            sendNotification(MainCityNotificationEnum.RefreshRedDot, CONST.MAINUI.ICONS.HeadInfoView)
            panel:RefreshRedDot()
        end
        ]]
    elseif (name == CONST.GLOBAL_NOFITY.USER_UID_CHANGED) then
        self:getViewComponent():SetUserId(tostring(body.uid))
    elseif (name == UserInfoPanelNotificationEnum.Click_btn_close) then
        --关闭界面前如果切换了可用皮肤则发送请求然后再关闭界面
        local characters = panel:GetCharacters()
        panel:RequestChangeSkin(function()
            for _, character in pairs(characters) do
                character:Destory()
            end
            self:closePanel()
        end)
    elseif name == UserInfoPanelNotificationEnum.RefreshSkinReddot then
        panel:RefreshSkinReddot(body)
    elseif name == "MainCityNotificationEnum_RefreshRedDot" then
        panel:RefreshRedDot()
    elseif name == UserInfoPanelNotificationEnum.ChangePart then
        panel:ChangePart(body)
    end
end

function UserInfoPanelMediator:onAfterDestroyPanel()
    App:RemoveAppOnPauseCallback(panel.OnAppPause)
    panel:OnRelease()
    MessageDispatcher:RemoveMessageListener(MessageType.Switch_Avatar_Frame, panel.ChangeAvatarFrame, panel)
    MessageDispatcher:RemoveMessageListener(MessageType.Switch_Avatar, panel.ChangeAvatar, panel)
end

return UserInfoPanelMediator
