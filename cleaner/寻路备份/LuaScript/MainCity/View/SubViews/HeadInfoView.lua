local SuperCls = require "UI.Components.HomeSceneTopIconBase"

local HeadInfoView = class(SuperCls)
function HeadInfoView:Create(layout)
    local go = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_HOMESCENE_HEADINFO_VIEW)
    go.transform:SetParent(layout.transform, false)

    local instance = HeadInfoView.new()
    instance:InitWithGameObject(go)

    return instance
end

function HeadInfoView:InitWithGameObject(go, callback)
    self.gameObject = go
    self.transform = go.transform
    self.callback = callback

    SuperCls.SetParent(self, go.transform)

    -- lbName
    self.lbName = go:FindComponentInChildren("lbName", typeof(Text))
    self.lbName.text = AppServices.User:GetNickName()
    AppServices.EventDispatcher:addObserver(
        self,
        GlobalEvents.MODIFY_NAME,
        function(param)
            self.lbName.text = AppServices.User:GetNickName()
        end
    )

    -- HeadItem
    local headItem = go:FindGameObject("HeadItem")
    Util.UGUI_AddButtonListener(
        headItem,
        function()
            self.exitBySelf = true
            PanelManager.showPanel(GlobalPanelEnum.UserInfoPanel)
        end
    )

    -- HeadImage
    self.headIcon = self.transform:Find("HeadItem/iconGame"):GetComponent(typeof(Image))
    self.headIconFB = self.transform:Find("HeadItem/iconFB"):GetComponent(typeof(CS.FaceBookAvatar))
    self:ChangeAvatar()
    -- AvatarFrame
    self.avatar_frame = find_component(headItem, "img_avatarFrame", Image)
    self.frame_bg = find_component(headItem, "bg", Image)
    self:ChangeAvatarFrame()
    local headController = {
        GetMainIconGameObject = function()
            return headItem
        end,
        SetTimeout = function(_self, key, _callback, delay)
            Runtime.InvokeCbk(_callback)
        end
    }
    self.headReddot = self.transform:Find("HeadItem/reddot")
    self:HandleRedDot()
    App.scene:AddWidget(CONST.MAINUI.ICONS.Head, headController)

    -- HeartItem
    local HeartItemInPanel = require("MainCity.View.SubViews.Components.HeartItemInPanel")
    self.heartItem = HeartItemInPanel:CreateWithGameObject(self.gameObject:FindGameObject("HeartItem"))
    self.heartItem:SetParent(self.transform, false)

    local HeartItemController = require("MainCity.View.SubViews/Controller/HeartItemController")
    local controller = HeartItemController.new()
    controller:AddView(self.heartItem)
    controller:AddView(App.scene.heartItem)
    App.scene:AddWidget(CONST.MAINUI.ICONS.EnergyIcon, controller)

    -- DiamondItem
    local DiamondItemInPanel = require("MainCity.View.SubViews.Components.DiamondItemInPanel")
    self.diamondItem = DiamondItemInPanel:CreateWithGameObject(self.gameObject:FindGameObject("DiamondItem"))
    self.diamondItem:SetParent(self.transform, false)
    local DiamondItemController = require("MainCity.View.SubViews/Controller/DiamondItemController")

    controller = DiamondItemController.new()
    controller:AddView(self.diamondItem)
    controller:AddView(App.scene.diamondItem)
    AppServices.DiamondLogic:BindView(controller)
    App.scene:AddWidget(CONST.MAINUI.ICONS.DiamondIcon, controller)

    -- 繁荣度暂时当等级使用
    local ExpItemItemInPanel = require("MainCity.View.SubViews.Components.ExpItemItemInPanel")
    self.expItem = ExpItemItemInPanel:CreateWithGameObject(self.gameObject:FindGameObject("ExpItem"))
    self.expItem:SetParent(self.transform, false)

    local ExpItemController = require("MainCity.View.SubViews/Controller/ExpItemController")
    controller = ExpItemController.new()
    controller:AddView(self.expItem)
    controller:AddView(App.scene.expItem)
    App.scene:AddWidget(CONST.MAINUI.ICONS.Experience, controller)

    --coinItem
    local CoinItemInPanel = require("MainCity.View.SubViews.Components.CoinItemInPanel")
    self.coinItem = CoinItemInPanel:CreateWithGameObject(self.gameObject:FindGameObject("CoinItem"))
    self.coinItem:SetParent(self.transform, false)
    local CoinItemController = require("MainCity.View.SubViews/Controller/CoinItemController")

    controller = CoinItemController.new()
    controller:AddView(self.coinItem)
    controller:AddView(App.scene.coinItem)
    AppServices.UserCoinLogic:BindView(controller)
    AppServices.LuckyTurntable:BindView(self.coinItem)
    --AppServices.MonCard:BindView(self.diamondItem)
    App.scene:AddWidget(CONST.MAINUI.ICONS.CoinIcon, controller)
    MessageDispatcher:AddMessageListener(MessageType.Switch_Avatar_Frame, self.ChangeAvatarFrame, self)
    MessageDispatcher:AddMessageListener(MessageType.Switch_Avatar, self.ChangeAvatar, self)


    if AppServices.SkinLogic:IsSkinPurchased("27303") and not App.mapGuideManager:HasComplete(GuideConfigName.GuidePlayerHatSkin) then
        WaitExtension.SetTimeout(function()
            PopupManager:CallWhenIdle(function()
                App.mapGuideManager:StartSeries(GuideConfigName.GuidePlayerHatSkin, {target = headItem,parent = self.gameObject})
            end)
        end, 1)
    end
end

function HeadInfoView:ShowEnterAnim(instant, finishCallback)
    --self.heartItem:SetActive(true)
    --self.diamondItem:SetActive(true)
    self.heartItem:SetValue()
    self.diamondItem:Refresh()
    self.expItem:Refresh()
    self.coinItem:Refresh()
    SuperCls.ShowEnterAnim(self, instant, finishCallback)
    if AppServices.SkinLogic:IsSkinPurchased("27303") then
        WaitExtension.SetTimeout(function()
            PopupManager:CallWhenIdle(function()
                App.mapGuideManager:StartSeries(GuideConfigName.GuidePlayerHatSkin, {target = App.scene:GetWidget(CONST.MAINUI.ICONS.Head).GetMainIconGameObject(),parent = self.gameObject})
            end)
        end, 1)
    end
end

function HeadInfoView:ShowExitAnim(instant, finishCallback)
    self.heartItem.buyFull:Hide()
    self.heartItem:StopNeedTimer()
    self.heartItem.buyNeed:Hide()
    SuperCls.ShowExitAnim(self, instant, finishCallback)
    if not self.exitBySelf and App.mapGuideManager:HasRunningGuide(GuideConfigName.GuidePlayerHatSkin) then
        App.mapGuideManager:BreakGuide()
    end
    self.exitBySelf = false
end

function HeadInfoView:RefreshItems()
    self.heartItem:SetValue()
    self.diamondItem:Refresh()
    self.expItem:Refresh()
    self.coinItem:Refresh()
end

function HeadInfoView:ChangeAvatarFrame()
    AppServices.AvatarFrame:SetAvatarFrame(self.avatar_frame, self.frame_bg, true)
end

function HeadInfoView:ChangeAvatar()
    AppServices.Avatar:ShowAvatar(self.headIcon, self.headIconFB)
end

function HeadInfoView:Dispose()
    AppServices.EventDispatcher:removeObserver(self, GlobalEvents.MODIFY_NAME)
    MessageDispatcher:RemoveMessageListener(MessageType.Switch_Avatar_Frame, self.ChangeAvatarFrame, self)
    MessageDispatcher:RemoveMessageListener(MessageType.Switch_Avatar, self.ChangeAvatar, self)
    self.heartItem:Dispose()
    AppServices.LuckyTurntable:UnBindView()
end

function HeadInfoView:HandleRedDot()
    local hasDot = AppServices.RedDotManage:GetRed("UserInfo")
    self.headReddot:SetActive(hasDot)
end

return HeadInfoView
