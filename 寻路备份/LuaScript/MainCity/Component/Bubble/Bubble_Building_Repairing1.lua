require("MainCity.Component.Bubble.Bubble_base")
---@class Building_Repairing1
local Building_Repairing1 = class(Bubble_Interface, "Building_Repairing1")

function Building_Repairing1:ctor()
    self.type = BubbleType.Building_Repairing1
    self.canClick = true
    self.needCache = true
end

function Building_Repairing1:InitData(param)
    local agentId = param.agentId
    self.agentId = agentId
    local agent = App.scene.objectManager:GetAgent(agentId)
    if agent then
        self:SetPosition(agent:GetAnchorPosition())
    else
        WaitExtension.InvokeDelay(function()
            MapBubbleManager:CloseBubble(agentId)
        end)
    end
end

function Building_Repairing1:onBubbleClick()
    local agentId = self.agentId
    local agent = App.scene.objectManager:GetAgent(agentId)
    if agent and agent.data then
        agent:ProcessClick()
    else
        MapBubbleManager:CloseBubble(agentId)
    end
end

return Building_Repairing1