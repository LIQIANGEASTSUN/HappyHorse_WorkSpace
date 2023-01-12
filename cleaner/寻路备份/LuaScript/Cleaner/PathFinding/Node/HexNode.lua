---@type Node
local Node = require "Cleaner.PathFinding.Node.Node"

local HexNode = class(Node, "HexNode")

-- 正六边形节点
function HexNode:ctor(row, col, neighborType)

end


return HexNode