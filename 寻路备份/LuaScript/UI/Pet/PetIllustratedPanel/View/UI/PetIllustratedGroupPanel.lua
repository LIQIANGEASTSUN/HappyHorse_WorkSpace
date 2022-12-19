---@type PetItemInfo
local PetItemInfo = require "UI.Pet.PetIllustratedPanel.View.UI.PetItemInfo"

local petCollectTemplateTool = {
    collectMap = nil,
    ownedMap = nil,
}

function petCollectTemplateTool:Clear()
    self.collectMap = nil
end

function petCollectTemplateTool:GetAll()
    if self.collectMap then
        return self.collectMap
    end

    self.collectMap = {}
    local config = AppServices.Meta:Category("PetCollectTemplate")
    for _, data in pairs(config) do
        local collectType = data.collectType
        local typeData = self.collectMap[collectType]
        if not typeData then
            typeData = {}
            self.collectMap[collectType] = typeData
        end

        table.insert(typeData, data)
    end

    for _, typeData in pairs(self.collectMap) do
        table.sort(typeData, function(a, b)
            return a.sort - b.sort
        end)
    end

    return self.collectMap
end

-- 获取拥有的的宠物
function petCollectTemplateTool:GetOwnedPet(type)
    self.ownedMap = {}
    local pets = AppServices.User:GetPets()
    if not pets then
        return nil
    end

    for _, pet in pairs(pets) do
        if not self.ownedMap[pet.type] then
            self.ownedMap[pet.type] = pet
        end
    end

    return self.ownedMap[type]
end

-- 未上阵的宠物信息
---@class PetIllustratedGroupPanel
local PetIllustratedGroupPanel = {
    illustratedGroup = nil,
    itemList = {},
    typeList = {},
    bgNmaes = {
        [1] = "ui_animal_map_bg01",
        [2] = "ui_animal_map_bg02",
        [3] = "ui_animal_map_bg01",
    },
    petIllustratedPanel = nil,
}

function PetIllustratedGroupPanel:refreshUI(petIllustratedPanel, illustratedGroup)
    self.petIllustratedPanel = petIllustratedPanel
    petCollectTemplateTool:Clear()

    self.illustratedGroup = illustratedGroup
    self.map = petCollectTemplateTool:GetAll()
    for _, typeData in pairs(self.map) do
        self:CreateType(typeData)
    end
end

function PetIllustratedGroupPanel:CreateType(typeData)
    local typeTr = self:CreateItem(self.illustratedGroup.illustratedType, self.illustratedGroup.typeParent)
    table.insert(self.typeList, typeTr.gameObject)
    self:SetBg(typeTr, typeData)

    local cloneTr = find_component(typeTr.gameObject,'Item',Transform)
    for _, data in pairs(typeData) do
        self:RefreshItem( data, cloneTr, typeTr.transform)
    end
end

function PetIllustratedGroupPanel:SetBg(typeTr, typeData)
    local bgImage = find_component(typeTr.gameObject, "Bg", Image)
    if #typeData > 0 then
        local data = typeData[1]
        local name = self.bgNmaes[data.collectType]
        local sprite = self:GetSprite(name)
        if Runtime.CSValid(sprite) then
            bgImage.sprite = sprite
        end
    end
end

function PetIllustratedGroupPanel:RefreshItem(data, cloneTr, parent)
    local pet = petCollectTemplateTool:GetOwnedPet(data.petType)
    local petItemInfo = PetItemInfo.new(cloneTr, parent, pet)

    if pet and pet.up == 0 then
        local click = function(pet) self:ExistOnClick(pet) end
        petItemInfo:RefreshExist(click)
    else
        petItemInfo:RefreshNotOwned(data.petType)
    end
    table.insert(self.itemList, petItemInfo)
end

function PetIllustratedGroupPanel:ExistOnClick(pet)
    if pet then
        self.petIllustratedPanel:ShowTeamEditorUp(pet)
    end
end

function PetIllustratedGroupPanel:AddToTeam(pet)
    for _, item in pairs(self.itemList) do
        if pet.type == item:GetType() then
            item:RefreshNotOwned(pet.type)
            break
        end
    end
end

function PetIllustratedGroupPanel:DownFromTeam(pet)
    for _, item in pairs(self.itemList) do
        if pet.type == item:GetType() then
            local click = function(pet2) self:ExistOnClick(pet2) end
            item:RefreshExist(click)
            break
        end
    end
end

function PetIllustratedGroupPanel:CreateItem(cloneTr, parent)
    local go = GameObject.Instantiate(cloneTr.gameObject)
    go.transform:SetParent(parent, false)
    go.transform.localScale = Vector3.one
    go.transform.localEulerAngles = Vector3.zero
    go.transform.localPosition = Vector3.zero
    go:SetActive(true)
    return go
end

function PetIllustratedGroupPanel:GetSprite(spriteName)
    self.petAtlas = App.uiAssetsManager:GetAsset(CONST.ASSETS.G_COMMONS_SPRITE)
    local sprite = self.petAtlas:GetSprite(spriteName)
    return sprite
end

function PetIllustratedGroupPanel:Clear()

end

function PetIllustratedGroupPanel:Hide()
    for _, v in pairs(self.itemList) do
       v:Destroy()
    end
    self.itemList = {}

    for _, v in pairs(self.typeList) do
        GameObject.Destroy(v)
    end
    self.typeList = {}
end

return PetIllustratedGroupPanel