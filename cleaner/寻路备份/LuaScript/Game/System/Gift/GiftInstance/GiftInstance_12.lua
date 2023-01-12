---
--- Created by Betta.
--- DateTime: 2021/9/9 18:25
---
---新手礼包2
local Base = require("Game.System.Gift.GiftInstance.GiftInstanceBase")
local NoBuyGift = require("Game.System.Gift.GiftPrecondition.GiftPreconditionNoBuyGift")
local GiftEnd = require("Game.System.Gift.GiftPrecondition.GiftPreconditionGiftEnd")
local NoRecharge = require("Game.System.Gift.GiftPrecondition.GiftPreconditionAfterNoRecharge")
---@class GiftInstance_12 : GiftInstanceBase
local GiftInstance_12 = class(Base, "GiftInstance_12")

function GiftInstance_12:ctor(config)
    GiftInstance_12.super.ctor(self, config)

    self.preGiftID = 11
    self.openDelay = 48 * 60 * 60

    local noBuyGift = NoBuyGift.new()
    noBuyGift:SetCheckParam(self.preGiftID)
    self.preconditionAry[#self.preconditionAry + 1] = noBuyGift
    local giftEnd = GiftEnd.new()
    giftEnd:SetCheckParam(self.preGiftID)
    self.preconditionAry[#self.preconditionAry + 1] = giftEnd
    local noRecharge = NoRecharge.new()
    noRecharge:SetCheckParam(self.preGiftID)
    self.preconditionAry[#self.preconditionAry + 1] = noRecharge
end

function GiftInstance_12:GetOpenTime()
    if not AppServices.GiftManager:HaveOpenInfo(self.preGiftID) then
        return 0
    end
    return AppServices.GiftManager:GetGiftCloseTime(self.preGiftID) + self.openDelay
end

function GiftInstance_12:IsAutoOpen()
    return true
end

function GiftInstance_12:GetPanelName()
    return "GiftNewconmerPanel"
end

function GiftInstance_12:GetUIConfig()
    return {Localization = {localization_title = "UI_gift_beginner2_title", localization_desc = "UI_gift_beginner2_desc"}}
end

return GiftInstance_12