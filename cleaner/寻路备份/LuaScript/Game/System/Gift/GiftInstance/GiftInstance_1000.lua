---GiftInstance_1000
--- Created by Betta.
--- DateTime: 2021/9/9 18:25
---
---钥匙礼包
local Base = require("Game.System.Gift.GiftInstance.GiftInstanceBase")
---@class GiftInstance_1000 : GiftInstanceBase
local GiftInstance_1000 = class(Base, "GiftInstance_1000")

function GiftInstance_1000:ctor(config)
    GiftInstance_1000.super.ctor(self, config)
end

function GiftInstance_1000:AutoOpenEvent()
    return {}
end

function GiftInstance_1000:GetPanelName()
    return "GiftExtraRewardPanel"
end

function GiftInstance_1000:GetPopFlag()
    return {}
end

function GiftInstance_1000:GetUIConfig()
    return {
        Localization = {
            localization_title = "yao shi li bao",
            localization_desc = "UI_gift_key_desc",
            text_buy = "UI_gift_buy"
        }
    }
end

function GiftInstance_1000:Open()
    console.dk("gift GiftInstance_1001 Open", self.config.id) --@DEL
    if not self.config then
        return
    end

    local shopTemplate = AppServices.Meta:Category("ShopTemplate")
    self.shopConfig = shopTemplate[tostring(self.config.itemIds[1])]
    MessageDispatcher:SendMessage(MessageType.Gift_Open, self)
    AppServices.GiftFrameManager:AddPack(GiftFrameType["Gift" .. self.config.id])
end

return GiftInstance_1000
