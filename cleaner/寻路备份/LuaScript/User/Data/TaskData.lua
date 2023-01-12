local DataBase = require "data.DataBase"
--- @class TaskData:DataBase
local TaskData = class(DataBase, 'TaskData')
---@return TaskData
function TaskData.Create()
    local instance = TaskData.new()
    instance:Init()
    return instance
end

--@override value:读取文件路径
function TaskData:GetFilePath()
    return FileUtil.GetUserPath() .. "/task_data.dat"
end

return TaskData.Create()