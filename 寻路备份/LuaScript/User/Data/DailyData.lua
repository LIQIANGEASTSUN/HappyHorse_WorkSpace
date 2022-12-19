local DataBase = require "data.DataBase"
---@class DailyData:DataBase @文件中数据在获取与存储前都会检查是否跨天，跨天则清除所有数据
local DailyData = class(DataBase, "DailyData")

---@return DailyData
function DailyData.Create()
    local instance = DailyData.new()
    instance:Init()
    return instance
end

--@override value:读取文件路径
function DailyData:GetFilePath()
    return FileUtil.GetUserPath() .. "/dfd.dat"
end

--通用接口
--GetKeyValue
--SetKeyValue
--GetData
--SetData
function DailyData:GetKeyValue(key, defaultValue)
    self:CheckRefresh()
    return DataBase.GetKeyValue(self, key, defaultValue)
end

function DailyData:SetKeyValue(key, value)
    self:CheckRefresh()
    DataBase.SetKeyValue(self, key, value)
end

---检查跨天，跨天清理数据
function DailyData:CheckRefresh()
    if TimeUtil.ServerTime() > self:GetNextRefreshTime() then
        self.data = {}
        self.data.___nextRefreshTime = self:GetNextRefreshTime()
    end
end

function DailyData:GetNextRefreshTime()
    if not self.data.___nextRefreshTime then
        self.data.___nextRefreshTime = RuntimeContext.CURRENT_DATATIME + TimeUtil._24H_To_Sec + TimeUtil._19H_To_Sec
        self.isSave = true
    end
    return self.data.___nextRefreshTime
end

return DailyData.Create()
