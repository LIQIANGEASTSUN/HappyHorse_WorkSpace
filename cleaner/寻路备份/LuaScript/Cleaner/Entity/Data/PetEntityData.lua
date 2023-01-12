local BaseEntityData = require "Cleaner.Entity.Data.BaseEntityData"
---@class PetEntityData
local PetEntityData = class(BaseEntityData, "PetEntityData")

function PetEntityData:ctor(meta)
    self.hp = meta.hp
    -- 宠物速度跟 Player 一样，先暂时写固定值
    self.speed = 5
end

function PetEntityData:ResetMeta(meta)
    self.meta = meta
    self.hp = meta.hp
end

function PetEntityData:GetMaxHp()
    return self.meta.hp
end

function PetEntityData:GetHp()
    return self.hp
end

function PetEntityData:SetHp(hp)
    self.hp = hp
end

return PetEntityData