---@type PetIllustrateStateBase
local PetIllustrateStateBase = require "UI.Pet.PetIllustratedPanel.View.State.PetIllustrateStateBase"

---@type PetSelectPetPanel
local PetSelectPetPanel = require "UI.Pet.PetIllustratedPanel.View.UI.PetSelectPetPanel"

---@type PetIllustrateState
local PetIllustrateState = require "UI.Pet.PetIllustratedPanel.View.State.PetIllustrateState"

---@type PetBattleTeamPanel
local PetBattleTeamPanel = require "UI.Pet.PetIllustratedPanel.View.UI.PetBattleTeamPanel"

---@class PetIllustrateBattleTeamState
local PetIllustrateBattleTeamState = class(PetIllustrateStateBase, "PetIllustrateBattleTeamState")

function PetIllustrateBattleTeamState:ctor(panel)
    self.stateType = PetIllustrateState.EditorBattleTeamState
    self.selectPet = nil
end

function PetIllustrateBattleTeamState:OnEnter()
    self.panel:showPanel(PetIllustrateState.EditorBattleTeamState)
    self.selectPet = self.transitionData.pet

    self:BattleTeamView()
    self:refreshEditorTeam()
end

function PetIllustrateBattleTeamState:OnExit()
    PetIllustrateStateBase.OnExit(self)
    PetSelectPetPanel:Hide()
end

function PetIllustrateBattleTeamState:TeamPetClick(petId)
    console.error("PetIllustrateBattleTeamState:TeamPetClick:"..petId)
end

function PetIllustrateBattleTeamState:CloseBtnClick()
    self:ChangeState(PetIllustrateState.IllustratedShowState)
end

function PetIllustrateBattleTeamState:refreshEditorTeam()
    local battleTeamEditor = self.panel:GetBattleTeamEditor()

    local parent = find_component(battleTeamEditor.gameObject,'SelectPet',Transform)
    local item = find_component(parent.gameObject,'Item',Transform)
    local txt_info = find_component(parent.gameObject,'TitleBg/txt_info',Text)
    local editorTeam = {txt_info = txt_info, parent = parent, item = item}

    PetSelectPetPanel:refreshUI(editorTeam, self.selectPet)
end

function PetIllustrateBattleTeamState:BattleTeamView()
    local battleTeamEditor = self.panel:GetBattleTeamEditor()
    local contentTr = battleTeamEditor.gameObject.transform:Find("BattleTeam/ScrollView/Viewport/Content")

    local txt_team = battleTeamEditor:Find("BattleTeam/TitleBg/txt_team").gameObject:GetComponent(typeof(Text))
    local team_parent = contentTr
    local team_item = find_component(contentTr.gameObject,'Item',Transform)
    self.battleTeam = {txt_team = txt_team, team_parent = team_parent, team_item = team_item}

    PetBattleTeamPanel:SetExistOnClickEvent(function(pet) self:BattleTeamExistOnClick(pet) end)
    PetBattleTeamPanel:SetAddOnClickEvent(function() self:BattleTeamAddOnClick() end)

    self:refreshBattleTeam(self.battleTeam)
end

-- 在编辑战队编队时点击了 Exist
function PetIllustrateBattleTeamState:BattleTeamExistOnClick(pet)
    self:RemovePetFromBattleTeam(pet)
    self:AddPetToBattleTeam(self.selectPet)
    self:ChangeState(PetIllustrateState.IllustratedShowState)
end

-- 在编辑战队编队时点击了 Add
function PetIllustrateBattleTeamState:BattleTeamAddOnClick()
    self:AddPetToBattleTeam(self.selectPet)
    self:ChangeState(PetIllustrateState.IllustratedShowState)
end

function PetIllustrateBattleTeamState:AddPetToBattleTeam(pet)
    AppServices.NetPetManager:SendPetUp(pet.id)
end

function PetIllustrateBattleTeamState:RemovePetFromBattleTeam(pet)
    AppServices.NetPetManager:SendPedDown(pet.id)
end

return PetIllustrateBattleTeamState