---
--- Created by Betta.
--- DateTime: 2021/8/10 16:08
---

local btnKeys = {
    [1] = "ui_profile_all",
    [2] = "ui_profile_cynthia",
    [3] = "ui_profile_nino",
}

---@class _UserInfoPanelBase:BasePanel
local _UserInfoPanelBase = class(BasePanel)

function _UserInfoPanelBase:ctor()

end

function _UserInfoPanelBase:setProxy(proxy)
    self.proxy = proxy
    --setProxy
end

function _UserInfoPanelBase:bindView()
    self.left = find_component(self.gameObject, "left")
    self.btn_edit = self.left:FindGameObject("townName/btn_edit")
    self.text_name = self.left:FindComponentInChildren("townName/txt_username", typeof(Text))
    self.go_avatar = self.left:FindGameObject("go_avatar")
    self.img_avatar = self.go_avatar:FindComponentInChildren("img_avatar", typeof(Image))
    self.img_avatarFB = self.go_avatar:FindComponentInChildren("img_avatarRaw", typeof(CS.FaceBookAvatar))
    self.frame_bg = self.go_avatar:FindComponentInChildren("img_board", typeof(Image))
    self.avatar_frame = self.go_avatar:FindComponentInChildren("img_avatarFrame", typeof(Image))
    self.btn_changeHead = self.go_avatar:FindGameObject("btn_modifyHead")
    self.txt_id = self.left:FindComponentInChildren("userID/txt_id", typeof(Text))
    self.btn_copy = self.left:FindGameObject("userID/btn_copy")
    self.lv_user = self.left:FindComponentInChildren("level/num", typeof(Text))
    self.num_diamond = self.left:FindComponentInChildren("diamond/num", typeof(Text))
    self.lv_user.text = AppServices.User:GetCurrentLevelId()
    self.num_diamond.text = AppServices.User:GetItemAmount(ItemId.DIAMOND)
    self.reddot = self.go_avatar:FindGameObject("reddot")

    self.right = find_component(self.gameObject, "right")
    self.skins = find_component(self.right, "skinsList")
    self.skin_ScrollRect = find_component(self.skins, "scrollView", ScrollListRenderer)

    self.btn_close = self.right:FindGameObject("btn_close")
    self.prefab_tog = find_component(self.right, "tog")
    self.title_model = find_component(self.right, "title_model", Text)
    self.btn_get = find_component(self.right, "btn_get")
    self.txt_desc = find_component(self.right, "txt_desc", Text)
    self.prefab_tog:SetActive(false)
    self.togGroup = find_component(self.right, "togGroup", Transform)
    self.toggles = {}
    self.toggleReddot = {}
    for i = 1, 3 do
        local tog = BResource.InstantiateFromGO(self.prefab_tog):GetComponent(typeof(Toggle))
        local txt_btn = find_component(tog.gameObject, "Text", Text)
        txt_btn.text = Runtime.Translate(btnKeys[i])
        tog:SetParent(self.togGroup, false)
        tog:SetActive(true)

        local reddotName
        if i == 2 then
            reddotName = "newRoleSkin"
            self.toggleReddot[reddotName] = tog.gameObject:FindGameObject("reddot")
        elseif i == 3 then
            reddotName = "newPetSkin"
            self.toggleReddot[reddotName] = tog.gameObject:FindGameObject("reddot")
        end
        self:RefreshSkinReddot(reddotName)

        local function onValueChange(active)
            if active then
                self:SwitchState(i)
                App.mapGuideManager:OnGuideFinishEvent(GuideEvent.TargetButtonClicked, tog.gameObject)
            end
        end
        tog.onValueChanged:AddListener(onValueChange)
        self.toggles[i] = tog
    end

    self.rawView = find_component(self.right, "raw", RawImage)
    self.camera = find_component(self.rawView, "cam_model", Camera)
    self.dragMask = find_component(self.rawView, "drag_mask")

    Runtime.Localize(self.left:FindGameObject("townName/label_username"), "ui.town_name_panel.title")
    Runtime.Localize(self.go_avatar:FindGameObject("btn_modifyHead/text_modifyHead"), "ui_settings_avatar")
    Runtime.Localize(self.left:FindGameObject("userID/label_id"), "ui_settings_id")
    Runtime.Localize(self.btn_get:FindGameObject("Text"), "ui_profile_get")

    local function OnClick_btn_edit(go)
        sendNotification(UserInfoPanelNotificationEnum.Click_btn_edit)
    end

    local function OnClick_btn_changeHead(go)
        sendNotification(UserInfoPanelNotificationEnum.Click_btn_changeHead)
    end

    local function OnClick__btn_close(go)
        sendNotification(UserInfoPanelNotificationEnum.Click_btn_close)
    end

    local function OnClick_btn_copy(go)
        local uid = AppServices.User:GetUid()
        if uid == RuntimeContext.DEVICE_ID then
            uid = ""
        end
        UITool.ShowContentTipAni(Runtime.Translate("Copied.Tips"), self.btn_copy.gameObject.transform.position + Vector3(0, 0.49, 0))
        CS.UnityEngine.GUIUtility.systemCopyBuffer = uid
    end

    Util.UGUI_AddButtonListener(self.btn_edit, OnClick_btn_edit)
    Util.UGUI_AddButtonListener(self.go_avatar, OnClick_btn_changeHead)
    Util.UGUI_AddButtonListener(self.btn_close, OnClick__btn_close)
    Util.UGUI_AddButtonListener(self.btn_copy, OnClick_btn_copy)
    Util.UGUI_AddButtonListener(self.btn_get, function()
        local skinId = self:GetUserChosenSkinId(self.curUser)
        local skinMeta = AppServices.SkinLogic:GetSkinMeta(skinId)
        if skinMeta then
            if skinMeta.getWay == 1 then
                --TODO 去获得
                local isOver = ActivityServices.GoldPass:IsOver()
                if isOver then
                    UITool.ShowContentTipAni(Runtime.Translate("Activity.Finishied.Tips"), self.btn_get.gameObject.transform.position + Vector3(0, 0.49, 0))
                    return
                end
                local isGoldPass = ActivityServices.GoldPass:IsUnlockPass()

                sendNotification(UserInfoPanelNotificationEnum.Click_btn_close)
                if not isGoldPass then
                    if self.arguments and self.arguments.closeCallback then
                        self.arguments.closeCallback = nil
                    end
                    local skinId = self:GetUserChosenSkinId(self.curUser)
                    AppServices.Jump.GoldPassActivatePanel(GoldPassRewardKind.Skin, function(closeByBtn)
                        if closeByBtn then
                            PanelManager.showPanel(GlobalPanelEnum.UserInfoPanel, {targetSkin = tostring(skinId)})
                        end
                    end)
                    return
                end
                if not self.arguments or not self.arguments.closeCallback then
                    AppServices.Jump.GoldPassSpecialReward(GoldPassRewardKind.Skin)
                end
            elseif skinMeta.getWay == 2 then
                local giftIns = AppServices.GiftManager:GetGiftInstance(skinMeta.getWayParam)
                if giftIns then
                    sendNotification(UserInfoPanelNotificationEnum.Click_btn_close)
                    AppServices.GiftManager:_OpenUI(giftIns)
                end
            end
        end
    end)

    ------------------------新增------------
    local RoleSkinParts = require("UI.Settings.UserInfo.View.RoleSkinParts")
    ---@type RoleSkinParts
    local skinParts = RoleSkinParts.Create(self.gameObject, Vector2(-146, 0))
    local skinId
    local skinType
    if self.arguments and self.arguments.showArrowSkin then
        skinId = self.arguments.showArrowSkin
        skinType = AppServices.SkinLogic:GetSkinMeta(skinId).type
    end
    skinParts:Init(skinType, skinId)
    skinParts:Hide()
    ---@type RoleSkinParts
    self.skinParts = skinParts
end

return _UserInfoPanelBase