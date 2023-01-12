local TeamMapCityView = {}

---@param rootView MainCity
function TeamMapCityView:Create(rootView)
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

    -- self.rhWidgetKeys = {}
    local settingButton = require "UI.Components.SettingButton":Create()
    widgetsMenu:AddRHButton(CONST.MAINUI.ICONS.SettingButton, settingButton)

    if not RuntimeContext.DISABLE_MAIL_SYSTEM then
        local MailButton = require "Game.System.Mail.UI.Components.MailButton"
        local mailButton = MailButton.Create()
        widgetsMenu:AddRHButton(CONST.MAINUI.ICONS.MailButton, mailButton)
    end

    local sceneId = App.scene:GetCurrentSceneId()
    local scenecfg = AppServices.Meta:Category("SceneTemplate")[sceneId]
    if scenecfg.type == SceneType.Remains then
        local RemainsBackButton = require "UI.Components.RemainsBackButton"
        local remainsBackButton = RemainsBackButton:Create()
        remainsBackButton:SetParent(bottomRight)
        rootView:AddWidget(CONST.MAINUI.ICONS.RemainsBackBtn, remainsBackButton)
        local RemainsDragonButton = require "UI.Components.RemainsDragonButton"
        local dragonBtn = RemainsDragonButton:Create()
        dragonBtn:SetParent(bottomLeft)
        -- dragonBtn:SetParent(self.layout:LeftLayout())
        --self.layout:RightLayoutAddChild(dragonBtn)
        rootView:AddWidget(CONST.MAINUI.ICONS.RemainsDragonBtn, dragonBtn)
    elseif scenecfg.type == SceneType.Maze then
        local MazeBackButton = require "UI.Components.MazeBackButton"
        local mazeBackButton = MazeBackButton:Create()
        mazeBackButton:SetParent(bottomRight)
        rootView:AddWidget(CONST.MAINUI.ICONS.MazeBackBtn, mazeBackButton)
    else
        local WorldMapButton = require "UI.Components.WorldMapButton"
        local worldMapBtn = WorldMapButton:Create()
        worldMapBtn:SetParent(bottomRight)
        rootView:AddWidget(CONST.MAINUI.ICONS.WorldMapBtn, worldMapBtn)
    end

    local BagButton = require "UI.Components.BagButton"
    local bagBtn = BagButton:Create()
    bagBtn:SetParent(bottomRight)
    rootView:AddWidget(CONST.MAINUI.ICONS.BagBtn, bagBtn)

    local scene = App:getRunningLuaScene()
    if scene and scene:IsScene(SceneMode.home) then
        local DragonShopButton = require "UI.Components.DragonShopButton"
        local dragonShopButton = DragonShopButton:Create()
        dragonShopButton:SetParent(bottomLeft)
        rootView:AddWidget(CONST.MAINUI.ICONS.DragonShopBtn, dragonShopButton)
    end

    if scene and scene:GetSceneType() == SceneType.Maze then
        -- local MazeShopButton = require "UI.Components.MazeShopButton"
        -- local mazeShopButton = MazeShopButton:Create()
        -- mazeShopButton:SetParent(bottomLeft)
        -- rootView:AddWidget(CONST.MAINUI.ICONS.MazeShopButton, mazeShopButton)

        local MazeTimeButton = require "UI.Components.MazeTimeButton"
        local mazeTimeButton = MazeTimeButton:Create()
        mazeTimeButton:SetParent(self.layout.transform)
        rootView:AddWidget(CONST.MAINUI.ICONS.MazeTimeButton, mazeTimeButton)
    end

    if AppServices.TeamManager.ShowIcon(sceneId) then
        local TeamButton = require "UI.Components.TeamButton"
        local teamButton = TeamButton:Create()
        teamButton:SetParent(bottomLeft)
        rootView:AddWidget(CONST.MAINUI.ICONS.TeamBtn, teamButton)
    end
    if App.scene:IsScene(SceneMode.home) then

        local DragonBagButton = require "UI.Components.DragonBagButton"
        self.dragonBagBtn = DragonBagButton:Create()
        self.dragonBagBtn:SetParent(bottomLeft)
        self.dragonBagBtn:Hide()
        rootView:AddWidget(CONST.MAINUI.ICONS.DragonBagBtn, self.dragonBagBtn)
    end

    local ActiveEggButton = require "UI.Components.ActiveEggsButton"
    local aeBtn = ActiveEggButton:Create()
    -- aeBtn:SetParent(self.layout:LeftLayout())
    self.layout:RightLayoutAddChild(aeBtn)
    rootView:AddWidget(CONST.MAINUI.ICONS.ActiveEggsButton, aeBtn)

    if
        AppServices.MapStarManager:IsABUnlock() and
            AppServices.MapStarManager:IsSceneActivated(App.scene:GetCurrentSceneId())
     then
        local SceneStarButton = require "UI.Components.SceneStarButton"
        local sceneStarButton = SceneStarButton.Create()
        sceneStarButton:SetParent(bottomLeft)
        rootView:AddWidget(CONST.MAINUI.ICONS.SceneStarButton, sceneStarButton)
    --[[else
        local AchievementButton = require "UI.Components.AchievementButton"
        local achievementButton = AchievementButton.Create()
        achievementButton:SetParent(bottomLeft)
        rootView:AddWidget(CONST.MAINUI.ICONS.AchievementButton, achievementButton)--]]
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

    -- local scene = App:getRunningLuaScene()
    if scene and scene:IsScene(SceneMode.home) then
        self.dragonInfo = include("UI.Components.DragonInfo")
        self.dragonInfo:Create(self.layout.transform)
        rootView:AddWidget(CONST.MAINUI.ICONS.DragonInfo, self.dragonInfo)

        local FactoryButton = require "UI.Components.FactoryButton"
        local factoryButton = FactoryButton:Create()
        factoryButton:SetParent(topLeft)
        rootView:AddWidget(CONST.MAINUI.ICONS.FactoryBtn, factoryButton)
    end
    ---energy buff widget
    local EnergyDiscountIcon = require "UI.Components.EnergyDiscountIcon"
    local energyDiscount = EnergyDiscountIcon.Create()
    energyDiscount:SetParent(topLeft)
    rootView:AddWidget(CONST.MAINUI.ICONS.EnergyDiscount, energyDiscount)

    local EnergyDiscountItemIcon = require "UI.Components.EnergyDiscountItemIcon"
    local energyDiscountItem = EnergyDiscountItemIcon.Create()
    energyDiscountItem:SetParent(topLeft)
    rootView:AddWidget(CONST.MAINUI.ICONS.EnergyDiscountItemIcon, energyDiscountItem)

    local MergeButton = require "UI.Components.MergeButton"
    local mergeButton = MergeButton:Create()
    mergeButton:SetParent(topLeft)
    mergeButton:CheckShowOrHide()
    rootView:AddWidget(CONST.MAINUI.ICONS.MergeButton, mergeButton)

    local BreedButton = require "UI.Components.BreedButton"
    local breedButton = BreedButton:Create()
    breedButton:SetParent(topLeft)
    breedButton:CheckShowOrHide()
    rootView:AddWidget(CONST.MAINUI.ICONS.BreedButton, breedButton)

    local LabButton = require "UI.Components.LabButton"
    local labButton = LabButton:Create()
    labButton:SetParent(topLeft)
    labButton:CheckShowOrHide()
    rootView:AddWidget(CONST.MAINUI.ICONS.LabButton, labButton)

    local BuildingRepairButton = require "UI.Components.BuildingRepairButton"
    local buildingRepairBtns = BuildingRepairButton:Create()
    buildingRepairBtns:SetParent(topLeft)
    rootView:AddWidget(CONST.MAINUI.ICONS.BuldingRepairBtns, buildingRepairBtns)

    local TeamMapInfo = require "UI.Components.TeamMapInfo"
    local teamMapInfo = TeamMapInfo:Create()
    teamMapInfo:SetParent(left)
    rootView:AddWidget(CONST.MAINUI.ICONS.TeamMapInfo, teamMapInfo)

    MessageDispatcher:AddMessageListener(MessageType.PiggyBankRefresh, self.OnRefreshPiggyBank, self)
    if AppServices.PiggyBank:ShowEnterIcon() then
        local PiggyBankButton = require("UI.Components.PiggyBankButton")
        self.piggyBankButton = PiggyBankButton:Create()
    end

    return self
end

function TeamMapCityView:Init(go, callback)
end

function TeamMapCityView:OnRefreshPiggyBank()
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

function TeamMapCityView:ShowComicsImages(onFinish)
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

function TeamMapCityView:HideComicsImages(onFinish)
    GameUtil.DoAnchorPosY(self.imgUp:GetComponent(typeof(RectTransform)), 49, 0.3, onFinish)
    GameUtil.DoAnchorPosY(self.imgDown:GetComponent(typeof(RectTransform)), -87, 0.3)
end

function TeamMapCityView:ShowHeadInfoPanel(val)
    self.rootView.heartItem:ShowExitAnim(true)
    self.rootView.diamondItem:ShowExitAnim(true)
    self.rootView.coinItem:ShowExitAnim(true)
    self.rootView.expItem:ShowExitAnim(true)
end

function TeamMapCityView:ShowAllTopIcons(instant, interactable)
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

function TeamMapCityView:HideAllTopIcons(instant, hideType)
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

function TeamMapCityView:RefreshRedDot(buttonName)
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

function TeamMapCityView:BeforeUnload()
    local settingButton = self.rootView:GetWidget(CONST.MAINUI.ICONS.SettingButton)
    if settingButton then
        settingButton:Unload()
    end

    if self.dragonBagBtn then
        self.dragonBagBtn:Dispose()
    end
end

function TeamMapCityView:Destroy()
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

function TeamMapCityView:ShowBottomIcons(isFirstTime)
    for k, v in pairs(self.rootView.widgets) do
        if type(v.OnEvent_ShowBottomIcons) == "function" then
            Runtime.InvokeCbk(v.OnEvent_ShowBottomIcons, v, isFirstTime)
        end
    end
end

local UIIconType2HideType = {
    [CONST.MAINUI.ICONS.BagBtn] = TopIconHideType.stayBagIcon
}
function TeamMapCityView:HideBottomIcons(instant, hideType)
    for k, v in pairs(self.rootView.widgets) do
        if
            (UIIconType2HideType[k] == nil or hideType == nil or hideType & UIIconType2HideType[k] == 0) and
                type(v.OnEvent_HideBottomIcons) == "function"
         then
            Runtime.InvokeCbk(v.OnEvent_HideBottomIcons, v, instant)
        end
    end
end

return TeamMapCityView
