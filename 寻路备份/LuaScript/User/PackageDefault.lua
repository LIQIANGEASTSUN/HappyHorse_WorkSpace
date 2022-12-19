local filename = "/pkg.dat"
---@class PackageDefault
local PackageDefault = {
}

function PackageDefault:Init()
    self.data = self:ReadFromStorage()
end

function PackageDefault:ReadFromStorage()
    local content = FileUtil.ReadFromFile(FileUtil.GetPersistentPath() .. filename, true) or {}
    return table.deserialize(content) or {}
end

function PackageDefault:FlushToStorage()
    local data = table.serialize(self.data)
    FileUtil.SaveWriteFile(data, FileUtil.GetPersistentPath() .. filename, true)
end

function PackageDefault:SetKeyValue(key, value, flushToStorage)
    local _type = type(key)
    console.assert(_type == "boolean" or _type == "string" or _type == "number") --@DEL
    self.data[key] = value
    if flushToStorage then
        self:FlushToStorage()
    end
end

function PackageDefault:GetValue(key, defaultValue)
    local ret = self.data[key]
    if ret == nil then
        return defaultValue
    end
    return ret
end

PackageDefault:Init()
return PackageDefault