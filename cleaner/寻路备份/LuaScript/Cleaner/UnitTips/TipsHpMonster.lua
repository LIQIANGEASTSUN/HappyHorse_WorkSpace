---@type UnitTipsInfo
local UnitTipsInfo = require "Cleaner.UnitTips.Base.UnitTipsInfo"

---@type UnitTipsBase
local UnitTipsBase = require "Cleaner.UnitTips.Base.UnitTipsBase"

---@type TipsHpMonster
local TipsHpMonster = class(UnitTipsBase, "TipsHpMonster")

function TipsHpMonster:ctor(unitId)
    self.positionRefreshTime = 0
    self.offsetPos = Vector3(0, 1, 0)
    self.maxHp = self.unit:GetMaxHp()
    self.unUseList = {}
    self.useList = {}
    self.isLoaded = false

    self:SetTipsType(TipsType.UnitMonsterHpTips)
    self:SetUseUpdate(true)
    self:SetTipsFollowType(UnitTipsInfo.TipsFollowType.Unit_And_Camera)
    self:SetTipsPath(CONST.ASSETS.G_MONSTER_HP_TIPS)
end

function TipsHpMonster:Refresh()
    if not self.isLoaded then
        return
    end

    local hp = self.unit:GetHp()
    local progress = hp / self.maxHp
    progress = math.clamp(progress, 0, 1)
    local x = progress * 0.5 - 0.5
    local position = Vector3(x, 0, 0)
    self.slider.localPosition = position
    self.slider.localScale = Vector3(progress, 1, 1)

    self:DamageText(self.tipsData.changeValue)
end

function TipsHpMonster:DamageText(changeValue)
    if math.abs(changeValue) < 1 then
        return
    end

    local item = {}
    if #self.unUseList > 0 then
        item = self.unUseList[#self.unUseList]
        table.remove(self.unUseList, #self.unUseList)
    else
        local textGo = self:CreateItem(self.txt_countTr, self.transform)
        item.txt_count = textGo.transform:GetComponent(typeof(TextMeshPro))
    end

    item.time = Time.realtimeSinceStartup
    item.txt_count.text = string.format("%.0f", changeValue)
    item.txt_count.transform.position = Vector3.zero
    item.txt_count.gameObject:SetActive(true)
    table.insert(self.useList, item)
end

function TipsHpMonster:LoadFinish()
    UnitTipsBase.LoadFinish(self)

    self.isLoaded = true
    self.transform = self.go.transform
    self.slider = self.transform:Find("slider/fill")
    self.txt_countTr = self.transform:Find("txt_count")
    self:Refresh()
end

function TipsHpMonster:CalculatePosition()
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

function TipsHpMonster:LateUpdate()
    UnitTipsBase.LateUpdate(self)

    for i = #self.useList, 1, -1 do
        local item = self.useList[i]
        local time = Time.realtimeSinceStartup - item.time
        local pos = Vector3(0, time * 0.5, 0)
        item.txt_count.transform.localPosition = pos

        if Time.realtimeSinceStartup - item.time >= 1 then
            item.txt_count.gameObject:SetActive(false)
            table.remove(self.useList, i)
            table.insert(self.unUseList, item)
        end
    end
end

function TipsHpMonster:CreateItem(cloneTr, parent)
    local go = GameObject.Instantiate(cloneTr.gameObject)
    go.transform:SetParent(parent, false)
    go.transform.localScale = Vector3.one
    go.transform.localEulerAngles = Vector3.zero
    go.transform.localPosition = Vector3.zero
    return go
end

return TipsHpMonster