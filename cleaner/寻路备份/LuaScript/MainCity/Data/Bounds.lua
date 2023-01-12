---@class Bounds
local Bounds = {
    xMin = nil,
    xMax = nil,
    zMin = nil,
    zMax = nil
}

function Bounds:InclusivePoint(point)
    self.xMin = math.min(point.x, self.xMin or point.x);
    self.xMax = math.max(point.x, self.xMax or point.x);
    self.zMin = math.min(point.y, self.zMin or point.y);
    self.zMax = math.max(point.y, self.zMax or point.y);
end

function Bounds:ContainsGrid(x, z)
    if self.xMin > x or self.xMax < x or self.zMin > z or self.zMax < z then
        return false
    end
    return true
end

return Bounds
