local DataBase = require "Data.DataBase"
---@class MapGiftData:DataBase @文件中数据在获取与存储前都会检查是否跨天，跨天则清除所有数据
local MapGiftData = class(DataBase, "MapGiftData")

---@return MapGiftData
function MapGiftData.Create()
    local instance = MapGiftData.new()
    instance:Init()
    return instance
end

--@override value:读取文件路径
function MapGiftData:GetFilePath()
    return FileUtil.GetUserPath() .. "/mapGiftData.dat"
end

---@return MapGiftData
return MapGiftData.Create()
