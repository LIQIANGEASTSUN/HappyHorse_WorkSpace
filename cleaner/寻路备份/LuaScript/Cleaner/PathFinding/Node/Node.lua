---@type FindPathInfo
local FindPathInfo = require "Cleaner.PathFinding.FindPathInfo"

---@class Node
local Node = class(nil, "Node")

function Node:ctor( row, col, neighborType)

    self.Row = row
    self.Col = col
    self.neighborType = neighborType
    self.Cost = 1

    self.H = 0
    self.G = 0

    self.Parent = nil

    self.NodeType = FindPathInfo.NodeType.Null

    self.NodeState = FindPathInfo.NodeState.Null

    self.ForceNeighbourList = {}

    self.Position = nil
end

function Node:GetF()
    return self.H + self.G
end

function Node:Clear()
    self.Parent = nil
    self.H = 0
    self.G = 0
    self.NodeState = FindPathInfo.NodeState.Null
    self.ForceNeighbourList = {}
end

function Node:CompareTo( node)
    --return F.CompareTo(node.F)
    if (self:GetF() ~= node:GetF()) then
        return self:GetF() - node:GetF()
    end

    if (not self:IsSameParent(node)) then
        return 0
    end

    local offsetCol1 = math.abs(self.Parent.Col - self.Col);
    local offsetCol2 = math.abs(self.Parent.Row - node.Col);
    -- 列优先
    if (offsetCol1 >= offsetCol2) then
        return -1
    end

    return 1
end

function Node:IsSameParent(node)
    if (nil == self.Parent or nil == node.Parent) then
        return false
    end

    return (self.Parent.Row == node.Parent.Row and self.Parent.Col == node.Parent.Col)
end

return Node