---
--- Created by Betta.
--- DateTime: 2021/9/9 18:25
---
---龙源石礼包4.99
local MaxLevel = require("Game.System.Gift.GiftPrecondition.GiftPreConditionMaxLevel")
local LessItemCount = require("Game.System.Gift.GiftPrecondition.GiftPreconditionLessItemCount")
local Base = require("Game.System.Gift.GiftInstance.GiftInstanceBase")
---@class GiftInstance_32 : GiftInstanceBase
local GiftInstance_32 = class(Base, "GiftInstance_32")

function GiftInstance_32:ctor(config)
    GiftInstance_32.super.ctor(self, config)

    self.checkCount = 10

    local maxLevel = MaxLevel.new()
    maxLevel:SetCheckParam(19)
    self.preconditionAry[#self.preconditionAry + 1] = maxLevel
    local lessItemCount = LessItemCount.new()
    lessItemCount:SetCheckParam(ItemId.DRAGONBREED, self.checkCount)
    self.preconditionAry[#self.preconditionAry + 1] = lessItemCount
end

function GiftInstance_32:AutoOpenEvent()
    return {}
end

function GiftInstance_32:GetPanelName()
    return "GiftResourcePanel"
end

function GiftInstance_32:GetPopFlag()
    return {}
end

function GiftInstance_32:GetUIConfig()
    return {Localization = {localization_title = "UI_gift_dragon_stone_title", localization_desc = "ui_gift_dragon_stone_desc", text_buy = "UI_gift_buy"}}
end

return GiftInstance_32