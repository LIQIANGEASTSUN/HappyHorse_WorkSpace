---
--- Created by Betta.
--- DateTime: 2021/9/9 18:25
---
---钥匙礼包
local Base = require("Game.System.Gift.GiftInstance.GiftInstanceBase")
---@class GiftInstance_31 : GiftInstanceBase
local GiftInstance_31 = class(Base, "GiftInstance_31")

function GiftInstance_31:ctor(config)
    GiftInstance_31.super.ctor(self, config)


end

function GiftInstance_31:AutoOpenEvent()
    return {}
end

function GiftInstance_31:GetPanelName()
    return "GiftResourcePanel"
end

function GiftInstance_31:GetPopFlag()
    return {1}
end

function GiftInstance_31:GetUIConfig()
    return {Localization = {localization_title = "yao shi li bao", localization_desc = "UI_gift_key_desc", text_buy = "UI_gift_buy"}}
end

return GiftInstance_31