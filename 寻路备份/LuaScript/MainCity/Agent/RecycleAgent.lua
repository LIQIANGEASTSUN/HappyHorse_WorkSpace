local NormalAgent = require("MainCity.Agent.NormalAgent")
---@class RecycleAgent:NormalAgent 可消除障碍物
local RecycleAgent = class(NormalAgent, "RecycleAgent")

local StateChangedHandles = {
    ---@param agent RecycleAgent
    [CleanState.clearing] = function(agent)
        agent:SetState(CleanState.cleared)
    end,
    ---@param agent RecycleAgent
    [CleanState.cleared] = function(agent)
        agent:InitRender(
            function(result)
                agent:SetClickable(true)
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
function RecycleAgent:OnStateChanged()
    local state = self:GetState()
    local handler = StateChangedHandles[state]
    if handler then
        return handler(self)
    end
end

function RecycleAgent:BlockBuilding()
    return true
end

function RecycleAgent:CanEdit()
    return self:GetState() == CleanState.cleared
end

function RecycleAgent:Suckable()
    return false
end

function RecycleAgent:ProcessClick()
    PanelManager.showPanel(GlobalPanelEnum.RecyclePanel)
end

return RecycleAgent
