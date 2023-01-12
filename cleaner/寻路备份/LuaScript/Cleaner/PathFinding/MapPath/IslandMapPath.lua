---@type PathFindingController
local PathFindingController = require "Cleaner.PathFinding.PathFindingController"

---@type AABB
local AABB = require "Cleaner.PathFinding.AABB.AABB"

---@type IslandTemplateTool
local IslandTemplateTool = require "Fsm.Ship.IslandTemplateTool"

---@type FindPathInfo
local FindPathInfo = require "Cleaner.PathFinding.FindPathInfo"

---@type IslandMapPath
local IslandMapPath = class(nil, "IslandMapPath")

function IslandMapPath:ctor(islandId)
    self.islandId = islandId
    self.neighbour = {}
    self.parentIsland = -1

    local islandConfig = IslandTemplateTool:GetData(islandId)
    local bornPos = islandConfig.bornPos

    local map = App.scene.mapManager
    local position = Vector3(bornPos[1], 0, bornPos[2])
    local region = map:FindRegionByPos(position)
    if not region or islandId ~= region:GetId() then
        return
    end

    -- console.error("IslandMapPath:"..islandId)
    -- console.error("min:"..region.bounds.xMin.."   "..region.bounds.zMin)
    -- console.error("max:"..region.bounds.xMax.."   "..region.bounds.zMax)
    -- console.error("===================")

    -- 创建地图避免边缘无法创建，将尺寸向四周扩大 2 格
    local min = map:ToWorld(region.bounds.xMin - 1, region.bounds.zMin - 1) --@DEL
    local max = map:ToWorld(region.bounds.xMax + 1, region.bounds.zMax + 1) --@DEL
    self.mapMin = Vector2(min.x, min.z)
    self.mapSize = Vector2(max.x - min.x, max.z - min.z)
    self.aabb = AABB.new(self.mapMin, self.mapMin + self.mapSize)
    self.unstoppableBuildingType = nil

    -- local cube = GameObject.CreatePrimitive(CS.UnityEngine.PrimitiveType.Cube)
    -- cube.transform.localScale = Vector3((max - min).x, 0.1, (max - min).z)
    -- cube.transform.position = (min + max) * 0.5
    -- cube.name = tostring(self.islandId)

    self:Init()
end

function IslandMapPath:Init()
    self.pathFindingController = PathFindingController.new(FindPathInfo.AlgorithmType.Jps, FindPathInfo.MapType.Quad_Eight_Cleaner)
    local mapNodeHandle = function(worldX, worldZ)
        return self:GridPositionType(worldX, worldZ)
    end
    self.pathFindingController:SetMapNodeHandle(mapNodeHandle)
    local map = App.scene.mapManager
    self.pathFindingController:CreateMap(self.mapMin, self.mapMin + self.mapSize, map.gridSize)

    --console.error("测试")
    --self.pathFindingController:GetAll()

    -- local startPos = Vector2(3.5, 17.5)
    -- local endPos = Vector2(-6.5, 0.5)
    -- self:Search(startPos, endPos)
end

function IslandMapPath:Search(startPos, endPos)
    local list = self.pathFindingController:Search(startPos.x, startPos.y, endPos.x, endPos.y)
    return list
end

-- x = transform.x, y = transform.z
function IslandMapPath:EnablePass(x, y)
    return self.pathFindingController:EnablePass(x, y)
end

function IslandMapPath:RandomPath(x, y)
    return self.pathFindingController:RandomPath(x, y)
end

function IslandMapPath:GetAreaNode(min, max)
    return self.pathFindingController:GetAreaNode(min, max)
end

function IslandMapPath:SetNeighbourIsland(islandId, position)
    -- 当前岛屿连接的岛屿:islandId, 当前岛屿的坐标 position，是跟岛屿:islandId 连接的点
    self.neighbour[islandId] = position
end

function IslandMapPath:GetNeightbour()
    return self.neighbour
end

function IslandMapPath:GetNeighbourPosition(islandId)
    return self.neighbour[islandId]
end

function IslandMapPath:SetParent(islandId)
    self.parentIsland = islandId
end

function IslandMapPath:GetParent()
    return self.parentIsland
end

function IslandMapPath:CleanedAgent(agent)
    local map = App.scene.mapManager
    local x, z = agent:GetMin()
    local sx, sz = agent:GetSize()

    -- 尺寸向 min 和 max 各延长 1，避免计算精度导致算的位置有偏差
    local position = map:ToWorld(x - 1, z - 1)
    local minPos = Vector2(position.x, position.z)

    position = map:ToWorld(x + sx + 1, z + sz + 1)
    local maxPos = Vector2(position.x, position.z)
    self.pathFindingController:OpenArea(minPos, maxPos)

    --console.error("测试")
    --self.pathFindingController:GetAll()
end

function IslandMapPath:GridPositionType(worldX, worldZ)
    local map = App.scene.mapManager
    local x, z = map:ToLocal(Vector3(worldX, 0, worldZ))
    return self:GridGridType(x, z)
end

function IslandMapPath:GridGridType(x, z)
    local map = App.scene.mapManager
    local state = map:GetState(x, z)
    if state < CleanState.clearing then
        return FindPathInfo.NodeType.Null
    end

    local gridType = map:GetGridType(x, z)
    if gridType <= TileType.pass then
        return FindPathInfo.NodeType.Null
    end

    local agents = map:GetObjects(x, z)
    for _, agent in pairs(agents) do
        local agentType = agent:GetType()
        if not self:IsUnstoppableBuild(agentType) then
            return FindPathInfo.NodeType.Obstacle
        end
    end

    return FindPathInfo.NodeType.Smooth
end

function IslandMapPath:IsUnstoppableBuild(buildType)
    if not self.unstoppableBuildingType then
        self.unstoppableBuildingType = {}
        local unstoppables = AppServices.Meta:GetConfigMetaValue("unstoppableBuildingType", 50)
        if unstoppables then
            unstoppables = table.deserialize(unstoppables)
        end

        for _, value in pairs(unstoppables) do
            self.unstoppableBuildingType[value] = true
        end
    end

    return self.unstoppableBuildingType[buildType]
end

return IslandMapPath