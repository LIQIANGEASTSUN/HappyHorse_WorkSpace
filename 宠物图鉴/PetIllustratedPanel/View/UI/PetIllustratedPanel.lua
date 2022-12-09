local _PetIllustratedPanelBase = require "UI.Pet.PetIllustratedPanel.View.UI.Base._PetIllustratedPanelBase"

---@type FsmStateMachine
local FsmStateMachine = require "Fsm.StateMachine.FsmStateMachine"

---@type PetIllustrateState
local PetIllustrateState = require "UI.Pet.PetIllustratedPanel.View.State.PetIllustrateState"

---@class PetIllustratedPanel:_PetIllustratedPanelBase
local PetIllustratedPanel = class(_PetIllustratedPanelBase)

-- 图鉴界面状态
local PetIllustratedStates = {
    [PetIllustrateState.IllustratedShowState] = "UI.Pet.PetIllustratedPanel.View.State.PetIllustrateShowState",
    [PetIllustrateState.EditorBattleTeamState] = "UI.Pet.PetIllustratedPanel.View.State.PetIllustrateBattleTeamState",
}

function PetIllustratedPanel:ctor()
    self.fsmStateMachine = FsmStateMachine.new()
    for _, path in pairs(PetIllustratedStates) do
        local state = include(path)
        local illustratedState = state.new(self)
        self.fsmStateMachine:Add(illustratedState)
    end
end

function PetIllustratedPanel:onAfterBindView()

end

function PetIllustratedPanel:SetArguments(arguments)
    self.arguments = arguments
end

function PetIllustratedPanel:refreshUI()
    self:RegisterEvent()

    local toStateType = PetIllustrateState.IllustratedShowState
    local transitionData = nil
    if self.arguments and self.arguments.editorPetId then
        toStateType = PetIllustrateState.EditorBattleTeamState
        local pet = AppServices.User:GetPet(self.arguments.editorPetId)
        transitionData = {pet = pet}
    end
    self.fsmStateMachine:ChangeState(toStateType, transitionData)
end

function PetIllustratedPanel:showPanel(state)
    local show = state == PetIllustrateState.IllustratedShowState
    self.illustrated.gameObject:SetActive(show)
    self.battleTeamEditor.gameObject:SetActive(not show)
end

function PetIllustratedPanel:GetIllustrated()
    return self.illustrated
end

function PetIllustratedPanel:GetBattleTeamEditor()
    return self.battleTeamEditor
end

function PetIllustratedPanel:GetCurrentState()
    return self.fsmStateMachine:GetCurrentState()
end

function PetIllustratedPanel:CloseBtnClick()
    local currentState = self:GetCurrentState()
    currentState:CloseBtnClick()
end

function PetIllustratedPanel:Hide()
    self:UnRegisterEvent()
end

function PetIllustratedPanel:RegisterEvent()

end

function PetIllustratedPanel:UnRegisterEvent()

end

return PetIllustratedPanel
