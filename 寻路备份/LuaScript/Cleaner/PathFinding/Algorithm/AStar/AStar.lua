---@class PathFindBase
local PathFindBase = require "Cleaner.PathFinding.Algorithm.PathFindBase"

---@type FindPathInfo
local FindPathInfo = require "Cleaner.PathFinding.FindPathInfo"

---@class AStar
local AStar = class(PathFindBase, "AStar")

function AStar:ctor(map)

end

function AStar:SearchPath( from, desitination)
    local result, fromNode, desitinationNode = self:SearchPrepare(from, desitination)
    if not result then
        return nil
    end

    if (fromNode.Row == desitinationNode.Row and fromNode.Col == desitinationNode.Col) then
        return nil
    end

    fromNode.NodeState = FindPathInfo.NodeState.InOpenTable
    -- 将起点加入到 open 表
    self.openHeap:Insert(fromNode)

    local result = nil
    while (self.openHeap:Count() > 0) do
        -- 取出 open 表中 F 值最小的节点
        local node = self.openHeap:DelRoot()
        -- 将 node 添加到 closed 表
        node.NodeState = FindPathInfo.NodeState.InColsedTable

        table.insert(self.closedList, node)

        -- 如果 node 是终点 则路径查找成功，并退出
        if (node.Row == desitinationNode.Row and node.Col == desitinationNode.Col) then
            result = node
            break
        end

        self:Neighbor(node, desitinationNode)
    end

    return result
end

-- 获取 currentNode 所有的相邻节点加入到 open 表
function AStar:Neighbor( currentNode, desitinationNode)
    -- 遍历获取 currentNode 所有相邻节点
    for i = 1, currentNode.neighborType do
        local neighborNode, distance = self.map:NodeNeighborWithDistance(currentNode, i)
        self:InsertToOpenHeap(neighborNode, currentNode, desitinationNode, distance)
    end
end

-- 将 neighborNode 加入到 open 表
function AStar:InsertToOpenHeap( neighborNode, currentNode, desitinationNode, distance)
    -- 空、不可通过节点不做处理
    if (nil == neighborNode) then
        return
    end

    if neighborNode.NodeType == FindPathInfo.NodeType.Obstacle then
        return
    end

    if neighborNode.NodeType == FindPathInfo.NodeType.Null then
        return
    end

    -- 已经加入到 closed 表的 node 不做处理
    if (neighborNode.NodeState == FindPathInfo.NodeState.InColsedTable) then
        return
    end

    local g = currentNode.G + currentNode.Cost * distance

    -- 在 open 表中
    if (neighborNode.NodeState == FindPathInfo.NodeState.InOpenTable) then
        -- 比较 neighborNode 记录的 G 值是否比 从 currentNode 到 neighborNode 的G 值更大
        -- 如果 neighborNode.G 更大，则更新 neighborNode.G 并设置 neighborNode.Parent = currentNode;
        if (neighborNode.G > g) then
            neighborNode.G = g
            neighborNode.Parent = currentNode
            -- 改变了 G 值，小根堆需要重排序
            self.openHeap:HeapCreate()
        end
    else
        -- 设置 neighborNode.G 值 = 从 起点 到 neighborNode 的总 G
        neighborNode.G = g

        -- 使用 曼哈顿 方法计算 H 值，即(neighborNode 到 终点的 Row、Col 偏移量绝对值之和)
        local h = math.abs(neighborNode.Row - desitinationNode.Row) + math.abs(neighborNode.Col - desitinationNode.Col)
        neighborNode.H = (h * neighborNode.Cost)
        -- 设置父节点
        neighborNode.Parent = currentNode

        neighborNode.NodeState = FindPathInfo.NodeState.InOpenTable
        self.openHeap:Insert(neighborNode)
    end
end

return AStar