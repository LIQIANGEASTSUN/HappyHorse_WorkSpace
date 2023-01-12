---
--- Created by Betta.
--- DateTime: 2021/9/9 18:25
---
---龙源石礼包6.99
local LessItemCount = require("Game.System.Gift.GiftPrecondition.GiftPreconditionLessItemCount")
local Base = require("Game.System.Gift.GiftInstance.GiftInstanceBase")
---@class GiftInstance_33 : GiftInstanceBase
local GiftInstance_33 = class(Base, "GiftInstance_33")

function GiftInstance_33:ctor(config)
    GiftInstance_33.super.ctor(self, config)

    self.checkCount = 10

    local lessItemCount = LessItemCount.new()
    lessItemCount:SetCheckParam(ItemId.DRAGONBREED, self.checkCount)
    self.preconditionAry[#self.preconditionAry + 1] = lessItemCount
end

function GiftInstance_33:AutoOpenEvent()
    return {}
end

function GiftInstance_33:GetPanelName()
    return "GiftResourcePanel"
end

function GiftInstance_33:GetPopFlag()
    return {}
end

function GiftInstance_33:GetUIConfig()
    return {Localization = {localization_title = "UI_gift_dragon_stone_title", localization_desc = "ui_gift_dragon_stone_desc", text_buy = "UI_gift_buy"}}
end

return GiftInstance_33