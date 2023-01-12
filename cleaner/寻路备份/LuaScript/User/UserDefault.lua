local kUserDefaultUri = "udf.dat"
-- require('MainCity.ConstDefine')

UserDefaultKeys = {
    KeySoundOn = "game.sound.on",    --音效开启
    KeyMusicOn = "game.music.on",    --音乐开启
    KeyLastSceneName = "game.lastscenename",
    KeyDiamondConfirm = "game.diamond.confirm",
    KeyLogLanguage = "game.log.language",
    KeyHightQuality = "game.highquality",
}

---@class UserDefault
local UserDefault = {
    data = {}
}

function UserDefault:Init()
    self.data = self:ReadFromStorage()
    self:Initialize()
end

function UserDefault:Initialize()
    if self:GetKeyValue(UserDefaultKeys.KeyMusicOn) ~= nil then
        App.audioManager:SetMusicEnable(self:GetKeyValue(UserDefaultKeys.KeyMusicOn))
    end
    if self:GetKeyValue(UserDefaultKeys.KeySoundOn) ~= nil then
        App.audioManager:SetEffectEnable(self:GetKeyValue(UserDefaultKeys.KeySoundOn))
    end

    local highQuality = self:GetHighQualityMode()
    self:SetHighQualityMode(highQuality, true)

    local newItemFlag = self:GetKeyValue("item.new_items")
    if newItemFlag ~= nil then
        ItemId.InitNewFlag(newItemFlag)
    end
end

function UserDefault:IsTriggered(arg)
    return self.data.arg
end

function UserDefault:SetTriggered(arg)
    self.data.arg = true
    self:FlushToStorage()
end

function UserDefault:ReadFromStorage()
    local content = FileUtil.ReadFromUserFile(kUserDefaultUri, true) or {}
    return table.deserialize(content) or {}
end

function UserDefault:FlushToStorage()
    local data = table.serialize(self.data)
    FileUtil.SaveWriteUserFile(data, kUserDefaultUri, true)
end

function UserDefault:SetKeyValue(key, value, flushToStorage)
    local _type = type(key)
    console.assert(_type == "boolean" or _type == "string" or _type == "number")
    self.data[key] = value
    if flushToStorage then
        self:FlushToStorage()
    end
end

function UserDefault:GetKeyValue(key, defaultValue)
    local ret = self.data[key]
    if ret == nil then
        self.data[key] = defaultValue
        return defaultValue
    end
    return ret
end

---获取高清模式开关
function UserDefault:GetHighQualityMode()
    local highQuality = self:GetKeyValue(UserDefaultKeys.KeyHightQuality)
    if highQuality == nil then --字段首次赋值
        highQuality = not RuntimeContext.LEGACY_DEVICE
        self:SetHighQualityMode(highQuality, true)
    end
    return highQuality
end

---设置高清模式开关
function UserDefault:SetHighQualityMode(highQuality, flushToStorage)
    if highQuality then
        BCore.SetShaderLOD(800)
    else
        BCore.SetShaderLOD(600)
    end
    self:SetKeyValue(UserDefaultKeys.KeyHightQuality, highQuality, flushToStorage)
end

return UserDefault