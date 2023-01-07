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

local struct = require "struct"
local NetStream = class("NetStream")

function NetStream:ctor(big, msgLenSize, msgIdSize)
    self.data = ""
    self.pos = 1

    if big then
        self.ENDIAN = ">"
    else
        self.ENDIAN = "<"
    end

    self.msgIdSize = msgIdSize
    self.msgLenSize = msgLenSize
    self.msgLenFmt = self.ENDIAN .. "i" .. msgLenSize
    self.msgReadFmg = self.ENDIAN .. string.format("i%di%dc", msgLenSize, msgIdSize)
    self.msgPutFmt = self.ENDIAN .. string.format("i%di%d", msgLenSize, msgIdSize)

    self.msgReadFmgWithBody0 = self.ENDIAN .. string.format("i%di%d", msgLenSize, msgIdSize)

    self.msgRC4KeyReadFmt = self.ENDIAN .. string.format("i%dc", msgLenSize)
end

function NetStream:GetMsgLen()
    return struct.unpack(self.msgLenFmt, self.data, self.pos)
end

function NetStream:GetData()
    return self.data
end

function NetStream:Sub(s, e)
    self.data = self.data:sub(s, e)
end

function NetStream:ReadMsg(bodyLen)
    if bodyLen == 0 then
        local len, msgId = struct.unpack(self.msgReadFmgWithBody0, self.data, self.pos)
        self.pos = self.pos + bodyLen + 8
        return len, msgId, nil
    end

    local len, msgId, data = struct.unpack(self.msgReadFmg .. bodyLen, self.data, self.pos)
    self.pos = self.pos + bodyLen + 8
    return len, msgId, data
end

function NetStream:ReadRC4KeyMsg(bodyLen)
    local len, data = struct.unpack(self.msgRC4KeyReadFmt .. bodyLen, self.data, self.pos)
    self.pos = self.pos + bodyLen + 4
    return len, data
end

function NetStream:Reset()
    self.data = ""
    self.pos = 1
end

function NetStream:Put(data)
    self.data = self.data .. data
end

function NetStream:Put2(msgId, len, data)

    self.data = self.data .. struct.pack(self.msgPutFmt, len, msgId) .. data
end

function NetStream:Put3(msgId, data, rc4)
    local len = string.len(data) + self.msgLenSize + self.msgIdSize
    local packedData = struct.pack(self.msgPutFmt, len, msgId) .. data
    if rc4 then
        self.data = self.data .. rc4:Crypt(packedData, self.msgLenSize + 1, string.len(packedData))
    else
        self.data = self.data .. packedData
    end
end

function NetStream:Len()
    return string.len(self.data) - self.pos + 1
end

return NetStream