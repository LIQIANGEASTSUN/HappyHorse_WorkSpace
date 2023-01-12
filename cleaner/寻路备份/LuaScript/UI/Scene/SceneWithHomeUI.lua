-- 按位标记
TopIconHideType = {
    stayHeartIcon = 1,
    stayDiamondIcon = 2,
    stayCoinIcon = 4,
    staySettingButton = 16,
    stayExpItem = 32,
    stayShakeIcon = 64,
    stayBagIcon = 128,
    -- 组合区
    stayStarCoinIcon = 12,
    stayDiamondCoinIcon = 6
}

local DiamondItem = require "UI.Components.DiamondItem"
local CoinItem = require "UI.Components.CoinItem"
local ExpItem = require "UI.Components.ExpItem"

local SuperCls = require "Game.Common.Scene"
---@class SceneWithHomeUI:Scene
local SceneWithHomeUI = class(SuperCls)

function SceneWithHomeUI:Awake()
    SuperCls.Awake(self)

    local AreaLayout = require "UI.Scene.AreaLayout"
    self.layout = AreaLayout:Create(self.canvas)

    self.flyPropsLayer = GameObject("FlyPropsLayer")
    self.flyPropsLayer:SetParent(self.canvas, false)
    local flyPropsRectTransform = self.flyPropsLayer:AddComponent(typeof(RectTransform))
    flyPropsRectTransform.anchorMin = Vector2.zero
    flyPropsRectTransform.anchorMax = Vector2.one
    flyPropsRectTransform.sizeDelta = Vector2.zero

    self:InitUI()
end

function SceneWithHomeUI:InitUI()
    if not self.canvas.transform:Find("CoinItem") then
       self.coinItem = CoinItem:Create()
       --self.coinItem.gameObject.transform:SetParent(self.canvas.transform, false)
       self.coinItem:SetParent(self.layout:Node())
       self:AddWidget(CONST.MAINUI.ICONS.CoinIcon, self.coinItem)
    end
    AppServices.UserCoinLogic:BindView(self.coinItem)
    if not self.canvas.transform:Find("DiamondItem") then
        self.diamondItem = DiamondItem:Create()
        self.diamondItem:SetParent(self.layout:Node(), false)
        self:AddWidget(CONST.MAINUI.ICONS.DiamondIcon, self.diamondItem)
    end
    AppServices.DiamondLogic:BindView(self.diamondItem)

    if not self.canvas.transform:Find("ExpItem") then
        self.expItem = ExpItem:Create()
        self.expItem:SetParent(self.layout:Node())
        self:AddWidget(CONST.MAINUI.ICONS.Experience, self.expItem)
     end
end

function SceneWithHomeUI:BeforeUnload()
    SuperCls.BeforeUnload(self)
    self.layout:BeforeUnload()
end

function SceneWithHomeUI:ShowAllTopIcons(instant, interactable)
end

function SceneWithHomeUI:HideAllTopIcons(instant, hideType)
    local eHideType = hideType or 0

    if eHideType & TopIconHideType.stayCoinIcon > 0 then
        self.coinItem:ShowEnterAnim()
        self.coinItem:SetInteractable(false)
    else
        self.coinItem:ShowExitAnim(instant)
    end

    if eHideType & TopIconHideType.stayDiamondIcon > 0 then
        self.diamondItem:ShowEnterAnim()
        self.diamondItem:SetInteractable(false)
    else
        self.diamondItem:ShowExitAnim(instant)
    end

    if eHideType & TopIconHideType.stayHeartIcon > 0 then
        self.heartItem:ShowEnterAnim()
        self.heartItem:SetInteractable(false)
    else
        self.heartItem:ShowExitAnim(instant)
    end
end

function SceneWithHomeUI:RefreshIcons()
    AppServices.UserCoinLogic:RefreshCoinNumber()
    AppServices.DiamondLogic:RefreshDiamondNumber()
end

--剧情加速按钮
function SceneWithHomeUI:GetSpeedUpButton()
    --[[屏蔽 2021年6月18日11:19:01 by 刘泽良 谢艳娇要求屏蔽
    if self.speedUpButton == nil then
        local go = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_HOMESCENE_SPEED_UP_BUTTON)
        go:SetParent(self.layout:Node(), false)
        local SpeedupButton = require("UI.ScreenPlays.UI.SpeedUpButton")
        self.speedUpButton = SpeedupButton:Create(go, AppServices.User.Default:GetKeyValue("dramaSpeed", 1))
        self.speedUpButton:Hide()
    end
    return self.speedUpButton
    --]]
end

return SceneWithHomeUI
