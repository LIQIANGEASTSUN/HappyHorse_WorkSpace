local RC4 = class("RC4")
local bit = require("bit")
local bxor = bit.bxor

function RC4:ctor(key)
    self.key = key
    self.s = {}

    self._i = 0
    self._j = 0

    self:KSA()
end

function RC4:KSA()
    local s = self.s
    local key = self.key

    local key_len = string.len(key)
    local key_byte = {}

    for i = 0, 255 do
        s[i] = i
    end

    for i = 1, key_len do
        key_byte[i - 1] = string.byte(key, i, i)
    end

    local j = 0
    for i = 0, 255 do
        j = (j + s[i] + key_byte[i % key_len]) % 256
        s[i], s[j] = s[j], s[i]
    end
end

function RC4:Crypt(buff, startIndex, endIndex)
    local s = self.s
    if endIndex < 0 then
        endIndex = #buff
    end

    local charResult = {}

    if startIndex > 1 then
        table.insert(charResult, string.sub(buff, 1, startIndex - 1))
    end

    for i = startIndex, endIndex do
        self._i = (self._i + 1) % 256
        self._j = (self._j + s[self._i]) % 256

        s[self._i], s[self._j] = s[self._j], s[self._i]

        local t = (s[self._i] + s[self._j]) % 256
        local buffChar = string.byte(buff, i, i)
        table.insert(charResult, string.char(bxor(buffChar, s[t])))
    end

    return table.concat(charResult)
end

return RC4