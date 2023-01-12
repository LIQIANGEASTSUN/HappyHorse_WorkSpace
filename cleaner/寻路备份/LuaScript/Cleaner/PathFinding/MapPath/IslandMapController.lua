
---@type PathFindingController
local PathFindingController = require "Cleaner.PathFinding.PathFindingController"

---@type FindPathInfo
local FindPathInfo = require "Cleaner.PathFinding.FindPathInfo"

---@class IslandMapController
local IslandMapController = {}

function IslandMapController:Init()
    self.pathFindingController = PathFindingController.new(FindPathInfo.AlgorithmType.Jps, FindPathInfo.MapType.Quad_Eight_Cleaner)
end

function IslandMapController:Search(startPos, endPos)
    local list = self.pathFindingController:Search(startPos.x, startPos.y, endPos.x, endPos.y)
    return list
end

function IslandMapController:EnablePass(x, y)
    return self.pathFindingController:EnablePass(x, y)
end

function IslandMapController:RandomPath(x, y)
    return self.pathFindingController:RandomPath(x, y)
end

function IslandMapController:GetAreaNode(min, max)
    return self.pathFindingController:GetAreaNode(min, max)
end

return IslandMapController