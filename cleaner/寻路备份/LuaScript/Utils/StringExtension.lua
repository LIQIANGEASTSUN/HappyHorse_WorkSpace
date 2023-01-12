function string.split(str, delim)
    if string.isEmpty(str) then
        return {}
    end

    -- Eliminate bad cases...
    local res = {}
    local temp = str
    local len
    while true do
        len = string.find(temp, delim, 1, true)
        if len ~= nil then
            local result = string.sub(temp, 1, len - 1)
            temp = string.sub(temp, len + 1)
            table.insert(res, result)
        else
            table.insert(res, temp)
            break
        end
    end

    return res
end

function string:escape()
    return (self:gsub("[%-%.%+%[%]%(%)%$%^%%%?%*]", "%%%1"):gsub("%z", "%%z"))
end

function string.isEmpty(str)
    return not str or type(str) ~= "string" or #str == 0
end
function string.starts(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end

function string.ends(String, End)
    return End == "" or string.sub(String, -string.len(End)) == End
end

function string:strip(pattern)
    local s = self
    pattern = pattern or "%s+"
    local _s = s:gsub("^" .. pattern, "")
    while _s ~= s do
        s = _s
        _s = s:gsub("^" .. pattern, "")
    end
    _s = s:gsub(pattern .. "$", "")
    while _s ~= s do
        s = _s
        _s = s:gsub(pattern .. "$", "")
    end
    return s
end

function string.join(...)
    local str = ""
    for _, v in ipairs({...}) do
        if v == nil then
            str = str .. "nil"
        else
            str = str .. tostring(v)
        end
    end

    return str
end

function string.enum(beginValue, datas)
    local ret = {}
    for k, v in ipairs(datas) do
        ret[v] = beginValue + k - 1
    end
    return ret
end

function string.trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end
