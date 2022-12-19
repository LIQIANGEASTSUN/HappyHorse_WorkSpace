local bitOp = {}

function bitOp.checkNums(nums)
    local n = nums
    if n >= 0 then
        return n
    else
        n = 0 - n
        n = 0xffffffff - n + 1
    end
    return n
end

function bitOp.And(num1, num2)
    local tmp1 = bitOp.checkNums(num1)
    local tmp2 = bitOp.checkNums(num2)
    local ret = 0
    local count = 0
    repeat
        local s1 = tmp1 % 2
        local s2 = tmp2 % 2
        if s1 == s2 and s1 == 1 then
            ret = ret + (1 << count)
        end
        tmp1 = tmp1 // 2
        tmp2 = tmp2 // 2
        count = count + 1
    until (tmp1 == 0 and tmp2 == 0)
    return ret
end

function bitOp.Or(num1, num2)
    local tmp1 = bitOp.checkNums(num1)
    local tmp2 = bitOp.checkNums(num2)
    local ret = 0
    local count = 0
    repeat
        local s1 = tmp1 % 2
        local s2 = tmp2 % 2
        if s1 ~= s2 or s1 ~= 0 then
            ret = ret + 2 ^ count
        end
        tmp1 = math.modf(tmp1 / 2)
        tmp2 = math.modf(tmp2 / 2)
        count = count + 1
    until (tmp1 == 0 and tmp2 == 0)
    return ret
end

function bitOp.Xor(num1, num2)
    local tmp1 = bitOp.checkNums(num1)
    local tmp2 = bitOp.checkNums(num2)
    local ret = 0
    local count = 0
    repeat
        local s1 = tmp1 % 2
        local s2 = tmp2 % 2
        if s1 ~= s2 then
            ret = ret + 2 ^ count
        end
        tmp1 = math.modf(tmp1 / 2)
        tmp2 = math.modf(tmp2 / 2)
        count = count + 1
    until (tmp1 == 0 and tmp2 == 0)
    return ret
end

return bitOp
