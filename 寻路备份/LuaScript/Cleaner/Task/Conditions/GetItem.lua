local SuperCls = require"Cleaner.Task.TaskConditionBase"
---@class GetItem:TaskConditionBase
local GetItem = class(SuperCls, "GetItem")
---获取监听
function GetItem:GetSubTaskEvents()
    return MessageType.Global_After_AddItem, self.OnTrigger
end

function GetItem:OnTrigger(itemId, count)
    local args = self:GetArgs()
    local id = args and args[1]
    if not id then
        return
    end
    if itemId == id then
        self:AddProgress(count or 1)
    end
end

return GetItem