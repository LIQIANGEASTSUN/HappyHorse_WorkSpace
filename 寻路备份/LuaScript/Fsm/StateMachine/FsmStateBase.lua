---@class FsmStateBase
local FsmStateBase = class(nil, "FsmStateBase")

-- transitions 状态转换的条件
--[[
local transition = {
    -- 查找用的，添加之后想删除需要用到
    index = 1
    CanTransition = function()
        -- 逻辑判断
        local result = false
        return result, toState, transitionData
    end
}
table.insert(transitions, transition)
--]]

-- 状态机基类
-- state 状态类型，int
function FsmStateBase:ctor()
    self.stateType = 0
    self.transitionMap = {}
    self.transitionData = nil
    ---@type FsmStateMachine
    self.stateMachine = nil
    --- 设置间隔时间执行
    self.intervalExecute = {}
end

function FsmStateBase:SetStateMachine(machine)
    self.stateMachine = machine
end

function FsmStateBase:ChangeState(toStateType, transitionData)
    local state = nil
    if self.stateMachine ~= nil then
        state = self.stateMachine:ChangeState(toStateType, transitionData)
    end
    return state
end

function FsmStateBase:OnEnter()

end

function FsmStateBase:OnTick()
    self:OnIntervalTick()
end

function FsmStateBase:OnExit()

end

function FsmStateBase:GetStateType()
    return self.stateType
end

function FsmStateBase:GetTransitionsMap()
    return self.transitionMap
end

function FsmStateBase:AddTransition(transition)
    table.insert(self.transitionMap, transition)
end

function FsmStateBase:RemoveTransition(index)
    for i, v in pairs(self.transitionMap) do
        if v.index and v.index == index then
            table.remove(self.transitionMap, i)
            break
        end
    end
end

function FsmStateBase:RemoveAllTransition()
    self.transitionMap = {}
end

function FsmStateBase:TransitionData(data)
    self.transitionData = data
end

function FsmStateBase:AddIntervalExecute(interval, func)
    local componet = {
        interval = interval,
        lastTime = 0,
        func = func
    }

    table.insert(self.intervalExecute, componet)
end

function FsmStateBase:OnIntervalTick()
    for i = 1, #self.intervalExecute do
        local componet = self.intervalExecute[i]
        if Time.realtimeSinceStartup - componet.lastTime >= componet.interval then
            componet.func()
            componet.lastTime = Time.realtimeSinceStartup
        end
    end
end

return FsmStateBase