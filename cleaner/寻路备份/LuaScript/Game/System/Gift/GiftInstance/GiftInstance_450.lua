---
--- Created by Betta.
--- DateTime: 2022/4/19 11:50
---
---棒棒糖礼包1
local Base = require("Game.System.Gift.GiftInstance.GiftInstanceBase")
---@class GiftInstance_450 : GiftInstanceBase
local GiftInstance_450 = class(Base, "GiftInstance_450")

function GiftInstance_450:ctor(config)
    GiftInstance_450.super.ctor(self, config)
end

function GiftInstance_450:GetPanelName()
    return "GiftResourcePanel"
end

function GiftInstance_450:AutoOpenEvent()
    return {}
end

function GiftInstance_450:GetUIConfig()
    return {Localization = {localization_title = "UI_gift_key_title", localization_desc = "UI_gift_key_desc", text_buy = "UI_gift_buy"}}
end

return GiftInstance_450