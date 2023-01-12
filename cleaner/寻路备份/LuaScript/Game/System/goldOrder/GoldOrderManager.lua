---
--- Created by Betta.
--- DateTime: 2021/9/24 11:51
---
---@class GoldOrderManager
local GoldOrderManager = {}


GoldOrderManager.State =
{
    Lock = 1,
    Open = 2,
    Close = 3
}

function GoldOrderManager:Init()
    self.configTemplate = AppServices.Meta.metas.ConfigTemplate
    self.state = GoldOrderManager.State.Lock
    self.openCDID = nil
    self.closeCDID = nil
    ---@class GoldOrderServerInfo
    ---@field cdEndMill number
    ---@field cumulativeAwardEndMill number
    ---@field itemId string
    --{itemTemplateId, count}[]
    ---@field cumulativeAwards table
    ---@field cumulativeNum number
    ---@field cumulativeCfgNums number[]
    --[[---@field endMill number--]]
    ---@type GoldOrderServerInfo
    self.serverInfo = nil

    if self:IsUnlock() then
        self:InfoRequest()
        self:ProcessUnlock()
    else
        MessageDispatcher:AddMessageListener(MessageType.Global_OnUnlock, self.Unlock, self)
    end
end

function GoldOrderManager:InfoRequest()
    if self:IsUnlock() == false then
        return
    end
    local function onFail(errorCode)
        console.dk("炼金炉服务器获取出事数据失败" .. errorCode) --@DEL
        ErrorHandler.ShowErrorPanel(errorCode)
    end
    local function onSucess(response)
        self.serverInfo = response
        self:AddStepAwardCD(self.serverInfo.cumulativeAwardEndMill / 1000 - TimeUtil.ServerTime())
        if self:IsOpen() then
            self:Open()
        else
            self:Close()
        end
    end
    Net.Alchemyfurnacemodulemsg_26001_AlchemyFurnaceInfo_Request({}, onFail, onSucess)
end

function GoldOrderManager:ProcessUnlock()
    MessageDispatcher:AddMessageListener(MessageType.Global_After_UseItem, function(itemID)
        if self.serverInfo ~= nil and itemID == self.serverInfo.itemId and self:IsOpen() and self:CanDraw() == false then
            MessageDispatcher:SendMessage(MessageType.Gold_Order_Can_Draw, false)
        end
    end)
    MessageDispatcher:AddMessageListener(MessageType.Global_After_AddItem, function(itemID)
        if self.serverInfo ~= nil and itemID == self.serverInfo.itemId and self:IsOpen() and self:CanDraw() then
            MessageDispatcher:SendMessage(MessageType.Gold_Order_Can_Draw, true)
        end
    end)
end

function GoldOrderManager:CheckServerInfoValid()
    if self.serverInfo == nil then --or self.serverInfo.endMill == 0 or self.serverInfo.cdEndMill == 0 or self.serverInfo.cumulativeAwardEndMill == 0 then
        return false
    end
    return true
end

function GoldOrderManager:IsUnlock()
    --return true
    return AppServices.Unlock:IsUnlock("goldOrder")
end

function GoldOrderManager:Unlock(key)
    if key == "goldOrder" then
        self:InfoRequest()
        self:ProcessUnlock()
        MessageDispatcher:RemoveMessageListener(MessageType.Global_OnUnlock,self.Unlock,self)
    end
end

function GoldOrderManager:ShowPanel()
    if self.serverInfo == nil then
        console.dk("ShowPanel失败，炼金炉数据还没拉取成功") --@DEL
        return
    end
    if AppServices.Unlock:IsUnlockOrShowTip("goldOrder") then
        PanelManager.showPanel(GlobalPanelEnum.GoldOrderPanel)
    end
end

function GoldOrderManager:IsOpen()
    return self:CheckServerInfoValid() and self.serverInfo.cdEndMill / 1000 < TimeUtil.ServerTime()
end

function GoldOrderManager:IsClose()
    return not self:CheckServerInfoValid() or self.serverInfo.cdEndMill / 1000 >= TimeUtil.ServerTime()
end

function GoldOrderManager:Open()
    self.state = GoldOrderManager.State.Open
    --self:AddOpenCD(self.serverInfo.endMill / 1000 - TimeUtil.ServerTime())
    MessageDispatcher:SendMessage(MessageType.Gold_Order_Open)
    MessageDispatcher:SendMessage(MessageType.Gold_Order_Can_Draw, self:CanDraw())
end

function GoldOrderManager:Close()
    self.state = GoldOrderManager.State.Close
    self:AddCloseCD(self.serverInfo.cdEndMill / 1000 - TimeUtil.ServerTime())
    MessageDispatcher:SendMessage(MessageType.Gold_Order_Close)
    MessageDispatcher:SendMessage(MessageType.Gold_Order_Can_Draw, false)
end
---开启倒计时
function GoldOrderManager:AddOpenCD(cd)
    --[[if self.openCDID ~= nil then
        WaitExtension.CancelTimeout(self.openCDID)
        self.openCDID = nil
    end
    self.openCDID = WaitExtension.InvokeRepeating(function()
        if AppServices.GoldOrder.serverInfo.endMill / 1000 < TimeUtil.ServerTime() then
            WaitExtension.CancelTimeout(self.openCDID)
            self.openCDID = nil
            self:InfoRequest()
        end
    end, 0, 1)--]]
end

function GoldOrderManager:AddCloseCD(cd)
    if self.closeCDID ~= nil then
        WaitExtension.CancelTimeout(self.closeCDID)
        self.closeCDID = nil
    end
    self.closeCDID = WaitExtension.InvokeRepeating(function()
        if AppServices.GoldOrder.serverInfo.cdEndMill / 1000 < TimeUtil.ServerTime() then
            WaitExtension.CancelTimeout(self.closeCDID)
            self.closeCDID = nil
            self:InfoRequest()
        end
    end, 0, 1)
end

function GoldOrderManager:AddStepAwardCD(cd)
    if self.stepAwardCDID ~= nil then
        WaitExtension.CancelTimeout(self.stepAwardCDID)
        self.stepAwardCDID = nil
    end
    self.stepAwardCDID = WaitExtension.InvokeRepeating(function()
        if AppServices.GoldOrder.serverInfo.cumulativeAwardEndMill / 1000 < TimeUtil.ServerTime() then
            WaitExtension.CancelTimeout(self.stepAwardCDID)
            self.stepAwardCDID = nil
            self:InfoRequest()
        end
    end, 0, 1)
end

function GoldOrderManager:Draw()
    if self:IsOpen() == false then
        return false
    end
    local itemID = self.serverInfo.itemId
    local function onFail(errorCode)
        console.dk("炼金失败" .. errorCode) --@DEL
        ErrorHandler.ShowErrorPanel(errorCode)
        MessageDispatcher:SendMessage(MessageType.Gold_Order_Draw, false)
    end
    local function onSucess(response)
        --self.serverInfo.endMill = 0
        self.serverInfo.cdEndMill = response.cdEndTime
        self.serverInfo.itemId = response.itemId
        self.serverInfo.cumulativeNum = self.serverInfo.cumulativeNum + 1
        ---奖品和消耗相关
        local needCount = tonumber(self.configTemplate["goldOrderItemNum"].value)
        AppServices.User:UseItem(itemID, needCount, ItemUseMethod.goldOrderCost)
        for _, item in ipairs(response.rewardItems) do
            local itemId = item.itemTemplateId
            local amount = item.count
            if itemId == ItemId.EXP then
                AppServices.User:AddExp(amount, "goldOrder")
            else
                AppServices.User:AddItem(itemId, amount, ItemGetMethod.goldOrderReward)
            end
        end
        local stepIndex =  AppServices.GoldOrder:GetStepAward(AppServices.GoldOrder.serverInfo.cumulativeNum)
        local awards
        if stepIndex ~= nil then
            awards = self.serverInfo.cumulativeAwards[stepIndex].items
            for _, item in ipairs(awards) do
                local itemId = item.itemTemplateId
                local amount = item.count
                if itemId == ItemId.EXP then
                    AppServices.User:AddExp(amount, "goldOrder")
                else
                    AppServices.User:AddItem(itemId, amount, ItemGetMethod.goldOrderTotalReward)
                end
            end
        end
        MessageDispatcher:SendMessage(MessageType.Gold_Order_Draw, true, response.rewardItems, self.serverInfo.cumulativeNum, itemID, awards)
        self:Close()
        local stepNumAry = self.serverInfo.cumulativeCfgNums
        if self.serverInfo.cumulativeNum == stepNumAry[#stepNumAry] then
            self:InfoRequest()
        end
        App.audioManager:PlayEffectAudio(CONST.AUDIO.Interface_sound_ui_furnace)
    end
    Net.Alchemyfurnacemodulemsg_26002_Alchemy_Request({}, onFail, onSucess)
    return true
end

function GoldOrderManager:SkipCloseCD(isAds)
    if self:IsClose() == false then
        return false
    end
    local params
    if isAds then
        params = {}
        params.needNum = 0
        params.ads = true
    else
        local cost = self:GetSkipCDCost()
        if AppServices.User:GetItemAmount(ItemId.DIAMOND) < cost then
            return false
        end
        params = {}
        params.needNum = cost
    end
    local function onFail(errorCode)
        console.dk("跳过cd失败" .. errorCode) --@DEL
        ErrorHandler.ShowErrorPanel(errorCode)
    end
    local function onSucess(response)
        AppServices.User:UseItem(ItemId.DIAMOND, response.num, ItemUseMethod.clearCDGoldOrder)
        self:InfoRequest()
    end

    Net.Alchemyfurnacemodulemsg_26003_FinishAlchemyFurnaceCD_Request(params, onFail, onSucess)
    return true
end

function GoldOrderManager:SkipDraw()
    if self:IsOpen() == false then
        return false
    end
    local function onFail(errorCode)
        console.dk("跳过炼金失败" .. errorCode) --@DEL
        ErrorHandler.ShowErrorPanel(errorCode)
    end
    local function onSucess(response)
        self:InfoRequest()
    end
    Net.Alchemyfurnacemodulemsg_26004_SkipAlchemy_Request({}, onFail, onSucess)
    return true
end

function GoldOrderManager:LocalAward(awardNum, serverAward, itemId)
    local configTemplate = self.configTemplate
    local itemMeta = AppServices.Meta:GetItemMeta(itemId)
    local sec = itemMeta.timeValue
    local value = configTemplate["goldOrderReward_goldValue"].value
    local divNum = configTemplate["goldOrderReward_perGold"].value
    --local awardNum = self.configTemplate[""]
    local goldNum = math.round(configTemplate["goldOrderItemNum"].value * sec * value)
    goldNum = (goldNum - 1) / divNum + 1
    --[[local special = true
    for _, award in ipairs(serverAward) do
        if award.itemTemplateId ~= ItemId.COIN then
            special = false
            break
        end
    end--]]
    local goldOrderReward_show = table.deserialize(configTemplate["goldOrderReward_show"].value)
    local iconRewardCount = math.min(awardNum, math.random(goldOrderReward_show[1], goldOrderReward_show[2]))
    local awardIndexAry = {}
    for i = 1, awardNum do
        awardIndexAry[i] = i
    end
    local iconAwardIndexSet = {}
    for i = 1, iconRewardCount do
        local randomIndex = math.random(#awardIndexAry)
        iconAwardIndexSet[awardIndexAry[randomIndex]] = true
        awardIndexAry[randomIndex] = awardIndexAry[#awardIndexAry]
        awardIndexAry[#awardIndexAry] = nil
    end
    --local orderRewardTypeWight =  table.deserialize(configTemplate["goldOrderReward_typeWeight"].value)
    --local goldRate = orderRewardTypeWight[1]
    --local specialRete = orderRewardTypeWight[2]
    local specialWeight = table.deserialize(configTemplate["goldOrderReward_specialWeight"].value)
    local diamondRate = specialWeight[1][1]
    local speedItemRate = specialWeight[2][1]
    local collectItemRate = specialWeight[3][1]
    local configItemIDRate = specialWeight[4][1]
    local configItemTypeRate = specialWeight[5][1]
    local glodFloat = table.deserialize(configTemplate["goldOrderReward_goldFloat"].value)
    local awardAry = {}
    for i = 1, awardNum do
        --if not special or math.random(1, goldRate + specialRete) <=goldRate then
        if iconAwardIndexSet[i] then
            local awardGoldNum = math.ceil(goldNum * (math.random() * math.abs(glodFloat[1] - glodFloat[2]) + math.min(glodFloat[1], glodFloat[2])))
            awardAry[#awardAry + 1] = {itemTemplateId = ItemId.COIN, count = awardGoldNum}
        else
            --special = false
            local random = math.random(1,diamondRate + speedItemRate + collectItemRate + configItemIDRate + configItemTypeRate)
            if random <= diamondRate then
                awardAry[#awardAry + 1] = {itemTemplateId = ItemId.DIAMOND, count = specialWeight[1][2]}
            elseif random <= diamondRate + speedItemRate then
                local speedItemTypeAry = table.deserialize(configTemplate["goldOrderReward_speedUpItemType"].value)
                local speedItemIdAry = {}
                for _, item in pairs(AppServices.Meta.metas.ItemTemplate) do
                    if table.exists(speedItemTypeAry, item.type) then
                        speedItemIdAry[#speedItemIdAry + 1] = item.id
                    end
                end
                if #speedItemIdAry > 0 then
                    local speedItemId = speedItemIdAry[math.random(1, #speedItemIdAry)]
                    awardAry[#awardAry + 1] = {itemTemplateId = speedItemId, count = specialWeight[2][2]}
                else    --容错
                    awardAry[#awardAry + 1] = {itemTemplateId = ItemId.COIN, count = 1}
                end
            elseif random <= diamondRate + speedItemRate + collectItemRate then
                local cfgs = AppServices.Meta:Category("CollectionTemplate")
                local itemIdAry = {}
                local itemIdSet = {}
                for _, cfg in pairs(cfgs) do
                    for _, item in pairs(cfg.items) do
                        if not itemIdSet[item[1]] then
                            itemIdSet[item[1]] = true
                            itemIdAry[#itemIdAry + 1] = item[1]
                        end
                    end
                end
                local itemId = itemIdAry[math.random(1, #itemIdAry)]
                awardAry[#awardAry + 1] = {itemTemplateId = itemId, count = specialWeight[3][2]}
            elseif random <= diamondRate + speedItemRate + collectItemRate + configItemIDRate then
                local configItemIDAry = table.deserialize(configTemplate["goldOrderReward_item"].value)
                local total = 0
                for _, item in ipairs(configItemIDAry) do
                    total = total + item[2]
                end
                if total > 0 then
                    local random2 = math.random(1, total)
                    total = 0
                    for _, item in ipairs(configItemIDAry) do
                        total = total + item[2]
                        if random2 <= total then
                            awardAry[#awardAry + 1] = {itemTemplateId = item[1], count = item[3]}
                            break
                        end
                    end
                else    --容错
                    awardAry[#awardAry + 1] = {itemTemplateId = ItemId.COIN, count = 1}
                end
            else
                local configItemTypeAry = table.deserialize(configTemplate["goldOrderReward_type"].value)
                local total = 0
                for _, itemType in ipairs(configItemTypeAry) do
                    total = total + itemType[2]
                end
                if total > 0 then
                    local random2 = math.random(1, total)
                    total = 0
                    local getItemType
                    for _, itemType in ipairs(configItemTypeAry) do
                        total = total + itemType[2]
                        if random2 <= total then
                            getItemType = itemType
                            break
                        end
                    end
                    local getItemAry = {}
                    local itemMeta = AppServices.Meta:GetAllItemMeta()
                    for _, item in pairs(itemMeta) do
                        if item.type == getItemType[1] then
                            getItemAry[#getItemAry + 1] = item.id
                        end
                    end
                    if #getItemAry > 0 then
                        local getItemID = getItemAry[math.random(1, #getItemAry)]
                        awardAry[#awardAry + 1] = {itemTemplateId = getItemID, count = getItemType[3]}
                    else    --容错
                        awardAry[#awardAry + 1] = {itemTemplateId = ItemId.COIN, count = 1}
                    end
                else    --容错
                    awardAry[#awardAry + 1] = {itemTemplateId = ItemId.COIN, count = 1}
                end
            end
        end
    end
    return awardAry
end

function GoldOrderManager:GetSkipCDCost()
    local goldOrderCDCost = table.deserialize(self.configTemplate["goldOrderCDCost"].value)
    local sec = math.max(0, self.serverInfo.cdEndMill / 1000 - TimeUtil.ServerTime())
    local count = math.ceil(sec / 60 / goldOrderCDCost[1]) * goldOrderCDCost[2]
    return count, math.fmod(sec, 60 * goldOrderCDCost[1]), 60 * goldOrderCDCost[1]
end

function GoldOrderManager:GetStepAward(cumulativeNum)
    local stepNumAry = self.serverInfo.cumulativeCfgNums
    local stepIndex = table.indexOf(stepNumAry, cumulativeNum)
    return stepIndex
end

function GoldOrderManager:CanDraw()
    if self:IsOpen() == false then
        return false
    end
    local needCount = tonumber(self.configTemplate["goldOrderItemNum"].value)
    local hasCount = AppServices.User:GetItemAmount(self.serverInfo.itemId)
    return needCount <= hasCount
end

--GoldOrderManager:Init()

return GoldOrderManager
