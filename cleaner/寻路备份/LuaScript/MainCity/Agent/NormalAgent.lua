local BaseAgent = require("MainCity.Agent.BaseAgent")
---@class NormalAgent:BaseAgent 可消除障碍物
local NormalAgent = class(BaseAgent, "NormalAgent")

local opacity = 1 --不透明
local transparency = 0.5 --半透明
local StateChangedHandles = {
    ---@param agent BaseAgent
    [CleanState.prepare] = function(agent)
        -- agent:InitRender(
        --     function(result)
        --         agent:SetTransparency(transparency)
        --         agent:SetClickable(false)
        --     end
        -- )
    end,
    ---@param agent NormalAgent
    [CleanState.clearing] = function(agent)
        if not agent:BlockGrid() then
            return agent:SetState(CleanState.cleared)
        end
    end,
    ---@param agent NormalAgent
    [CleanState.cleared] = function(agent)
        agent:InitRender(
            function(result)
                agent:TweenTransparency(opacity)
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

---触发状态改变
function NormalAgent:SetState(state)
    if self.data:SetState(state) then
        return self:HandleStateChanged()
    end
end

---@private
---触发显示更新/格子状态更新
function NormalAgent:OnStateChanged()
    local state = self:GetState()
    local handler = StateChangedHandles[state]
    if handler then
        return handler(self)
    end
end

function NormalAgent:IsComplete()
    return self:GetState() == CleanState.cleared
end

function NormalAgent:BlockGrid()
    return false
end

-----------------------------点击逻辑-------------------------------
function NormalAgent:ProcessClick()
end

return NormalAgent
