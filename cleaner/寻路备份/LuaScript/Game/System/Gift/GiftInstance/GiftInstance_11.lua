---
--- Created by Betta.
--- DateTime: 2021/9/9 18:25
---
---新手礼包1
local MaxLevel = require("Game.System.Gift.GiftPrecondition.GiftPreConditionMaxLevel")
local Base = require("Game.System.Gift.GiftInstance.GiftInstanceBase")
---@class GiftInstance_11 : GiftInstanceBase
local GiftInstance_11 = class(Base, "GiftInstance_11")

function GiftInstance_11:ctor(config)
    GiftInstance_11.super.ctor(self, config)

    local maxLevel = MaxLevel.new()
    MaxLevel:SetCheckParam(6)
    self.preconditionAry[#self.preconditionAry + 1] = maxLevel
end

function GiftInstance_11:IsAutoOpen()
    return true
end

function GiftInstance_11:GetPanelName()
    return "GiftNewconmerPanel2"
end

function GiftInstance_11:GetUIConfig()
    return {Localization = {localization_title = "UI_gift_beginner3_title", localization_desc = "UI_gift_beginner3_desc1", localization_desc2 = "UI_gift_beginner3_desc2"}}
end

return GiftInstance_11