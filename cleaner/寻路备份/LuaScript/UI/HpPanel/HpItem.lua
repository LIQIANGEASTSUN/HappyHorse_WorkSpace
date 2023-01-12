---@class HpItem
local HpItem = class(nil, "HpItem")

local hpColor = {
    [1] = Color.blue,
    [2] = Color.blue,
    [3] = Color.red,
}

function HpItem:ctor(parentRect, clone, data)
    self.parentRect = parentRect
    self.go = self:CreateItem(clone, parentRect.transform)

    self.instanceId = data.instanceId

    self.rect = self.go.transform:GetComponent(typeof(RectTransform))
    self.text = self.go.transform:Find("Text"):GetComponent(typeof(Text))
    self.text.color = hpColor[data.type]

    self.sprite = AppServices.UnitManager:GetUnit(self.instanceId)
    self.target = self.sprite:GetTransform()
    self.maxHp = self.sprite:GetMaxHp()
    self.level = self.sprite:GetLevel()

    self.types = {}

    self.currentShow = -1

    self.useList = {}
    self.unUseList = {}
end

function HpItem:refresh(data)
    self:ResetType(data)
    self:Update()
    self:DamageText(data.changeValue)
end

function HpItem:ResetType(data)
    local typeData = self:GetType(data.type)
    if Runtime.CSValid(typeData.slider) then
        typeData.slider.value = data.hp / self.maxHp
    end

    if Runtime.CSValid(typeData.txt_level) then
        self.level = self.sprite:GetLevel()
        typeData.txt_level.text = tostring(self.level)
    end

    self:Show(data.type, data.show)
end

function HpItem:DamageText(changeValue)
    if math.abs(changeValue) < 1 then
        return
    end

    local item = {}
    if #self.unUseList > 0 then
        item = self.unUseList[#self.unUseList]
        item.text.gameObject:SetActive(true)
        item.rect.anchoredPosition3D  = Vector3(0, 0, 0)
        table.remove(self.unUseList, #self.unUseList)
    else
        local textGo = self:CreateItem(self.text.transform, self.go.transform)
        item.text = textGo:GetComponent(typeof(Text))
        item.rect = textGo:GetComponent(typeof(RectTransform))
    end

    item.time = Time.realtimeSinceStartup
    item.text.text = string.format("%.0f", changeValue)
    table.insert(self.useList, item)
end

function HpItem:Show(showType, show)
    if self.currentShow == showType and show then
        return
    end

    if show then
        self.currentShow = showType
        self.delayHide = nil
    else
        self.currentShow = -1
        if showType > 0 then
            self.delayHide = Time.realtimeSinceStartup + 0.5
            return
        end
    end

    for type, typeData in pairs(self.types) do
        local show = (type == showType) and show
        typeData.tr.gameObject:SetActive(show)
    end
end

function HpItem:Update()
    if self.delayHide and Time.realtimeSinceStartup > self.delayHide then
        self:Show(-1, false)
    end

    if not Runtime.CSValid(self.target) then
        return
    end

    local follow = self.target.position + Vector3(0, 1, 0)
    local position = GameUtil.WorldToUISpace(self.parentRect, follow)
    self.rect.anchoredPosition3D  = position

    for i = #self.useList, 1, -1 do
        local item = self.useList[i]
        if Time.realtimeSinceStartup - item.time >= 1 then
            item.text.gameObject:SetActive(false)
            table.remove(self.useList, i)
            table.insert(self.unUseList, item)
        else
            local pos = Vector3(0, 2, 0)
            item.rect.anchoredPosition3D = item.rect.anchoredPosition3D + pos
        end
    end
end

function HpItem:GetType(type)
    if self.types[type] then
        return self.types[type]
    end

    local typeData = {}

    local name = string.format("Type%d", type)
    local tr = self.go.transform:Find(name)
    local levelTr = tr:Find("Level")

    typeData.tr = tr
    if Runtime.CSValid(levelTr) then
        typeData.txt_level = levelTr:GetComponent(typeof(Text))
    end
    local sliderTr = tr:Find("Slider")
    if Runtime.CSValid(sliderTr) then
        typeData.slider = sliderTr:GetComponent(typeof(Slider))
    end

    self.types[type] = typeData
    return typeData
end

function HpItem:CreateItem(cloneTr, parent)
    local go = GameObject.Instantiate(cloneTr.gameObject)
    go.transform:SetParent(parent, false)
    go.transform.localScale = Vector3.one
    go.transform.localEulerAngles = Vector3.zero
    go.transform.localPosition = Vector3.zero
    go:SetActive(true)
    return go
end

function HpItem:Destroy()
    if Runtime.CSValid(self.go) then
        GameObject.Destroy(self.go)
    end
end

return HpItem