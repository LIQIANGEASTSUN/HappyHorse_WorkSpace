---@class BaseAction
local BaseAction = class()

function BaseAction:ctor(entity)
    ---@type Dragon
    self.entity = entity
end

function BaseAction:OnEnter()
    self.active = true
    -- console.tprint(self.entity.gameObject, "In Action: nil") --@DEL
end

function BaseAction:CanChangeTo(state)
    return true
end

function BaseAction:ChangeToNextState()
    self.entity:ChangeAction(EntityState.none)
end

function BaseAction:Tick()
end

function BaseAction:OnExit()
    self.active = nil
end

return BaseAction
