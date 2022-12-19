---
--- Created by Betta.
--- DateTime: 2021/9/13 12:33
---
local Base = require("Game.System.Gift.GiftPrecondition.GiftPreconditionBase")
---@class GiftPreconditionAfterNoRecharge : GiftPreConditionBase
local GiftPreconditionAfterNoRecharge = class(Base, "GiftPreconditionAfterNoRecharge")

function GiftPreconditionAfterNoRecharge:SetCheckParam(checkGiftID)
    self.checkGiftID = checkGiftID
end

function GiftPreconditionAfterNoRecharge:Check()
    local ret = AppServices.User:GetLastRechargeTime() < AppServices.GiftManager:GetGiftCloseTime(self.checkGiftID)
    console.dk(AppServices.GiftManager:GetGiftCloseTime(self.checkGiftID), "以后是否充值：", ret) --@DEL
    return ret
end

return GiftPreconditionAfterNoRecharge