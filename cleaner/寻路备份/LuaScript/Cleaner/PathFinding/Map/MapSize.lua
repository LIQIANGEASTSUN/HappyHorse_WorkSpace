---@class MapSize
local MapSize = class(nil, "MapSize")


function MapSize:ctor(min, max)
    self.min = min
    self.minX = min.x
    self.minY = min.y

    self.max = max
    self.maxX = max.x
    self.maxY = max.y
end

function MapSize:Xwidth()
    return self.max.x - self.min.x
end

function MapSize:Ywidth()
    return self.max.y - self.min.y
end

function MapSize:Contians(x, y)
    if (x < self.min.x) or (x > self.max.x) then
        return false
    end

    if (y < self.min.y) or (y > self.max.y) then
        return false
    end

    return true
end

return MapSize