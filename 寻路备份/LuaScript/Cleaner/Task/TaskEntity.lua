---@class TaskEntity
local TaskEntity = class(nil, "TaskEntity")

function TaskEntity:ctor(taskSn, data)
    self:setSn(taskSn)
    self:initCondition()
    self:initProgress(data)
    if self:IsDone() then
    end
end

---初始化任务条件监听
---@private
function TaskEntity:initCondition()
    local cfg = self:GetConfig()
    local conditionSn = cfg.taskEnum
    local TaskTypes = require("Cleaner.Task.TaskType")
    local sub_class = TaskTypes[conditionSn]
    if sub_class then
        local sub = sub_class.new(conditionSn, cfg.args, self)
        self:addCondition(sub)
    end
end

---@private
---初始化任务进度
function TaskEntity:addCondition(taskCondition)
    ---@type TaskConditionBase
    self.taskCondition = taskCondition
end

---@return TaskConditionBase
function TaskEntity:GetCondition()
    return self.taskCondition
end

---@private
---初始化进度
function TaskEntity:initProgress(data)
    local progress = data and data.progress or 0
    ---TODO LZL 根据TaskCondition来计算progress, 比如累计
    self:setProgress(progress)
end

---@private
---设置任务id
function TaskEntity:setSn(taskSn)
    self.taskSn = taskSn
end

---获得任务id
function TaskEntity:GetSn()
    return self.taskSn
end

function TaskEntity:GetTaskType()
    local cfg = self:GetConfig()
    return cfg.taskType
end
---获取任务的配置表
function TaskEntity:GetConfig()
    if not self.cfg then
        self.cfg = AppServices.Meta:Category("TaskTemplate")[tostring(self:GetSn())]
    end
    return self.cfg
end

---检查在接到任务的时候, 是不是已经完成了
function TaskEntity:StartCheck()
    local condition = self:GetCondition()
    if condition:GetCountType() then
        return
    end
    local progress = condition:StartCheck()
    local curPro = self:GetProgress()
    if progress > curPro then
        self:AddProgress(progress - curPro)
    end
end

function TaskEntity:setProgress(progress)
    self.progress = progress
end

function TaskEntity:AddProgress(addValue)
    local newProgress = self:GetProgress() + addValue
    self:setProgress(newProgress)
    MessageDispatcher:SendMessage(MessageType.Task_OnTaskAddProgress, self:GetSn(), newProgress)
    if newProgress >= self:GetTotal() then
        self:TaskFinish()
    end
end

function TaskEntity:GetProgress()
    return self.progress or 0
end

function TaskEntity:GetTotal()
    local cfg = self:GetConfig()
    return cfg and cfg.needNum or 1
end

function TaskEntity:GetTasKDesc()
    local cond = self:GetCondition()
    if not cond then
        return
    end
    local str = cond:GetTasKDesc()
    return str
end

function TaskEntity:TaskFinish()
    MessageDispatcher:SendMessage(MessageType.Task_OnTaskFinish, self:GetSn(), self:GetTaskType())
end

function TaskEntity:IsDone()
    return self:GetProgress() >= self:GetTotal()
end

function TaskEntity:removeCondition()
    if self.taskCondition then
        self.taskCondition:Destory()
        self.taskCondition = nil
    end
end

function TaskEntity:Destory()
    self.taskSn = nil
    self.cfg = nil
    self:removeCondition()
end

return TaskEntity
