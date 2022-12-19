---@class LocalDevice
local LocalDevice = {
    data = {},
    Enum = {
        PENDING_PRIVACY_ANDROID = 1,    -- 看到了隐私面板，还没有确认
        CONFIRM_PRIVACY_ANDROID = 2,    -- 确认了隐私面板
        MUSICON = 3,                    -- 登陆界面音乐
    }
}

function LocalDevice:Init()
    self.PersistentPath = FileUtil.GetPersistentPath() .. '/' .."device.dat"

    local data = self:ReadFromStorage()
    self:InitFromData(data)
end

function LocalDevice:InitFromData(src)
    for k,v in pairs(src) do
        if type(v) ~= "function" then
            self.data[k] = v
        end
	end
end

function LocalDevice:encode()
    local dst = {}
	for k,v in pairs(self.data) do
        if k ~="class" and v ~= nil and type(v) ~= "function" then
            dst[k] = v
        end
	end
	return dst
end

function LocalDevice:ReadFromStorage()
    local content = FileUtil.ReadFromFile(self.PersistentPath, true) or {}
    return table.deserialize(content) or {}
end

function LocalDevice:FlushToStorage()
    local content = table.serialize(self:encode())
    FileUtil.SaveWriteFile(content, self.PersistentPath, true)
end

function LocalDevice:GetValue(val)
    return self.data[val]
end

function LocalDevice:SetValue(key, val, flush)
    self.data[key] = val
    if flush then
        self:FlushToStorage()
    end
end

LocalDevice:Init()

return LocalDevice