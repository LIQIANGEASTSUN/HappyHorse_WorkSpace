local SuperCls = require"Cleaner.Task.TaskConditionBase"
---@class PetLevel:TaskConditionBase
local PetLevel = class(SuperCls, "PetLevel")

function PetLevel:StartCheck()
    local pets = AppServices.User:GetPets()
    if table.isEmpty(pets) then
        return 0
    end
    local cnt = 0
    local petType = self:GetTaskArg()
    for _, pet in ipairs(pets) do
        if pet.level >= petType then
            cnt = cnt + 1
        end
    end
    return cnt
end

---获取监听
function PetLevel:GetSubTaskEvents()
    return MessageType.PetUpLevel, self.OnTrigger
end

function PetLevel:OnTrigger(petType, level)
    local tarLevel = self:GetTaskArg()
    if not tarLevel then
        return
    end
    if level >= tarLevel then
        local cur = self:StartCheck()
        local oldNum = self.taskEntity:GetProgress()
        if cur > oldNum then
            self:AddProgress(cur - oldNum)
        end
    end
end

return PetLevel