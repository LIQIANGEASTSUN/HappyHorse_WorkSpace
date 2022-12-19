---
--- Created by Betta.
--- DateTime: 2021/9/13 15:03
---
local Base = require("Game.System.Gift.GiftPrecondition.GiftPreconditionBase")
---@class GiftPreconditionBoughtGift : GiftPreConditionBase
local GiftPreconditionBoughtGift = class(Base, "GiftPreconditionBoughtGift")

function GiftPreconditionBoughtGift:ctor(checkGiftID, isLast)
    self.checkGiftID = checkGiftID
    self.isLast = isLast
end

function GiftPreconditionBoughtGift:Check()
    if self.checkGiftID == nil then
        return false
    end
    local ret = AppServices.GiftManager:IsBoughtGift(self.checkGiftID, self.isLast)
    console.dk(self.checkGiftID, "礼包是否购买：", ret) --@DEL
    return ret
end

return GiftPreconditionBoughtGift