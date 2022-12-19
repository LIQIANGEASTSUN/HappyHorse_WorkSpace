---@class DataBase
local DataBase = class(nil, "DataBase")
local instance
---@return DataBase
function DataBase.Instance()
    if not instance then
        instance = DataBase.new()
        instance:Init()
    end
    return instance
end

function DataBase:ctor()
    self.data = {}
end

function DataBase:Init()
    self.kDataUri = self:GetFilePath()
    self.data = self:ReadFromStorage()
    self.updateFuncId =
        WaitExtension.InvokeRepeating(
        function()
            self:UpdateTimer()
        end,
        0,
        1
    )
end

--@override value:读取文件路径
function DataBase:GetFilePath()
    return ""
end

--@override value:默认结构
function DataBase:GetDefaul()
    return {}
end

function DataBase:ReadFromStorage()
    local content = FileUtil.ReadFromFile(self.kDataUri, true)

    if string.isEmpty(content) then
        return self:GetDefaul()
    end

    local data = table.deserialize(content) or self:GetDefaul()
    return data
end

function DataBase:FlushToStorage()
    self.isSave = false
    local data = table.serialize(self.data)
    FileUtil.SaveWriteFile(data, self.kDataUri, true)
end

function DataBase:UpdateTimer()
    if self.isSave then
        self:FlushToStorage()
    end
end

--- 给key赋值并保存
function DataBase:SetKeyValue(key, value)
    local _type = type(key)
    assert(_type == "boolean" or _type == "string" or _type == "number")
    self.data[key] = value
    self.isSave = true
end

---通过key获得相关值 defaultValue：默认值
function DataBase:GetKeyValue(key, defaultValue)
    local ret = self.data[key]
    if ret == nil then
        return defaultValue
    end
    return ret
end

--- 获得数据库数据
function DataBase:GetData()
    return self.data
end

---重设数据库数据并保存
function DataBase:SetData(data)
    self.data = data
    self.isSave = true
end

return DataBase
