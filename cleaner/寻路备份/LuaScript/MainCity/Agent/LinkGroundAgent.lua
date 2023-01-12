local GroundAgent = require("MainCity.Agent.GroundAgent")
---@class LinkGroundAgent:GroundAgent 可消除障碍物
local LinkGroundAgent = class(GroundAgent, "LinkGroundAgent")

local StateChangedHandles = {
    ---@param agent LinkGroundAgent
    [CleanState.prepare] = function(agent)
        local modelName = "airWall"
        if agent.render then
            agent.render:SetModelName(modelName)
        else
            agent:SetAssetName(modelName)
        end
        --GetAssetName
        agent:InitRender(
            function(result)
                agent:SetClickable(true)
                local go = agent:GetGameObject()
                go.name = "prepare"
            end
        )
    end,
    ---@param agent LinkGroundAgent
    [CleanState.clearing] = function(agent)
        local islandId = agent:GetIslandId()
        local progress = AppServices.IslandManager:GetIslandProgress(islandId)
        agent:ShowBuyableRender(progress == 1)
    end,
    ---@param agent LinkGroundAgent
    [CleanState.cleared] = function(agent)
        agent:DestroyTip()
        if agent.render then
            agent.render:OnDestroy()
            agent.render = nil
        end
        agent:SetAssetName(nil)
        agent:InitRender(
            function(result)
                agent:SetClickable(true)
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

function LinkGroundAgent:ctor()
    MessageDispatcher:AddMessageListener(MessageType.IslandProgressChange, self.OnIslandProgressChange, self)
end

function LinkGroundAgent:OnIslandProgressChange(islandId, progress)
    if self:GetState() ~= CleanState.clearing then
        return
    end
    local myIslandId = self:GetIslandId()
    if progress >= 1 and myIslandId == islandId then
        self:ShowBuyableRender(true)
    end
end

function LinkGroundAgent:ShowBuyableRender(buyable)
    local modelName = "airWall"
    if self.render then
        self.render:SetModelName(modelName)
    else
        self:SetAssetName(modelName)
    end

    self:InitRender(
        function(result)
            self:SetClickable(true)
            local go = self:GetGameObject()
            go.name = buyable and self:GetId() or "wall"
            if buyable then
                self:ShowTip()
            end
        end
    )
end

function LinkGroundAgent:GetIslandId()
    if not self.islandId then
        local x, z = self:GetMin()
        if x and z then
            local region = App.scene.mapManager:GetRegionByGrid(x, z)
            if region then
                self.islandId = region:GetId()
            end
        end
    end

    return self.islandId
end

---@private
---触发显示更新/格子状态更新
function LinkGroundAgent:OnStateChanged()
    local state = self:GetState()
    local handler = StateChangedHandles[state]
    if handler then
        return handler(self)
    end
end

function LinkGroundAgent:Suckable()
    if self.alive then
        return self:GetState() == CleanState.clearing
    end
end

function LinkGroundAgent:InitExtraData(extra)
    self.data:InitExtraData(extra)
end

function LinkGroundAgent:Destroy()
    MessageDispatcher:RemoveMessageListener(MessageType.IslandProgressChange, self.OnIslandProgressChange, self)
end

return LinkGroundAgent
