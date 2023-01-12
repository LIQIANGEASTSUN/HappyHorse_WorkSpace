---@class AutoJump
local AutoJump = {}

---跳转任务
function AutoJump.JumpTask(taskSn)
    AppServices.JumpTask.JumpByTaskSn(taskSn)
end

---@param agent BaseAgent
function AutoJump.FocusAgent(agent, callback, moveCameraDuration)
    if not agent then
        return
    end
    local pos = agent:GetAnchorPosition(true)
    MessageDispatcher:SendMessage(MessageType.Camera_Follow_Player, false)
    local cbk = function()
        MessageDispatcher:SendMessage(MessageType.Camera_Follow_Player, true)
        Runtime.InvokeCbk(callback)
    end
    MoveCameraLogic.Instance():MoveCameraToLook2(pos, moveCameraDuration or 0.5, nil, cbk)
end

function AutoJump.JumpFactoryByItemId(itemId)
    local cfgs = AppServices.Meta:Category("BuildingLevelTemplate")
    local agentTemplateId
    for _, cfg in pairs(cfgs) do
        for _, item in ipairs(cfg.production) do
            if item[1] == itemId then
                agentTemplateId = cfg.building
                break
            end
        end
        if agentTemplateId then
            break
        end
    end
    if not agentTemplateId then
        return
    end
    local agent = App.scene.objectManager:GetAgentByTemplateId(agentTemplateId)
    if not agent or agent:GetState() < CleanState.clearing then
        return
    end
    agent:ProcessClick()
end

function AutoJump.JumpDecorationFactory()
    local agent = App.scene.objectManager:GetAgentByType(AgentType.decoration_factory)
    if not agent or agent:GetState() < CleanState.clearing then
        return
    end
    agent:ProcessClick()
end

function AutoJump.JumpRecycle()
    local agent = App.scene.objectManager:GetAgentByType(AgentType.recycle)
    if not agent or agent:GetState() < CleanState.clearing then
        return
    end
    agent:ProcessClick()
end

function AutoJump.JumpDock()
    local agent = App.scene.objectManager:GetAgentByType(AgentType.dock)
    if not agent or agent:GetState() < CleanState.clearing then
        return
    end
    agent:ProcessClick()
end

function AutoJump.JumpLinkIsland()
    local inIsland, region_id = AppServices.IslandManager:InIsland()
    if not inIsland then
        AutoJump.JumpDock()
        return
    end

    local regionMgr = App.scene.mapManager and App.scene.mapManager.regionManager

    local region = regionMgr and regionMgr:FindRegion(region_id)
    if region then
        local agents = region:FindAllAgents()
        for _, agent in pairs(agents) do
            local agentType = agent:GetType()
            if (agentType == AgentType.ground or agentType == AgentType.linkHomeland_groud) and agent:Suckable() then
                return AutoJump.FocusAgent(agent)
            end
        end
    end
    local str = "击败boss后即可扩建"
    AppServices.UITextTip:Show(str)
end

return AutoJump