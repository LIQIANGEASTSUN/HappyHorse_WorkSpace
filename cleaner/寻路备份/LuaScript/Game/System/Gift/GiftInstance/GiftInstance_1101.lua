---GiftInstance_1101
--- Created by Betta.
--- DateTime: 2021/9/9 18:25
---
---钥匙礼包
local Base = require("Game.System.Gift.GiftInstance.GiftInstance_1100")
---@class GiftInstance_1101 : GiftInstance_1100
local GiftInstance_1101 = class(Base, "GiftInstance_1101")

function GiftInstance_1101:ctor(config)
    GiftInstance_1101.super.ctor(self, config)
    self.donotShowUI = true
    self.donotCreateIcon = true
end

return GiftInstance_1101
