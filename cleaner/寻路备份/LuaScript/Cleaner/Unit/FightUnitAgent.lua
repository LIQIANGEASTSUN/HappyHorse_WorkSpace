local FightUnitBase = require "Cleaner.Unit.FightUnitBase"

---@type FightUnitAgent
local FightUnitAgent = class(FightUnitBase, "FightUnitAgent")

function FightUnitAgent:ctor()
    ---@type BaseAgent
    self.agent = nil
end

function FightUnitAgent:SetAgent(agent)
    self.agent = agent
end

function FightUnitAgent:GetPosition()
    return self.agent:GetWorldPosition()
end

function FightUnitAgent:GetTransform()
    return self.agent:GetGameObject().transform
end

function FightUnitAgent:EnableAttack()
    return false
end

return FightUnitAgent