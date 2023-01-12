local SuperCls = require "UI.Components.DiamondItem"

---@class DiamondItemLite:DiamondItem
local DiamondItemLite = class(SuperCls)

---@return DiamondItemLite
function DiamondItemLite:Create()
    local gameObject = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_HOMESCENE_DIAMONDITEM)
    return DiamondItemLite:CreateWithGameObject(gameObject)
end

function DiamondItemLite:CreateWithGameObject(gameObject)
    local instance = DiamondItemLite.new()
    instance:InitWithGameObject(gameObject)
    return instance
end

function DiamondItemLite:InitWithGameObject(gameObject)
    SuperCls.InitWithGameObject(self, gameObject)
    self.animator_add.gameObject:SetActive(false)
end

-- 不能点击
function DiamondItemLite:OnAddBtnClick()
end

function DiamondItemLite:SetInteractable(value)
end

function DiamondItemLite:HandleRedDot()
end

function DiamondItemLite:ShowEnterAnim(instant, finishCallback)
    SuperCls.ShowEnterAnim(self, instant, finishCallback)
end

function DiamondItemLite:OnHit()
    self.icon_animator:SetTrigger("add")
end

return DiamondItemLite
