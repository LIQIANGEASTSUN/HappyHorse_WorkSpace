local SuperCls = require"Cleaner.Task.TaskConditionBase"
---@class LevelUp:TaskConditionBase
local LevelUp = class(SuperCls, "LevelUp")
---获取监听
function LevelUp:GetSubTaskEvents()
    return MessageType.Global_After_Player_Levelup, self.OnTrigger
end

function LevelUp:OnTrigger(level)
    local tarLv = self:GetTaskArg()
    if not tarLv then
        return
    end
    if level >= tarLv then
        self:AddProgress(1)
    end
end

function LevelUp:GetTasKDesc()
    local cfg = self:GetConfig()
    if not cfg then
        return
    end
    local str = cfg.requirement
    return Runtime.Translate(str, {level = tostring(self:GetTaskArg())})
end

return LevelUp