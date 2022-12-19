local SuperCls = require "UI.Components.HeartItem"

---@class HeartItemInPanel:HeartItem
local HeartItemInPanel = class(SuperCls)

function HeartItemInPanel:CreateWithGameObject(gameObject)
    local instance = HeartItemInPanel.new()
    instance:InitWithGameObject(gameObject)
    instance:InitBuy()
    return instance
end
local notAdsTimeKey = "notAdsTimeKey"
function HeartItemInPanel:InitBuy()
    local onClickGet1 = function(buyItem)
        buyItem:Hide()
        AppServices.Jump.Command_ToTaskBoard()
    end

    local onClickGet2 = function(buyItem)
        buyItem:Hide()
        if AppServices.Unlock:IsUnlockOrShowTip("Waterwheel") then
            AppServices.Jump.Command_ToWaterwheel()
        end
    end

    local createBuyNeed = function()
        local buyNeed = {}
        local buyNeedRoot = find_component(self.gameObject, "buyNeedRoot")
        buyNeed.root = buyNeedRoot
        buyNeed.count = find_component(buyNeedRoot, "count", Text)
        buyNeed.buyBtn = find_component(buyNeedRoot, "buyBtn")
        buyNeed.cost = find_component(buyNeed.buyBtn, "cost", Text)
        buyNeed.bg = find_component(buyNeedRoot, "bg", CS.EventTriggerPassThrough)
        buyNeed.getBtn1 = find_component(buyNeedRoot, "getBtn1")
        buyNeed.getBtn2 = find_component(buyNeedRoot, "getBtn2")

        Util.UGUI_AddButtonListener(
            buyNeed.buyBtn,
            function()
                AppServices.DiamondConfirmUIManager:Click(
                    buyNeed.buyBtn,
                    function()
                        buyNeed:OnClickBuy()
                    end
                )
            end
        )

        Util.UGUI_AddButtonListener(
            buyNeed.getBtn1,
            function()
                onClickGet1(buyNeed)
            end
        )

        Util.UGUI_AddButtonListener(
            buyNeed.getBtn2,
            function()
                onClickGet2(buyNeed)
            end
        )

        local onClickBg = function()
            if AppServices.User:GetItemAmount(ItemId.ENERGY) < 5 then
                AppServices.GiftManager:TryShowGift({21, 22, 23})
            end
            buyNeed:Hide()
        end
        buyNeed.bg.onPointerClick = onClickBg

        buyNeed.OnClickBuy = function(buyNeed)
            buyNeed:Hide()

            local needItems = {}
            table.insert(needItems, {itemId = ItemId.ENERGY, count = buyNeed.needCount})
            local function requestCallback(result, msg)
                if not result then
                    return
                end
                for i, v in ipairs(needItems) do
                    AppServices.User:AddItem(v.itemId, v.count, ItemGetMethod.quickSupplementEnergy)
                end
                AppServices.User:UseItem(ItemId.DIAMOND, buyNeed.costCount, ItemUseMethod.quickSupplementEnergy)
                local widget = ItemId.GetWidget(ItemId.ENERGY)
                if widget then
                    widget:Refresh()
                end
                widget = ItemId.GetWidget(ItemId.DIAMOND)
                if widget then
                    widget:Refresh()
                end
                PanelManager.closePanel(GlobalPanelEnum.BuyItemPanel)
            end

            local hasDiamondCount = AppServices.User:GetItemAmount(ItemId.DIAMOND)
            if hasDiamondCount >= buyNeed.costCount then
                self:SupplementEnergyRequest(3, buyNeed.costCount, buyNeed.needCount, requestCallback)
            else
                require("Game.Processors.RequestIAPProcessor").Start(
                    function()
                        PanelManager.closePanel(GlobalPanelEnum.BuyItemPanel)
                        PanelManager.showPanel(GlobalPanelEnum.MoneyShopPanel, {source = "buyNeedHeart"})
                    end
                )
            end
        end

        buyNeed.Show = function(buyNeed, needCount)
            if PanelManager.isShowingAnyPanel() then
                return
            end

            buyNeed.needCount = needCount
            buyNeed.root:SetActive(true)
            buyNeed.bg.transform:SetParent(App.scene.layout.transform)
            buyNeed.bg.transform:SetAsFirstSibling()
            buyNeed.count.text = "+" .. needCount
            local energyDiamondExchange = tonumber(AppServices.Meta:GetConfigMetaValue("energyDiamondExchange"))
            buyNeed.costCount = math.ceil(needCount / energyDiamondExchange)
            buyNeed.cost.text = buyNeed.costCount
            MessageDispatcher:AddMessageListener(MessageType.Global_After_Show_Panel, buyNeed.OnShowPanel, buyNeed)
        end

        buyNeed.OnShowPanel = function(buyNeed)
            if Runtime.CSNull(buyNeed.root) then
                return
            end
            buyNeed:Hide()
        end

        buyNeed.Hide = function(buyNeed)
            MessageDispatcher:RemoveMessageListener(MessageType.Global_After_Show_Panel, buyNeed.OnShowPanel, buyNeed)
            if Runtime.CSNull(buyNeed.root) then
                return
            end
            buyNeed.root:SetActive(false)
            buyNeed.bg.transform:SetParent(buyNeed.root.transform)
            buyNeed.bg.transform:SetAsFirstSibling()
        end

        return buyNeed
    end
    self.buyNeed = createBuyNeed()

    local createBuyFull = function()
        local buyFull = {}
        local buyFullRoot = find_component(self.gameObject, "buyFullRoot")
        buyFull.root = buyFullRoot
        buyFull.time = find_component(buyFullRoot, "time", Text)
        buyFull.buyFullBtn = find_component(buyFullRoot, "buyFullBtn")
        buyFull.buyFullCost = find_component(buyFull.buyFullBtn, "cost", Text)
        buyFull.buyBtn = find_component(buyFullRoot, "buyBtn")
        buyFull.buyCost = find_component(buyFull.buyBtn, "cost", Text)
        buyFull.count = find_component(buyFullRoot, "count", Text)
        buyFull.buyFullCount = find_component(buyFullRoot, "buyFullCount", Text)
        buyFull.bg = find_component(buyFullRoot, "bg", CS.EventTriggerPassThrough)

        buyFull.getBtn1 = find_component(buyFullRoot, "getBtn1")
        buyFull.getBtn2 = find_component(buyFullRoot, "getBtn2")

        Util.UGUI_AddButtonListener(
            buyFull.buyBtn,
            function()
                AppServices.DiamondConfirmUIManager:Click(
                    buyFull.buyBtn,
                    function()
                        buyFull:OnClickBuy()
                    end
                )
            end
        )

        Util.UGUI_AddButtonListener(
            buyFull.buyFullBtn,
            function()
                AppServices.DiamondConfirmUIManager:Click(
                    buyFull.buyFullBtn,
                    function()
                        buyFull:OnClickBuyFull()
                    end
                )
            end
        )

        Util.UGUI_AddButtonListener(
            buyFull.getBtn1,
            function()
                onClickGet1(buyFull)
            end
        )

        Util.UGUI_AddButtonListener(
            buyFull.getBtn2,
            function()
                onClickGet2(buyFull)
            end
        )

        local onClickBg = function()
            if AppServices.User:GetItemAmount(ItemId.ENERGY) < 5 then
                AppServices.GiftManager:TryShowGift({21, 22, 23})
            end
            buyFull:Hide()
        end
        buyFull.bg.onPointerClick = onClickBg

        buyFull.OnClickBuyFull = function(buyFull)
            buyFull:Hide()
            local metaMgr = AppServices.Meta
            local userMgr = AppServices.User
            -- local level = userMgr:GetCurrentLevelId()
            -- local levelConfig = metaMgr:GetLevelConfig(level)
            local maxCount = HeartManager:GetMaxCount()
            local hasCount = userMgr:GetItemAmount(ItemId.ENERGY)
            local needCount = maxCount - hasCount
            -- local energyMakeUp = levelConfig.energyMakeUp
            if needCount <= 0 then
                local str = Runtime.Translate("ui_energy_full")
                AppServices.UITextTip:Show(str)
                return
            end

            local energyDiamondExchange = metaMgr:GetConfigMetaValueNumber("energyDiamondExchange", 4)
            local diamondCost = math.ceil(needCount / energyDiamondExchange)

            local needItems = {}
            table.insert(needItems, {itemId = ItemId.ENERGY, count = needCount})
            local function requestCallback(result, msg)
                if not result then
                    return
                end
                for _, v in ipairs(needItems) do
                    userMgr:AddItem(v.itemId, v.count, ItemGetMethod.fillUpEnergy)
                end
                userMgr:UseItem(ItemId.DIAMOND, diamondCost, ItemGetMethod.fillUpEnergy)
                local widget = ItemId.GetWidget(ItemId.ENERGY)
                if widget then
                    widget:Refresh()
                end
                widget = ItemId.GetWidget(ItemId.DIAMOND)
                if widget then
                    widget:Refresh()
                end
                PanelManager.closePanel(GlobalPanelEnum.BuyItemPanel)
            end

            local hasDiamondCount = AppServices.User:GetItemAmount(ItemId.DIAMOND)
            if hasDiamondCount >= diamondCost then
                self:SupplementEnergyRequest(3, diamondCost, needCount, requestCallback)
            else
                require("Game.Processors.RequestIAPProcessor").Start(
                    function()
                        PanelManager.closePanel(GlobalPanelEnum.BuyItemPanel)
                        PanelManager.showPanel(GlobalPanelEnum.MoneyShopPanel, {source = "buyFullHeart"})
                    end
                )
            end
        end

        buyFull.OnClickBuy = function(buyFull)
            buyFull:Hide()

            local level = AppServices.User:GetCurrentLevelId()
            local levelConfig = AppServices.Meta:GetLevelConfig(level)
            local energyMakeUp = levelConfig.energyMakeUp

            local needItems = {}
            table.insert(needItems, {itemId = ItemId.ENERGY, count = energyMakeUp[3]})
            local function requestCallback(result, msg)
                if not result then
                    return
                end
                local rwds = {}
                for i, v in ipairs(needItems) do
                    AppServices.User:AddItem(v.itemId, v.count, ItemGetMethod.supplement100Energy)
                    local rwd = {ItemId = v.itemId, Amount = v.count}
                    table.insert(rwds, rwd)
                end
                AppServices.User:UseItem(ItemId.DIAMOND, energyMakeUp[2], ItemUseMethod.supplement100Energy)
                local widget = ItemId.GetWidget(ItemId.ENERGY)
                if widget then
                    widget:Refresh()
                end
                widget = ItemId.GetWidget(ItemId.DIAMOND)
                if widget then
                    widget:Refresh()
                end
                local pcb =
                    PanelCallbacks:Create(
                    function()
                        PanelManager.closePanel(GlobalPanelEnum.BuyItemPanel)
                    end
                )
                PanelManager.showPanel(GlobalPanelEnum.CommonRewardPanel, {rewards = rwds}, pcb)
            end

            local hasDiamondCount = AppServices.User:GetItemAmount(ItemId.DIAMOND)
            if hasDiamondCount >= energyMakeUp[2] then
                self:SupplementEnergyRequest(2, energyMakeUp[2], energyMakeUp[3], requestCallback)
            else
                require("Game.Processors.RequestIAPProcessor").Start(
                    function()
                        PanelManager.closePanel(GlobalPanelEnum.BuyItemPanel)
                        PanelManager.showPanel(GlobalPanelEnum.MoneyShopPanel, {source = "buyFullHeart"})
                    end
                )
            end
        end

        buyFull.Show = function(buyFull)
            buyFull.root:SetActive(true)
            buyFull.bg.transform:SetParent(App.scene.layout.transform)
            buyFull.bg.transform:SetAsFirstSibling()
            local level = AppServices.User:GetCurrentLevelId()
            local energyMakeUp = AppServices.Meta:GetLevelConfig(level).energyMakeUp
            -- buyFull.buyFullCost.text = energyMakeUp[1]
            buyFull.count.text = energyMakeUp[3]
            buyFull.buyCost.text = energyMakeUp[2]
            buyFull:StartTick()

            MessageDispatcher:AddMessageListener(MessageType.Global_After_Show_Panel, buyFull.OnShowPanel, buyFull)
        end

        buyFull.OnShowPanel = function(buyFull)
            if Runtime.CSNull(buyFull.root) then
                return
            end
            buyFull:Hide()
        end

        buyFull.Tick = function(buyFull)
            buyFull.time.text = TimeUtil.SecToMS(HeartManager:GetLeftTime())
            -- 计算补足体力的消耗, 1钻石4体力 在ConfigTemplate
            local metaMgr = AppServices.Meta
            local userMgr = AppServices.User
            local maxCount = HeartManager:GetMaxCount()
            local hasCount = userMgr:GetItemAmount(ItemId.ENERGY)
            local needCount = maxCount - hasCount
            local energyDiamondExchange = metaMgr:GetConfigMetaValueNumber("energyDiamondExchange", 4)
            local costCount = math.ceil(needCount / energyDiamondExchange)
            -- buyFull.needCount = needCount
            -- buyFull.costCount = costCount
            buyFull.buyFullCount.text = needCount
            buyFull.buyFullCost.text = costCount
        end

        buyFull.StopTick = function(buyFull)
            App.scene:RemoveTickerObserver(buyFull)
        end

        buyFull.StartTick = function(buyFull)
            App.scene:AddTickerObserver(buyFull)
            buyFull:Tick()
        end

        buyFull.Hide = function(buyFull)
            buyFull.bg.transform:SetParent(buyFull.root.transform)
            buyFull.bg.transform:SetAsFirstSibling()
            buyFull:StopTick()
            buyFull.root:SetActive(false)
            MessageDispatcher:RemoveMessageListener(MessageType.Global_After_Show_Panel, buyFull.OnShowPanel, buyFull)
        end

        return buyFull
    end
    self.buyFull = createBuyFull()

    local function createClockAds()
        local clockAds = {}
        clockAds.gameObject = find_component(self.gameObject, "clockAds")
        local root = find_component(clockAds.gameObject, "root")
        clockAds.cd = find_component(root, "cd", Image)
        clockAds.count = find_component(root, "count", Text)

        clockAds.config = AppServices.AdsManager:GetConfigByType(AdsTypes.AdsClock)
        clockAds.count.text = clockAds.config.reward[1][2]
        clockAds.AdsClockCodition = tonumber(AppServices.Meta:GetConfigMetaValue("AdsClockCodition"))

        clockAds.CheckShow = function(clockAds)
            if clockAds.playing then
                return
            end
            if not AppServices.AdsManager:CheckActiveById(AdsTypes.AdsClock) then
                return
            end
            if AppServices.User:GetItemAmount(ItemId.ENERGY) >= clockAds.AdsClockCodition then
                return
            end
            local lastNotAdsTime = AppServices.User.Default:GetKeyValue(notAdsTimeKey, 0)
            if lastNotAdsTime + clockAds.config.param[2] > TimeUtil.ServerTime() then
                return
            end
            if clockAds.gameObject.activeInHierarchy then
                return
            end
            clockAds:Show()
            DcDelegates.Ads:LogWinShow(AdsTypes.AdsClock)
            DcDelegates.Ads:LogEntryShow(AdsTypes.AdsClock)
        end

        clockAds.Show = function(clockAds)
            clockAds.gameObject:SetActive(true)
            clockAds.startTime = TimeUtil.ServerTime()
            App.scene:RemoveTickerObserver(clockAds)
            App.scene:AddTickerObserver(clockAds)
            clockAds:Tick()
        end

        clockAds.GetLeftTime = function(clockAds)
            local lastTime = TimeUtil.ServerTime() - clockAds.startTime
            local remainTime = clockAds.config.param[1]
            return math.max(remainTime - lastTime, 0)
        end

        clockAds.Tick = function(clockAds)
            local lastTime = TimeUtil.ServerTime() - clockAds.startTime
            local remainTime = clockAds.config.param[1]
            local fillAmount = math.max(0, (remainTime - lastTime) / remainTime)
            clockAds.cd.fillAmount = fillAmount
            if fillAmount <= 0 then
                clockAds:Hide()
                clockAds:StopTick()
                AppServices.User.Default:SetKeyValue(notAdsTimeKey, TimeUtil.ServerTime(), true)
            end
        end

        clockAds.StopTick = function(clockAds)
            App.scene:RemoveTickerObserver(clockAds)
        end

        clockAds.Hide = function(clockAds)
            clockAds.gameObject:SetActive(false)
        end

        local function playAdsCallback(result)
            if not result then
                clockAds.playing = nil
                if clockAds:GetLeftTime() > 0 then
                    clockAds.gameObject:SetActive(true)
                end
                return
            end
            local rewardCount = clockAds.config.reward[1][2]
            AppServices.User:AddItem(ItemId.ENERGY, rewardCount, "AdsClock")

            local rwds = {
                {ItemId = ItemId.ENERGY, Amount = rewardCount}
            }
            PanelManager.showPanel(GlobalPanelEnum.CommonRewardPanel, {rewards = rwds})

            local requestCallback = function()
                clockAds.playing = nil
            end

            AppServices.AdsManager:RequsetReward(
                {adsType = AdsTypes.AdsClock, onSuc = requestCallback, onFail = requestCallback}
            )
        end

        local function OnClockAds()
            clockAds.gameObject:SetActive(false)
            clockAds.playing = true
            AppServices.AdsManager:PlayAds(AdsTypes.AdsClock, nil, playAdsCallback)
            DcDelegates.Ads:LogEntryClick(AdsTypes.AdsClock)
        end

        Util.UGUI_AddButtonListener(clockAds.gameObject, OnClockAds, {noAudio = true})

        return clockAds
    end

    self.clockAds = createClockAds()
    local img_numberBg = find_component(self.gameObject, "img_numberBg")
    Util.UGUI_AddButtonListener(
        img_numberBg,
        function()
            if not self.Interactable then
                return
            end

            -- local level = AppServices.User:GetCurrentLevelId()
            local maxCount = HeartManager:GetMaxCount()
            local hasCount = AppServices.User:GetItemAmount(ItemId.ENERGY)
            if hasCount < maxCount then
                self.buyFull:Show()
            end
        end
    )

    AppServices.EventDispatcher:addObserver(
        self,
        GlobalEvents.ShowBindingTip,
        function(eventData)
            self:StopNeedTimer()
            ---@type NormalAgent
            local agent = eventData.data
            local id, cost = agent:GetCurrentCost()
            local has = AppServices.User:GetItemAmount(id)
            if has < cost and id ~= 0 and tostring(id) == ItemId.ENERGY then
                self:ShowBuyNeed(cost - has)
            end
        end
    )

    MessageDispatcher:AddMessageListener(MessageType.Global_After_Show_Panel, self.StopNeedTimer, self)

    AppServices.EventDispatcher:addObserver(
        self,
        GlobalEvents.HideBindingTip,
        function()
            self:StopNeedTimer()
        end
    )

    AppServices.EventDispatcher:addObserver(
        self,
        GlobalEvents.MAIN_CITY_FULLY_LOADED,
        function()
            AppServices.EventDispatcher:removeObserver(self, GlobalEvents.MAIN_CITY_FULLY_LOADED)
            self.clockAds:CheckShow()
        end
    )

    MessageDispatcher:AddMessageListener(MessageType.Global_After_UseItem, self.OnUseItemEvent, self)
end

function HeartItemInPanel:OnUseItemEvent(itemId)
    if itemId ~= ItemId.ENERGY then
        return
    end

    self.clockAds:CheckShow()

    local energyCount = AppServices.User:GetItemAmount(ItemId.ENERGY)
    if energyCount ~= 0 then
        return
    end

    if PanelManager.isShowingAnyPanel() then
        return
    end

    --App.mapGuideManager:StartSeries(GuideConfigName.GuideEnergy)
    if App.mapGuideManager:HasRunningGuide(GuideIDs.GuideEnergy) then
        --PanelManager.showPanel(GlobalPanelEnum.PowerShopPanel, {source = "GuideEnergy"})
        return
    end

    self.buyFull:Show()
end

function HeartItemInPanel:StopNeedTimer()
    if self.needTimer then
        WaitExtension.CancelTimeout(self.needTimer)
        self.needTimer = nil
    end
end

function HeartItemInPanel:ShowBuyNeed(needCount)
    self:StopNeedTimer()
    self.needTimer =
        WaitExtension.SetTimeout(
        function()
            self.needTimer = nil
            self.buyNeed:Show(needCount)
        end,
        2
    )
end

function HeartItemInPanel:SetInteractable(value)
end

function HeartItemInPanel:ShowExitAnim(instant, finishCallback, distance)
end

function HeartItemInPanel:ShowEnterAnim(instant, finishCallback)
end

--mark 标记位  1:固定消耗补满体力   2:固定消耗补充指定体力 3:计算消耗补充一定量体力
function HeartItemInPanel:SupplementEnergyRequest(mark, diamonds, energies, callback)
    local function onSuccess(msg)
        callback(true, msg)
    end

    local function onFailed(errorCode)
        ErrorHandler.ShowErrorPanel(errorCode)
        callback(false, errorCode)
    end

    Net.Itemmodulemsg_2009_SupplementEnergy_Request(
        {mark = mark, diamonds = diamonds, energies = energies},
        onFailed,
        onSuccess
    )
end

function HeartItemInPanel:Dispose()
    SuperCls.Dispose(self)
    self.buyNeed:Hide()
    self.buyFull:Hide()
    -- self.buyFull:StopTick()
    self.clockAds:StopTick()
    self:StopNeedTimer()
    AppServices.EventDispatcher:removeObserver(self, GlobalEvents.ShowBindingTip)
    MessageDispatcher:RemoveMessageListener(MessageType.Global_After_Show_Panel, self.StopNeedTimer, self)
    AppServices.EventDispatcher:removeObserver(self, GlobalEvents.HideBindingTip)
    MessageDispatcher:RemoveMessageListener(MessageType.Global_After_UseItem, self.OnUseItemEvent, self)
end

return HeartItemInPanel
