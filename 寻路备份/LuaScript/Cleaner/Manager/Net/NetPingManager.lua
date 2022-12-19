-- 道具网络消息模块
---@class NetPingManager
local NetPingManager = {}

function NetPingManager:Init()
    self:RegisterEvent()
end

function NetPingManager:SCpingEvent(msg)
    --- 心跳回调，同步一下时间戳
    if not self.serverRefreshTime then
        self.serverRefreshTime = true
        TimeUtil.ServerRefreshTime(msg.time)
    end
end

function NetPingManager:RegisterEvent()
    AppServices.NetWorkManager:addObserver(MsgMap.SCPing, self.SCpingEvent, self)
end

function NetPingManager:UnRegisterEvent()
    AppServices.NetWorkManager:removeObserver(MsgMap.SCPing, self.SCpingEvent, self)
end

function NetPingManager:Release()
    self:UnRegisterEvent()
end

return NetPingManager