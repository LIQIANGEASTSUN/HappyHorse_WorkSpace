---@type IMap
local IMap = require "Cleaner.PathFinding.Map.IMap"

---@type FindPathInfo
local FindPathInfo = require "Cleaner.PathFinding.FindPathInfo"

---@type Node
local Node = require "Cleaner.PathFinding.Node.Node"

---@type Position
local Position = require "Cleaner.PathFinding.Map.Position"

---@type MapQuad
local MapQuad = class(IMap, "MapQuad")

function MapQuad:ctor()
    self.nodeWidth = 1
end

function MapQuad:Create(min, max, width)
    IMap.Create(self, min, max, width)
    self.nodeWidth = width

    self.maxCol = math.ceil(self.mapSize:Xwidth() / self.nodeWidth)
    self.maxRow = math.ceil(self.mapSize:Ywidth() / self.nodeWidth)

    self:CreateGrid()
end

-- 创建网格
function MapQuad:CreateGrid()
    for i = 0, self.maxRow - 1 do
        for j = 0, self.maxCol - 1 do
            self:CreateNode(i, j)
        end
    end
end

function MapQuad:CreateNode( row, col)
    local position = self:RowColToPosition(row, col)
    local nodeType = FindPathInfo.NodeType.Smooth    --  _mapTerrainData.GetNodeData(i, j, ref cost);
    if (nil ~= self.mapNodeHandle) then
        nodeType = self.mapNodeHandle(position.x, position.y)
    end

    self:CreateNodeWithType(row, col, nodeType)
end

function MapQuad:CreateNodeWithType( row, col, nodeType)
    if (nodeType == FindPathInfo.NodeType.Null or nodeType == FindPathInfo.NodeType.Obstacle) then
        return
    end

    local index = self:RCToIndex(row, col)
    local node = Node.new(row, col, self.neighborType)
    node.NodeType = nodeType
    node.Position = self:RowColToPosition( row, col)
    self.gridDic[index] = node
end

-- 根据坐标获取 Node
function MapQuad:PositionToNode( x,  y)
    local result, row, col = self:PositionToRowCell(x, y)
    if(not result) then
        return nil
    end

    return self:GetNode(row, col)
end

function MapQuad:PositionToRowCell( x, y)
    if (not self.mapSize:Contians(x, y)) then
        return false, 0, 0
    end

    local row = math.floor((y - self.mapSize.minY) / self.nodeWidth)
    local col = math.floor((x - self.mapSize.minX) / self.nodeWidth)
    return true, row, col
end

function MapQuad:RowColToPosition( row, col)
    local x = self.mapSize.minX + (col + 0.5) * self.nodeWidth
    local y = self.mapSize.minY + (row + 0.5) * self.nodeWidth
    return Position.new(x, y)
end

-- Node node, int index
function MapQuad:NodeNeighbourRowCol( node, index)
    -- 每个节点 4/8个邻居的相对二维坐标
    local neighborArr = FindPathInfo.NeighborQuad[self.neighborType]
    local row = node.Row + neighborArr[index][1]
    local col = node.Col + neighborArr[index][2]
    return row, col
end

return MapQuad