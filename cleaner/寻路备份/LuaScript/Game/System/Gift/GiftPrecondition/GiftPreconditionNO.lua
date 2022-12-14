---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by DKSS.
--- DateTime: 2022/5/31 18:54
---

local Base = require("Game.System.Gift.GiftPrecondition.GiftPreconditionBase")
---@class GiftPreconditionNO : GiftPreConditionBase
local GiftPreconditionNO = class(Base, "GiftPreconditionNO")

function GiftPreconditionNO:ctor(precondition)
    self.precondition = precondition
end

function GiftPreconditionNO:Check()
    return not self.precondition:Check()
end

return GiftPreconditionNO