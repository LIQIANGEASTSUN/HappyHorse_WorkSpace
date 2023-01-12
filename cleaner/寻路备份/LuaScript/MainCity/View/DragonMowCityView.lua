local DragonMowCityView = {}

---@param rootView MainCity
function DragonMowCityView:Create(rootView)
    self.rootView = rootView
    self.layout = rootView.layout
    return self
end

function DragonMowCityView:SendMowFinishLevelRequest()
    local reward = ActivityServices.Mow:GetSceneAllReward()
    local function onSuccess(response)
        for _, value in pairs(reward) do
            AppServices.User:AddItem(value.itemTemplateId, value.count, ItemGetMethod.MowFinishLevel)
        end
    end

    local function onFailed(errorCode)
        if errorCode ~= 28905 then
            ErrorHandler.ShowErrorPanel(errorCode)
        end
    end
    Net.Activitymowmodulemsg_28103_MowFinishLevel_Request(
        {activityId = ActivityServices.Mow:GetActivityId(), items = reward},
        onFailed,
        onSuccess
    )
end

function DragonMowCityView:ReportData(state)
    local mgr = ActivityServices.Mow
    local attri = mgr:GetAttribute()
    local chosenDragon = mgr:GetChosenDragon()
    local energy = AppServices.MagicalCreatures:GetCreaturePhysicalStrengthLimit(chosenDragon)
    local creatureData = AppServices.MagicalCreatures:GetCreatureByCreatureId(chosenDragon)
    local dragonTemplateId = creatureData.templateId
    local score = mgr:GetGameScore()
    DcDelegates:Log(
        SDK_EVENT.mow_finish,
        {
            dragonEnergy = energy,
            type = attri,
            dragonId = dragonTemplateId,
            result = state,
            score = score
        }
    )
end

function DragonMowCityView:OnGameStateChanged(state)
    if state == ParkourGameState.Ready then
        self.countdown:StarTick()
    elseif state == ParkourGameState.Playing then
        self.handleButton:ActiviateBtn()
    elseif state == ParkourGameState.GameFailed then
        self:ReportData(0)
        GameUtil.BlockAll(2, "parkour_game_failed")
        self:SendMowFinishLevelRequest()
        self:PlayDieEffect()
        WaitExtension.SetTimeout(
            function()
                GameUtil.BlockAll(0, "parkour_game_failed")
                PanelManager.showPanel(GlobalPanelEnum.MowFailedPanel)
            end,
            1.5
        )
    elseif state == ParkourGameState.GameSuccess then
        self:ReportData(1)
        self:SendMowFinishLevelRequest()
        PanelManager.showPanel(GlobalPanelEnum.MowRewardPanel)
        local driver = AppServices.MagicalCreatures:GetDriver()
        local player = driver and driver.player
        if not player then
            return
        end
        player.gameObject:SetActive(false)
    end
end

function DragonMowCityView:PlayDieEffect()
    local path = "Prefab/Activities/Mow/E_parkour_dead.prefab"
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

function DragonMowCityView:Init()
    MessageDispatcher:AddMessageListener(MessageType.Mow_GameState_Changed, self.OnGameStateChanged, self)

    local HandleButton = require "UI.Activities.Mow.Components.MowHandleButton"
    local handleButton = HandleButton:Create()
    handleButton:SetParent(self.layout.transform)
    self.rootView:AddWidget(CONST.MAINUI.ICONS.MowHandleButton, handleButton)
    self.handleButton = handleButton

    local Countdown = require "UI.Activities.Mow.Components.MowCountdown"
    self.countdown = Countdown:Create()
    self.countdown:SetParent(self.layout.transform)

    local ScoreItem = require "UI.Activities.Mow.Components.MowScoreItem"
    local scoreItem = ScoreItem:Create()
    scoreItem:SetParent(self.layout.transTC)
    self.rootView:AddWidget(CONST.MAINUI.ICONS.MowScoreItem, scoreItem)

    local ProgressItem = require "UI.Activities.Mow.Components.MowProgressItem"
    self.progressItem = ProgressItem:Create()
    self.progressItem:SetParent(self.layout.transTC)
    self.rootView:AddWidget(CONST.MAINUI.ICONS.MowTimeProcess, self.progressItem)

    --[[local DragonsItem = require "UI.Components.DragonExploit.DragonExploitDragons"
    local dragonsItem = DragonsItem:Create()
    dragonsItem:SetParent(self.layout.transBC)
    self.rootView:AddWidget(CONST.MAINUI.ICONS.ExploitDragons, dragonsItem)
    local dragonList = ActivityServices.DragonExploit:GetChosenDragons()
    dragonsItem:SetData(dragonList)--]]
    --buff图标
    local BuffItem = require "UI.Activities.Mow.Components.MowBuff"
    local buffItem_Drop = BuffItem:Create()
    buffItem_Drop:SetParent(self.layout.transR)
    buffItem_Drop:SetData(ItemId.BuffDoubleMowScore)
    buffItem_Drop.gameObject.transform.anchoredPosition = Vector2(0, -58)
    self.rootView:AddWidget(CONST.MAINUI.ICONS.BuffDoubleMowScore, buffItem_Drop)

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
    bagBtn.gameObject:SetActive(true)
    bagBtn:SetInteractable(false)
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

function DragonMowCityView:BeforeUnload()
    MessageDispatcher:RemoveMessageListener(MessageType.Mow_GameState_Changed, self.OnGameStateChanged, self)

    self.countdown:BeforeUnload()
    self.progressItem:BeforeUnload()
    self.rootView:GetWidget(CONST.MAINUI.ICONS.BuffDoubleMowScore):BeforeUnload()
    --self.rootView:GetWidget(CONST.MAINUI.ICONS.ExploitDragons):BeforeUnload()
    --self.rootView:GetWidget(CONST.MAINUI.ICONS.ExploitBuffs_2Drop):BeforeUnload()
    --self.rootView:GetWidget(CONST.MAINUI.ICONS.ExploitBuffs_2Collect):BeforeUnload()
end

function DragonMowCityView:ShowBottomIcons(isFirstTime)
    for k, v in pairs(self.rootView.widgets) do
        if type(v.OnEvent_ShowBottomIcons) == "function" then
            Runtime.InvokeCbk(v.OnEvent_ShowBottomIcons, v, isFirstTime)
        end
    end
end

local UIIconType2HideType = {
    [CONST.MAINUI.ICONS.BagBtn] = TopIconHideType.stayBagIcon
}
function DragonMowCityView:HideBottomIcons(instant, hideType)
    for k, v in pairs(self.rootView.widgets) do
        if
            (UIIconType2HideType[k] == nil or hideType == nil or hideType & UIIconType2HideType[k] == 0) and
                type(v.OnEvent_HideBottomIcons) == "function"
         then
            Runtime.InvokeCbk(v.OnEvent_HideBottomIcons, v, instant)
        end
    end
end

function DragonMowCityView:Destroy()
end

return DragonMowCityView
