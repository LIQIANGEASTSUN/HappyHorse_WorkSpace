---@type UnitTipsInfo
local UnitTipsInfo = require "Cleaner.UnitTips.Base.UnitTipsInfo"

---@type UnitTipsBase
local UnitTipsBase = require "Cleaner.UnitTips.Base.UnitTipsBase"

---@type UnitProductFinishTips
local UnitProductFinishTips = class(UnitTipsBase, "UnitProductFinishTips")

function UnitProductFinishTips:ctor(unitId)
    self:SetTipsType(TipsType.UnitProductFinishTips)
    self:SetUseUpdate(true)
    self:SetTipsFollowType(UnitTipsInfo.TipsFollowType.Unit)
    self:SetTipsPath(CONST.ASSETS.G_PRODUCT_FINISH_TIPS)
end

function UnitProductFinishTips:Click()
    UnitTipsBase.Click(self)

    local unitId = self:GetUnitId()
    local factoryUnit = AppServices.UnitManager:GetUnit(unitId)
    if factoryUnit then
        factoryUnit:ProductionTipsClick()
    end
end

function UnitProductFinishTips:LoadFinish()
    UnitTipsBase.LoadFinish(self)

    local icon = self.go.transform:Find("Icon"):GetComponent(typeof(SpriteRenderer))
    local txt_count = self.go.transform:Find("txt_count"):GetComponent(typeof(TextMeshPro))

    local productionData = self.unit:GetProductionData()
    for _, data in pairs(productionData.outItem) do
        local key = data.key
        local count = data.value
        local itemData = AppServices.Meta:Category("ItemTemplate")[tostring(key)]
        local sprite = self:GetItemSprite(itemData.icon)
        icon.sprite = sprite
        txt_count.text = tostring(count)
    end
end

return UnitProductFinishTips