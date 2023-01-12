local SuperCls = require"Cleaner.Task.TaskConditionBase"
---@class RecycleItem:TaskConditionBase
local RecycleItem = class(SuperCls, "RecycleItem")
---获取监听
function RecycleItem:GetSubTaskEvents()
    return MessageType.Global_After_Recycle, self.OnTrigger
end

function RecycleItem:OnTrigger(itemHash)
    local args = self:GetArgs()
    local id = args and args[1]
    if not id then
        id = 2
    end
    for itemId, cnt in pairs(itemHash) do
        if itemId == id then
            self:AddProgress(cnt)
        end
    end
end

return RecycleItem