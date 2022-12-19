local SuperCls = require"Cleaner.Task.TaskConditionBase"
---@class FindAgent:TaskConditionBase
local FindAgent = class(SuperCls, "FindAgent")
---获取监听
function FindAgent:GetSubTaskEvents()
    return MessageType.Global_After_Agent_Clearing, self.OnTrigger
end

function FindAgent:OnTrigger(sceneId, agentId)
    local args = self:GetArgs()
    local id = args and args[1]
    if not id then
        return
    end
    if agentId == id then
        self:AddProgress(1)
    end
end

return FindAgent