local NormalAgent = require("MainCity.Agent.NormalAgent")
---@class DecorationAgent:NormalAgent 可消除障碍物
local DecorationAgent = class(NormalAgent, "DecorationAgent")

local StateChangedHandles = {
    ---@param agent DecorationAgent
    [CleanState.clearing] = function(agent)
        return agent:SetState(CleanState.cleared)
    end,
    ---@param agent DecorationAgent
    [CleanState.cleared] = function(agent)
        agent:InitRender(
            function(result)
                agent:SetClickable(false)
                MessageDispatcher:SendMessage(MessageType.AgentCleaned, agent.id)
            end
        )
        local x, z = agent:GetMin()
        local sx, sz = agent:GetSize()
        --后触发格子状态
        ---@type MapManager
        local map = App.scene.mapManager

        return map:SetBlockState(x, sx, z, sz, CleanState.cleared)
    end
}

---@private
---触发显示更新/格子状态更新
function DecorationAgent:OnStateChanged()
    local state = self:GetState()
    local handler = StateChangedHandles[state]
    if handler then
        return handler(self)
    end
end

function DecorationAgent:BlockBuilding()
    return false
end

function DecorationAgent:EnterEditMode()
    return false
end

function DecorationAgent:Suckable()
    return false
end

return DecorationAgent
