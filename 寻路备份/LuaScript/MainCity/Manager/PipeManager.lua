---
--- Created by Betta.
--- DateTime: 2022/7/27 10:36
---
---@class PipeInfoData
---@field state number
---@field plantId string

---@class PipeItem
local PipeItem = class(nil, "PipeItem")

function PipeItem:ctor(cfg, pipeId)
    self.state = cfg[2]
    self.endState = cfg[3]
    self.pipeId = pipeId
end

---@param serverInfo PipeInfoData
function PipeItem:SetServerInfo(serverInfo)
    self.state = serverInfo.state
end



---@class PipeGroup
local PipeGroup = class(nil, "PipeGroup")

function PipeGroup:ctor(sceneId, serverInfo)
    ---@type table<string, PipeItem>
    self.infoData = {}

    local cfgs = AppServices.Meta:Category("PipeTemplate")
    for _, cfg in pairs(cfgs) do
        if cfg.sceneId == sceneId then
            for _, pipeItemCfg in ipairs(cfg.location) do
                self.infoData[tostring(pipeItemCfg[1])] = PipeItem.new(pipeItemCfg, cfg.id)
            end
        end
    end
    self:SetServerInfo(serverInfo)
end

---@param serverInfo PipeInfoData[]
function PipeGroup:SetServerInfo(serverInfo)
    for _, infoData in ipairs(serverInfo) do
        if self.infoData[infoData.plantId] then
            self.infoData[infoData.plantId]:SetServerInfo(infoData)
        end
    end
end
---@class PipeManager
local PipeManager = {}

function PipeManager:Init()
    ---@type table<string, PipeGroup>
    self.scenePipe = {}
end


function PipeManager:ResponseSceneInfo(sceneID, serverInfo)
    if self.scenePipe[sceneID] then
        self.scenePipe[sceneID]:SetServerInfo(serverInfo)
    else
        self.scenePipe[sceneID] = PipeGroup.new(sceneID, serverInfo)
    end
end
---@return PipeItem
function PipeManager:GetPipeItem(sceneId, agentId)
    local pipeGroup = self.scenePipe[sceneId]
    if pipeGroup  then
        local pipeItem = self.scenePipe[sceneId].infoData[agentId]
        return pipeItem
    end
    return nil
end

function PipeManager:GetPipeState(sceneId, agentId, agentState)
    local pipeItem = self:GetPipeItem(sceneId, agentId)
    if pipeItem then
        if agentState == CleanState.cleared then
            return pipeItem.endState
        else
            return pipeItem.state
        end
    end
    return 1
end

function PipeManager:GetFirstUndoneAgentId(pipeId)
    local sceneId = App.scene:GetCurrentSceneId()
    local cfg = AppServices.Meta:Category("PipeTemplate")[pipeId]
    if cfg and cfg.sceneId == sceneId then
        for _, pipeItemCfg in ipairs(cfg.location) do
            local agentId = tostring(pipeItemCfg[1])
            local endState = tonumber(pipeItemCfg[3])
            if agentId and endState then
                local agent = App.scene.objectManager:GetAgent(agentId)
                if agent and agent.data and agent.data.meta then
                    local tState = tonumber(agent.data.meta.FuncParam[1]) --转一圈需要几次。
                    if tState and (self:GetPipeState(sceneId, agent:GetId(), agent:GetState()) - 1) % tState + 1 ~= endState then
                        return agentId
                    end
                end
            end
        end
    end
    return nil
end

function PipeManager:TurnPipleRequest(sceneId, agentId, cost, callback)
    local function onSuc(response)
        local pipeItem = self:GetPipeItem(sceneId, agentId)
        if pipeItem then
            if response.plants and cost and response.plants.consumed.count >= cost  then
                pipeItem.state = pipeItem.state + 1
            end
            if response.finished then
                MessageDispatcher:SendMessage(MessageType.PipeFinished, pipeItem.pipeId)
            end
        end
        if response.costs then
            for _, itemMsg in ipairs(response.costs) do
                AppServices.User:UseItem(itemMsg.itemTemplateId, itemMsg.count, ItemUseMethod.turn_pipe)
                local widget = ItemId.GetWidget(itemMsg.itemTemplateId)
                if widget and not widget:IsDisposed() then
                    local cur = widget.GetValue and widget:GetValue() or 0
                    if widget.SetValue then
                        widget:SetValue(cur - itemMsg.count)
                    end
                end
            end
        end
        Runtime.InvokeCbk(callback, true, response.plants)
    end

    local function onFail(eCode)
        ErrorHandler.ShowErrorPanel(eCode)
        Runtime.InvokeCbk(callback, false)
    end
    Net.Scenemodulemsg_25327_TurnPipe_Request({sceneId = sceneId, plantId = agentId}, onFail, onSuc)
end

PipeManager:Init()

return PipeManager