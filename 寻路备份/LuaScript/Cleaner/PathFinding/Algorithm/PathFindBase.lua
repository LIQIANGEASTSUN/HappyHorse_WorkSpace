
---@type Heap
local Heap = require "Cleaner.PathFinding.Heap.Heap"

---@class PathFindBase
local PathFindBase = class(nil, "PathFindBase")

function PathFindBase:ctor(map)
    ---@type IMap 地图数据
    self.map = map

    ---@type Heap 小根堆保存开放节点，目的在于提高获取最小F值点效率
    self.openHeap = Heap.new()
    self.openHeap:SetHeapType(false)

    -- closed 表
    self.closedList = {}
end

function PathFindBase:SearchPrepare(from, desitination)
    -- 重置上次访问过的节点
    for _, node in pairs(self.closedList) do
        node:Clear()
    end

    local list = self.openHeap:DataList()
    for _, node in pairs(list) do
        node:Clear()
    end

    self.openHeap:MakeEmpty()
    self.closedList = {}

    -- 起点
    local fromNode = self.map:PositionToNode(from.x, from.y)
    -- 终点
    local desitinationNode = self.map:PositionToNode(desitination.x, desitination.y)
    if (nil == fromNode or nil == desitinationNode) then
        return false, fromNode, desitinationNode
    end

    if (fromNode.Row == desitinationNode.Row and fromNode.Col == desitinationNode.Col) then
        return false, fromNode, desitinationNode
    end

    return true, fromNode, desitinationNode
end

function PathFindBase:SearchPath(from, desitination)
    return {}
end

return PathFindBase