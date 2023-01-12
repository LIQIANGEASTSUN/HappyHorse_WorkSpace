---
--- Created by Betta.
--- DateTime: 2021/12/21 18:36
---
---推图礼包
local Base = require("Game.System.Gift.GiftInstance.GiftInstanceBase")
---@class GiftInstance_460 : GiftInstanceBase
local GiftInstance_460 = class(Base, "GiftInstance_460")

function GiftInstance_460:ctor(config)
    GiftInstance_460.super.ctor(self, config)

    self:AddPrecondition(Base.PreconditionLessItemCount.new(ItemId.ENERGY, 1000))
    self:AddPrecondition(Base.PreconditionOR.new({Base.PreconditionCurSceneLowerlimit.new(1, 6), Base.PreconditionCurSceneLowerlimit.new(2), Base.PreconditionCurSceneLowerlimit.new(10)}))
end

function GiftInstance_460:AutoOpenEvent()
    return {GIFT_OPEN_TIME.OnChangeNewScene}
end

function GiftInstance_460:GetPanelName()
    return "GiftEnergyPanel"
end

function GiftInstance_460:GetPopFlag()
    return {}
end

function GiftInstance_460:GetUIConfig()
    return {Localization = {localization_title = "UI_explore_help_special"}}
end

return GiftInstance_460