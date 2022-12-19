---@type IMap
local IMap = require "Cleaner.PathFinding.Map.IMap"

---@type FindPathInfo
local FindPathInfo = require "Cleaner.PathFinding.FindPathInfo"

---@type Node
local HexNode = require "Cleaner.PathFinding.Node.HexNode"

---@type Position
local Position = require "Cleaner.PathFinding.Map.Position"

---@type MapHex
local MapHex = class(IMap, "MapHex")

-- 正六边形格子地图，横向六边形，长边对应的 X 轴，短边对应的 Z 轴
--   ****
-- *      *   -> X 轴
--   ****
function MapHex:ctor(mapType)
    -- 六边形外径比例
    self.OUTER_RADIUS = 1
    -- 六边形内径比例
    self.INNER_RADIUS = 0.866
    -- 六边形外径
    self.outerRadius = 1
    -- 六边形内径
    self.innerRadius = 1

    -- 六边形六个顶点相对于中心的坐标
    self.corners = {}
end

function MapHex:Create(min, max, radius)
    IMap.Create(self, min, max, radius)

    --MapType = MapType.Hex
    self.outerRadius = self.OUTER_RADIUS * radius
    self.innerRadius = self.INNER_RADIUS * radius
    self:SetCorners()

    local rowHeight = max.y - min.y
    self.maxRow = math.round(rowHeight / self.innerRadius)

    local colWidth = max.x - min.x;
    self.maxCol = math.round((colWidth / self.outerRadius) / 0.75) + 1

    self:CreateGrid()
end

function MapHex:SetCorners()
    local outerRadius = self.outerRadius
    local innerRadius = self.innerRadius
    self.corners = {
        Position.new(outerRadius * 0.25, innerRadius * 0.5),
        Position.new(outerRadius * 0.5, 0),
        Position.new(outerRadius * 0.25, -innerRadius * 0.5),
        Position.new(-outerRadius * 0.25, -innerRadius * 0.5),
        Position.new(-outerRadius * 0.5, 0),
        Position.new(-outerRadius * 0.25, innerRadius * 0.5)
    }
end

-- 创建网格:行 以 z 轴正方向为 正，列 以 x 轴正方向为 正
function MapHex:CreateGrid()
    for i = 0, self.maxRow do
        for j = 0, self.maxCol do
            self:CreateNode(i, j)
        end
    end
end

function MapHex:CreateNodeWithType( row, col, nodeType)
    if (nodeType == FindPathInfo.NodeType.Null or nodeType == FindPathInfo.NodeType.Obstacle) then
        return
    end

    local index = self:RCToIndex(row, col)
    ---@type HexNode
    local hexNode = HexNode.new(row, col, self.neighborType)

    hexNode.NodeType = nodeType
    hexNode.Cost = 1
    local position = self:RowColToPosition(row, col)
    hexNode.Position = position

    self.gridDic[index] = hexNode

    local result, row2, col2 = self:PositionToRowCell(position.x, position.y)
    if row ~= row2 or col ~= col2 then
        console.error("1 CreateNodeWithType:"..tostring(result).."  row:"..row.." col:"..col.." x:"..position.x.."  y:"..position.y)
        console.error("2 CreateNodeWithType:  row2:"..row2.." col2:"..col2)
    end
end

-- 根据坐标获取 Node
function MapHex:PositionToNode( x,  y)
    local result, row, col = self:PositionToRowCell(x, y)
    if(not result) then
        return nil
    end

    return self:GetNode(row, col)
end

-- 根据坐标获取 Node
function MapHex:PositionToRowCell( x, y)
    if (not self.mapSize:Contians(x, y)) then
        return false, 0, 0
    end

    ---@type Position
    local position = Position.new(x, y)

    x = x - self.mapSize.minX
    y = y - self.mapSize.minY

    local result = false;
    local row = 0;
    local col = 0;

    local value = (x / self.outerRadius) / 0.75
    local mideleCol = math.round(value)

    for tempCol = mideleCol - 1, mideleCol + 1 do
        value = y / self.innerRadius - (tempCol % 2) * 0.5
        local midleRow = math.round(value)

        for tempRow = midleRow - 1, midleRow + 1 do
            ---@type Node
            local node = self:GetNode(tempRow, tempCol)
            result = self:NodeContainPosition(node, position)
            if result then
                row = tempRow
                col = tempCol
                break
            end
        end
    end

    if (not result) then
        return false, 0, 0
    end

    return true, row, col
end

--- 根据 Node 获取坐标
function MapHex:NodeToPosition(node)
    return node.Position
end

function MapHex:RowColToPosition( row, col)
    local x = self.mapSize.minX + (0.75 * col) * self.outerRadius
    local y = self.mapSize.minY + (row + (col % 2) * 0.5) * self.innerRadius
    return Position.new(x, y)
end

-- Node node, int index
function MapHex:NodeNeighbourRowCol( node, index)
    local value = node.Col % 2
    local dir = FindPathInfo.NeighborHex[value][index]

    local row = node.Row + dir[1]
    local col = node.Col + dir[2]
    return row, col
end

-- HexNode hexNode, Position position
function MapHex:NodeContainPosition( hexNode, position)
    if (nil == hexNode) then
        return false
    end

    ---@type Position
    local center = hexNode.Position
    for i = 1, #self.corners do
        ---@type Position
        local vectex1 = Position:PositionAddPosition(center, self.corners[i])

        local secondIndex = (i + 1) % #self.corners
        if secondIndex == 0 then
            secondIndex = 1
        end
        ---@type Position
        local vectex2 = Position:PositionAddPosition(center, self.corners[secondIndex])

        ---@type Position
        local vectexOffset = Position:PositionSubPosition(vectex2, vectex1)
        ---@type Vector3
        local vectexVector = Vector3(vectexOffset.x, 0, vectexOffset.y).normalized

        ---@type Position
        local offset = Position:PositionSubPosition(position, vectex1)
        ---@type Vector3
        local offsetVector = Vector3(offset.x, 0, offset.y).normalized

        local cross = Vector3.Cross(vectexVector, offsetVector)
        if (cross.y < 0) then
            return false
        end
    end

    return true
end

function MapHex:Update()
    for _, node in pairs(self.gridDic) do
        self:DrawHexCell(node)
    end
end

function MapHex:DrawHexCell(hexCell)
    ---@type Position
    local center = hexCell.Position
    for i = 1, #self.corners do
        ---@type Position
        local pos = center + self.corners[i]

        local secondIndex = (i + 1) % #self.corners
        ---@type Position
        local pos2 = Position:PositionAddPosition(center, self.corners[secondIndex])

        ---@type Vector3
        local p1 = Vector3.new(pos.X, 0, pos.Y)
        ---@type Vector3
        local p2 = Vector3.new(pos2.X, 0, pos2.Y)
        CS.UnityEngine.Debug.DrawRay(p1, p2 - p1, Color.red)
    end
end

return MapHex