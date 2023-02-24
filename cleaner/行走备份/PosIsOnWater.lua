---@class PosIsOnWater
local PosIsOnWater = {
    pos = Vector3(0, 1.5, 0)
}

function PosIsOnWater:IsOnWater(position)
    if not self.rayCast then
        self.rayCast = RayCast()
        self.rayCast:SetDirection(Vector3(0, -1, 0))
        self.rayCast:SetDistance(2)
        self.rayCast:SetLayerName("Ground")
        self.rayCast:SetCacheCount(3)
    end

    self.pos.x = position.x
    self.pos.z = position.z
    local count = self.rayCast:RaycastNonAllocCount(self.pos)
    return count <= 0
end

return PosIsOnWater