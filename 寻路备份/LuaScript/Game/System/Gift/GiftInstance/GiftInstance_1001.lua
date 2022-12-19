---GiftInstance_1001
--- Created by Betta.
--- DateTime: 2021/9/9 18:25
---
---钥匙礼包
local Base = require("Game.System.Gift.GiftInstance.GiftInstance_1000")
---@class GiftInstance_1001 : GiftInstance_1000
local GiftInstance_1001 = class(Base, "GiftInstance_1001")

function GiftInstance_1001:ctor(config)
    GiftInstance_1001.super.ctor(self, config)
end

return GiftInstance_1001
