local SuperCls = require"Cleaner.Task.TaskConditionBase"
---@class GetPet:TaskConditionBase
local GetPet = class(SuperCls, "GetPet")
---获取监听
function GetPet:GetSubTaskEvents()
    return MessageType.AddPet, self.OnTrigger
end

function GetPet:OnTrigger(petType, level, count)
    local args = self:GetArgs()
    local tarType = args and args[1]
    if not tarType then
        return
    end
    if petType == tarType then
        self:AddProgress(count or 1)
    end
end

return GetPet