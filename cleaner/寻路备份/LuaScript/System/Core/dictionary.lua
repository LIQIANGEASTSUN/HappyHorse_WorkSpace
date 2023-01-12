dictionary = {}

function dictionary.clear(dic)
    if not dic then
        return
    end

    for k, v in pairs(dic) do
        dic[k] = nil
    end
end

function dictionary.copyto(from, to)
    if not from or not to then
        return
    end

    for k, v in pairs(from) do
        to[k] = v
    end
end

---@overload fun(dic:table):function
---@generic V
---@param dic table<any, V> | V[]
---@param comp fun(a:V, b:V):boolean
function dictionary.removeif(dic, comp)
    if not dic then
        return
    end
    console.assert(type(comp) == "function", "function compare illegal, it should be function with return value and parameter")

    local delKeys = {}
    for k, v in pairs(dic) do
        if comp(k, v) then
            table.insert(delKeys, k)
        end
    end
    for i = 1, #delKeys do
        dic[delKeys[i]] = nil
    end
end

function dictionary.keys(dic)
    if not dic then
        return
    end

    local keys = {}
    for k, v in pairs(dic) do
        table.insert(key, k)
    end
    return keys
end

function dictionary.values(dic)
    if not dic then
        return
    end

    local values = {}
    for k, v in pairs(dic) do
        table.insert(values, v)
    end
    return values
end
