---@type FindPathInfo
local FindPathInfo = require "Cleaner.PathFinding.FindPathInfo"

---@type Position
local Position = require "Cleaner.PathFinding.Map.Position"

---@type JPSTool
local JPSTool = {}

-- 节点是否有强制邻居
-- IMap _map, Node node, Position dir
function JPSTool:HasForceNeighbour( _map, node, dir)
    if ((nil == node) or (node.NodeType == FindPathInfo.NodeType.Null) or (node.NodeType == FindPathInfo.NodeType.Obstacle)) then
        return false
    end

    node.ForceNeighbourList = {}
    -- 横、纵 方向
    if ((dir.x == 0) or (dir.y == 0)) then
        local result1 = self:CheckHVForceNeighbour(_map, node, dir, 1)
        local result2 = self:CheckHVForceNeighbour(_map, node, dir, -1)
        return result1 or result2
    else -- 对角/斜向
        local result1 = self:CheckDiagonalForceNeighbour(_map, node, dir, 1)
        local result2 = self:CheckDiagonalForceNeighbour(_map, node, dir, -1)
        return result1 or result2
    end
end

-- 判断水平、垂直方向(水平向右、水平向左、竖直向上、竖直向下)的强制邻居
-- IMap _map, Node node, Position dir, int sign
function JPSTool:CheckHVForceNeighbour( map, node, dir, sign)
    ---@type Position
    local obstacleDir = Position.new(math.abs(dir.y) * sign, math.abs(dir.x) * sign)
    ---@type Position
    local nodePosition = Position.new(node.Row, node.Col)
    local obstacleNodePos = Position:PositionAddPosition(nodePosition, obstacleDir)
    ---@type Position
    local neighbourPos = Position:PositionAddPosition(obstacleNodePos, dir)

    ---@type Node
    local obstacleNode = map:GetNode(math.floor(obstacleNodePos.x), math.floor(obstacleNodePos.y))
    ---@type Node
    local neighbourNode = map:GetNode(math.floor(neighbourPos.x), math.floor(neighbourPos.y))

    if (nil == neighbourNode) then
        return false
    end

    if (neighbourNode.NodeType == FindPathInfo.NodeType.Null) then
        return false
    end

    if (neighbourNode.NodeType == FindPathInfo.NodeType.Obstacle) then
        return false
    end

    if ((nil == obstacleNode) or (obstacleNode.NodeType == FindPathInfo.NodeType.Null) or (obstacleNode.NodeType == FindPathInfo.NodeType.Obstacle)) then
        local pos = map:NodeToPosition(neighbourNode)
        table.insert(node.ForceNeighbourList, pos)
        return true
    end

    return false
end

-- 判断斜向(左上、左下、右上、右下)的强制邻居
-- IMap _map, Node node, Position dir, int sign
function JPSTool:CheckDiagonalForceNeighbour( map, node, dir, sign)
    ---@type Position
    local nodePosition = Position.new(node.Row, node.Col)
    local prePos = Position:PositionSubPosition(nodePosition, dir)
    ---@type Position
    local obstacleDir = nil
    ---@type Position
    local neighbourDir = nil
    if (sign == 1) then
        obstacleDir = Position.new(dir.x, 0)
        neighbourDir = Position.new(dir.x, 0)
    else
        obstacleDir = Position.new(0, dir.y)
        neighbourDir = Position.new(0, dir.y)
    end

    ---@type Position
    local obstacleNodePos = Position:PositionAddPosition(prePos, obstacleDir)
    ---@type Position
    local neighbourPos = Position:PositionAddPosition(obstacleNodePos, neighbourDir)

    ---@type Node
    local obstacleNode = map:GetNode(math.floor(obstacleNodePos.x), math.floor(obstacleNodePos.y))
    ---@type Node
    local neighbourNode = map:GetNode(math.floor(neighbourPos.x), math.floor(neighbourPos.y))

    if ((nil == neighbourNode) or (neighbourNode.NodeType == FindPathInfo.NodeType.Null) or (neighbourNode.NodeType == FindPathInfo.NodeType.Obstacle)) then
        return false
    end

    if ((nil == obstacleNode) or (obstacleNode.NodeType == FindPathInfo.NodeType.Null) or (obstacleNode.NodeType == FindPathInfo.NodeType.Obstacle)) then
        ---@type Position
        local pos = map:NodeToPosition(neighbourNode)
        table.insert(node.ForceNeighbourList, pos)
        return true
    end

    return false
end

return JPSTool