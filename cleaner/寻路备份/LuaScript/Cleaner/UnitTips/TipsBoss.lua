---@type UnitTipsInfo
local UnitTipsInfo = require "Cleaner.UnitTips.Base.UnitTipsInfo"

---@type UnitTipsBase
local UnitTipsBase = require "Cleaner.UnitTips.Base.UnitTipsBase"

---@type TipsBoss
local TipsBoss = class(UnitTipsBase, "TipsBoss")

function TipsBoss:ctor(unitId)
    self.positionRefreshTime = 0
    self.offsetPos = Vector3(0, 2.5, 0)
    self.isLoaded = false

    self:SetTipsType(TipsType.UnitBoss)
    self:SetUseUpdate(true)
    self:SetTipsFollowType(UnitTipsInfo.TipsFollowType.Unit_And_Camera)
    self:SetTipsPath(CONST.ASSETS.G_BOSS_TIPS)
end

function TipsBoss:Refresh()
    if not self.isLoaded then
        return
    end

    self.txt_name.text = "Boss"
end

function TipsBoss:LoadFinish()
    UnitTipsBase.LoadFinish(self)
    self.isLoaded = true

    self.transform = self.go.transform
    self.txt_name = self.transform:Find("txt_name"):GetComponent(typeof(TextMeshPro))
    self:Refresh()
end

return TipsBoss