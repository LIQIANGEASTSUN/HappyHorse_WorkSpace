local SuperCls = require"Cleaner.Task.TaskConditionBase"
---@class LinkIsland:TaskConditionBase
local LinkIsland = class(SuperCls, "LinkIsland")
---获取监听
function LinkIsland:GetSubTaskEvents()
    return MessageType.IslandLinkHomeland, self.OnTrigger
end

function LinkIsland:OnTrigger(id)
    self:AddProgress(1)
end

return LinkIsland