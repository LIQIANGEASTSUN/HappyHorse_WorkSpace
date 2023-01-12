---
--- Created by Betta.
--- DateTime: 2021/9/9 18:25
---
---能量礼包1
local LessItemCount = require("Game.System.Gift.GiftPrecondition.GiftPreconditionLessItemCount")
local PiggyBank = require("Game.System.Gift.GiftPrecondition.GiftPreconditionPiggyBank")
local Base = require("Game.System.Gift.GiftInstance.GiftInstanceBase")
---@class GiftInstance_21 : GiftInstanceBase
local GiftInstance_21 = class(Base, "GiftInstance_21")

function GiftInstance_21:ctor(config)
    GiftInstance_21.super.ctor(self, config)

    self.checkCount = 5

    local lessItemCount = LessItemCount.new()
    lessItemCount:SetCheckParam(ItemId.ENERGY, self.checkCount)
    self.preconditionAry[#self.preconditionAry + 1] = lessItemCount
    local piggyBank = PiggyBank.new()
    piggyBank:SetCheckParam(false, false)
    self.preconditionAry[#self.preconditionAry + 1] = piggyBank
end

function GiftInstance_21:IsAutoOpen()
    return true
end

function GiftInstance_21:AutoOpenEvent()
    local t = GiftInstance_21.super.AutoOpenEvent(self)
    table.insert(t, GIFT_OPEN_TIME.OnUseItem)
    return t
end

function GiftInstance_21:GetPanelName()
    return "GiftEnergyPanel"
end

function GiftInstance_21:GetPopFlag()
    return {}
end

function GiftInstance_21:GetUIConfig()
    return {Localization = {localization_title = "UI_gift_energy_title"}}
end

return GiftInstance_21