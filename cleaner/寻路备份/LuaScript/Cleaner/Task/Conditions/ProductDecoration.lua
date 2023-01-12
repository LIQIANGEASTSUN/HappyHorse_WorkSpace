local SuperCls = require"Cleaner.Task.TaskConditionBase"
---@class ProductDecoration:TaskConditionBase
local ProductDecoration = class(SuperCls, "ProductDecoration")
---获取监听
function ProductDecoration:GetSubTaskEvents()
    return MessageType.StartProductDecoration, self.OnTrigger
end

function ProductDecoration:OnTrigger()
    self:AddProgress(1)
end

return ProductDecoration