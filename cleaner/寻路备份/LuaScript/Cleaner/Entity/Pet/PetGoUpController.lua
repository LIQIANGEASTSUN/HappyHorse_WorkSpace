---@type PetTemplateTool
local PetTemplateTool = require "Cleaner.Entity.Pet.PetTemplateTool"

---@class PetGoUpController
local PetGoUpController = {
    config = nil
}

function PetGoUpController:GetData(type, level)
    local id = PetTemplateTool:Getkey(type, level)
    if not self.config then
        self.config =  AppServices.Meta:Category("PetTemplate")
    end
    return self.config[tostring(id)]
end

-- 宠物当前等级允许升级
function PetGoUpController:AllowUpgrade(type, level)
    local data = self:GetData(type, level)
    local result = (nil ~= data.upgradeCost) and (#data.upgradeCost > 0)
    return result, data.upgradeCost
end

-- 宠物当前等级允许升星
function PetGoUpController:AllowUpStar(type, level)
    local data = self:GetData(type, level)
    local result = (nil ~= data.upStageCost) and (#data.upStageCost > 0)
    return result, data.upStageCost
end

-- 升级、升星 所需 道具 是否足够使用
function PetGoUpController:EnougthItems(data)
    if not data or #data <= 0 then
        return true
    end

    local result = true
    for _, v in pairs(data) do
        local sn = v[1]
        local count = v[2]

        local item = AppServices.User.GetItemAmount(sn)
        if not item or item.num < count then
            result = false
            break
        end
    end

    return result
end

return PetGoUpController