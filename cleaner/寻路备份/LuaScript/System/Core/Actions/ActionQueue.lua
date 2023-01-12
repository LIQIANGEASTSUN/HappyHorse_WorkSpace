---@class ActionQueue @update 在 GameplayScene 里
local ActionQueue = class(nil, "ActionQueue", true)
function ActionQueue:ctor()
    self.actions = {}
    self.count = 0
end

function ActionQueue:Create()
    local instance = ActionQueue.new()
    return instance
end

function ActionQueue:Update()
    if self.count == 0 then return end

    local runningList = {}
    for index, action in ipairs(self.actions) do
        action:Update()
        if action:IsFinished() then
            action:CallFinishCallback()
        else
            table.insert(runningList, action)
        end
    end
    self.actions = runningList
    self.count = #runningList
end

function ActionQueue:AddFrameAction(action)
    table.insert(self.actions, action)
    self.count = self.count + 1
end

function ActionQueue:Clear()
    self.actions = {}
    self.count = 0
end

return ActionQueue