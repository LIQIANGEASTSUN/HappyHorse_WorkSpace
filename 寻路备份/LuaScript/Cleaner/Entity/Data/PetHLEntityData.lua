local BaseEntityData = require "Cleaner.Entity.Data.BaseEntityData"

---@class PetHLEntityData
local PetHLEntityData = class(BaseEntityData, "PetHLEntityData")

function PetHLEntityData:ctor(meta)
    -- 宠物速度跟 Player 一样，先暂时写固定值
    self.speed = 5
end

function PetHLEntityData:ResetMeta(meta)
    self.meta = meta
end

return PetHLEntityData