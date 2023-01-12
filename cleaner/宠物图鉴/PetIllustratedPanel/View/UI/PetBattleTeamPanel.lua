---@type PetItemInfo
local PetItemInfo = require "UI.Pet.PetIllustratedPanel.View.UI.PetItemInfo"

---@class PetBattleTeamPanel
local PetBattleTeamPanel = {
    battleTeam = nil, -- {txt_team = txt_team, team_parent = team_parent, team_item = team_item}
    itemList = {},
}

function PetBattleTeamPanel:refreshUI(battleTeam)
    self.battleTeam = battleTeam

    local pets = self:GetInBattleTeamPet()
    local enableUseCount = self:GetEnableCount()
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

function PetBattleTeamPanel:GetEnableCount()
    local level = self:PlayerLevel()
    local config = AppServices.Meta:Category("LevelTemplate")
    local data = config[tostring(level)]
    return data.takePetNum
end

function PetBattleTeamPanel:RefreshItem(pet, islock)
    local cloneTr = self.battleTeam.team_item
    local parent = self.battleTeam.team_parent
    local petItemInfo = PetItemInfo.new(cloneTr, parent, pet)
    if islock then
        petItemInfo:RefreshLock(self.lockOnClick)
    elseif pet then
        petItemInfo:RefreshExist(self.existOnClick)
    else
        petItemInfo:RefreshAdd(self.addOnClick)
    end
    table.insert(self.itemList, petItemInfo)
end

function PetBattleTeamPanel:SetExistOnClickEvent(callBack)
    self.existOnClick = callBack
end

function PetBattleTeamPanel:SetAddOnClickEvent(callBack)
    self.addOnClick = callBack
end

function PetBattleTeamPanel:SetLockOnClickEvent(callBack)
    self.lockOnClick = callBack
end

function PetBattleTeamPanel:ExistOnClick(pet)
    if self.existOnClick then
        self.existOnClick(pet)
    end
end

function PetBattleTeamPanel:LockOnClick()
    if self.lockOnClick then
        self.lockOnClick()
    end
end

function PetBattleTeamPanel:AddOnClick()
    if self.addOnClick then
        self.addOnClick()
    end
end

function PetBattleTeamPanel:Hide()
    for _, v in pairs(self.itemList) do
       v:Destroy()
    end
    self.itemList = {}
    self.existOnClick = nil
    self.addOnClick = nil
    self.lockOnClick = nil
end

return PetBattleTeamPanel