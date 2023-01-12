---
--- Created by Betta.
--- DateTime: 2022/5/12 15:36
---


local Base = require("Game.System.Gift.GiftPrecondition.GiftPreconditionBase")
---@class GiftPreconditionPiggyBank : GiftPreConditionBase
local GiftPreconditionPiggyBank = class(Base, "GiftPreconditionPiggyBank")

function GiftPreconditionPiggyBank:SetCheckParam(isOpen, isCanOpen)
    self.isOpen = isOpen
    self.isCanOpen = isCanOpen
end

function GiftPreconditionPiggyBank:Check()
    return self.isOpen == AppServices.PiggyBank:IsInCD() and self.isCanOpen == AppServices.PiggyBank:CanOpen()
end

return GiftPreconditionPiggyBank