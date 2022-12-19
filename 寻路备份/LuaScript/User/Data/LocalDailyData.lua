local DataBase = require "data.DataBase"
---@class LocalDailyData:DataBase @文件中数据在获取与存储前都会检查是否跨天，跨天则清除所有数据
local LocalDailyData = class(DataBase, "LocalDailyData")

---@return LocalDailyData
function LocalDailyData.Create()
    local instance = LocalDailyData.new()
    instance:Init()
    return instance
end

--@override value:读取文件路径
function LocalDailyData:GetFilePath()
    return FileUtil.GetUserPath() .. "/local_daily.dat"
end

--通用接口
--GetKeyValue
--SetKeyValue
--GetData
--SetData
function LocalDailyData:GetKeyValue(key, defaultValue)
    self:CheckRefresh()
    return DataBase.GetKeyValue(self, key, defaultValue)
end

function LocalDailyData:SetKeyValue(key, value)
    self:CheckRefresh()
    DataBase.SetKeyValue(self, key, value)
end

---检查跨天，跨天清理数据
function LocalDailyData:CheckRefresh()
    -- local tz = TimeUtil.GetTimeZoneTime()
    -- if not tz then
    --     return
    -- end
    if TimeUtil.ServerTime() > self:GetNextRefreshTime() then
        self.data = {}
        self.data.___nextRefreshTime = self:GetNextRefreshTime()
    end
end

function LocalDailyData:GetNextRefreshTime()
    if not self.data.___nextRefreshTime then
        self.data.___nextRefreshTime = RuntimeContext.CURRENT_TIMEZONE_REFRESHTIME
        self.isSave = true
    end
    return self.data.___nextRefreshTime
end

return LocalDailyData.Create()
