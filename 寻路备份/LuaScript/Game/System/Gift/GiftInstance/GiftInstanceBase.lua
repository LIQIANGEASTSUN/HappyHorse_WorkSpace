---
--- Created by Betta.
--- DateTime: 2021/9/8 16:59
---
---@class GiftInstanceBase
local GiftInstanceBase = class(nil, "GiftInstanceBase")
GiftInstanceBase.PreconditionAfterNoRecharge = require("Game.System.Gift.GiftPrecondition.GiftPreconditionAfterNoRecharge")
GiftInstanceBase.PreconditionAND = require("Game.System.Gift.GiftPrecondition.GiftPreconditionAND")
GiftInstanceBase.PreconditionBoughtGift = require("Game.System.Gift.GiftPrecondition.GiftPreconditionBoughtGift")
GiftInstanceBase.PreconditionCurSceneLowerlimit = require("Game.System.Gift.GiftPrecondition.GiftPreconditionCurSceneLowerlimit")
GiftInstanceBase.PreconditionGiftEnd = require("Game.System.Gift.GiftPrecondition.GiftPreconditionGiftEnd")
GiftInstanceBase.PreconditionLessItemCount = require("Game.System.Gift.GiftPrecondition.GiftPreconditionLessItemCount")
GiftInstanceBase.PreconditionMaxLevel = require("Game.System.Gift.GiftPrecondition.GiftPreConditionMaxLevel")
GiftInstanceBase.PreconditionNO= require("Game.System.Gift.GiftPrecondition.GiftPreconditionNO")
GiftInstanceBase.PreconditionOR = require("Game.System.Gift.GiftPrecondition.GiftPreconditionOR")
GiftInstanceBase.PreconditionTriggerGift = require("Game.System.Gift.GiftPrecondition.GiftPreconditionTriggerGift")
GiftInstanceBase.PreconditionUserGroup = require("Game.System.Gift.GiftPrecondition.GiftPreconditionUserGroup")


function GiftInstanceBase:ctor(config)
    console.assert(config ~= nil, "config is nil")
    ---@type GiftTemplate
    self.config = config
    --self.closeTime = 0
    --self.openTime = 0
    self.popTime = 0    --时间
    self.popTimes = 0   --次数
    ---@type GiftPreConditionBase[]
    self.preconditionAry = {}
    self.shopConfig = nil
end

function GiftInstanceBase:Open()
    console.dk("gift Open", self.config.id) --@DEL
    --[[
    local shopTemplate = AppServices.Meta:Category("ShopTemplate")
    for _, config in pairs(shopTemplate) do
        if config.shopSubType == self.config.id then
            self.shopConfig = config
            break
        end
    end
    ]]
    if not self.config then
        return
    end

    if self.config.shopGroupID ~= "-1" then
        local meta = AppServices.ShopGroupManager:GetShopGoods(self.config.shopGroupID)
        self.shopConfig = meta[1]
        self.shopType = AppServices.ShopGroupManager:GetShopCostType(self.config.shopGroupID)
    elseif not string.isEmpty(self.config.diamondShopID) then
        local shopTemplate = AppServices.Meta:Category("DiamondShopTemplate")
        self.shopConfig = shopTemplate[self.config.diamondShopID]
        self.shopType = CurrencyType.Diamond
    elseif not string.isEmpty(self.config.shopID) then
        local shopTemplate = AppServices.Meta:Category("ShopTemplate")
        self.shopConfig = shopTemplate[self.config.shopID]
        self.shopType = CurrencyType.Money
    end
    MessageDispatcher:SendMessage(MessageType.Gift_Open, self)
    AppServices.GiftFrameManager:AddPack(GiftFrameType["Gift" .. self.config.id])
end

function GiftInstanceBase:Close()
    console.dk("gift close", self.config.id) --@DEL
    MessageDispatcher:SendMessage(MessageType.Gift_Close, self)
    AppServices.GiftFrameManager:RemovePack(GiftFrameType["Gift" .. self.config.id])
end
---@return GiftPreConditionBase
function GiftInstanceBase:AddPrecondition(precondition)
    self.preconditionAry[#self.preconditionAry + 1] = precondition
    return precondition
end

function GiftInstanceBase:Check()
    console.dk("check instance Id", self.config.id) --@DEL
    for _, v in ipairs(self.preconditionAry) do
        if not v:Check() then
            return false
        end
    end
    return true
end

function GiftInstanceBase:IsAutoOpen()
    return false
end

function GiftInstanceBase:AutoOpenEvent()
    return {GIFT_OPEN_TIME.OnLevelUp, GIFT_OPEN_TIME.OnSelfCDEnd, GIFT_OPEN_TIME.OnLogin, GIFT_OPEN_TIME.OnGroupCDEnd, GIFT_OPEN_TIME.OnGiftClose}
end

function GiftInstanceBase:GetOpenTime()
    return 0
end

function GiftInstanceBase:GetPanelName()
    return ""
end

function GiftInstanceBase:GetPopFlag()
    return {1, 2}
end

function GiftInstanceBase:GetUIConfig()
    return {Localization= {}}
end

function GiftInstanceBase:CheckPopUP()
    --do return true end
    if self.popTime + self.config.popUpCD * 3600 > TimeUtil.ServerTime() then   --cd 不足
        return false
    end
    if self.popTime < TimeUtil.Get0ClockOfToday() then  --上次弹是上一天的了，不判断次数
        return true
    end
    return self.popTimes < self.config.popUpTimes
end

function GiftInstanceBase:CountPopUp()
    if self.popTime < TimeUtil.Get0ClockOfToday() then  --上次弹是上一天的了，从头计数
        self.popTimes = 0
    end
    self.popTimes = self.popTimes + 1
    self.popTime = TimeUtil.ServerTime()
    AppServices.GiftManager:WriteToFile()
end

return GiftInstanceBase
