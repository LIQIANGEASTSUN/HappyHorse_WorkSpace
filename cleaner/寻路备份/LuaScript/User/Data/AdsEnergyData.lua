local DataBase = require "Data.DataBase"
---@class AdsEnergyData:DataBase @文件中数据在获取与存储前都会检查是否跨天，跨天则清除所有数据
local AdsEnergyData = class(DataBase, "AdsEnergyData")

---@return AdsEnergyData
function AdsEnergyData.Create()
    local instance = AdsEnergyData.new()
    instance:Init()
    return instance
end

--@override value:读取文件路径
function AdsEnergyData:GetFilePath()
    return FileUtil.GetUserPath() .. "/ads_energy.dat"
end

---@return AdsEnergyData
return AdsEnergyData.Create()
