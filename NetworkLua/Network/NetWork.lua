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
local socket = require "socket.core"

local NetDefine = require "System.Core.Network.NetDefine"
local TCPSocket = require "System.Core.Network.TCPSocket"
local NetProcessor = require "System.Core.Network.NetProcessor"
local NetStream = require "System.Core.Network.NetStream"

local pb = require "pb"
local protoc = require "System.Core.Network.protoc"
--local json = require "cjson"

local NetWork = class("NetWork")

local function NetError(error)
    print("error:", "NetWork Log", error)
end

function NetWork:ctor(...)
    self.tcpSocket = nil
    self.connectAction = nil
    self.msgRoute = {}

    --local protoFile = io.open("Lua//NetWork//full.proto","r")
    --local protoBuff
    --if protoFile ~= nil then
    --    protoBuff = protoFile:read "*a"
    --    protoFile:close()
    --    print("protoFile存在："..protoBuff)
    --end

    local protoFile = FileUtil.ReadFromFile("E:/DragonClient/client/Assets/HomeLand/LuaScript/System/Core/Network/full.proto", true)
    --local protoFile = Cube.AssetsManager.Instance:LoadAsset("full.txt")
    --print(".......：：1：" .. tostring(protoFile))
    --print(".......：：2：" .. protoFile.text)
    --print(".......：：3：" .. protoFile.bytes)

    protoc:load(tostring(protoFile))
end

function NetWork:Setup(host, port, connectAction)
    self:Shutdown()

    self.connectAction = connectAction

    local connactCallback = function(flag)
        if self.connectAction then
            self.connectAction(flag)
        end

        self.connectAction = nil
    end


    local onStateChanged = function(state, err)
        NetError("net state changed " .. state .. " err: " .. tostring(err))

        if state == NetDefine.NetState.Game then
            connactCallback(true)
        elseif state == NetDefine.NetState.Connected then
        elseif state == NetDefine.NetState.ConnectFailed then
            connactCallback(false)
        elseif state == NetDefine.NetState.Connecting then
        elseif state == NetDefine.NetState.Closed then
            connactCallback(false)
        elseif state == NetDefine.NetState.Disconnect then
            connactCallback(false)
        elseif state == NetDefine.NetState.PingTimeout then
        end

    end

    local onMessage = function(msgId, msgName, msg, msgLen)
        --NetError("recv msg " .. msgName .. "：" .. json.encode(msg))
        local callbacks = self.msgRoute[msgId]
        if callbacks then
            for _, cb in ipairs(callbacks) do
                cb(msgId, msg)
            end
        end
    end

    self.tcpSocket = TCPSocket.new()
    self.tcpSocket:Connect(host, port, NetDefine.ConnectTimeout, onStateChanged, NetProcessor.new(onMessage))
end

function NetWork:Route(msgId, ac)
    local callbacks = self.msgRoute[msgId]
    if not callbacks then
        callbacks = {}
        self.msgRoute[msgId] = callbacks
    end

    table.insert(callbacks, ac)
end

function NetWork:Shutdown()
    if self.tcpSocket ~= nil then
        self.tcpSocket:Close()
        self.tcpSocket = nil
    end
end

function NetWork:Send(msgId, msg)
    if not self.tcpSocket then
        NetError("socket closed")
        return
    end

    local msgName = MsgMap[msgId]
    --print("当前请求："..msgName)
    local data = pb.encode(msgName, msg)
    --NetError("send msg " .. msgName .. "：" .. json.encode(msg))
    self.tcpSocket:Send(msgId, data)
end

function NetWork:Tick(deltaTime)
    if self.tcpSocket == nil then
        return
    end

    self.tcpSocket:Tick(deltaTime)
end

local _instance = NetWork.new()
return _instance
