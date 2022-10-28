local string = string
local tonumber = tonumber
local setmetatable = setmetatable
local error = error
local ipairs = ipairs
local pairs = pairs
local io = io
local table = table
local math = math
local assert = assert
local tostring = tostring

require "System.Core.Network.MsgMap"
local NetDefine = require "System.Core.Network.NetDefine"
local NetProcessor = class("NetProcessor")
local pb = require("pb")

local MAX_LEN = 1024 * 8

function NetProcessor:ctor(onMessage)
    self.onMessage = onMessage
end

function NetProcessor:Process(netStream)
    local len = netStream:Len()
    if len <= 0 then
        return
    end
    local msgHeadLen = NetDefine.MessageLenSize + NetDefine.MessageIdSize
    repeat
        local msgLen = netStream:GetMsgLen()

        if msgLen < msgHeadLen then
            return "parse msg fatal error"
        end

        if msgLen > MAX_LEN then
            return "parse msg max fatal error"
        end

        if len < msgLen then
            break
        end

        local msgLen, msgId, msgBody = netStream:ReadMsg(msgLen - msgHeadLen)
        local msgName = MsgMap[msgId]
        local msg = pb.decode(msgName, msgBody)
        self.onMessage(msgId, msgName, msg, msgLen)
        len = netStream:Len()
        if len == 0 then
            netStream:Reset()
        end
    until len < NetDefine.MessageLenSize
end

return NetProcessor
