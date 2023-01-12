---@type PetItemInfo
local PetItemInfo = require "UI.Pet.PetIllustratedPanel.View.UI.PetItemInfo"

-- 上阵的宠物信息
---@class PetBattleTeamPanel
local PetBattleTeamPanel = {
    battleTeam = nil,
    itemList = {},
    petIllustratedPanel = nil,
}

function PetBattleTeamPanel:refreshUI(petIllustratedPanel, battleTeam)
    self.petIllustratedPanel = petIllustratedPanel
    self.battleTeam = battleTeam

    self.txt_team = self.battleTeam:Find("Bg/TitleBg/txt_team").gameObject:GetComponent(typeof(Text))
    self.team_item = find_component(self.battleTeam.gameObject,'Item',Transform)

    self:Clear()
    local pets = self:GetInBattleTeamPet()
    local enableUseCount = self:GetPlayerLevelTakeCount()
    local maxCount = self:GetMaxCount()
    for i = 1, maxCount do
        local pet = nil
        local islock = i > enableUseCount
        if i <= #pets then
            pet = pets[i]
        end
        self:RefreshItem(pet, islock)
    end
end

function PetBattleTeamPanel:AddToTeam(pet)
    for _, item in pairs(self.itemList) do
        local type = item:GetType()
        if type <= 0 then
            item:SetPet(pet)
            local click = function(pet) self:ExistOnClick(pet) end
            item:RefreshExist(click)
            break
        end
    end
end

function PetBattleTeamPanel:DownFromTeam(pet)
    for _, item in pairs(self.itemList) do
        if pet.type == item:GetType() then
            item:SetPet(nil)
            local click = function() self:AddOnClick() end
            item:RefreshAdd(click)
            break
        end
     end
end

-- 获取跟随出战的宠物
function PetBattleTeamPanel:GetInBattleTeamPet()
    local result = {}
    local pets = AppServices.User:GetPets()
    if not pets then
        return result
    end
    for _, pet in pairs(pets) do
        if pet.up == 1 then
            table.insert(result, pet)
        end
    end
    return result
end

function PetBattleTeamPanel:GetTakeCount()
    local pets = self:GetInBattleTeamPet()
    return #pets
end

function PetBattleTeamPanel:PlayerLevel()
    local level = AppServices.User.data.level
    return level
end

-- 角色可以携带的最大宠物数量
function PetBattleTeamPanel:GetMaxCount()
    local config = AppServices.Meta:Category("ConfigTemplate")
    local value = config["petLimitNum"].value
    return tonumber(value)
end

-- Player 当前等级可以携带几个宠物
function PetBattleTeamPanel:GetPlayerLevelTakeCount()
    local level = self:PlayerLevel()
    local config = AppServices.Meta:Category("LevelTemplate")
    local data = config[tostring(level)]
    return data.takePetNum
end

function PetBattleTeamPanel:RefreshItem(pet, islock)
    local cloneTr = self.team_item
    local parent = self.battleTeam
    local petItemInfo = PetItemInfo.new(cloneTr, parent, pet)
    if islock then
        local click = function() self:LockOnClick() end
        petItemInfo:RefreshLock(click)
    elseif pet then
        local click = function(pet) self:ExistOnClick(pet) end
        petItemInfo:RefreshExist(click)
    else
        local click = function() self:AddOnClick() end
        petItemInfo:RefreshAdd(click)
    end
    table.insert(self.itemList, petItemInfo)
end

function PetBattleTeamPanel:LockOnClick()
end

function PetBattleTeamPanel:ExistOnClick(pet)
    if pet then
        self.petIllustratedPanel:ShowTeamEditorDown(pet)
    end
end

function PetBattleTeamPanel:AddOnClick()
end

function PetBattleTeamPanel:Clear()
    for _, v in pairs(self.itemList) do
        v:Destroy()
     end
     self.itemList = {}
end

function PetBattleTeamPanel:Hide()
    self:Clear()
end

return PetBattleTeamPanel