---@class NetManager
local NetManager = {}
local NetWork = require("System.Core.Network.NetWork")
local NET_TICK_TIME = 0.5
local NET_HEARTBEAT_DELAY_TIME = 5
function NetManager:Init()
end

function NetManager:Send(msgId, data)
    self:CancelHeartBeat()
    NetWork:Send(msgId, data)
    self:StartheartBeat(NET_HEARTBEAT_DELAY_TIME)
end

function NetManager:Recieved(msgId, callback)
    NetWork:Route(msgId, callback)
end

function NetManager:Remove(msgId, callback)
    NetWork:Remove(msgId, callback)
end

function NetManager:Login(loginLogic)
    NetWork:Setup(
        NetworkConfig.rpcUrl,
        NetworkConfig.rpcPort,
        function(result)
            if result then
                Runtime.InvokeCbk(loginLogic)
            else
                self:CancelNetTick()
            end
        end
    )
    self:StartNetTick(NET_TICK_TIME)
end

function NetManager:StartNetTick(delayTime)
    if not self.netTimeId then
        self.netTimeId =
            WaitExtension.InvokeRepeating(
            function()
                NetWork:Tick(delayTime)
            end,
            0,
            delayTime
        )
    end
end
function NetManager:CancelNetTick()
    if self.netTimeId then
        WaitExtension.CancelTimeout(self.netTimeId)
        self.netTimeId = nil
    end
end
function NetManager:RunHeartBeat()
    NetWork:Send(MsgMap.CSPing)
end
function NetManager:CancelHeartBeat()
    if self.heartBeatTimeId then
        WaitExtension.CancelTimeout(self.heartBeatTimeId)
        self.heartBeatTimeId = nil
    end
end
function NetManager:StartheartBeat(delayTime)
    if not self.heartBeatTimeId then
        self.heartBeatTimeId =
            WaitExtension.InvokeRepeating(
            function()
                self:RunHeartBeat()
            end,
            0,
            delayTime
        )
    end
end

NetManager:Init()
return NetManager
