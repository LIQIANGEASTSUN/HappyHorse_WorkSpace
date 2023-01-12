local SuperCls = require"Cleaner.Task.TaskConditionBase"
---@class Login:TaskConditionBase
local Login = class(SuperCls, "Login")
---获取监听
function Login:GetSubTaskEvents()
    return MessageType.DAY_SPAN, self.OnTrigger
end

function Login:OnTrigger()
    self:AddProgress(1)
end

return Login