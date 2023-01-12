local DragonParkourCityView = {}

---@param rootView MainCity
function DragonParkourCityView:Create(rootView)
    self.rootView = rootView
    self.layout = rootView.layout
    return self
end

function DragonParkourCityView:SendParkourFinishLevelRequest()
    local reward = ActivityServices.Parkour:GetSceneAllReward()
    local function onSuccess(response)
        for _, value in pairs(reward) do
            AppServices.User:AddItem(value.itemTemplateId, value.count, ItemGetMethod.ParkourFinishLevel)
        end
    end

    local function onFailed(errorCode)
        if errorCode ~= 28905 then
            ErrorHandler.ShowErrorPanel(errorCode)
        end
    end
    Net.Activityparkourmodulemsg_27103_ParkourFinishLevel_Request(
        {activityId = ActivityServices.Parkour:GetActivityId(), items = reward},
        onFailed,
        onSuccess
    )
end

function DragonParkourCityView:ReportData(state)
    local attri = ActivityServices.Parkour:GetAttribute()
    local chosenDragon = ActivityServices.Parkour:GetChosenDragon()
    local energy = AppServices.MagicalCreatures:GetCreaturePhysicalStrengthLimit(chosenDragon)
    local creatureData = AppServices.MagicalCreatures:GetCreatureByCreatureId(chosenDragon)
    local dragonTemplateId = creatureData.templateId
    local score = ActivityServices.Parkour:GetGameScore()
    DcDelegates:Log(
        SDK_EVENT.parkour_finish,
        {
            dragonEnergy = energy,
            type = attri,
            dragonId = dragonTemplateId,
            result = state,
            score = score
        }
    )
end

function DragonParkourCityView:OnGameStateChanged(state)
    if state == ParkourGameState.Ready then
        self.countdown:StarTick()
    elseif state == ParkourGameState.GameFailed then
        self:ReportData(0)
        GameUtil.BlockAll(2, "parkour_game_failed")
        self:SendParkourFinishLevelRequest()
        self:PlayDieEffect()
        WaitExtension.SetTimeout(
            function()
                GameUtil.BlockAll(0, "parkour_game_failed")
                PanelManager.showPanel(GlobalPanelEnum.ParkourFailedPanel)
            end,
            1.5
        )
    elseif state == ParkourGameState.GameSuccess then
        self:ReportData(1)
        self:SendParkourFinishLevelRequest()
        PanelManager.showPanel(GlobalPanelEnum.DragonParkourRewardPanel)
        local driver = AppServices.MagicalCreatures:GetDriver()
        local player = driver and driver.player
        if not player then
            return
        end
        player.gameObject:SetActive(false)
    end
end

function DragonParkourCityView:PlayDieEffect()
    local path = "Prefab/Activities/Parkour/E_parkour_dead.prefab"
    local function create()
        local driver = AppServices.MagicalCreatures:GetDriver()
        local player = driver and driver.player
        if not player then
            return
        end
        local position = player:GetPosition() + Vector3(1, 0.8, -1.5)
        local effect = BResource.InstantiateFromAssetName(path)
        effect:SetPosition(position)
    end
    App.uiAssetsManager:LoadAssets({path}, create)
end

function DragonParkourCityView:Init()
    MessageDispatcher:AddMessageListener(MessageType.Parkour_GameState_Changed, self.OnGameStateChanged, self)
    -- MessageDispatcher:AddMessageListener(MessageType.Parkour_Collect_Item, self.OnGameStateChanged, self)

    --[[local QuitButton = require "UI.Components.DragonExploit.DragonExploitQuitButton"
    local quitButton = QuitButton:Create()
    quitButton:SetParent(self.layout.transTC)
    self.rootView:AddWidget(CONST.MAINUI.ICONS.ExploitQuitButton, quitButton)--]]
    local JumpButton = require "UI.Activities.Parkour.Components.ParkourJumpButton"
    local jumpButton = JumpButton:Create()
    jumpButton:SetParent(self.layout.transBR)
    self.rootView:AddWidget(CONST.MAINUI.ICONS.ParkourJump, jumpButton)

    local Countdown = require "UI.Activities.Parkour.Components.ParkourCountdown"
    self.countdown = Countdown:Create()
    self.countdown:SetParent(self.layout.transform)

    local ScoreItem = require "UI.Activities.Parkour.Components.ParkourScoreItem"
    local scoreItem = ScoreItem:Create()
    scoreItem:SetParent(self.layout.transTC)
    self.rootView:AddWidget(CONST.MAINUI.ICONS.ParkourScoreItem, scoreItem)

    local ProgressItem = require "UI.Activities.Parkour.Components.ParkourProgressItem"
    self.progressItem = ProgressItem:Create()
    self.progressItem:SetParent(self.layout.transTC)
    --self.rootView:AddWidget(CONST.MAINUI.ICONS.ExploitProgress, progressItem)

    --[[local DragonsItem = require "UI.Components.DragonExploit.DragonExploitDragons"
    local dragonsItem = DragonsItem:Create()
    dragonsItem:SetParent(self.layout.transBC)
    self.rootView:AddWidget(CONST.MAINUI.ICONS.ExploitDragons, dragonsItem)
    local dragonList = ActivityServices.DragonExploit:GetChosenDragons()
    dragonsItem:SetData(dragonList)--]]
    --buff图标
    local BuffItem = require "UI.Activities.Parkour.Components.ParkourBuff"
    local buffItem_Drop = BuffItem:Create()
    buffItem_Drop:SetParent(self.layout.transR)
    buffItem_Drop:SetData(ItemId.BuffDoubleParkourScore)
    buffItem_Drop.gameObject.transform.anchoredPosition = Vector2(0, -58)
    self.rootView:AddWidget(CONST.MAINUI.ICONS.BuffDoubleParkourScore, buffItem_Drop)

    --[[local buffItem_Collect = BuffItem:Create()
    buffItem_Collect:SetParent(self.layout.transR)
    buffItem_Collect:SetData(ItemId.Buff2Collect)
    buffItem_Collect.gameObject.transform.anchoredPosition = Vector2(0,-186)
    self.rootView:AddWidget(CONST.MAINUI.ICONS.ExploitBuffs_2Collect, buffItem_Collect)

    --self.layout.transR_Act.gameObject:SetActive(false)
    --self.layout.transR_Pro.gameObject:SetActive(false)
    --local layout = self.layout.transR:GetComponent(typeof(CS.UnityEngine.UI.GridLayoutGroup))
    --layout.enabled = true
    --layout.childAlignment = 4
    ----]]
    local BagButton = require "UI.Components.BagButton"
    local bagBtn = BagButton:Create()
    bagBtn:SetParent(self.layout.transBR)
    bagBtn.gameObject:SetActive(false)
    self.rootView:AddWidget(CONST.MAINUI.ICONS.BagBtn, bagBtn)

    local DiamondItem = require "UI.Components.DiamondItem"
    local CoinItem = require "UI.Components.CoinItem"

    local coinItem = CoinItem:Create()
    coinItem:SetParent(self.layout:Node())
    coinItem.gameObject:SetActive(false)
    self.rootView:AddWidget(CONST.MAINUI.ICONS.CoinIcon, coinItem)

    local diamondItem = DiamondItem:Create()
    diamondItem:SetParent(self.layout:Node(), false)
    diamondItem.gameObject:SetActive(false)
    self.rootView:AddWidget(CONST.MAINUI.ICONS.DiamondIcon, diamondItem)

    local HeartItem = require "UI.Components.HeartItem"
    local heartItem = HeartItem:Create()
    heartItem:SetParent(self.layout:Node(), false)
    heartItem.gameObject:SetActive(false)
    self.rootView:AddWidget(CONST.MAINUI.ICONS.EnergyIcon, heartItem)
end

function DragonParkourCityView:BeforeUnload()
    MessageDispatcher:RemoveMessageListener(MessageType.Parkour_GameState_Changed, self.OnGameStateChanged, self)
    --MessageDispatcher:RemoveMessageListener(MessageType.Parkour_Collect_Item, self.OnGameStateChanged, self)

    self.countdown:BeforeUnload()
    self.progressItem:BeforeUnload()
    self.rootView:GetWidget(CONST.MAINUI.ICONS.BuffDoubleParkourScore):BeforeUnload()
    --self.rootView:GetWidget(CONST.MAINUI.ICONS.ExploitDragons):BeforeUnload()
    --self.rootView:GetWidget(CONST.MAINUI.ICONS.ExploitBuffs_2Drop):BeforeUnload()
    --self.rootView:GetWidget(CONST.MAINUI.ICONS.ExploitBuffs_2Collect):BeforeUnload()
end

function DragonParkourCityView:ShowBottomIcons(isFirstTime)
    for k, v in pairs(self.rootView.widgets) do
        if type(v.OnEvent_ShowBottomIcons) == "function" then
            Runtime.InvokeCbk(v.OnEvent_ShowBottomIcons, v, isFirstTime)
        end
    end
end

local UIIconType2HideType = {
    [CONST.MAINUI.ICONS.BagBtn] = TopIconHideType.stayBagIcon
}
function DragonParkourCityView:HideBottomIcons(instant, hideType)
    for k, v in pairs(self.rootView.widgets) do
        if
            (UIIconType2HideType[k] == nil or hideType == nil or hideType & UIIconType2HideType[k] == 0) and
                type(v.OnEvent_HideBottomIcons) == "function"
         then
            Runtime.InvokeCbk(v.OnEvent_HideBottomIcons, v, instant)
        end
    end
end

function DragonParkourCityView:Destroy()
end

return DragonParkourCityView
