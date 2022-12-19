---@type PetIllustrateStateBase
local PetIllustrateStateBase = require "UI.Pet.PetIllustratedPanel.View.State.PetIllustrateStateBase"

---@type PetIllustrateState
local PetIllustrateState = require "UI.Pet.PetIllustratedPanel.View.State.PetIllustrateState"

---@type PetIllustratedGroupPanel
local PetIllustratedGroupPanel = require "UI.Pet.PetIllustratedPanel.View.UI.PetIllustratedGroupPanel"

---@class PetIllustrateShowState
local PetIllustrateShowState = class(PetIllustrateStateBase, "PetIllustrateShowState")

function PetIllustrateShowState:ctor(panel)
    self.stateType = PetIllustrateState.IllustratedShowState
end

function PetIllustrateShowState:OnEnter()
    self.panel:showPanel(PetIllustrateState.IllustratedShowState)
    self:BattleTeamView()
    self:refreshIllustratedGroup()
end

function PetIllustrateShowState:OnExit()
    PetIllustrateStateBase.OnExit(self)
    PetIllustratedGroupPanel:Hide()
end

function PetIllustrateShowState:CloseBtnClick()
    PanelManager.closePanel(GlobalPanelEnum.PetIllustratedPanel, nil)
end

function PetIllustrateShowState:BattleTeamView()
    local illustrate = self.panel:GetIllustrated()
    local contentTr = illustrate.gameObject.transform:Find("ScrollView/Viewport/Content")

    local txt_team = contentTr:Find("BattleTeam/Bg/TitleBg/txt_team").gameObject:GetComponent(typeof(Text))
    local team_parent = find_component(contentTr.gameObject,'BattleTeam',Transform)
    local team_item = find_component(contentTr.gameObject,'BattleTeam/Item',Transform)
    self.battleTeam = {txt_team = txt_team, team_parent = team_parent, team_item = team_item}

    self:refreshBattleTeam(self.battleTeam)
end



function PetIllustrateShowState:ToBattleTeamState(pet)
    local transitionData = {pet = pet}
    self:ChangeState(PetIllustrateState.EditorBattleTeamState, transitionData)
end

return PetIllustrateShowState