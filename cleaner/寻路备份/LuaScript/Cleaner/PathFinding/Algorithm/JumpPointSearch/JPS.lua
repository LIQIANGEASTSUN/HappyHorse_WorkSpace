---@type PathFindBase
local PathFindBase = require "Cleaner.PathFinding.Algorithm.PathFindBase"

---@type FindPathInfo
local FindPathInfo = require "Cleaner.PathFinding.FindPathInfo"

---@type JPSTool
local JPSTool = require "Cleaner.PathFinding.Algorithm.JumpPointSearch.JPSTool"

---@type Position
local Position = require "Cleaner.PathFinding.Map.Position"

---@class JPS Jump Point Search 算法
local JPS = class(PathFindBase, "JPS")

function JPS:ctor(map)

end

-- Position from, Position desitination
function JPS:SearchPath( from, desitination)
    local result, fromNode, desitinationNode = self:SearchPrepare(from, desitination)
    if not result then
        return nil
    end

    fromNode.NodeState = FindPathInfo.NodeState.InOpenTable
    -- 将起点加入到 open 表
    self.openHeap:Insert(fromNode)

    while (self.openHeap:Count() > 0) do
        -- 取出 open 表中 F 值最小的节点 Node
        local node = self.openHeap:DelRoot()
        -- 将 node 添加到 closed 表
        node.NodeState = FindPathInfo.NodeState.InColsedTable
        table.insert(self.closedList, node)

        -- 如果 node 是终点 则路径查找成功，并退出
        if ((node.Row == desitinationNode.Row) and (node.Col == desitinationNode.Col)) then
            return node
        end

        self:CheckNode(fromNode, desitinationNode, node)
    end

    return nil
end

-- Node origin, Node desitination, Node node
function JPS:CheckNode( origin, desitination, node)
    if (nil == node.Parent) then
        -- 搜索上下左右四个方向
        for  i = 1, node.neighborType do
            -- Node
            local temp = self.map:NodeNeighbor(node, i)
            self:SearchHV(origin, desitination, node, temp)
        end
    else
        local horizontalDir = self:Dir(node.Row, node.Parent.Row)
        local verticalDir = self:Dir(node.Col, node.Parent.Col)

        if (horizontalDir ~= 0) then
            -- Node
            local temp = self.map:GetNode(node.Row + horizontalDir, node.Col)
            self:SearchHV(origin, desitination, node, temp)
        end

        if (verticalDir ~= 0) then
            -- Node
            local temp = self.map:GetNode(node.Row, node.Col + verticalDir)
            self:SearchHV(origin, desitination, node, temp)
        end
    end

    if (nil == node.Parent) then
        for i = 1, node.neighborType do
            ---@type Node
            local temp = self.map:NodeNeighbor(node, i)
            self:SearchDiagonal(origin, desitination, node, temp)
        end
    else
        local horizontalDir = self:Dir(node.Row, node.Parent.Row)
        local verticalDir = self:Dir(node.Col, node.Parent.Col)
        if ((horizontalDir ~= 0) and (verticalDir ~= 0)) then
            ---@type Node
            local temp = self.map:GetNode(node.Row + horizontalDir, node.Col + verticalDir);
            self:SearchDiagonal(origin, desitination, node, temp);
        end

        for i = 1, #node.ForceNeighbourList do
            ---@type Position
            local pos = node.ForceNeighbourList[i]
            ---@type Node
            local forceNeighbour = self.map:PositionToNode(pos.x, pos.y)
            self:SearchDiagonal(origin, desitination, node, forceNeighbour)
        end
    end
end

-- 节点是否使跳跃点
-- Node origin, Node desitination, Node preNode, Node node, int rowDir, int colDir
function JPS:IsJumpPoint( origin, desitination, preNode, node, rowDir, colDir)
    if (not self:InvalidNode(node)) then
        return nil
    end

    if (node.NodeType == FindPathInfo.NodeType.Null) then
        return nil
    end

    if (node.NodeType == FindPathInfo.NodeType.Obstacle) then
        return nil
    end

    -- 一： 如果 node 是起点/终点,则 node 是跳点
    if (self:IsSameNode(node, origin) or self:IsSameNode(node, desitination)) then
        return node
    end

    -- 二： 如果 node 至少有一个强迫邻居,则 node 是跳点
    if (self:HasForceNeighbour(preNode, node)) then
        return node
    end

    -- 如果父节点在斜方向上(意味着这是斜向搜索),节点 node 的水平或者垂直方向上有满足条件 一、二的点
    if ((rowDir ~= 0) and (colDir ~= 0)) then
        return self:JumpSearchHV( origin, desitination, node, rowDir, colDir)
    end

    return nil
end

-- 节点是否有强制邻居
-- Node preNode, Node node
function JPS:HasForceNeighbour( preNode, node)
    if ((nil == preNode) or (nil == node)) then
        return false
    end

    ---@type Position
    local dir = Position.new(self:Dir(node.Row, preNode.Row), self:Dir(node.Col, preNode.Col))
    return JPSTool:HasForceNeighbour(self.map, node, dir);
end

-- Node origin, Node desitination, Node currentNode, Node temp
function JPS:SearchHV( origin, desitination, currentNode, temp)
    if (not self:InvalidNode(temp)) then
        return
    end

    if (temp.NodeType == FindPathInfo.NodeType.Null) then
        return
    end

    if (temp.NodeType == FindPathInfo.NodeType.Obstacle) then
        return
    end

    local horizontalDir = self:Dir(temp.Row, currentNode.Row)
    local verticalDir = self:Dir(temp.Col, currentNode.Col)
    ---@type Node
    local jumpNode = self:IsJumpPoint(origin, desitination, currentNode, temp, horizontalDir, verticalDir)
    if (nil ~= jumpNode) then
        if (not self:InvalidNode(jumpNode)) then
            return
        end
        self:InsertToOpenHeap(jumpNode, currentNode, desitination);
    end

    jumpNode = self:JumpSearchHV(origin, desitination, temp, horizontalDir, verticalDir);
    if (nil ~= jumpNode) then
        if (not self:InvalidNode(jumpNode)) then
            return
        end
        self:InsertToOpenHeap(jumpNode, currentNode, desitination);
    end
end

-- Node origin, Node desitination, Node currentNode, Node temp
function JPS:SearchDiagonal( origin, desitination, currentNode, temp)
    if (nil == temp) then
        return
    end

    local horizontalDir = self:Dir(temp.Row, currentNode.Row)
    local verticalDir = self:Dir(temp.Col, currentNode.Col)
    ---@type Node
    local preNode = currentNode
    while (true) do
        if (nil == temp)then
            break
        end

        if (temp.NodeState == FindPathInfo.NodeState.InColsedTable) then
            break
        end

        if (temp.NodeState == FindPathInfo.NodeState.InOpenTable) then
            break
        end

        if (nil ~= self:IsJumpPoint(origin, desitination, preNode, temp, horizontalDir, verticalDir)) then
            self:InsertToOpenHeap(temp, currentNode, desitination)
            break
        end

        if ((temp.NodeType == FindPathInfo.NodeType.Null) or (temp.NodeType == FindPathInfo.NodeType.Obstacle)) then
            break
        end

        preNode = temp
        temp = self.map:GetNode(temp.Row + horizontalDir, temp.Col + verticalDir)
    end
end

-- Node jumpNode, Node currentNode, Node desitination
function JPS:InsertToOpenHeap( jumpNode, currentNode, desitination)
    -- 设置 neighborNode.G 值 = 从 起点 到 neighborNode 的总 G
    local G = currentNode.G + self:Distance(currentNode, jumpNode)
    -- 使用 曼哈顿 方法计算 H 值，即(neighborNode 到 终点的 Row、Col 偏移量绝对值之和)
    local H = self:Offset(jumpNode, desitination)
    local F = H + G
    -- 在 open 表中
    if (jumpNode.NodeState == FindPathInfo.NodeState.InOpenTable) then
        -- 比较 jumpNode 记录的 F 值是否比 从 currentNode 到 neighborNode 的 F 值更大
        -- 如果 jumpNode.F 更大，则更新 jumpNode.F 并设置 neighborNode.Parent = currentNode
        if (jumpNode:GetF() > F) then
            jumpNode.G = G
            jumpNode.H = H
            -- 设置父节点
            jumpNode.Parent = currentNode
            -- 改变了 G 值，小根堆需要重排序
            self.openHeap:HeapCreate()
        end
    else
        jumpNode.G = G
        jumpNode.H = H
        -- 设置父节点
        jumpNode.Parent = currentNode
        jumpNode.NodeState = FindPathInfo.NodeState.InOpenTable
        self.openHeap:Insert(jumpNode)
    end
end

--- 横向、竖向 跳跃搜索
--- Node origin, Node desitination, Node node, int rowDir, int colDir
function JPS:JumpSearchHV( origin, desitination, node, rowDir, colDir)
    local i = node.Row
    while(rowDir ~= 0) do
        i = i + rowDir
        ---@type Node
        local temp = self.map:GetNode(i, node.Col)
        if (nil == temp) then
            break
        end

        if (temp.NodeType == FindPathInfo.NodeType.Null) then
            break
        end

        if (temp.NodeType == FindPathInfo.NodeType.Obstacle) then
            break
        end

        if (nil ~= self:IsJumpPoint(origin, desitination, node, temp, rowDir, 0)) then
            return temp
        end
    end

    i = node.Col
    while (colDir ~= 0) do
        i = i + colDir
        ---@type Node
        local temp = self.map:GetNode(node.Row, i)
        if (nil == temp) then
            break
        end

        if (temp.NodeType == FindPathInfo.NodeType.Null) then
            break
        end

        if (temp.NodeType == FindPathInfo.NodeType.Obstacle) then
            break
        end

        if (nil ~= self:IsJumpPoint(origin, desitination, node, temp, 0, colDir)) then
            return temp
        end
    end
    return nil
end

-- 判断相同节点
-- Node left, Node right
function JPS:IsSameNode( left, right)
    if ((nil == left) or (nil == right)) then
        return false
    end
    return (left.Row == right.Row) and (left.Col == right.Col)
end

-- Node n1, Node n2
function JPS:IsNeighbour( n1, n2)
    return (math.abs(n1.Row - n2.Row) <= 1) and (math.abs(n1.Col - n2.Col) <= 1)
end

-- Node n1, Node n2
function JPS:Offset( n1, n2)
    return math.abs(n1.Row - n2.Row) + math.abs(n1.Col - n2.Col)
end

-- Node n1, Node n2
function JPS:Distance( n1, n2)
    local r = n1.Row - n2.Row
    local c = n1.Col - n2.Col
    return math.sqrt(r * r + c * c)
end

-- 搜索方向
-- int v1, int v2
function JPS:Dir( v1, v2)
    local value = v1 - v2
    if (value > 0) then
        return 1
    elseif (value == 0) then
        return 0
    end
    return -1
end

-- Node node
function JPS:InvalidNode( node)
    if ((nil == node) or (node.NodeState == FindPathInfo.NodeState.InColsedTable)) then
        return false
    end
    return true
end

return JPS