---@type FsmStateBase
local FsmStateBase = require "Fsm.StateMachine.FsmStateBase"

---@type PetBattleTeamPanel
local PetBattleTeamPanel = require "UI.Pet.PetIllustratedPanel.View.UI.PetBattleTeamPanel"

---@class PetIllustrateStateBase
local PetIllustrateStateBase = class(FsmStateBase, "PetIllustrateStateBase")

function PetIllustrateStateBase:ctor(panel)
    ---@type PetIllustratedPanel
    self.panel = panel
end

function PetIllustrateStateBase:OnExit()
    PetBattleTeamPanel:Hide()
end

function PetIllustrateStateBase:TeamPetClick(petId)

end

function PetIllustrateStateBase:CloseBtnClick()

end

function PetIllustrateStateBase:refreshBattleTeam(battleTeam)
    PetBattleTeamPanel:refreshUI(battleTeam)
end
return PetIllustrateStateBase