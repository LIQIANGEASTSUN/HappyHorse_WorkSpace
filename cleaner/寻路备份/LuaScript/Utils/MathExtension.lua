---Returns x rounded to the nearest integer.
---WARNING: the return value may be not what you want
---         the round type is not ToEven. EX:
---             math.round( 1.5) =  2
---             math.round(-1.5) = -2
---             math.round( 2.5) =  3
---             math.round(-2.5) = -3
---@param x number
---@return number
function math.round(x)
    x = tonumber(x) or 0
    return math.floor(x + 0.5)
end

--- Linearly interpolates between from and to by interpolation.
--- interpolation is a value between 0 and 1
--- this function will return value:from when give a 0, return value:to when give a 1
--- @param from number
--- @param to number
--- @param interpolation number
function math.lerp(from, to, interpolation)
    interpolation = math.clamp(interpolation, 0, 1)
    return from + (to - from) * interpolation
end

function math.inverseLerp(from, to, value)
    value = math.clamp(from, to, value)
    if value == from then
        return 0
    end
    if value == to then
        return 1
    end
    return (value - from) / (to - from)
end

---Clamps a value between minimum and maximum value.
---@param value number
---@param from number
---@param to number
function math.clamp(value, from, to)
    if from > to then
        from, to = to, from
    end
    value = math.max(from, value)
    value = math.min(to, value)
    return value
end

function math.sinOut(t)
    if t < 0 then
        t = 0
    end
    if t > 1 then
        t = 1
    end
    -- sin(3/2*PI*X) + 1
    return math.min(1, math.sin((t / 2 + 3 / 2) * math.pi) + 1)
end

---获取数值在非均匀分布数值段上的假分布值
---@param sortedArray List<number> 非均匀数值段(从小到大有序排列数组)
---@param value number 数值
function math.InhomogeneousInterp(sortedArray, value)
    local section_count = #sortedArray
    local seg
    for i = 1, section_count do
        if value < sortedArray[i] then
            seg = i - 1
            break
        end
    end
    if not seg then
        return 1
    end
    local from = sortedArray[seg] or 0
    local to = sortedArray[seg + 1]
    to = to or from

    local interp = (math.inverseLerp(from, to, value) + seg) / section_count
    return interp
end

---用于在非均匀分布的进度节点上显示指定进度, 其中sortedArray为从小到大的节点分布值, value为当前进度数值.
---interpValues与sortedArray一一对应. 函数将计算value落在sortedArray哪个区间,
---然后根据区间值从interpValues计算出对应的插值
---@param sortedArray number[] 递增节点[1, 3, 4, 7, ... n]
---@param interpValues number[] 指定插值(进度)[0.1, 0.12, 0.3, ...1]
---@param value number 取值
function math.InhomogeneousStrictInterp(sortedArray, interpValues, value)
    local seg = #sortedArray
    if seg ~= #interpValues then
        console.error("确保两个数组长度相同!") --@DEL
        return 0
    end
    if seg == 0 or value == 0 then
        return 0
    end

    if value <= sortedArray[1] then
        local interp = math.inverseLerp(0, sortedArray[1], value)
        return math.lerp(0, interpValues[1], interp)
    end
    if value >= sortedArray[seg] then
        return interpValues[seg]
    end

    for index = 1, seg - 1, 1 do
        if sortedArray[index] <= value and value <= sortedArray[index + 1] then
            local interp = math.inverseLerp(sortedArray[index], sortedArray[index + 1], value)
            return math.lerp(interpValues[index], interpValues[index + 1], interp)
        end
    end
    console.error("能跑到这里说明出问题了!") --@DEL
    return 0
end

---若M为偶数输出true，为奇数输出false
---@param M unsignedint
local function isEven(M)
    -- return (M & 0x01) == 0
    local add = (require "Utils.bitOp").And
    return add(M, 0x01) == 0
end

---@param X number
---@param N unsigned interger
function math.pow(X, N)
    if N == 0 then
        return 1
    elseif N == 1 then
        return X
    elseif isEven(N) then
        return math.pow(X * X, N >> 1)
    else
        return X * math.pow(X * X, N >> 1)
    end
end

function math.randomWithSeed(m, n)
    math.randomseed(tostring(os.time()):reverse():sub(1, 7))
    return math.random(m, n)
end

---返回权重随机区间 r=math.weight({20, 30, 50})20%=1,30%=2,50%=3
---@param ratetb int[] 权重数组
function math.weight(ratetb)
    if #ratetb == 1 then
        return 1
    end

    local ttr = 0
    for _, v in ipairs(ratetb) do
        ttr = ttr + v
    end
    local rr = math.random(ttr)

    local count = 0
    for i, v in ipairs(ratetb) do
        count = count + v
        if count >= rr then
            return i
        end
    end
end

function math.randomFloat(m, n)
    if not n then
        n = m
        m = 0
    end
    m = math.round(m * 100)
    n = math.round(n * 100)
    return math.random(m, n)/100
end
