--insertWidgetsBegin
--    btn_close
--insertWidgetsEnd

--insertRequire
local _PetInfoPanelBase = require "UI.Pet.PetInfoPanel.View.UI.Base._PetInfoPanelBase"
---@type PetInfoItem
local PetInfoItem = require "UI.Pet.PetInfoPanel.View.UI.PetInfoItem"
---@type PetInfoTypeEnum
local PetInfoTypeEnum = require "UI.Pet.PetInfoPanel.View.UI.PetInfoTypeEnum"

---@class PetInfoPanel:_PetInfoPanelBase
local PetInfoPanel = class(_PetInfoPanelBase)


function PetInfoPanel:ctor()
    self.itemList = {}
end

function PetInfoPanel:onAfterBindView()

end

function PetInfoPanel:refreshUI()
    local data = {index = 1}
    self:TypeClick(data)
end

function PetInfoPanel:TypeClick(data)
    for index, item in pairs(self.typeUI) do
        local select = data.index == index
        item.select.gameObject:SetActive(select)
        item.unSelect.gameObject:SetActive(not select)
    end

    self:RefreshType(data.index)
end

function PetInfoPanel:GetTypeData(type)
    local data = {}
    local pets = AppServices.User:GetPets()
    for _, pet in pairs(pets) do
        if type == PetInfoTypeEnum.Team and pet.up ~= 0 then
            table.insert(data, pet)
        elseif type == PetInfoTypeEnum.Other and pet.up == 0 then
            table.insert(data, pet)
        end
    end
    return data
end

function PetInfoPanel:RefreshType(type)
    self:ClearItem()
    local data = self:GetTypeData(type)

    for _, pet in pairs(data) do
        local itemGo = self:CreateItem(self.item, self.itemParent)
        local petInfoItem = PetInfoItem.new(itemGo, pet, type, self)
        petInfoItem:refresh()
        table.insert(self.itemList, petInfoItem)
    end
end

function PetInfoPanel:ClearItem()
    for _, item in pairs(self.itemList) do
        item:Destroy()
    end
    self.itemList = {}
end

function PetInfoPanel:Hide()
    self:ClearItem()
end

function PetInfoPanel:CreateItem(cloneTr, parent)
    local go = GameObject.Instantiate(cloneTr.gameObject)
    go.transform:SetParent(parent, false)
    go.transform.localScale = Vector3.one
    go.transform.localEulerAngles = Vector3.zero
    go.transform.localPosition = Vector3.zero
    go:SetActive(true)
    return go
end

return PetInfoPanel
