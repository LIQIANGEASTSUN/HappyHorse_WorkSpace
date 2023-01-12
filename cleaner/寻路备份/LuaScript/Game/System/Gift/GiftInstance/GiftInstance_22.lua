---
--- Created by Betta.
--- DateTime: 2021/9/9 18:25
---
---能量礼包2
local Base = require("Game.System.Gift.GiftInstance.GiftInstanceBase")
local NoBuyGift = require("Game.System.Gift.GiftPrecondition.GiftPreconditionNoBuyGift")
local GiftEnd = require("Game.System.Gift.GiftPrecondition.GiftPreconditionGiftEnd")
local PiggyBank = require("Game.System.Gift.GiftPrecondition.GiftPreconditionPiggyBank")
---@class GiftInstance_22 : GiftInstanceBase
local GiftInstance_22 = class(Base, "GiftInstance_22")

function GiftInstance_22:ctor(config)
    GiftInstance_22.super.ctor(self, config)

    self.preGiftID = 21
    self.openDelay = 36 * 60 * 60

    local noBuyGift = NoBuyGift.new()
    noBuyGift:SetCheckParam(self.preGiftID)
    self.preconditionAry[#self.preconditionAry + 1] = noBuyGift
    local giftEnd = GiftEnd.new()
    giftEnd:SetCheckParam(self.preGiftID)
    self.preconditionAry[#self.preconditionAry + 1] = giftEnd
    local piggyBank = PiggyBank.new()
    piggyBank:SetCheckParam(false, false)
    self.preconditionAry[#self.preconditionAry + 1] = piggyBank
end

function GiftInstance_22:GetOpenTime()
    if not AppServices.GiftManager:HaveOpenInfo(self.preGiftID) then
        return 0
    end
    return AppServices.GiftManager:GetGiftCloseTime(self.preGiftID) + self.openDelay
end

function GiftInstance_22:IsAutoOpen()
    return true
end

function GiftInstance_22:GetPanelName()
    return "GiftEnergyPanel"
end

function GiftInstance_22:GetPopFlag()
    return {}
end

function GiftInstance_22:GetUIConfig()
    return {Localization = {localization_title = "UI_gift_energy_title"}}
end

return GiftInstance_22