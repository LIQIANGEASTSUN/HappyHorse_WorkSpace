---@type IMap
local IMap = require "Cleaner.PathFinding.Map.IMap"

---@type FindPathInfo
local FindPathInfo = require "Cleaner.PathFinding.FindPathInfo"

---@type Node
local Node = require "Cleaner.PathFinding.Node.Node"

---@type Position
local Position = require "Cleaner.PathFinding.Map.Position"

---@type MapCleaner
local MapCleaner = class(IMap, "MapCleaner")

function MapCleaner:ctor(mapType)
    self.mapType = mapType
    self.neighborType = FindPathInfo.MapNodeNeighborType[mapType]
end

function MapCleaner:Create(min, max, width)

end

function MapCleaner:SetMapNodeHandle(handle)
    self.mapNodeHandle = handle
end

-- 开辟一块区域
function MapCleaner:OpenArea(min, max)
end

function MapCleaner:StartSearch()
    self.gridDic = {}
end

function MapCleaner:GetAreaNode(min, max)
    self.gridDic = {}
    local resultList = {}
    local _, minRow, minCol = self:PositionToRowCell(min.x, min.y)
    local _, maxRow, maxCol = self:PositionToRowCell(max.x, max.y)
    for row = minRow, maxRow do
        for col = minCol, maxCol do
            local node = self:GetNode(row, col)
            local nodeType = node and node.NodeType or FindPathInfo.NodeType.Null
            local value = (nodeType ~= FindPathInfo.NodeType.Null) and (nodeType ~= FindPathInfo.NodeType.Obstacle)
            if value then
                local position = self:NodeToPosition(node)
                table.insert(resultList, Vector3(position.x, 0, position.y))
            end
        end
    end

    return resultList
end

function MapCleaner:CreateNode( row, col)

end

-- 设置一个区域的格子类型
function MapCleaner:SetAreaNodeType( min, max, nodeType)

end

function MapCleaner:CreateNodeWithType( row, col, nodeType)
end

function MapCleaner:SetNode( node, nodeType)

end

-- 地图所有节点
function MapCleaner:Grid()
    local result = {}
    return result
end

-- 地图尺寸
function MapCleaner:MapSize()
    return nil
end

-- 根据坐标获取 Node
-- float x, float y
function MapCleaner:PositionToNode(worldX, worldZ)
    local result, row, col = self:PositionToRowCell(worldX, worldZ)
    if(not result) then
        return nil
    end

    return self:GetNode(row, col)
end

function MapCleaner:PositionToRowCell( worldX, worldZ)
    local map = App.scene.mapManager
    local x, z = map:ToLocal(Vector3(worldX, 0, worldZ))
    local row, col = x, z
    return true, row, col
end

--- 根据 Node 获取坐标
-- Node node
function MapCleaner:NodeToPosition(node)
    local row, col = node.Row, node.Col
    return self:RowColToPosition(row, col)
end

function MapCleaner:RowColToPosition( row, col)
    local map = App.scene.mapManager
    local position = map:ToWorld(row, col)
    return Position.new(position.x, position.z)
end

--- 获取 Node 的第 index 个邻居
-- Node node, int index, ref float distance
function MapCleaner:NodeNeighborWithDistance( node, index)
    local row, col = self:NodeNeighbourRowCol(node, index)

    local distance = 0
    ---@type Node
    local temp = self:GetNode(row, col)
    if (nil ~= temp) then
        distance = math.sqrt(math.abs(node.Row - row) + math.abs(node.Col - col))
    end
    return temp, distance
end

-- Node node, int index
function MapCleaner:NodeNeighbourRowCol( node, index)
    -- 每个节点 4/8个邻居的相对二维坐标
    local neighborArr = FindPathInfo.NeighborQuad[self.neighborType]
    local row = node.Row + neighborArr[index][1]
    local col = node.Col + neighborArr[index][2]
    return row, col
end

--- Node node, int index
function MapCleaner:NodeNeighbor( node, index)
    local row, col = self:NodeNeighbourRowCol(node, index);
    ---@type Node
    local temp = self:GetNode(row, col)
    return temp
end

-- int row, int col
function MapCleaner:GetNode(row, col)
    local index = self:RCToIndex(row, col)
    local node = self.gridDic[index]

    if not node then
        node = Node.new(row, col, self.neighborType)
        self.gridDic[index] = node
    end

    node.NodeType = FindPathInfo.NodeType.Null

    local x, z = row, col
    local map = App.scene.mapManager
    local state = map:GetState(x, z)
    if state < CleanState.clearing then
        return node
    end

    local gridType = map:GetGridType(x, z)
    if gridType <= TileType.pass then
        return node
    end

    local agents = map:GetObjects(x, z)
    for _, agent in pairs(agents) do
        local agentType = agent:GetType()
        if not self:IsUnstoppableBuild(agentType) then
            node.NodeType = FindPathInfo.NodeType.Obstacle
            return node
        end
    end

    node.NodeType = FindPathInfo.NodeType.Smooth
    return node
end

-- int row, int col
function MapCleaner:RCToIndex( row, col)
    self.maxCol = 10000
    local index = row * self.maxCol + col
    return index
end

function MapCleaner:IsUnstoppableBuild(buildType)
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

return MapCleaner