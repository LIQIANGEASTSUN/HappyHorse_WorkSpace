---GiftInstance_1100
--- Created by Betta.
--- DateTime: 2021/9/9 18:25
---
---钥匙礼包
local Base = require("Game.System.Gift.GiftInstance.GiftInstanceBase")
---@class GiftInstance_1100 : GiftInstanceBase
local GiftInstance_1100 = class(Base, "GiftInstance_1100")

function GiftInstance_1100:ctor(config)
    GiftInstance_1100.super.ctor(self, config)
    self.donotShowUI = true
    self.donotCreateIcon = true
end

function GiftInstance_1100:AutoOpenEvent()
    return {}
end

function GiftInstance_1100:GetPanelName()
    return ""
end

function GiftInstance_1100:GetPopFlag()
    return {}
end

function GiftInstance_1100:GetUIConfig()
    return {
        Localization = {
            localization_title = "yao shi li bao",
            localization_desc = "UI_gift_key_desc",
            text_buy = "UI_gift_buy"
        }
    }
end

function GiftInstance_1100:Open()
    if not self.config then
        return
    end

    local shopTemplate = AppServices.Meta:Category("ShopTemplate")
    self.shopConfig = shopTemplate[tostring(self.config.itemIds[1])]
end

return GiftInstance_1100
