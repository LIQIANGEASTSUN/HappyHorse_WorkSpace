---@type RVO2Manager
local RVO2Manager = { }

function RVO2Manager:Init()
    local neighborDist = 5
    local maxNeighbors = 5
    local timeHorizon = 2
    local timeHorizonObst = 2.1
    local radius = 0.5
    local maxSpeed = 5
    local velocity = Vector2(0, 0)
    RVO2Controller.Instance:setAgentDefaults(neighborDist, maxNeighbors, timeHorizon, timeHorizonObst, radius, maxSpeed, velocity)
end

function RVO2Manager:Update(dt)
    if self.isTest then
        self:SetVelocity(self.blueMap)
        self:SetVelocity(self.redMap)
    end

    RVO2Controller.Instance:setTimeStep(dt)
    RVO2Controller.Instance:doStep()

    if self.isTest then
        self:SetPosition(self.blueMap)
        self:SetPosition(self.redMap)
    end
end

function RVO2Manager:Release()
    RVO2Controller.Instance:Clear()
end

--- Test ------------------------------
function RVO2Manager:SetVelocity(map)
    for agentId, tr in pairs(map.agents) do
        local velocity = (map.target.position - tr.position)
        local v = Vector2(velocity.x, 0).normalized * 3
        RVO2Controller.Instance:setAgentPrefVelocity(agentId, v)
    end
end

function RVO2Manager:SetPosition(map)
    for agentId, tr in pairs(map.agents) do
        local p = RVO2Controller.Instance:getAgentPosition(agentId)
        local position = Vector3(p.x, 0, p.y)
        tr.position = position
    end
end

function RVO2Manager:CreateTest()
    if not self.isTest then
        self.isTest = true

        self.blueMap = {}
        self:CreateAgent(self.blueMap, Vector3(180, 0, 100),  Vector3(90, 0, 100), CS.UnityEngine.PrimitiveType.Sphere,  Color(0, 0, 1, 1))

        self.redMap = {}
        self:CreateAgent( self.redMap, Vector3(50, 0, 100), Vector3(130, 0, 100), CS.UnityEngine.PrimitiveType.Cube,  Color(0, 0, 0, 1))

        self:CreateObstacle()
    else
        RVO2Controller.Instance:removeObstacle(self.obstacleGroupId)
    end
end

function RVO2Manager:CreateAgent(map, targetPos, pos, type, color)
    map.target = self:CreateGo(type, Vector3(1, 1, 1), color).transform
    map.target.transform.position = targetPos
    map.target.name = "RVO2Target"

    map.agents = {}
    for i = 1, 10 do
        for j = 1, 10 do
            local go = self:CreateGo(type, Vector3(0.5, 0.5, 0.5), color)
            local position = Vector3(pos.x + (i - 5) * 1.6, 0, pos.z + (j - 5) * 1.6)
            go.transform.position = position
            local p = Vector2(position.x, position.z)
            local rvo2AgentId = RVO2Controller.Instance:addAgent(p)
            map.agents[rvo2AgentId] = go.transform
        end
    end
end

function RVO2Manager:CreateObstacle()
    local posArr = { Vector2(100, 90), Vector2(110, 90), Vector2(110, 100), Vector2(100, 100)}
    for i, pos in ipairs(posArr) do
        local go = self:CreateGo(CS.UnityEngine.PrimitiveType.Cube, Vector3(0.5, 0.5, 0.5), Color(1, 0, 0, 1))
        go.transform.position = Vector3(pos.x, 0, pos.y)
        go.name = tostring(i)
    end

    self.obstacleGroupId = RVO2Controller.Instance:addObstacle(posArr)
end

function RVO2Manager:CreateGo(type, scale, color)
    local go = GameObject.CreatePrimitive(type)
    go.transform.localScale = scale
    local render = go:GetComponent(typeof(CS.UnityEngine.Renderer))
    local mat = render.material
    mat:SetColor("_Color", color)
    return go
end

---------------------------------------

return RVO2Manager