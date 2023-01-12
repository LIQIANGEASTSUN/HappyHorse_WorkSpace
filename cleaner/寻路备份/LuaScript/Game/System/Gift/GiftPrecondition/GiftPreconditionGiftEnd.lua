---
--- Created by Betta.
--- DateTime: 2021/9/13 11:36
---
---判断礼包是否已经结束
local Base = require("Game.System.Gift.GiftPrecondition.GiftPreconditionBase")
---@class GiftPreconditionGiftEnd : GiftPreConditionBase
local GiftPreconditionGiftEnd = class(Base, "GiftPreconditionGiftEnd")

function GiftPreconditionGiftEnd:SetCheckParam(checkGiftID)
    self.checkGiftID = checkGiftID
end

function GiftPreconditionGiftEnd:Check()
    local ret = false
    if AppServices.GiftManager:HaveOpenInfo(self.checkGiftID) then
        local closeTime = AppServices.GiftManager:GetGiftCloseTime(self.checkGiftID)
        ret = TimeUtil.ServerTime() >= closeTime
    end
    console.dk(self.checkGiftID, "礼包是否结束：", ret) --@DEL
    return ret
end

return GiftPreconditionGiftEnd
