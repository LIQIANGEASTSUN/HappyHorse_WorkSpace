---@class VaccumActionBase
local VaccumActionBase = class(nil, "VaccumActionBase")

function VaccumActionBase:ctor(vaccumCleaner)
    ---@type VaccumCleaner
    self.vaccum = vaccumCleaner
end

function VaccumActionBase:CanStop()
    return true
end

return VaccumActionBase
