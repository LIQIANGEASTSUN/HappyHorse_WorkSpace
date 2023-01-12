
local Application = CS.UnityEngine.Application
---@class FileUtil
FileUtil = class(nil, "FileUtil")

local CSFileUtil = CS.XEngine.FileUtil

function FileUtil.CreateFolder(foldername)
    local safeName = string.gsub(tostring(foldername), '%p', "")
    local path = FileUtil.GetPersistentPath() .. "/" .. safeName
    print("Create Folder " .. safeName) --@DEL
    CSFileUtil.CreateDirectory(path)
end

local function GetUserFolderPath(uid)
    return FileUtil.GetPersistentPath() .. '/' .. string.gsub(tostring(uid), '%p', "")
end

function FileUtil.GetUserPath()
    local uid = LogicContext.UID
    return GetUserFolderPath(uid)
end

function FileUtil.SaveWriteUserFile(data, filename, encrypt)
    local function _SafeWrite()
        local uid = LogicContext.UID
        FileUtil.CreateFolder(uid)
        local path = GetUserFolderPath(uid) .. '/' .. filename
        FileUtil.SaveWriteFile(data, path, encrypt)
    end
    if RuntimeContext.UNITY_EDITOR then
        _SafeWrite()
    else
        pcall(_SafeWrite)
    end
end

function FileUtil.ReadFromUserFile(filename, decrypt)
    local uid = LogicContext.UID
    console.assert(uid, "uid must exist")
    local path = GetUserFolderPath(uid) .. '/' .. filename
    return FileUtil.ReadFromFile(path, decrypt)
end

function FileUtil.SaveWriteFile(data, path, encrypt)
    if encrypt == nil then
        encrypt = false
    end
    local tempPath = path .. "." .. os.time()
    local file = io.open(tempPath, "w")
    console.assert(file, tempPath)

    if not file then return end

    local finalData = data
    if encrypt then
        finalData = FileUtil.Encrypt(data)
    end

    local success = file:write(finalData)
    if success then
        file:flush()
        file:close()
        os.remove(path)
        os.rename(tempPath, path)
    else
        file:close()
        os.remove(tempPath)
    end

    print(string.format("###Write File [Encrypt:%s] %s", encrypt, path)) --@DEL
end

function FileUtil.ReadFromFile(path, decrypt)
    if decrypt == nil then
        decrypt = false
    end
    print(string.format("###Read File [Decrypt:%s] %s", decrypt, path)) --@DEL
    local file = io.open(path, "rb")
    if file then
        local data = file:read("*a")
        file:close()

        if data then
            local result = data
            if decrypt then
                result = FileUtil.Decrypt(data)
            end
            if result then return result end
        end
    end
    return nil
end

function FileUtil.GetPersistentPath()
    return Application.persistentDataPath
end

function FileUtil.Encrypt(data)
    return data
end

function FileUtil.Decrypt(data)
    return data
end