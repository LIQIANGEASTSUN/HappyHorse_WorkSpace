---
--- Created by Betta.
--- DateTime: 2021/9/13 16:24
---

local Base = require("Game.System.Gift.GiftPrecondition.GiftPreconditionBase")
---@class GiftPreconditionLessItemCount : GiftPreConditionBase
local GiftPreconditionLessItemCount = class(Base, "GiftPreconditionLessItemCount")

function GiftPreconditionLessItemCount:ctor(itemID, itemCount)
    self:SetCheckParam(itemID, itemCount)
end

function GiftPreconditionLessItemCount:SetCheckParam(itemID, itemCount)
    self.itemID = itemID
    self.itemCount = itemCount
end

function GiftPreconditionLessItemCount:Check()
    local hadCount = AppServices.User:GetItemAmount(self.itemID)
    local ret = hadCount < self.itemCount
    console.dk(string.format("%s数量是否小于%s:%s", self.itemID, self.itemCount, ret)) --@DEL
    return ret
end

return GiftPreconditionLessItemCount