--------------------Job_CheckMagicalProfit
local Job_CheckMagicalProfit = {}

function Job_CheckMagicalProfit:Init(priority)
    self.name = priority
end

function Job_CheckMagicalProfit:CheckPop()
    AppServices.MagicalCreatures:GetProfitsFromServer(RuntimeContext.CACHES.SERVER_MAP.autoReceivedCollectRewards)
    self.profits = AppServices.MagicalCreatures:GetOfflineProfits()
    return self.profits and #self.profits > 0
end

function Job_CheckMagicalProfit:Do(finishCallback)
    local rwds = {}
    for _, profit in pairs(self.profits) do
        local id = profit.itemTemplateId
        local count = profit.count
        AppServices.User:AddItem(id, count, ItemGetMethod.dragonAutoReceiveCollectReward)
        table.insert(rwds, {ItemId = id, Amount = count})
    end
    local pcb = PanelCallbacks:Create(finishCallback)
    AppServices.MagicalCreatures:ClearOfflineProfits()
    PanelManager.showPanel(GlobalPanelEnum.DragonAssistRewardPanel, {rewards = rwds}, pcb)
end
function Job_CheckMagicalProfit:DoEnd()
    self.profits = nil
end

return Job_CheckMagicalProfit
