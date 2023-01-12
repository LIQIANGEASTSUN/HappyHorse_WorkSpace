---@type Position
local Position = require "Cleaner.PathFinding.Map.Position"

---@type Heap
local Heap = require "Cleaner.PathFinding.Heap.Heap"

---@type FindPathInfo
local FindPathInfo = require "Cleaner.PathFinding.FindPathInfo"

---@class PathFindingController
local PathFindingController = class(nil, "PathFindingController")

function PathFindingController:ctor(algorithmType, mapType)
    -- 算法
    self.pathFind = nil

    self:InitMap(mapType)
    self:CreatePathFind(algorithmType)
end

function PathFindingController:CreatePathFind(algorithmType)
    local pathFindAlias = FindPathInfo.Algorithms[algorithmType]
    local pathFind = include(pathFindAlias)

    -- 初始化 算法，并将地图数据传递进去
    self.pathFind = pathFind.new(self.map)
end

function PathFindingController:InitMap(mapType)
    local mapAlias = FindPathInfo.Maps[mapType]
    local map = include(mapAlias)
    -- 地图
    self.map = map.new(mapType)
end

function PathFindingController:SetMapNodeHandle(handle)
    self.map:SetMapNodeHandle(handle)
end

-- Vector2 min, Vector2 max, float gridSize
function PathFindingController:CreateMap( min, max, gridSize)
    self.map:Create(min, max, gridSize)
end

-- Vector2 center, Vector2 size, int nodeType
function PathFindingController:SetAreaNodeType( center, size, nodeType)
    size = size * 0.5
    local min = center - size
    local max = center + size
    self.map:SetAreaNodeType(min, max, nodeType)
end

function PathFindingController:OpenArea(min, max)
    self.map:OpenArea(min, max)
end

function PathFindingController:GetNode(x, y)
    local node = self.map:PositionToNode(x, y)
    return node
end

-- return List<Vector2>  -- float startX, float startY, float endX, float endY
function PathFindingController:Search( startX, startY, endX, endY)
    local list = {}
    -- 获取开始位置、终点位置
    ---@type Position
    local from = Position.new(startX, startY)
    local to = Position.new(endX, endY)

    -- 搜索路径，如果返回结果为 null，则说明没有找到路径，否则说明已找到路径，且 pathNode 为终点节点
    -- 顺着 pathNode 一直向上查找 parentNode，最终将到达开始点
    ---@type Node
    local pathNode = self.pathFind:SearchPath(from, to)
    while (nil ~= pathNode) do
        ---@type Position
        local pos = self.map:NodeToPosition(pathNode)
        ---@type Vector2
        local vec = Vector2(pos.x, pos.y)
        table.insert(list, 1, vec)
        pathNode = pathNode.Parent
    end

    return list
end

function PathFindingController:GetAreaNode(min, max)
    return self.map:GetAreaNode(min, max)
end

function PathFindingController:EnablePass(x, y)
    local node = self:GetNode(x, y)
    if not node then
        return false
    end

    local nodeType = node.NodeType
    return (nodeType ~= FindPathInfo.NodeType.Null) and  (nodeType ~= FindPathInfo.NodeType.Obstacle)
end

function PathFindingController:RandomPath(x, y)
    local node = self:GetNode(x, y)
    if not node then
        return false, Vector3(0, 0, 0)
    end

    local resultNode = nil
    local bigHeap = Heap.new()
    bigHeap:SetHeapType(true)
    node.NodeState = FindPathInfo.NodeState.InColsedTable
    bigHeap:Insert(node)

    local list = {}
    table.insert(list, node)

    local count = 0
    while bigHeap:Count() > 0 do
        local node = bigHeap:DelRoot()
        resultNode = node
        for i = 1, node.neighborType do
            local neighborNode = self.map:NodeNeighbor(node, i)
            local nodeType = neighborNode.NodeType
            if neighborNode and neighborNode.NodeState ~= FindPathInfo.NodeState.InColsedTable and nodeType == FindPathInfo.NodeType.Smooth then
                local distance = math.abs(resultNode.Row - neighborNode.Row) + math.abs(resultNode.Col - neighborNode.Col)
                neighborNode.G = resultNode.G + neighborNode.Cost * distance
                neighborNode.NodeState = FindPathInfo.NodeState.InColsedTable
                bigHeap:Insert(neighborNode)

                table.insert(list, neighborNode)
            end
        end

        count = count + 1
        if count > 10 then
            break
        end
    end

    for _, node in pairs(list) do
        node:Clear()
    end
    list = {}

    local position = self.map:NodeToPosition(resultNode)
    return true, Vector3(position.x, 0, position.y)
end

-- 岛屿地图测试
function PathFindingController:GetAll()
    if self.allCube then
        for _, go in pairs(self.allCube) do
            GameObject.Destroy(go)
        end
    end
    self.allCube = {}

    -- List<Vector3>
    local list = {}
    local nodes = self.map:Grid()
    for _, node in pairs(nodes) do
        ---@type Position
        local position = self.map:NodeToPosition(node)
        local cube = GameObject.CreatePrimitive(CS.UnityEngine.PrimitiveType.Sphere)
        cube.transform.localScale = Vector3.one * 0.1
        cube.transform.position = Vector3(position.x, 0, position.y)
        table.insert(self.allCube, cube)

        local vec3 = Vector3(position.x, 0, position.y)
        table.insert(list, vec3)
    end
    return list
end

return PathFindingController