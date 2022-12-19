---
--- Created by Betta.
--- DateTime: 2022/4/19 11:50
---
---棒棒糖礼包old不分档次
local Base = require("Game.System.Gift.GiftInstance.GiftInstanceBase")
---@class GiftInstance_34 : GiftInstanceBase
local GiftInstance_34 = class(Base, "GiftInstance_34")

function GiftInstance_34:GetPanelName()
    return "GiftResourcePanel"
end

function GiftInstance_34:AutoOpenEvent()
    return {}
end

function GiftInstance_34:GetUIConfig()
    return {Localization = {localization_title = "UI_gift_key_title", localization_desc = "UI_gift_key_desc", text_buy = "UI_gift_buy"}}
end

return GiftInstance_34


