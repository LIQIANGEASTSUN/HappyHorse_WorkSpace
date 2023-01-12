local SuperCls = require"Cleaner.Task.TaskConditionBase"
---@class HavePet:TaskConditionBase
local HavePet = class(SuperCls, "HavePet")

function HavePet:StartCheck()
    local pets = AppServices.User:GetPets()
    if table.isEmpty(pets) then
        return 0
    end
    local cnt = 0
    local petType = self:GetTaskArg()
    for _, pet in ipairs(pets) do
        if pet.type == petType then
            cnt = cnt + 1
        end
    end
    return cnt
end

---获取监听
function HavePet:GetSubTaskEvents()
    return MessageType.AddPet, self.OnTrigger
end

function HavePet:OnTrigger(petType, level, count)
    local tarType = self:GetTaskArg()
    if not tarType then
        return
    end
    if petType == tarType then
        self:AddProgress(count or 1)
    end
end

return HavePet