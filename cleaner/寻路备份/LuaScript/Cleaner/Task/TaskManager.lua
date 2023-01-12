---@class TaskManager 任务管理器
local TaskManager = {
    ---任务进度数据
    ---@type TaskEntity[]
    taskEntities = {},
    ---任务状态快速缓存
    _taskStateCache = {},
}

---@type TaskEntity
local TaskEntity = require("Cleaner.Task.TaskEntity")

function TaskManager:Init()
    self:RegisterListener()
    local task = AppServices.User:GetTaskInfo()
    for _, v in ipairs(task.progress) do
        self:UpdateTaskState(v.key, TaskState.started)
    end
    for _, taskSn in ipairs(task.finish) do
        self:UpdateTaskState(taskSn, TaskState.finish)
    end
    if table.isEmpty(task.progress) and table.isEmpty(task.finish) then
        self:StartNextTask(1010001)
    end
    self:InitTaskList(task.progress)
end

function TaskManager:RegisterListener()
    if self._registered then
        return
    end
    self._registered = true
    AppServices.NetWorkManager:addObserver(MsgMap.SCTaskFinish, self.OnTaskFinishMsg, self)
    MessageDispatcher:AddMessageListener(MessageType.Task_OnTaskAddProgress, self.OnTaskAddProgress, self)
end

function TaskManager:GetConfigBySn(taskSn)
    local cfgs = self._cfgs
    if not cfgs then
        local tmps = AppServices.Meta:Category("TaskTemplate")
        cfgs = {}
        for _, cfg in pairs(tmps) do
            cfgs[cfg.sn] = cfg
        end
        self._cfgs = cfgs
    end

    return cfgs[taskSn]
end

---更新任务状态
---@param newState TaskState 任务状态
function TaskManager:UpdateTaskState(taskSn, newState)
    self._taskStateCache[taskSn] = newState
end

---@return TaskState
function TaskManager:GetTaskState(taskSn)
    return self._taskStateCache[taskSn]
end

function TaskManager:InitTaskList(msg)
    for _, data in ipairs(msg) do
        local taskSn = data.key
        local taskEntity = self:CreateTaskEntity(taskSn, {progress = data.value})
        self:SetTaskEntity(taskSn, taskEntity)
    end
end

function TaskManager:CreateTaskEntity(taskSn, data)
    local e = TaskEntity.new(taskSn, data)
    return e
end

function TaskManager:SetTaskEntity(taskSn, taskEntity)
    self.taskEntities[taskSn] = taskEntity
end

function TaskManager:GetTaskEntity(taskSn)
    return self.taskEntities[taskSn]
end

function TaskManager:GetTaskEntities()
    return self.taskEntities
end

function TaskManager:StartNextTask(taskSn)
    AppServices.User:UpdateTaskProgress(taskSn, 0)
    local taskEntity = self:CreateTaskEntity(taskSn)
    self:SetTaskEntity(taskSn, taskEntity)
    self:StartTask(taskEntity)
end

---@param taskEntity TaskEntity
function TaskManager:StartTask(taskEntity)
    local taskSn = taskEntity:GetSn()
    self:UpdateTaskState(taskSn, TaskState.started)
    taskEntity:StartCheck()
    MessageDispatcher:SendMessage(MessageType.Task_OnTaskStart, taskSn, taskEntity:GetTaskType())
end

function TaskManager:TaskFinish(taskSn)
    if not taskSn then
        return
    end
    local tasks = AppServices.User:GetTaskInfo()
    if table.exists(tasks and tasks.finish or {}, taskSn) then
        console.error("任务已经完成", taskSn) --@DEL
        return
    end
    local taskEntity = self:GetTaskEntity(taskSn)
    if not taskEntity then
        return
    end
    if not taskEntity:IsDone() then
        console.error("任务还未完成", taskSn, taskEntity:GetProgress(), taskEntity:GetTotal()) --@DEL
        return
    end
    local msg = {
        sn = taskSn
    }
    AppServices.NetWorkManager:Send(MsgMap.CSTaskFinish, msg)
end

function TaskManager:OnTaskFinishMsg(msg)
    local taskSn = msg.sn
    if not taskSn then
        return
    end
    self:UpdateTaskState(taskSn, TaskState.finish)
    AppServices.User:SetTaskFinish(taskSn)
    local taskEntity = self:GetTaskEntity(taskSn)
    local taskType = taskEntity:GetTaskType()
    taskEntity:Destory()
    MessageDispatcher:SendMessage(MessageType.Task_After_TaskSubmit, taskSn, taskType)
    self:SetTaskEntity(taskSn, nil)
    local cfg = self:GetConfigBySn(taskSn)
    -- 发奖励
    for _, item in ipairs(cfg.reward or {}) do
        AppServices.User:AddItem(item[1], item[2], ItemGetMethod.Task)
    end
    -- 开启下一个任务
    if cfg.nextSn then
        self:StartNextTask(cfg.nextSn)
    end
end

function TaskManager:OnTaskAddProgress(taskSn, newProgress)
    AppServices.User:UpdateTaskProgress(taskSn, newProgress)
end
---@return int, TaskEntity
function TaskManager:GetMainTask()
    local es = self:GetTaskEntities()
    for sn, e in pairs(es) do
        if e:GetTaskType() == TaskType.Main then
            return sn, e
        end
    end
end

TaskManager:Init()

return TaskManager