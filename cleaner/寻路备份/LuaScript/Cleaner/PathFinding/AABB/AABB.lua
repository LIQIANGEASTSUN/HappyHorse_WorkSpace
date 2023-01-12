---@class AABB
local AABB = class(nil, "AABB")

function AABB:ctor(min, max)
    self.min = min -- Vector2.zero
    self.max = max -- Vector2.zero
end

-- other内部的点，与自己距离最近的 min点 和 max点
-- min点 和 max点 都是 other 内部的点
function AABB:OtherNearestToSelf(other)
    local resultMin = self:NearestPoint(other, self.min)
    local resultMax = self:NearestPoint(other, self.max)
    return resultMin, resultMax
end

-- 自己内部的点，到 other 距离最近的点 min点 和 max 点
-- min点 和 max 点 都是自己内部的点
function AABB:SelfNearestToOther(other)
    local resultMin, resultMax = self:OtherNearestToSelf(other)
    resultMin = self:NearestPoint(self, resultMin)
    resultMax = self:NearestPoint(self, resultMax)
    return resultMin, resultMax
end

-- AABB aabb, Vector2 pos
function AABB:NearestPoint( aabb, pos)
    local x = pos.x
    x = x > aabb.max.x and aabb.max.x or x
    x = x < aabb.min.x and aabb.min.x or x

    local y = pos.y
    y = y > aabb.max.y and aabb.max.y or y
    y = y < aabb.min.y and aabb.min.y or y

    return Vector2(x, y)
end

function AABB:IsIntersect( other)
    if ((self.max.x < other.min.x) or (self.min.x > other.max.x)) then
        return false
    end

    if ((self.max.y < other.min.y) or (self.min.y > other.max.y)) then
        return false
    end

    return true
end

return AABB