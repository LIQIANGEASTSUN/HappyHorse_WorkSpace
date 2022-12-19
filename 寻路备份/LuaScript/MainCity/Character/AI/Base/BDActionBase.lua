--[[
    Wrap Behavior Degisn Task API
]]
local BDActionBase = class(nil, "BDActionBase")

---@param brain IBrain
function BDActionBase:ctor(csTask, owner, brain)
    self.csTask = csTask
    self.owner = owner
    self.brain = brain
    self.treeBlackboard = nil
end

function BDActionBase:SetBlackboard(blackboard)
    self.treeBlackboard = blackboard
end

-- OnAwake is called once when the behavior tree is enabled. Think of it as a constructor
function BDActionBase:OnAwake()
end

--- OnStart is called immediately before execution. It is used to setup any variables that need to be reset from the previous run.
function BDActionBase:OnStart()
end

-- OnUpdate runs the actual task.
function BDActionBase:OnUpdate()
    return BDTaskStatus.Success
end

function BDActionBase:OnLateUpdate()
end

function BDActionBase:OnFixedUpdate()
end

-- OnEnd is called after execution on a success or failure.
function BDActionBase:OnEnd()
end

--OnPause is called when the behavior is paused or resumed.
function BDActionBase:OnPause(paused)
end

function BDActionBase:OnConditionalAbort()
end

--Returns the priority of the task, used by the Priority Selector.
function BDActionBase:GetPriority()
    return 0
end

--Returns the utility of the task, used by the Utility Selector for Utility Theory.
function BDActionBase:GetUtility()
    return 0
end

--OnBehaviorComplete is called after the behavior tree finishes executing.
function BDActionBase:OnBehaviorComplete()
end

function BDActionBase:OnBehaviorRestart()
end

--OnReset is called by the inspector to reset the public properties
function BDActionBase:OnReset()
end

function BDActionBase:GetStringParam(index)
    return self.csTask:GetStringParam(index)
end

function BDActionBase:GetNumParam(index)
    return self.csTask:GetNumParam(index)
end

function BDActionBase:GetGameObject()
    if self.brain then
        return self.brain:GetGameObject()
    end
end
function BDActionBase:GetEntity()
    if self.brain then
        return self.brain:GetEntity()
    end
end

-- call when owner behavour tree destroy
function BDActionBase:OnDestroy()
    self.csTask = nil
    self.owner = nil
    self.brain = nil
    self.treeBlackboard = nil
end

return BDActionBase
