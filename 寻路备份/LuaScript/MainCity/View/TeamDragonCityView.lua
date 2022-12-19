local TeamDragonCitiyView = {}

---@param rootView MainCity
function TeamDragonCitiyView:Create(rootView)
    self.rootView = rootView
    self.layout = rootView.layout
    local bottomLeft = self.layout:BottomLeft()
    local topLeft = self.layout:TopLeft()
    local bottomRight = self.layout:BottomRight()
    local left = self.layout:LeftLayout()

    local HeadInfoView = require("MainCity.View.SubViews.HeadInfoView")
    local headInfoView = HeadInfoView:Create(self.layout:Node())
    rootView:AddWidget(CONST.MAINUI.ICONS.HeadInfoView, headInfoView)

    local HRWidgetsMenu = require("MainCity.View.SubViews.HRWidgetsMenu")
    local widgetsMenu = HRWidgetsMenu:Create(self.layout:WidgetsNode())
    rootView:AddWidget(CONST.MAINUI.ICONS.HRWidgetsMenu, widgetsMenu)
    self:ShowHeadInfoPanel(true)

    local settingButton = require "UI.Components.SettingButton":Create()
    widgetsMenu:AddRHButton(CONST.MAINUI.ICONS.SettingButton, settingButton)

    if not RuntimeContext.DISABLE_MAIL_SYSTEM then
        local MailButton = require "Game.System.Mail.UI.Components.MailButton"
        local mailButton = MailButton.Create()
        widgetsMenu:AddRHButton(CONST.MAINUI.ICONS.MailButton, mailButton)
    end

    local sceneId = App.scene:GetCurrentSceneId()
    local WorldMapButton = require "UI.Components.WorldMapButton"
    local worldMapBtn = WorldMapButton:Create()
    worldMapBtn:SetParent(bottomRight)
    rootView:AddWidget(CONST.MAINUI.ICONS.WorldMapBtn, worldMapBtn)

    local BagButton = require "UI.Components.BagButton"
    local bagBtn = BagButton:Create()
    bagBtn:SetParent(bottomRight)
    rootView:AddWidget(CONST.MAINUI.ICONS.BagBtn, bagBtn)

    local scene = App:getRunningLuaScene()
    if AppServices.TeamManager.ShowIcon(sceneId) then
        local TeamButton = require "UI.Components.TeamButton"
        local teamButton = TeamButton:Create()
        teamButton:SetParent(bottomLeft)
        rootView:AddWidget(CONST.MAINUI.ICONS.TeamBtn, teamButton)
    end

    local ActiveEggButton = require "UI.Components.ActiveEggsButton"
    local aeBtn = ActiveEggButton:Create()
    self.layout:RightLayoutAddChild(aeBtn)
    rootView:AddWidget(CONST.MAINUI.ICONS.ActiveEggsButton, aeBtn)

    if AppServices.MapStarManager:IsABUnlock()
        and AppServices.MapStarManager:IsSceneActivated(sceneId)
     then
        local SceneStarButton = require "UI.Components.SceneStarButton"
        local sceneStarButton = SceneStarButton.Create()
        sceneStarButton:SetParent(bottomLeft)
        rootView:AddWidget(CONST.MAINUI.ICONS.SceneStarButton, sceneStarButton)
    end

    if scene and scene:GetSceneType() ~= SceneType.Maze then
        local BombEntryIcon = require "UI.Components.BombEntryIcon"
        local bombItem = BombEntryIcon:Create()
        bombItem:SetParent(bottomRight)
        rootView:AddWidget(CONST.MAINUI.ICONS.Bomb, bombItem)
    end

    local PruneButton = require "UI.Components.PruneButton"
    local pruneBtn = PruneButton:Create()
    widgetsMenu:AddRHButton(CONST.MAINUI.ICONS.Prune, pruneBtn)

    ---energy buff widget
    local EnergyDiscountIcon = require "UI.Components.EnergyDiscountIcon"
    local energyDiscount = EnergyDiscountIcon.Create()
    energyDiscount:SetParent(topLeft)
    rootView:AddWidget(CONST.MAINUI.ICONS.EnergyDiscount, energyDiscount)

    local EnergyDiscountItemIcon = require "UI.Components.EnergyDiscountItemIcon"
    local energyDiscountItem = EnergyDiscountItemIcon.Create()
    energyDiscountItem:SetParent(topLeft)
    rootView:AddWidget(CONST.MAINUI.ICONS.EnergyDiscountItemIcon, energyDiscountItem)

    -- local BuildingRepairButton = require "UI.Components.BuildingRepairButton"
    -- local buildingRepairBtns = BuildingRepairButton:Create()
    -- buildingRepairBtns:SetParent(topLeft)
    -- rootView:AddWidget(CONST.MAINUI.ICONS.BuldingRepairBtns, buildingRepairBtns)

    local TeamDragonInfo = require "UI.Components.TeamDragonInfo"
    local teamDragonInfo = TeamDragonInfo:Create()
    teamDragonInfo:SetParent(left)
    rootView:AddWidget(CONST.MAINUI.ICONS.TeamDragonInfo, teamDragonInfo)

    local TeamDragonButton = require "UI.Components.TeamDragonButton"
    local dragonBtn = TeamDragonButton:Create()
    dragonBtn:SetParent(bottomLeft)
    rootView:AddWidget(CONST.MAINUI.ICONS.TeamDragonButton, dragonBtn)

    local DragonEnergyDiscountIcon = require"UI.Components.DragonEnergyDiscountIcon"
    local dragonEnergyDiscount = DragonEnergyDiscountIcon.Create()
    dragonEnergyDiscount:SetParent(topLeft)
    rootView:AddWidget(CONST.MAINUI.ICONS.DragonEnergyDiscount, dragonEnergyDiscount)

    MessageDispatcher:AddMessageListener(MessageType.PiggyBankRefresh, self.OnRefreshPiggyBank, self)
    if AppServices.PiggyBank:ShowEnterIcon() then
        local PiggyBankButton = require("UI.Components.PiggyBankButton")
        self.piggyBankButton = PiggyBankButton:Create()
    end

    return self
end

function TeamDragonCitiyView:Init(go, callback)
end

function TeamDragonCitiyView:OnRefreshPiggyBank()
    if AppServices.PiggyBank:ShowEnterIcon() then
        if self.piggyBankButton == nil then
            local PiggyBankButton = require("UI.Components.PiggyBankButton")
            self.piggyBankButton = PiggyBankButton:Create()
        end
    else
        if self.piggyBankButton ~= nil then
            self.piggyBankButton:Dispose()
            self.piggyBankButton = nil
        end
    end
end

function TeamDragonCitiyView:ShowComicsImages(onFinish)
    if not (Runtime.CSValid(self.imgUp) and Runtime.CSValid(self.imgDown)) then
        local go = BResource.InstantiateFromAssetName("Prefab/UI/Buildin/CanvasScreenPlay.prefab")
        local screenPlayCanvas = go:GetComponent(typeof(Canvas))
        local canvasScaler = screenPlayCanvas:GetComponent(typeof(CanvasScaler))
        local height, width = Screen.height, Screen.width
        local ratio = width / height
        local designRation = 1280 / 700
        if ratio > designRation then
            canvasScaler.matchWidthOrHeight = 1
        else
            canvasScaler.matchWidthOrHeight = 0
        end

        screenPlayCanvas.sortingOrder = -1
        screenPlayCanvas.worldCamera = Camera.main

        self.imgUp = go:FindGameObject("ImgUp")
        self.imgDown = go:FindGameObject("ImgDown")
    end
    GameUtil.DoAnchorPosY(self.imgUp:GetComponent(typeof(RectTransform)), -46, 0.3, onFinish)
    GameUtil.DoAnchorPosY(self.imgDown:GetComponent(typeof(RectTransform)), 81, 0.3)
end

function TeamDragonCitiyView:HideComicsImages(onFinish)
    GameUtil.DoAnchorPosY(self.imgUp:GetComponent(typeof(RectTransform)), 49, 0.3, onFinish)
    GameUtil.DoAnchorPosY(self.imgDown:GetComponent(typeof(RectTransform)), -87, 0.3)
end

function TeamDragonCitiyView:ShowHeadInfoPanel(val)
    self.rootView.heartItem:ShowExitAnim(true)
    self.rootView.diamondItem:ShowExitAnim(true)
    self.rootView.coinItem:ShowExitAnim(true)
    self.rootView.expItem:ShowExitAnim(true)
end

function TeamDragonCitiyView:ShowAllTopIcons(instant, interactable)
    local headInfoView = App.scene:GetWidget(CONST.MAINUI.ICONS.HeadInfoView)
    if headInfoView then
        headInfoView:ShowEnterAnim()
        ------------------------------------
        self.rootView.heartItem:ShowExitAnim(true)
        self.rootView.diamondItem:ShowExitAnim(true)
        self.rootView.coinItem:ShowExitAnim(true)
        self.rootView.expItem:ShowExitAnim(true)
    end

    -- self.bagButton:ShowEnterAnim()
    --小图标滑入
    self.rootView.layout:WidgetsIn()
end

function TeamDragonCitiyView:HideAllTopIcons(instant, hideType)
    local headInfoView = App.scene:GetWidget(CONST.MAINUI.ICONS.HeadInfoView)
    if headInfoView then
        headInfoView:ShowExitAnim(
            false,
            function()
                -- local hideType = hideType or 0
                if not hideType then
                    return
                end
                -- 延迟处理以下内容
                if hideType & TopIconHideType.stayDiamondIcon > 0 then
                    self.rootView.diamondItem:Refresh()
                    self.rootView.diamondItem:ShowEnterAnim()
                    self.rootView.diamondItem:SetInteractable(false)
                else
                    self.rootView.diamondItem:ShowExitAnim(instant)
                end

                if hideType & TopIconHideType.stayHeartIcon > 0 then
                    self.rootView.heartItem:Refresh()
                    self.rootView.heartItem:ShowEnterAnim()
                    self.rootView.heartItem:SetInteractable(false)
                else
                    self.rootView.heartItem:ShowExitAnim(instant)
                end

                if hideType & TopIconHideType.stayCoinIcon > 0 then
                    self.rootView.coinItem:Refresh()
                    self.rootView.coinItem:ShowEnterAnim()
                    self.rootView.coinItem:SetInteractable(false)
                else
                    self.rootView.coinItem:ShowExitAnim(instant)
                end

                if hideType & TopIconHideType.stayExpItem > 0 then
                    self.rootView.expItem:Refresh()
                    self.rootView.expItem:ShowEnterAnim()
                    self.rootView.expItem:SetInteractable(false)
                else
                    self.rootView.expItem:ShowExitAnim(instant)
                end
            end,
            160
        )
    --self.headInfoView:SetInteractable(false)
    end
    -- self.settingButton:SetInteractable(false)

    -- 小图标滑出
    self.rootView.layout:WidgetOut()
    if self.dragonBag then
        self.dragonBag:Hide()
    end
end

function TeamDragonCitiyView:RefreshRedDot(buttonName)
    if not self.rhWidgetKeys then
        return
    end
    for _, eType in ipairs(self.rhWidgetKeys) do
        ---@type HomeSceneTopIconBase
        local buttonInstance = self.rootView:GetWidget(eType)
        if buttonInstance and buttonInstance.RefreshRedDot then
            buttonInstance:RefreshRedDot()
        end
    end
end

function TeamDragonCitiyView:BeforeUnload()
    local settingButton = self.rootView:GetWidget(CONST.MAINUI.ICONS.SettingButton)
    if settingButton then
        settingButton:Unload()
    end

    if self.dragonBagBtn then
        self.dragonBagBtn:Dispose()
    end
end

function TeamDragonCitiyView:Destroy()
    if self.dragonInfo then
        self.dragonInfo:Dispose()
        self.dragonInfo = nil
    end
    if self.dragonBag then
        self.dragonBag:Dispose()
        self.dragonBag = nil
    end
    MessageDispatcher:RemoveMessageListener(MessageType.PiggyBankRefresh, self.OnRefreshPiggyBank, self)
    if self.piggyBankButton then
        self.piggyBankButton:Dispose()
        self.piggyBankButton = nil
    end
end

function TeamDragonCitiyView:ShowBottomIcons(isFirstTime)
    for k, v in pairs(self.rootView.widgets) do
        if type(v.OnEvent_ShowBottomIcons) == "function" then
            Runtime.InvokeCbk(v.OnEvent_ShowBottomIcons, v, isFirstTime)
        end
    end
end

local UIIconType2HideType = {
    [CONST.MAINUI.ICONS.BagBtn] = TopIconHideType.stayBagIcon
}
function TeamDragonCitiyView:HideBottomIcons(instant, hideType)
    for k, v in pairs(self.rootView.widgets) do
        if
            (UIIconType2HideType[k] == nil or hideType == nil or hideType & UIIconType2HideType[k] == 0) and
                type(v.OnEvent_HideBottomIcons) == "function"
         then
            Runtime.InvokeCbk(v.OnEvent_HideBottomIcons, v, instant)
        end
    end
end

return TeamDragonCitiyView
