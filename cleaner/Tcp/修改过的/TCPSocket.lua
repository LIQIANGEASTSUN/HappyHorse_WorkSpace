local socket = require "socket.core"

local NetDefine = require "System.Core.Network.NetDefine"
local NetStream = require "System.Core.Network.NetStream"
local RC4 = require "System.Core.Network.RC4"
local TCPSocket = class("TCPSocket")

function TCPSocket:ctor(...)
    self.socket = nil
    self.state = NetDefine.NetState.None

    self.processor = nil

    self.recvStream = NetStream.new(NetDefine.BigEndian, NetDefine.MessageLenSize, NetDefine.MessageIdSize)
    self.sendStream = NetStream.new(NetDefine.BigEndian, NetDefine.MessageLenSize, NetDefine.MessageIdSize)

    self.rc4 = nil

    self.totalSent = 0
    self.totalRecv = 0

    -- connect
    self.connectTime = nil
    self.timeout = 2
    self.onStateChanged = nil
    self.encryptKey = nil

    self.lastTime = 0
end

function TCPSocket:Connect(host, port, timeout, onStateChanged, processor)
    self.timeout = timeout
    self.onStateChanged = onStateChanged
    self.processor = processor

    self.socket = socket.tcp()
    self.socket:settimeout(timeout)
    self.socket:setoption("tcp-nodelay", true)

    local ret, status = self.socket:connect(host, port)

    ----
    --if ret then
    --    self:SetState(NetDefine.NetState.ConnectFailed, "error")
    --    self:ClearSocket()
    --    return
    --end

    self.connectTime = socket.gettime()

    if ret == 1 or "already connected" == status then
        self:SetState(NetDefine.NetState.Connected)
    else
        self:SetState(NetDefine.NetState.Connecting)
    end
end

function TCPSocket:Close()
    self:SetState(NetDefine.NetState.Closed, "")
    self:ClearSocket()
end

function TCPSocket:ClearSocket()
    if self.socket ~= nil then
        self.socket:close()
        self.socket:shutdown()
        self.socket = nil
    end

    --self:ctor()
end

function TCPSocket:SetState(state, error)
    self.state = state
    if self.onStateChanged then
        self.onStateChanged(state, error)
    end
end

function TCPSocket:Tick(deltaTime)
    if self.state == NetDefine.NetState.Connecting then
        self:ProcessConnect()
        self:ProcessInput()
    elseif self.state == NetDefine.NetState.Connected then
        self:ProcessInput()
        self:ProcessEncryptKey()
    elseif self.state == NetDefine.NetState.Game then
        self:ProcessInput()
        self:ProcessMsg()
        self:ProcessOutput()
    end
end

function TCPSocket:ProcessConnect()
    if not self.socket then
        return
    end

    local currTime = socket.gettime() - self.connectTime
    if currTime > self.timeout then
        self:SetState(NetDefine.NetState.ConnectFailed, "connect timeout")
        self:ClearSocket()
    end

    local wfd = {self.socket}
    local _, wset, _ = socket.select(nil, wfd, 0)

    if wset and #wset >= 1 then
        self:SetState(NetDefine.NetState.Connected)
    end
end

-- function TCPSocket:ProcessInput()
--     if not self.socket then
--         return
--     end

--     local rfd = {self.socket}
--     local rset, _, _ = socket.select(rfd, nil, 0)

--     if #rset <= 0 then
--         return
--     end

--     local buffer, status, partial = self.socket:receive("*a")

--     local lenBuf = 0
--     local lenPartial = 0

--     if buffer then
--         lenBuf = string.len(buffer)
--     end

--     if partial then
--         lenPartial = string.len(partial)
--     end

--     local receiveResult = (buffer and lenBuf > 0) and (partial and lenPartial > 0)
--     if not receiveResult then
--         if status == "timeout" then
--             --self:SetState(NetDefine.NetState.PingTimeout, status)
--             --return
--         elseif status == "closed" then
--             self:SetState(NetDefine.NetState.Closed, status)
--             self:ClearSocket()
--             return
--         end
--     end

--     if (not buffer or lenBuf == 0) and (not partial or lenPartial == 0) then
--         self:SetState(NetDefine.NetState.Disconnect, status)
--         self:ClearSocket()
--         return
--     end

--     if buffer then
--         self.recvStream:Put(buffer)
--     end

--     if partial then
--         self.recvStream:Put(partial)
--     end

--     self.totalRecv = self.totalRecv + lenBuf + lenPartial
-- end

function TCPSocket:ProcessInput()
    if not self.socket then
        return
    end

    local rfd = {self.socket}
    local rset, _, _ = socket.select(rfd, nil, 0)

    if #rset <= 0 then
        return
    end

    local buffer, status, partial = self.socket:receive("*a")

    local lenBuf = 0
    local lenPartial = 0

    if buffer then
        lenBuf = string.len(buffer)
    end

    if partial then
        lenPartial = string.len(partial)
    end

    if (not buffer or lenBuf == 0) and (not partial or lenPartial == 0) then
        self:SetState(NetDefine.NetState.Disconnect, status)
        self:ClearSocket()
        return
    end

    if buffer then
        self.recvStream:Put(buffer)
    end

    if partial then
        self.recvStream:Put(partial)
    end

    self.totalRecv = self.totalRecv + lenBuf + lenPartial
end

function TCPSocket:ProcessMsg()
    if (self.processor == nil) then
        --MainMod:OpenError(CommonTipsMod:GetTipStrWithAlias("NETWORK_ERROR_RESTART"))
        return
    end
    local error = self.processor:Process(self.recvStream)
    if error then
        self:SetState(NetDefine.NetState.Disconnect, error)
        self:ClearSocket()
    end

    local time = socket.gettime()
    if NetDefine.CheckPing then
        if time - self.lastTime > NetDefine.PingTimeout then
            self:SetState(NetDefine.NetState.PingTimeout, "")
        end
    end

    self.lastTime = time
end

function TCPSocket:ProcessEncryptKey()
    if not NetDefine.UseRC4Crypt then
        self.rc4 = nil
        self:SetState(NetDefine.NetState.Game, "")
        return
    end

    local len = self.recvStream:Len()
    if len <= 0 then
        return
    end

    local msgLen = self.recvStream:GetMsgLen()
    local msgHeadLen = NetDefine.MessageLenSize
    local _, rc4Key = self.recvStream:ReadRC4KeyMsg(msgLen - msgHeadLen)
    self.rc4 = RC4.new(rc4Key)

    local time = socket.gettime()
    if NetDefine.CheckPing then
        if time - self.lastTime > NetDefine.PingTimeout then
            self:SetState(NetDefine.NetState.PingTimeout, "")
        end
    else
        self:SetState(NetDefine.NetState.Game, "")
    end

    self.lastTime = time
end

function TCPSocket:ProcessOutput()
    if self.socket == nil then
        return
    end

    self.sendStream:RefreshData()
    if self.sendStream:Len() <= 0 then
        return
    end
    local sent, status = self.socket:send(self.sendStream:GetData())

    if not sent then
        self:SetState(NetDefine.NetState.Disconnect, status)
        self:ClearSocket()
        return
    end

    self.totalSent = self.totalSent + sent
    self.sendStream:Sub(sent + 1, -1)
end

function TCPSocket:Send(msgId, data)
    self.sendStream:Put3(msgId, data, self.rc4)
end

return TCPSocket
