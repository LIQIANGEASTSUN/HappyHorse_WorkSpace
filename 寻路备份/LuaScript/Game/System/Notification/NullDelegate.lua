local NullDelegate = {}

function NullDelegate:Schedule(title, body, ts, key)
    console.trace("<color=#00ff00>添加通知：id: ", key, "\t通知时间", os.date("%Y-%m-%d %H:%M:%S", ts), title, body, "</color>") --@DEL
end

function NullDelegate:UnscheduleAll()
end

function NullDelegate:IsLaunchByLocalNotice()
    return false
end

function NullDelegate:GetLaunchNoticeKey()
    return "NullDelegate"
end

function NullDelegate:GetLaunchNoticeTS()
    return os.time()
end

function NullDelegate:IsOpen()
    return true
end

function NullDelegate:RequestOpen()
end

return NullDelegate
