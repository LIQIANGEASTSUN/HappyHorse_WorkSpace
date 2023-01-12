local SuperCls = require"Cleaner.Task.TaskConditionBase"
---@class ProductItem:TaskConditionBase
local ProductItem = class(SuperCls, "ProductItem")
---获取监听
function ProductItem:GetSubTaskEvents()
    return MessageType.StartProduction, self.OnTrigger
end

function ProductItem:OnTrigger(itemId, count)
    local args = self:GetArgs()
    local id = args and args[1]
    if not id then
        return
    end
    if id == itemId then
        self:AddProgress(count or 1)
    end
end

return ProductItem