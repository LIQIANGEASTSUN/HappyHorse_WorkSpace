require "Fsm.StateMachine.FsmStateBase"

---@class FsmStateMachine
local FsmStateMachine = class(nil, "FsmStateMachine")

function FsmStateMachine:ctor()
    self.stateMap = {}
    ---@type FsmStateBase
    self.currentState = nil
    self.ChangeStateEvent = nil
end

function FsmStateMachine:SetChangeStateEvent(callBack)
    self.ChangeStateEvent = callBack
end

function FsmStateMachine:Add(stateBase)
    local stateType = stateBase:GetStateType()
    stateBase:SetStateMachine(self)
    self.stateMap[stateType] = stateBase
end

function FsmStateMachine:GetCurrentState()
    return self.currentState
end

function FsmStateMachine:SetCurrentState(state)
    self.currentState = state
end

function FsmStateMachine:ChangeState(toStateType, transitionData)
    local state = self:GetCurrentState()
    if nil ~= state and toStateType == state:GetStateType() then
        return
    end

    if state ~= nil then
        state:OnExit()
    end

    local toState = self.stateMap[toStateType]
    if toState == nil then
        console.error("FsmStateMachine toStateId is nil", toStateType) --@DEL
        self:SetCurrentState(nil)
        return nil
    end

    self:SetCurrentState(toState)
    toState:TransitionData(transitionData)
    toState:OnEnter()
    toState:OnTick()

    if nil ~= self.ChangeStateEvent then
        self.ChangeStateEvent(toStateType, transitionData)
    end

    return toState
end

function FsmStateMachine:OnTick()
    local state = self:GetCurrentState()
    if state == nil then
        return
    end

    state:OnTick()
    local transitionMap = state:GetTransitionsMap()
    for _, transition in pairs(transitionMap) do
        local result, toState, transitionData = transition.CanTransition()
        if result then
            self:ChangeState(toState, transitionData)
            break
        end
    end
end

function FsmStateMachine:OnExit()
    local state = self:GetCurrentState()
    if nil ~= state then
        state:OnExit()
        self:SetCurrentState(nil)
    end
end

return FsmStateMachine