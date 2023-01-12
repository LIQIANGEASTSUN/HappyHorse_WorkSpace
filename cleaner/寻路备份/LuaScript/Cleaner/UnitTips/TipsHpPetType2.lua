---@type UnitTipsInfo
local UnitTipsInfo = require "Cleaner.UnitTips.Base.UnitTipsInfo"

---@type TipsHpMonster
local TipsHpMonster = require "Cleaner.UnitTips.TipsHpMonster"

---@type TipsHpPetType2
local TipsHpPetType2 = class(TipsHpMonster, "TipsHpPetType2")

function TipsHpPetType2:ctor(unitId)
    self:SetTipsType(TipsType.UnitPetHpType2Tips)
    self:SetUseUpdate(true)
    self:SetTipsFollowType(UnitTipsInfo.TipsFollowType.Unit_And_Camera)
    self:SetTipsPath(CONST.ASSETS.G_PET_HP_TYPE2_TIPS)
end

function TipsHpPetType2:Refresh()
    TipsHpMonster.Refresh(self)
    if not Runtime.CSValid(self.slider) then
        return
    end

    local level = self.unit:GetLevel()
    self.txt_level.text = tostring(level)
end

function TipsHpPetType2:LoadFinish()
    self.transform = self.go.transform
    self.txt_level = self.transform:Find("txt_level"):GetComponent(typeof(TextMeshPro))
    TipsHpMonster.LoadFinish(self)
end

return TipsHpPetType2