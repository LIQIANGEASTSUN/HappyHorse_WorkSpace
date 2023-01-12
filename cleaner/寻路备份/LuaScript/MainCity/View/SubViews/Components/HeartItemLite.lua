local SuperCls = require "UI.Components.HeartItem"

---@class HeartItemLite:HeartItem
local HeartItemLite = class(SuperCls)

function HeartItemLite:Create()
    local gameObject = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_HOMESCENE_HEARTITEM)
    return HeartItemLite:CreateWithGameObject(gameObject)
end

function HeartItemLite:CreateWithGameObject(gameObject)
    local instance = HeartItemLite.new()
    instance:InitWithGameObject(gameObject)
    return instance
end

function HeartItemLite:InitWithGameObject(gameObject)
    SuperCls.InitWithGameObject(self, gameObject)
    self.btn_add:SetActive(false)
end

function HeartItemLite:OnAddBtnClick()
end

function HeartItemLite:SetInteractable(value)
end

function HeartItemLite:OnHit()
    self.flickerAnimator:SetTrigger("shake")
end

return HeartItemLite
