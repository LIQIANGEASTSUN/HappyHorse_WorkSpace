---@class TaskConditionBase 任务条件基类
local TaskConditionBase = class(nil, "TaskConditionBase")
function TaskConditionBase:ctor(sn, args, taskEntity)
    self:setSn(sn)
    self:setArgs(args)
    self:setTaskEntity(taskEntity)
end

---@private
---设置父级任务实体
function TaskConditionBase:setTaskEntity(taskEntity)
    ---@type TaskEntity
    self.taskEntity = taskEntity
end

---@return TaskEntity
function TaskConditionBase:GetTaskEntity()
    return self.taskEntity
end

---获取任务的计数类型
---@return TaskCountType
function TaskConditionBase:GetCountType()
    local cfg = self:GetConfig()
    return cfg.countType
end

---接到任务的时候检查是不是已经完成了
function TaskConditionBase:StartCheck()
    console.error("子类未覆盖StartCheck方法") --@DEL
end

---增加进度
function TaskConditionBase:AddProgress(addValue)
    local taskEntity = self:GetTaskEntity()
    if not taskEntity then
        return
    end
    if self:IsDone() then
        return
    end
    taskEntity:AddProgress(addValue)
end

---@private
---设置sn
function TaskConditionBase:setSn(sn)
    self.sn = sn
end

function TaskConditionBase:GetSn()
    return self.sn
end

---@private
function TaskConditionBase:setArgs(args)
    self.args = args
end

function TaskConditionBase:GetArgs()
    return self.args
end

function TaskConditionBase:GetTaskArg()
    local args = self:GetArgs()
    return args and args[1]
end

---获取配置
function TaskConditionBase:GetConfig()
    if not self.cfg then
        local sn = self:GetSn()
        if not sn then
            return
        end
        sn = tostring(sn)
        self.cfg = AppServices.Meta:Category("TaskEnumTemplate")[sn]
    end
    return self.cfg
end

function TaskConditionBase:GetSubTaskEvents()
    console.error("子类实现") --@DEL
end

function TaskConditionBase:RegisterListener()
    if self._registered then
        return
    end
    self._registered = true
    local msgKey, callback, subKey = self:GetSubTaskEvents()
    if msgKey then
        if subKey then
            MessageDispatcher:AddSubMessageListener(msgKey, callback, self, subKey)
        else
            MessageDispatcher:AddMessageListener(msgKey, callback, self)
        end
    end
end

function TaskConditionBase:RemoveListener()
    if not self._registered then
        return
    end
    self._registered = nil
    local msgKey, callback, subKey = self:GetSubTaskEvents()
    if msgKey then
        if subKey then
            MessageDispatcher:RemoveSubMessageListener(msgKey, callback, self, subKey)
        else
            MessageDispatcher:RemoveMessageListener(msgKey, callback, self)
        end
    end
end

function TaskConditionBase:GetTasKDesc()
    local cfg = self:GetConfig()
    return cfg and cfg.requirement
end

function TaskConditionBase:Destory()
    self:RemoveListener()
    self.sn = nil
    self.cfg = nil
    self.taskEntity = nil
    self.args = nil
end
return TaskConditionBase
