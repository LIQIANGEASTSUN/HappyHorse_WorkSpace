---
--- Created by Betta.
--- DateTime: 2021/9/13 15:19
---
--GiftPreconditionNoBuyGift
local Base = require("Game.System.Gift.GiftPrecondition.GiftPreconditionBase")
---@class GiftPreconditionNoBuyGift : GiftPreConditionBase
local GiftPreconditionNoBuyGift = class(Base, "GiftPreconditionNoBuyGift")

function GiftPreconditionNoBuyGift:SetCheckParam(checkGiftID)
    self.checkGiftID = checkGiftID
end

function GiftPreconditionNoBuyGift:Check()
    local ret = not AppServices.GiftManager:IsBoughtGift(self.checkGiftID)
    console.dk(self.checkGiftID, "礼包是否没购买：", ret) --@DEL
    return ret
end

return GiftPreconditionNoBuyGift