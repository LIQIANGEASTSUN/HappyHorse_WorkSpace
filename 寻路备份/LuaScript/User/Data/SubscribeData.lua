local DataBase = require "Data.DataBase"
---@class SubscribeData:DataBase @文件中数据在获取与存储前都会检查是否跨天，跨天则清除所有数据
local SubscribeData = class(DataBase, "SubscribeData")

---@return SubscribeData
function SubscribeData.Create()
    local instance = SubscribeData.new()
    instance:Init()
    return instance
end

--@override value:读取文件路径
function SubscribeData:GetFilePath()
    return FileUtil.GetUserPath() .. "/SubscribeData.dat"
end

function SubscribeData:GetServerData()
    if table.isEmpty(self.data) then
        return {}
    end

    local result = {}
    for _, value in pairs(self.data) do
        if value.expired > TimeUtil.ServerTime() then
            table.insert(result,{productId = value.productId,expired = value.expired})
        end
    end
    return result
end

---@return SubscribeData
return SubscribeData.Create()
