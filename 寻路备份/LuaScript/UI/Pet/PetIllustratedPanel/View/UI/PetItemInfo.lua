---@type PetTemplateTool
local PetTemplateTool = require "Cleaner.Entity.Pet.PetTemplateTool"

---@type PetItemInfo
local PetItemInfo = class(nil, "PetItemInfo")

local PetItemInfoType = {
    Add = 1,
    Exist = 2,
    Lock = 3,
    NotOwned = 4,
}

function PetItemInfo:ctor(cloneTr, parent, pet)
    self.parent = parent
    self.go = self:CreateItem(cloneTr)
    self.pet = pet

    local addTr = find_component(self.go,'Add',Transform)
    if Runtime.CSValid(addTr) then
        self.btn_add = find_component(addTr.gameObject, 'btn_add', Button)
        Util.UGUI_AddButtonListener(self.btn_add.gameObject, function()
            if self.addOnClick then
                self.addOnClick()
            end
        end)
    end

    local existTr = find_component(self.go,'Exist',Transform)
    if Runtime.CSValid(existTr) then
        self.btn_exist = find_component(existTr.gameObject, 'btn_exist', Button)
        Util.UGUI_AddButtonListener(self.btn_exist.gameObject, function()
            if self.existOnClick then
                self.existOnClick(self.pet)
            end
        end)
    end

    local lockTr = find_component(self.go,'Lock',Transform)
    if Runtime.CSValid(lockTr) then
        self.btn_lock = find_component(lockTr.gameObject, 'btn_lock', Button)
        Util.UGUI_AddButtonListener(self.btn_lock.gameObject, function()
            if self.lockOnClick then
                self.lockOnClick()
            end
        end)
    end

    local notOwnedTr = find_component(self.go,'NotOwned',Transform)

    self.trList = {
        [PetItemInfoType.Add] = addTr,
        [PetItemInfoType.Exist] = existTr,
        [PetItemInfoType.Lock] = lockTr,
        [PetItemInfoType.NotOwned] = notOwnedTr,
    }
end

function PetItemInfo:GetType()
    if self.pet then
        return self.pet.type
    end
    return -1
end

function PetItemInfo:SetPet(pet)
    self.pet = pet
end

-- 状态：待添加
function PetItemInfo:RefreshAdd(addOnClick)
    self.addOnClick = addOnClick
    self:Show(PetItemInfoType.Add)
end

-- 状态：已拥有
function PetItemInfo:RefreshExist(existOnClick)
    self.existOnClick = existOnClick
    local go = self:Show(PetItemInfoType.Exist)
    if not Runtime.CSValid(go) then
        return
    end

    local icon = find_component(go,'Icon',Image)
    local txtHp = find_component(go,'HpBg/txt_hp',Text)
    local txt_attack = find_component(go,'AttackBg/txt_attack', Text)
    --local slider = find_component(go,'Slider', Slider)
    local txt_level = find_component(go, 'txt_level', Text)

    local petId = PetTemplateTool:Getkey(self.pet.type, self.pet.level)
    local petData = AppServices.Meta:Category("PetTemplate")[tostring(petId)]

    icon.sprite = self:GetSprite(petData.icon)

    txtHp.text = tostring(petData.hp)
    local skillId = petData.skillId
    local skillData = AppServices.Meta:Category("SkillTemplate")[tostring(skillId)]
    txt_attack.text = tostring(skillData.attackPower)
    txt_level.text = string.format("Lv%d", self.pet.level)
end

-- 状态：锁
function PetItemInfo:RefreshLock(lockOnClick)
    self.lockOnClick = lockOnClick
    self:Show(PetItemInfoType.Lock)
end

-- 状态：未拥有
function PetItemInfo:RefreshNotOwned(petType)
    local go =  self:Show(PetItemInfoType.NotOwned)
    if not Runtime.CSValid(go) then
        return
    end

    local icon = find_component(go,'Icon',Image)
    local petId = PetTemplateTool:Getkey(petType, 1)
    local petData = AppServices.Meta:Category("PetTemplate")[tostring(petId)]

    icon.sprite = self:GetSprite(petData.icon)
end

function PetItemInfo:Show(type)
    for k, tr in pairs(self.trList) do
        local show = k == type
        if Runtime.CSValid(tr) then
            tr.gameObject:SetActive(show)
        end
    end
    return self.trList[type]
end

function PetItemInfo:CreateItem(cloneTr)
    local go = GameObject.Instantiate(cloneTr.gameObject)
    go.transform:SetParent(self.parent, false)
    go.transform.localScale = Vector3.one
    go.transform.localEulerAngles = Vector3.zero
    go.transform.localPosition = Vector3.zero
    go:SetActive(true)
    return go
end

function PetItemInfo:GetSprite(spriteName)
    self.petAtlas = App.uiAssetsManager:GetAsset(CONST.ASSETS.G_ITEM_ICONS)
    local sprite = self.petAtlas:GetSprite(spriteName)
    return sprite
end

function PetItemInfo:Destroy()
    if Runtime.CSValid(self.go) then
        GameObject.Destroy(self.go)
    end
end

return PetItemInfo