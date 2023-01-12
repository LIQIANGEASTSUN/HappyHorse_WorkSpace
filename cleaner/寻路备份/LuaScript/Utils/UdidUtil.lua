local kUdidConfig = FileUtil.GetPersistentPath() .. "/system.udid"

local UdidUtil = {}
function UdidUtil:getUdid()
    local result
    local data = UdidUtil:readFromStorage()
    if data then
        result = data
        if RuntimeContext.UNITY_IOS then
            local newUdid = BCore.GetUDIDV3(result)
            console.warn(nil, "UDID", result, newUdid)
            -- 更新保存
            --UdidUtil:saveUdid(result)
        end
    end

    if string.isEmpty(result) then
        result = BCore.GetUDIDV3()
        if RuntimeContext.UNITY_IOS then
            -- 写入配置文件
            UdidUtil:saveUdid(result)
        end
    end
    return result
end

function UdidUtil:clearUdid()
    os.remove(kUdidConfig)
end

function UdidUtil:readFromStorage()
    local filePath = kUdidConfig
    return FileUtil.ReadFromFile(filePath, true)
end

function UdidUtil:saveUdid(newUdid)
    local data = newUdid
    local filePath = kUdidConfig
    FileUtil.SaveWriteFile(data, filePath, true)
end

return UdidUtil