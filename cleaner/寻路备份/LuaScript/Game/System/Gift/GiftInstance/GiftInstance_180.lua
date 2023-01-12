---
--- Created by Betta.
--- DateTime: 2022/6/6 11:40
---
---龙源石礼包18.99 _33
local LessItemCount = require("Game.System.Gift.GiftPrecondition.GiftPreconditionLessItemCount")
local Base = require("Game.System.Gift.GiftInstance.GiftInstanceBase")
---@class GiftInstance_180 : GiftInstanceBase
local GiftInstance_180 = class(Base, "GiftInstance_180")

function GiftInstance_180:ctor(config)
    GiftInstance_180.super.ctor(self, config)

    self.checkCount = 10

    local lessItemCount = LessItemCount.new()
    lessItemCount:SetCheckParam(ItemId.DRAGONBREED, self.checkCount)
    self.preconditionAry[#self.preconditionAry + 1] = lessItemCount

    local Bought180 = Base.PreconditionBoughtGift.new(180, false)  --购买了180档次

    local trigger180 = Base.PreconditionTriggerGift.new(180)
    local Bought33 = Base.PreconditionBoughtGift.new(33, true)
    local upCheck = Base.PreconditionAND.new({ Bought33, Base.PreconditionNO.new(trigger180)})  --购买了33档位，还没触发过180档位，尝试触发452档位
    self:AddPrecondition(Base.PreconditionOR.new({Bought180, upCheck}))
end

function GiftInstance_180:AutoOpenEvent()
    return {}
end

function GiftInstance_180:GetPanelName()
    return "GiftResourcePanel"
end

function GiftInstance_180:GetPopFlag()
    return {}
end

function GiftInstance_180:GetUIConfig()
    return {Localization = {localization_title = "UI_gift_dragon_stone_title", localization_desc = "ui_gift_dragon_stone_desc", text_buy = "UI_gift_buy"}}
end

return GiftInstance_180