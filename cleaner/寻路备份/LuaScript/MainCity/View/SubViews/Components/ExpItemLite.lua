local SuperCls = require "UI.Components.ExpItem"

---@class ExpItemLite:ExpItem
local ExpItemLite = class(SuperCls)

function ExpItemLite:Create()
    local gameObject = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_HOMESCENE_EXPITEM)
    return ExpItemLite:CreateWithGameObject(gameObject)
end

function ExpItemLite:CreateWithGameObject(gameObject)
    local instance = ExpItemLite.new()
    instance:InitWithGameObject(gameObject)
    return instance
end

function ExpItemLite:InitWithGameObject(gameObject)
    SuperCls.InitWithGameObject(self, gameObject)
    -- self.btn_add:SetActive(false)
end

function ExpItemLite:OnAddBtnClick()
end

function ExpItemLite:OnHit()
    if self.icon_animator then
        self.icon_animator:SetTrigger("add")
    end
end

function ExpItemLite:SetInteractable(value)
end

return ExpItemLite
