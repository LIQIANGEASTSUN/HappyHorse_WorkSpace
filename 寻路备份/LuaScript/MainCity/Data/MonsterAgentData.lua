---@type AgentData
local AgentData = require "MainCity.Data.AgentData"

---@class MonsterAgentData
local MonsterAgentData = class(AgentData, "MonsterAgentData")

function MonsterAgentData:ctor()
    self.createEntityId = 0
    self.suckable = false
    self.waitExtensionId = nil
    self.creating = false
    self.isBossAgent = false
end

function MonsterAgentData:SetCreateEntityId(id)
    self.createEntityId = id
end

function MonsterAgentData:GetCreateEntityId()
    return self.createEntityId
end

function MonsterAgentData:SetSuckable(value)
    self.suckable = value
end

function MonsterAgentData:GetSuckable()
    return self.suckable
end

function MonsterAgentData:SetWaitExtensionId(id)
    self.waitExtensionId = id
end

function MonsterAgentData:GetWaitExtensionId()
    return self.waitExtensionId
end

function MonsterAgentData:SetCreating(value)
    self.creating = value
end

function MonsterAgentData:IsCreating()
    return self.creating
end

function MonsterAgentData:SetIsBossAgent(value)
    self.isBossAgent = value
end

function MonsterAgentData:GetIsBossAgent()
    return self.isBossAgent
end

return MonsterAgentData