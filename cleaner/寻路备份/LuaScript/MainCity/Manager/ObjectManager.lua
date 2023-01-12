local AgentTypes =
    setmetatable(
    {
        _registry = {
            -- [AgentType.ship] = "ShipAgent"
            [AgentType.food_factory] = "FoodFactoryAgent",
            [AgentType.dock] = "ShipDockAgent",
            [AgentType.resource] = "ResourceAgent",
            [AgentType.recycle] = "RecycleAgent",
            [AgentType.animal] = "MonsterAgent",
            [AgentType.ground] = "GroundAgent",
            [AgentType.decoration] = "DecorationAgent",
            [AgentType.recovery_pet] = "RecoveryPetAgent",
            [AgentType.decoration_factory] = "DecorationFactoryAgent",
            [AgentType.decoration_building] = "NormalAgent",
            [AgentType.linkHomeland_groud] = "LinkGroundAgent",
        }
    },
    {
        __index = function(t, k)
            local name = t._registry[k]
            if string.isEmpty(name) then
                console.error("Agent of Type:[", tostring(k), "] Not Found! Using Type:NormalAgent") --@DEL
                name = "NormalAgent"
            end
            local path = "MainCity.Agent." .. name
            local v = include(path)
            rawset(t, k, v)
            return v
        end
    }
)
local AgentDataTypes =
    setmetatable(
    {
        _registry = {
            [AgentType.animal] = "MonsterAgentData",
            [AgentType.ground] = "GroundData",
            [AgentType.linkHomeland_groud] = "GroundData",
        }
    },
    {
        __index = function(t, k)
            local name = t._registry[k]
            if string.isEmpty(name) then
                name = "AgentData"
            end
            local path = "MainCity.Data." .. name
            local v = include(path)
            rawset(t, k, v)
            return v
        end
    }
)

---@class ObjectManager
local ObjectManager = class(nil, "ObjectManager")

function ObjectManager:ctor(sceneId)
    self.isAlive = true
    ---@type dictionary<string, ObjectData>
    self.mapDatas = CONST.RULES.LoadObjectData(sceneId)

    --记录场景中的所有物体<id, agent>
    ---@type dictionary<string, BaseAgent>
    self.sceneObjs = {}

    self.rootGo = GameObject("ObjectsRoot")
    UserInput.registerListener(self, UserInputType.clickObstacle, self.HandleClick)
end

function ObjectManager:CreateAgents(datas)
    local deleted = {}
    for _, id in ipairs(datas.removeBuildings or {}) do
        deleted[id] = true
    end

    local buildings = {}
    for _, building in ipairs(datas.putBuildings or {}) do
        buildings[building.id] = building
    end

    local mapManager = App.scene.mapManager
    ---第一步 先创建所有建筑
    for id, _ in pairs(self.mapDatas) do
        local agent = self:CreateAgent(id, buildings[id])
        if agent then
            self.sceneObjs[id] = agent
            mapManager:InsertObject(agent)
        end
    end
    ---第二步 动态创建的建筑
    for id, building in pairs(buildings) do
        local agent = self.sceneObjs[id]
        if not agent then
            agent = self:CreateAgent(id, building)
            if agent then
                self.sceneObjs[id] = agent
                mapManager:InsertObject(agent)
            end
        end
        if agent then
            agent:InitExtraData(building)
        else
            console.error("Agent Create Failed: " .. table.tostring(building)) --@DEL
        end
    end
    for _, building in pairs(datas.unlockBuildingsProgress or {}) do
        local id = building.id
        local agent = self.sceneObjs[id]
        if not agent then
            agent = self:CreateAgent(id, buildings[id])
            if agent then
                self.sceneObjs[id] = agent
                mapManager:InsertObject(agent)
            end
        end
        if agent then
            agent:InitExtraData(building.progress)
        else
            console.error("Agent Create Failed: " .. table.tostring(building)) --@DEL
        end
    end

    ---第三步 设置初始状态
    local uncontroled = {} --未被统计物体
    for id, v in pairs(self.sceneObjs) do
        local agent = v
        if agent.alive then
            if deleted[id] then
                agent:InitState(CleanState.cleared)
            elseif buildings[id] then
                agent:InitState(CleanState.clearing)
            else
                table.insert(uncontroled, agent)
            end
        end
    end

    for _, agent in pairs(uncontroled) do
        if agent.alive then
            agent:InitState(CleanState.locked)
        end
    end

    ---第四步 状态变化逻辑
    for _, agent in pairs(self.sceneObjs) do
        if agent.alive then
            agent:HandleStateChanged()
        end
    end
    self.allAgentInitFinish = true
end
---@return BaseAgent
function ObjectManager:CreateAgent(id, sdata)
    local mapData = self.mapDatas[id]
    local tid = (mapData and mapData.tid) or (sdata and sdata.tid)
    if not tid then
        console.error("未找到障碍物数据[", tostring(id), "]没有配置") --@DEL
        return
    end
    local meta = AppServices.Meta:GetBindingMeta(tostring(tid))
    if not meta then
        console.error("障碍物模板id[", tostring(mapData.tid), "]没有配置") --@DEL
        return
    end
    local dataCls = AgentDataTypes[meta.type]
    local agentData = dataCls.new(mapData, meta)
    ---@type BaseAgent
    local agent = AgentTypes[meta.type].new(id, agentData)
    agent:InitServerData(sdata)
    return agent
end

function ObjectManager:GetRoot()
    return self.rootGo
end

function ObjectManager:GetMapData(id)
    return self.mapDatas[id]
end

---@return BaseAgent
function ObjectManager:GetAgent(id)
    return self.sceneObjs[id]
end

---@return BaseAgent 返回找到的第一个 无序, 仅适合场景中只有一个templateId的障碍物
function ObjectManager:GetAgentByTemplateId(templateId)
    -- mapData.id
    for _, agent in pairs(self.sceneObjs) do
        if agent:GetTemplateId() == templateId then
            return agent
        end
    end
end

---@return BaseAgent 返回找到的第一个 无序, 仅适合场景中只有一个type的障碍物
function ObjectManager:GetAgentByType(agentType)
    -- mapData.id
    for _, agent in pairs(self.sceneObjs) do
        if agent:GetType() == agentType then
            return agent
        end
    end
end

---@return BaseAgent[] 返回指定type的所有agent
function ObjectManager:GetAgentsByType(agentType, canBeSeen)
    local result = {}
    for _, agent in pairs(self.sceneObjs) do
        if agent:GetType() == agentType and (not canBeSeen or agent:CanBeSeen()) then
            table.insert(result, agent)
        end
    end
    return result
end

function ObjectManager:IsAllAgentInitFinish()
    return self.allAgentInitFinish
end

function ObjectManager:DestroyObject(id)
    self.sceneObjs[id] = nil
end

function ObjectManager:HandleClick()
    local ids = UserInput.getCastList()
    if not ids and #ids == 0 then
        return
    end
    local agent = self:GetAgent(ids[1])
    agent:ProcessClick()
end

function ObjectManager:DrawGizmos()
    for _, obj in pairs(self.sceneObjs) do
        obj:DrawGizmos()
    end
    -- if CS.GizmosUtil.showAgentId then
    --     for key, obj in pairs(self.sceneObjs) do
    --         obj:DrawGizmos()
    --     end
    -- end
    -- if CS.GizmosUtil.showAgentState then
    --     for key, obj in pairs(self.sceneObjs) do
    --         obj:DrawGizmos()
    --     end
    -- end
end

---根据障碍物的obstacleType配置来查找障碍物
---@param obstacleType int 障碍物类型
---@param position Vector3 查找的起点
---@param CanJumpNotClearing bool 是否允许查找未显示的障碍物
function ObjectManager:GetAgentByObstacleType(
    obstacleType,
    position,
    CanJumpNotClearing,
    getNearIds,
    noCleard,
    lookupWay)
    local selAgent, minDis = nil
    local agentIds = nil
    local minId = nil
    for agentId, agent in pairs(self.sceneObjs) do
        if
            (CanJumpNotClearing or agent:CanBeSeen()) and (not noCleard or agent:GetState() ~= CleanState.cleared) and
                agent:GetObstacleType() == obstacleType
         then
            if position then
                local curPos = agent:GetWorldPosition()
                local dis = curPos:FlatDistance(position)
                if getNearIds then
                    agentIds = agentIds or {}
                    table.insert(agentIds, {id = agentId, dis = dis})
                end
                if not lookupWay or lookupWay == LookUpWay.NearPlayer then
                    if not minDis or minDis > dis then
                        minDis = dis
                        selAgent = agent
                    end
                else
                    if not minId or minId > tonumber(agentId) then
                        minId = tonumber(agentId)
                        selAgent = agent
                    end
                end
            else
                return agent
            end
        end
    end
    return selAgent, minDis, agentIds
end
function ObjectManager:GetAgentAchievementType(
    achievementType,
    position,
    CanJumpNotClearing,
    getNearIds,
    noCleard,
    lookupWay,
    onlyClearing)
    local selAgent, minDis = nil
    local agentIds = nil
    local minId = nil
    for agentId, agent in pairs(self.sceneObjs) do
        if
            (CanJumpNotClearing or agent:CanBeSeen(onlyClearing)) and
                (not noCleard or agent:GetState() ~= CleanState.cleared) and
                agent:GetAchievementType() == achievementType
         then
            if position then
                local curPos = agent:GetWorldPosition()
                local dis = curPos:FlatDistance(position)
                if getNearIds then
                    agentIds = agentIds or {}
                    table.insert(agentIds, {id = agentId, dis = dis})
                end
                if not lookupWay or lookupWay == LookUpWay.NearPlayer then
                    if not minDis or minDis > dis then
                        minDis = dis
                        selAgent = agent
                    end
                else
                    if not minId or minId > tonumber(agentId) then
                        minId = tonumber(agentId)
                        selAgent = agent
                    end
                end
            else
                return agent
            end
        end
    end
    return selAgent, agentIds, minDis
end

function ObjectManager:GetAgentsByAchievementType(achievementType, position)
    local res = nil
    for agentId, agent in pairs(self.sceneObjs) do
        if agent:GetAchievementType() == achievementType and agent:GetState() ~= CleanState.cleared then
            res = res or {}
            local curPos = agent:GetWorldPosition()
            local dis = curPos:FlatDistance(position)
            local info = {
                id = agentId,
                idInt = tonumber(agentId),
                dis = dis
            }
            table.insert(res, info)
        end
    end
    return res
end

function ObjectManager:GetAgentByTemplateIds(
    templateIds,
    position,
    CanJumpNotClearing,
    onlyClearing,
    getNearIds,
    lookupWay)
    local selAgent, minDis, agentIds = nil
    local minId
    for agentId, agent in pairs(self.sceneObjs) do
        local check = true
        if agent:GetState() == CleanState.cleared and agent.HasDrops then
            if not agent:HasDrops() then
                check = false
            end
        end
        if check and (CanJumpNotClearing or agent:CanBeSeen(onlyClearing)) and templateIds[agent:GetTemplateId()] then
            if position then
                local curPos = agent:GetWorldPosition()
                local dis = curPos:FlatDistance(position)
                if getNearIds then
                    agentIds = agentIds or {}
                    table.insert(agentIds, {id = agentId, dis = dis})
                end
                if not lookupWay or lookupWay == LookUpWay.NearPlayer then
                    if not minDis or minDis > dis then
                        minDis = dis
                        selAgent = agent
                    end
                else
                    if not minId or minId > tonumber(agentId) then
                        minId = tonumber(agentId)
                        selAgent = agent
                    end
                end
            else
                return agent
            end
        end
    end
    return selAgent, agentIds
end

local function sortAgentId(a, b)
    local an, bn = tonumber(a), tonumber(b)
    return an < bn
end

function ObjectManager:GetAgentIdsByTemplateIds(templateIds, CanJumpNotClearing, onlyClearing, lookupWay)
    local ids = {}
    for agentId, agent in pairs(self.sceneObjs) do
        local check = true
        if agent:GetState() == CleanState.cleared and agent.HasDrops then
            if not agent:HasDrops() then
                check = false
            end
        end
        if check and (CanJumpNotClearing or agent:CanBeSeen(onlyClearing)) and templateIds[agent:GetTemplateId()] then
            table.insert(ids, agentId)
        end
    end
    table.sort(ids, sortAgentId)
    return ids
end

function ObjectManager:SetPrune(prune)
    for _, agent in pairs(self.sceneObjs) do
        agent:SetPrune(prune)
    end
end
-----------------------------------------------------------------------------------------------------------
function ObjectManager.GetDataType(type)
    return AgentDataTypes[type]
end-------------------------------------------------------------------------------
function ObjectManager:OnDestroy()
    self.isAlive = nil
    -- console.warn(nil, '*-*-*-*-*-*-*-*-*-*-*-*-object manager --- destroy*-*-*-*-*-*-*-*-*-*-*-*-')

    if self.sceneObjs then
        for _, binding in pairs(self.sceneObjs) do
            binding:Destroy()
        end
    end
    self.sceneObjs = {}
    self.mapDatas = {}

    Runtime.CSDestroy(self.rootGo)
    self.rootGo = nil
    UserInput.removeListener(self, UserInputType.clickObstacle)
end
return ObjectManager
