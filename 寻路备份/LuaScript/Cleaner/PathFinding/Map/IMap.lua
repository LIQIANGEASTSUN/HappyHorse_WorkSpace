---@type FindPathInfo
local FindPathInfo = require "Cleaner.PathFinding.FindPathInfo"

---@type MapSize
local MapSize = require "Cleaner.PathFinding.Map.MapSize"

---@type Position
local Position = require "Cleaner.PathFinding.Map.Position"

---@class IMap
local IMap = class(nil, "IMap")

function IMap:ctor(mapType)
    ---@type MapSize
    self.mapSize = nil
    self.gridDic = {}

    -- 最大行
    self.maxRow = 1
    -- 最大列
    self.maxCol = 1

    self.mapType = mapType
    self.neighborType = FindPathInfo.MapNodeNeighborType[mapType]

    self.mapNodeHandle = nil
end

function IMap:Create(min, max, width)
    self.mapSize = MapSize.new(min, max)
end

function IMap:SetMapNodeHandle(handle)
    self.mapNodeHandle = handle
end

-- 开辟一块区域
function IMap:OpenArea(min, max)
    local _, minRow, minCol = self:PositionToRowCell(min.x, min.y)
    local _, maxRow, maxCol = self:PositionToRowCell(max.x, max.y)
    for row = minRow, maxRow do
        for col = minCol, maxCol do
            self:CreateNode(row, col)
        end
    end
end

function IMap:GetAreaNode(min, max)
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

function IMap:CreateNode( row, col)
    local position = self:RowColToPosition(row, col)
    local nodeType = FindPathInfo.NodeType.Smooth    --  _mapTerrainData.GetNodeData(i, j, ref cost);
    if (nil ~= self.mapNodeHandle) then
        nodeType = self.mapNodeHandle(position.x, position.y)
    end

    self:CreateNodeWithType(row, col, nodeType)
end

-- 设置一个区域的格子类型
function IMap:SetAreaNodeType( min, max, nodeType)
    local _, minRow, minCol = self:PositionToRowCell(min.x, min.y)
    local _, maxRow, maxCol = self:PositionToRowCell(max.x, max.y)
    -- if (not result or not result2) then
    --     return
    -- end

    for row = minRow, maxRow do
        for col = minCol, maxCol do
            local node = self:GetNode(row, col)
            if (nil == node) then
                self:CreateNodeWithType(row, col, nodeType)
            else
                self:SetNode(node, nodeType)
            end
        end
    end
end

function IMap:CreateNodeWithType( row, col, nodeType)
end

function IMap:SetNode( node, nodeType)
    if (nil == node) then
        return
    end

    node.NodeType = nodeType
    if (nodeType == FindPathInfo.NodeType.Null or nodeType == FindPathInfo.NodeType.Obstacle) then
        local index = self:RCToIndex(node.Row, node.Col)
        self.gridDic[index] = nil
    end
end

-- 地图所有节点
function IMap:Grid()
    local result = {}
    for _, node in pairs(self.gridDic) do
        table.insert(result, node)
    end
    return result
end

-- 地图尺寸
function IMap:MapSize()
    return self.mapSize
end

-- 根据坐标获取 Node
-- float x, float y
function IMap:PositionToNode(x, y)
    return nil
end

--- 根据 Node 获取坐标
-- Node node
function IMap:NodeToPosition(node)
    return node.Position
end

function IMap:RowColToPosition( row, col)
    return Position.new(0, 0)
end

--- 获取 Node 的第 index 个邻居
-- Node node, int index, ref float distance
function IMap:NodeNeighborWithDistance( node, index)
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
function IMap:NodeNeighbourRowCol( node, index)
    return 1, 1
end

--- Node node, int index
function IMap:NodeNeighbor( node, index)
    local row, col = self:NodeNeighbourRowCol(node, index);
    ---@type Node
    local temp = self:GetNode(row, col)
    return temp
end

-- int row, int col
function IMap:GetNode(row, col)
    if ((row < 0) or (row >= self.maxRow) or (col < 0) or (col >= self.maxCol)) then
        return nil
    end

    local index = self:RCToIndex(row, col)
    return self.gridDic[index]
end

-- int row, int col
function IMap:RCToIndex( row, col)
    local index = row * self.maxCol + col
    return index
end

return IMap