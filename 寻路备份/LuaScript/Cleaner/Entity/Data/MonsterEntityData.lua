local BaseEntityData = require "Cleaner.Entity.Data.BaseEntityData"
---@class MonsterEntityData
local MonsterEntityData = class(BaseEntityData, "MonsterEntityData")

function MonsterEntityData:ctor(meta)
    self.hp = meta.hp
end

function MonsterEntityData:GetMaxHp()
    return self.meta.hp
end

function MonsterEntityData:GetHp()
    return self.hp
end

function MonsterEntityData:SetHp(hp)
    self.hp = hp
end

function MonsterEntityData:IsBoss()
    return self.meta.isBoss == 1
end

function MonsterEntityData:GetAtrribute()
    return BaseEntityData.GetAtrribute(self)
end

return MonsterEntityData