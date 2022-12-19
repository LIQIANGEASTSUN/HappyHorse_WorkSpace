local DebugHelper = {}

function DebugHelper.PassMissionTo(taskId)
    console.lzl('跳转任务', taskId) --@DEL
    AppServices.Task:GmJumpTask(taskId)
end

function DebugHelper.UnlocalAllMap()
    local sceneNames = CONST.GAME.SCENE_NAMES
    -- for i, sceneId in ipairs(sceneNames) do
    for i = #sceneNames, 1, -1 do
        local sceneId = sceneNames[i]
        local cfg = AppServices.Meta:GetSceneCfg()[sceneId]
        if cfg.unlockCondition == 1 and cfg.param then
            if not AppServices.Task:IsTaskFinish(cfg.param) then
                console.lzl('解锁任务', cfg.param) --@DEL
                AppServices.Task:GmJumpTask(cfg.param, true)
                break
            end
        end
    end

    local btn = App.scene:GetWidget(CONST.MAINUI.ICONS.WorldMapBtn)
	if not btn then
		console.lzl("解锁按钮不存在! eType == ", tostring(CONST.MAINUI.ICONS.WorldMapBtn)) --@DEL
		return
	end
	if btn.canvasGroup then
		btn.canvasGroup.alpha = 1
	end
    btn.img_btn:SetActive(true)
end

local digState = {
    Waiting = 0,
    Digging = 1,
    Digged = 2,
}

function DebugHelper.AutoDig(digDis)
    local playerPos = GetPers("Femaleplayer"):GetPosition()
    digDis = digDis or 3
    -- local count = 0
    local blockAutoDig = {
        [AgentType.bomb] = true,
        [AgentType.dragonCollect] = true,
    }
    local agents = App.scene.objectManager.sceneObjs
    DebugHelper._diggAgentStates = DebugHelper._diggAgentStates or {}
    local sceneId = App.scene:GetCurrentSceneId()
    local digStatesCache = DebugHelper._diggAgentStates[sceneId]
    if not digStatesCache then
        digStatesCache = {}
        DebugHelper._diggAgentStates[sceneId] = digStatesCache
    end
    local diggingAgents = DebugHelper._diggingAgents
    if not diggingAgents then
        diggingAgents = {}
        DebugHelper._diggingAgents = diggingAgents
    end
    for i, agent in pairs(agents) do
        local agentPos = agent:GetWorldPosition()
        if agentPos:FlatDistance(playerPos) <= digDis then
            local state = agent:GetState()
            local agentType = agent:GetType()
            if state == CleanState.clearing and not blockAutoDig[agentType]then
                local isUnlock = agent:IsTaskUnlock()
                local canAuto = agent:GetType() ~= AgentType.TimeLimitGiftAgent
                if canAuto and isUnlock then
                    local id, cost = agent:GetCurrentCost()
                    if cost == 0 then
                        local agentId = agent:GetId()
                        if not digStatesCache[agentId] then
                            digStatesCache[agentId] = digState.Waiting
                            table.insert(diggingAgents, agentId)
                        end
                    end
                    local itType = AppServices.Meta:GetItemType(id)
                    if agent:HasDragonReward() then
                        -- console.lzl('发光的不挖')
                    elseif itType == PropsType.dragonKey then
                        -- console.lzl('需要钥匙的不挖')
                    else
                        local agentId = agent:GetId()
                        if not digStatesCache[agentId] then
                            digStatesCache[agentId] = digState.Waiting
                            table.insert(diggingAgents, agentId)
                        end
                    end
                end
            end
        end
    end

    if #diggingAgents == 0 then
        return
    end
    DebugHelper.AutoDigEx()
end

function DebugHelper.AutoDigEx()
    local diggingAgents = DebugHelper._diggingAgents
    if not diggingAgents or #diggingAgents == 0 then
        return
    end
    local sceneId = App.scene:GetCurrentSceneId()
    local digStatesCache = DebugHelper._diggAgentStates[sceneId]
    if not digStatesCache then
        digStatesCache = {}
        DebugHelper._diggAgentStates[sceneId] = digStatesCache
    end
    local total = 0
    local agents = {}
    for i = #diggingAgents, 1, -1 do
        local agentId = diggingAgents[i]
        if digStatesCache[agentId] == digState.Waiting then
            table.insert(agents, agentId)
            table.remove(diggingAgents, i)
            digStatesCache[agentId] = digState.Digging
            total = total + 1
            if total >= 5 then
                break
            end
        end
    end
    if total == 0 then
        return
    end
    local cur = 0
    local requestCbk = function(refreshAgent, response)
        Runtime.InvokeCbk(refreshAgent, response)
        cur = cur + 1
        if cur >= total then
            DebugHelper.AutoDigEx()
        end
    end
    ConnectionManager:block()
    for _, agentId in ipairs(agents) do
        local agent = App.scene.objectManager:GetAgent(agentId)
        digStatesCache[agentId] = digState.Digged
        if agent then
            agent:StartClean(nil, requestCbk)
        end
    end
    console.lzl('挖掘了周围的障碍物', total, '个') --@DEL
    ConnectionManager:flush(true)
end

return DebugHelper