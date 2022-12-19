---@class BaseEntityData
local BaseEntityData = class(nil, "BaseEntityData")

function BaseEntityData:ctor(meta)
    self.meta = meta
end


function BaseEntityData:GetMaxHp()
    return 1
end

function BaseEntityData:GetHp()
    return 1
end

function BaseEntityData:SetHp(hp)

end

function BaseEntityData:ChangeHp(value)
    local maxHp = self:GetMaxHp()
    local hp = self:GetHp()
    hp = hp + value
    hp = math.max(0, hp)
    hp = math.min(maxHp, hp)

    self:SetHp(hp)
end

function BaseEntityData:GetAtrribute()
    return self.meta.attribute
end

return BaseEntityData