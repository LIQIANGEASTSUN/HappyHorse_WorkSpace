---@class Position
local Position = class(nil, "Position")

function Position:ctor(x, y)
    self.x = x
    self.y = y
end

function Position:PositionAddPosition(pos1, pos2)
    local x = pos1.x + pos2.x
    local y = pos1.y + pos2.y
    local position = Position.new(x, y)
    return position
end

function Position:PositionSubPosition(pos1, pos2)
    local x = pos1.x - pos2.x
    local y = pos1.y - pos2.y
    local position = Position.new(x, y)
    return position
end

return Position