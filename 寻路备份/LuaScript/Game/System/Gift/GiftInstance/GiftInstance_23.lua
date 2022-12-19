---
--- Created by Betta.
--- DateTime: 2021/9/9 18:25
---
---能量礼包3
local Base = require("Game.System.Gift.GiftInstance.GiftInstanceBase")
local GiftEnd = require("Game.System.Gift.GiftPrecondition.GiftPreconditionGiftEnd")
local PiggyBank = require("Game.System.Gift.GiftPrecondition.GiftPreconditionPiggyBank")
---@class GiftInstance_23 : GiftInstanceBase
local GiftInstance_23 = class(Base, "GiftInstance_23")

function GiftInstance_23:ctor(config)
    GiftInstance_23.super.ctor(self, config)

    self.preGiftID = 21
    self.openDelay = 36 * 60 * 60

    local boughtGift21 = Base.PreconditionBoughtGift.new(21, true)
    local boughtGift22 = Base.PreconditionBoughtGift.new(22, true)
    self:AddPrecondition(Base.PreconditionOR.new({boughtGift21, boughtGift22}))

    local giftEnd = GiftEnd.new()
    giftEnd:SetCheckParam(self.preGiftID)
    self.preconditionAry[#self.preconditionAry + 1] = giftEnd
    local piggyBank = PiggyBank.new()
    piggyBank:SetCheckParam(false, false)
    self.preconditionAry[#self.preconditionAry + 1] = piggyBank
end

function GiftInstance_23:GetOpenTime()
    if not AppServices.GiftManager:HaveOpenInfo(self.preGiftID) then
        return 0
    end
    return AppServices.GiftManager:GetGiftCloseTime(self.preGiftID) + self.openDelay
end

function GiftInstance_23:IsAutoOpen()
    return true
end

function GiftInstance_23:GetPanelName()
    return "GiftEnergyPanel"
end

function GiftInstance_23:GetPopFlag()
    return {}
end

function GiftInstance_23:GetUIConfig()
    return {Localization = {localization_title = "UI_gift_energy_title"}}
end

return GiftInstance_23