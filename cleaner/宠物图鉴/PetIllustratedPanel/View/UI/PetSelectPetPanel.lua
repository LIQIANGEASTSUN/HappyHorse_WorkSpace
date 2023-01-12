---@type PetItemInfo
local PetItemInfo = require "UI.Pet.PetIllustratedPanel.View.UI.PetItemInfo"

---@class PetSelectPetPanel
local PetSelectPetPanel = {
    itemList = {}
}

function PetSelectPetPanel:refreshUI(editorTeam, pet)
    local cloneTr = editorTeam.item
    local parent = editorTeam.parent
    local petItemInfo = PetItemInfo.new(cloneTr, parent, pet)
    petItemInfo:RefreshExist()
    table.insert(self.itemList, petItemInfo)
end

function PetSelectPetPanel:Hide()
    for _, v in pairs(self.itemList) do
       v:Destroy()
    end
    self.itemList = {}
end

return PetSelectPetPanel