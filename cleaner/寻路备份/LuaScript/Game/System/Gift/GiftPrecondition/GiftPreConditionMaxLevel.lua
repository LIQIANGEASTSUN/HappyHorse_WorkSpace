---
--- Created by Betta.
--- DateTime: 2021/9/15 20:24
---

local Base = require("Game.System.Gift.GiftPrecondition.GiftPreconditionBase")
---@class GiftPreconditionMaxLevel : GiftPreConditionBase
local GiftPreconditionMaxLevel = class(Base, "GiftPreconditionMaxLevel")

function GiftPreconditionMaxLevel:SetCheckParam(level)
    self.level = level
end

function GiftPreconditionMaxLevel:Check()
    return AppServices.User:GetCurrentLevelId() <= self.level
end

return GiftPreconditionMaxLevel