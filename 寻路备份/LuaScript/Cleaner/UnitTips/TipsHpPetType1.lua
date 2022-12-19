
---@type UnitTipsInfo
local UnitTipsInfo = require "Cleaner.UnitTips.Base.UnitTipsInfo"

---@type UnitTipsBase
local UnitTipsBase = require "Cleaner.UnitTips.Base.UnitTipsBase"

---@type TipsHpPetType1
local TipsHpPetType1 = class(UnitTipsBase, "TipsHpPetType1")

function TipsHpPetType1:ctor(unitId)
    self.positionRefreshTime = 0
    self.offsetPos = Vector3(0, 1, 0)
    self.isLoaded = false

    self:SetTipsType(TipsType.UnitPetHpType1Tips)
    self:SetUseUpdate(true)
    self:SetTipsFollowType(UnitTipsInfo.TipsFollowType.Unit_And_Camera)
    self:SetTipsPath(CONST.ASSETS.G_PET_HP_TYPE1_TIPS)
end

function TipsHpPetType1:Refresh()
    if not self.isLoaded then
        return
    end

    local level = self.unit:GetLevel()
    self.txt_level.text = tostring(level)
end

function TipsHpPetType1:LoadFinish()
    UnitTipsBase.LoadFinish(self)
    self.isLoaded = true

    self.transform = self.go.transform
    self.txt_level = self.transform:Find("txt_level"):GetComponent(typeof(TextMeshPro))
    self:Refresh()
end

function TipsHpPetType1:CalculatePosition()
    if not self.lastRefreshPosTime then
        self.lastRefreshPosTime = 0
    end
    if Time.realtimeSinceStartup - self.lastRefreshPosTime < self.positionRefreshTime then
        return
    end
    self.lastRefreshPosTime = Time.realtimeSinceStartup

    if Runtime.CSValid(self.go) then
        local position = self:GetTargetPosition()
        local cameraPosition = Camera.main.transform.position
        --cameraPosition.x = position.x
        local offset = cameraPosition - position
        offset = offset.normalized

        self.transform.position = position + self.offsetPos + offset * 3
    end
end

return TipsHpPetType1