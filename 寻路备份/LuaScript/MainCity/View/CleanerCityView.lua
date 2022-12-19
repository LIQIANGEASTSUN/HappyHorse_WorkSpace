local CleanerCityView = {}

---@param rootView MainCity
function CleanerCityView:Create(rootView)
    self.rootView = rootView
    self.layout = rootView.layout
    return self
end

function CleanerCityView:SendParkourFinishLevelRequest()
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

function CleanerCityView:ReportData(state)
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

function CleanerCityView:OnGameStateChanged(state)
    if state == ParkourGameState.Ready then
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

function CleanerCityView:PlayDieEffect()
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

function CleanerCityView:Init()
    MessageDispatcher:AddMessageListener(MessageType.Parkour_GameState_Changed, self.OnGameStateChanged, self)
    -- MessageDispatcher:AddMessageListener(MessageType.Parkour_Collect_Item, self.OnGameStateChanged, self)

    local UserInfoWidget = require "UI.Components.UserInfoWidget"
    local userInfo = UserInfoWidget:Create()
    userInfo:SetParent(self.layout.transLT)
    self.rootView:AddWidget(CONST.MAINUI.ICONS.UserInfoWidget, userInfo)

    local PropsWidget = require "UI.Components.PropsWidget"
    local propsWidget = PropsWidget:Create()
    propsWidget:SetParent(self.layout.transRT)
    self.rootView:AddWidget(CONST.MAINUI.ICONS.PropsWidget, propsWidget)

    local BagButton = require "UI.Components.BagButton"
    local bagBtn = BagButton:Create()
    bagBtn:SetParent(self.layout.transR)
    self.rootView:AddWidget(CONST.MAINUI.ICONS.BagButton, bagBtn)

    local GMButton = require "UI.Components.GMButton"
    local gmBtn = GMButton:Create()
    gmBtn:SetParent(self.layout.transBL)
    self.rootView:AddWidget(CONST.MAINUI.ICONS.GMButton, gmBtn)

    local PetInfoButton = require "UI.Components.PetInfoButton"
    local petInfoBtn = PetInfoButton:Create()
    petInfoBtn:SetParent(self.layout.transBL)
    self.rootView:AddWidget(CONST.MAINUI.ICONS.PetInfoButton, petInfoBtn)

    local AnimalsButton = require "UI.Components.AnimalsButton"
    local animalsBtn = AnimalsButton:Create()
    animalsBtn:SetParent(self.layout.transBL)
    self.rootView:AddWidget(CONST.MAINUI.ICONS.AnimalsButton, animalsBtn)

    local CleanerButton = require "UI.Components.CleanerButton"
    local cleanerBtn = CleanerButton:Create()
    cleanerBtn:SetParent(self.layout.transBL)
    self.rootView:AddWidget(CONST.MAINUI.ICONS.CleanerButton, cleanerBtn)

    local ShopButton = require "UI.Components.ShopButton"
    local shopBtn = ShopButton:Create()
    shopBtn:SetParent(self.layout.transBL)
    self.rootView:AddWidget(CONST.MAINUI.ICONS.ShopButton, shopBtn)

    local TaskButton = require"UI.Components.TaskButton"
    local taskBtn = TaskButton:Create()
    taskBtn:SetParent(self.layout.transTC2)
    self.rootView:AddWidget(CONST.MAINUI.ICONS.TaskButton, taskBtn)
    -- local DiamondItem = require "UI.Components.DiamondItem"
    -- local CoinItem = require "UI.Components.CoinItem"

    -- local coinItem = CoinItem:Create()
    -- coinItem:SetParent(self.layout:Node())
    -- coinItem.gameObject:SetActive(false)
    -- self.rootView:AddWidget(CONST.MAINUI.ICONS.CoinIcon, coinItem)

    -- local diamondItem = DiamondItem:Create()
    -- diamondItem:SetParent(self.layout:Node(), false)
    -- diamondItem.gameObject:SetActive(false)
    -- self.rootView:AddWidget(CONST.MAINUI.ICONS.DiamondIcon, diamondItem)

    -- local HeartItem = require "UI.Components.HeartItem"
    -- local heartItem = HeartItem:Create()
    -- heartItem:SetParent(self.layout:Node(), false)
    -- heartItem.gameObject:SetActive(false)
    -- self.rootView:AddWidget(CONST.MAINUI.ICONS.EnergyIcon, heartItem)

    -- local joyStickCanvas = GameObject.Find("VirtualJoystickCanvas")
    -- local btn = find_component(joyStickCanvas, "Button")
    -- Util.UGUI_AddButtonListener(
    --     btn,
    --     function()
    --         AppServices.Jump.changeSceneById("city")
    --     end
    -- )
end

function CleanerCityView:BeforeUnload()
    MessageDispatcher:RemoveMessageListener(MessageType.Parkour_GameState_Changed, self.OnGameStateChanged, self)
end

function CleanerCityView:ShowBottomIcons(isFirstTime)
    for k, v in pairs(self.rootView.widgets) do
        if type(v.OnEvent_ShowBottomIcons) == "function" then
            Runtime.InvokeCbk(v.OnEvent_ShowBottomIcons, v, isFirstTime)
        end
    end
end

local UIIconType2HideType = {
    [CONST.MAINUI.ICONS.BagButton] = TopIconHideType.stayBagIcon
}
function CleanerCityView:HideBottomIcons(instant, hideType)
    for k, v in pairs(self.rootView.widgets) do
        if
            (UIIconType2HideType[k] == nil or hideType == nil or hideType & UIIconType2HideType[k] == 0) and
                type(v.OnEvent_HideBottomIcons) == "function"
         then
            Runtime.InvokeCbk(v.OnEvent_HideBottomIcons, v, instant)
        end
    end
end


function CleanerCityView:ShowComicsImages(onFinish)
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

function CleanerCityView:HideComicsImages(onFinish)
    GameUtil.DoAnchorPosY(self.imgUp:GetComponent(typeof(RectTransform)), 49, 0.3, onFinish)
    GameUtil.DoAnchorPosY(self.imgDown:GetComponent(typeof(RectTransform)), -87, 0.3)
end

function CleanerCityView:Destroy()
end

return CleanerCityView
