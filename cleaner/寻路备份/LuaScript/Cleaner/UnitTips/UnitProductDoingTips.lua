---@type UnitTipsInfo
local UnitTipsInfo = require "Cleaner.UnitTips.Base.UnitTipsInfo"

---@type UnitTipsBase
local UnitTipsBase = require "Cleaner.UnitTips.Base.UnitTipsBase"

---@type UnitProductDoingTips
local UnitProductDoingTips = class(UnitTipsBase, "UnitProductDoingTips")

function UnitProductDoingTips:ctor(unitId)
    self.startTime = 0
    self.endTime = 0
    self.totalTime = 0

    self:SetTipsType(TipsType.UnitProductDoingTips)
    self:SetUseUpdate(true)
    self:SetTipsFollowType(UnitTipsInfo.TipsFollowType.Unit)
    self:SetTipsPath(CONST.ASSETS.G_PRODUCT_DOING_TIPS)
end

function UnitProductDoingTips:Click()
    UnitTipsBase.Click(self)

    local unitId = self:GetUnitId()
    local factoryUnit = AppServices.UnitManager:GetUnit(unitId)
    if factoryUnit then
        factoryUnit:ProductionTipsClick()
    end
end

function UnitProductDoingTips:LoadFinish()
    UnitTipsBase.LoadFinish(self)
    self.transform = self.go.transform

    --local icon = self.go.transform:Find("IconBG/Icon"):GetComponent(typeof(SpriteRenderer))
    self.txt_time = self.go.transform:Find("txt_time"):GetComponent(typeof(TextMeshPro))
    self.slider = self.transform:Find("slider/fill")

    local productionData = self.unit:GetProductionData()
    self.startTime = productionData.startTime
    self.endTime = productionData.endTime
    self.totalTime = self.endTime - self.startTime

    --[[
    for _, data in pairs(productionData.outItem) do
        local key = data.key
        local itemData = AppServices.Meta:Category("ItemTemplate")[tostring(key)]
        local sprite = self:GetItemSprite(itemData.icon)
        icon.sprite = sprite
    end
    --]]
end

function UnitProductDoingTips:RefreshTime()
    if not self.lastRefreshTime then
        self.lastRefreshTime = 0
    end
    if Time.realtimeSinceStartup - self.lastRefreshTime < 1 then
        return
    end

    if not Runtime.CSValid(self.txt_time) then
        return
    end

    if self.startTime > TimeUtil.ServerTime() then
        self.txt_time.text = ""
        return
    end

    local time = self.endTime - TimeUtil.ServerTime()
    self.txt_time.text = TimeUtil.SecToMS(time)

    local progress = 1 - time / self.totalTime
    progress = math.clamp(progress, 0, 1)
    local x = progress * 0.5 - 0.5
    local position = Vector3(x, 0, 0)
    self.slider.localPosition = position
    self.slider.localScale = Vector3(progress, 1, 1)
end

function UnitProductDoingTips:LateUpdate()
    UnitTipsBase.LateUpdate(self)
    self:RefreshTime()
end

return UnitProductDoingTips