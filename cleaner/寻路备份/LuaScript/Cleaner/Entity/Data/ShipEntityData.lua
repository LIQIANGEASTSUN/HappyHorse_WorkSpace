local BaseEntityData = require "Cleaner.Entity.Data.BaseEntityData"

---@class ShipEntityData
local ShipEntityData = class(BaseEntityData, "ShipEntityData")

function ShipEntityData:ctor()
    self.moveDistance = 5
end

function ShipEntityData:GetMoveDis()
    return self.moveDistance
end

return ShipEntityData