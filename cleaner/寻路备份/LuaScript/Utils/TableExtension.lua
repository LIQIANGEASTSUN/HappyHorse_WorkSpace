local _json = require("rapidjson")
local _jsonNull = _json.null

-- unpack = unpack or table.unpack
-- if not table.unpack then
--     table.unpack = unpack
-- end

function table.tostring(tbl, indent, limit, depth, jstack)
    limit = limit or 1000
    depth = depth or 7
    jstack = jstack or { name = "top" }
    local i = 0

    local output = {}
    --local info = debug.getinfo(2)
    --table.insert(output, info.source .. " ")
    --table.insert(output, info.currentline .. "\n")
    if type(tbl) == "table" then
        -- very important to avoid disgracing ourselves with circular referencs...
        for i, t in pairs(jstack) do
            if tbl == t then
                return "<" .. i .. ">,\n"
            end
        end
        jstack[jstack.name] = tbl

        table.insert(output, "{\n")

        local name = jstack.name
        for key, value in pairs(tbl) do
            local innerIndent = (indent or " ") .. (indent or " ")
            table.insert(output, innerIndent .. tostring(key) .. " = ")
            jstack.name = name .. "." .. tostring(key)
            table.insert(
                    output,
                    value == tbl and "<parent>," or table.tostring(value, innerIndent, limit, depth, jstack)
            )

            i = i + 1
            if i > limit then
                table.insert(output, (innerIndent or "") .. "...\n")
                break
            end
        end

        table.insert(output, indent and (indent or "") .. "},\n" or "}")
    else
        if type(tbl) == "string" then
            tbl = string.format("%q", tbl)
        end -- quote strings
        table.insert(output, tostring(tbl) .. ",\n")
    end

    return table.concat(output)
end

function table.count(tab)
    local count = 0
    for k, v in pairs(tab) do
        count = count + 1
    end
    return count
end

function table.indexOf(t, v)
    for key, value in pairs(t) do
        if value == v then
            return key
        end
    end
    return nil
end

function table.insertIfNotExist(t, v)
    if not t then
        return
    end

    if not table.indexOf(t, v) then
        table.insert(t, v)
    end
end

function table.exists(t, v)
    return table.indexOf(t, v) ~= nil
end

---
--- Remove elements from `list`.
--- It shifts down the elements `list[#list]`, `...`, `list[2]`, `list[1]`
--- This will erease element if the function `comp` returns true
--- when the parameter is an element from `list`.
---
---@overload fun(list:table):function
---@generic V
---@param list table<any, V> | V[]
---@param comp fun(a:V, b:V):boolean
---@return V[]
function table.removeIf(list, comp)
    if list and comp then
        for i = #list, 1, -1 do
            if comp(list[i]) then
                table.remove(list, i)
            end
        end
    end
end

function table.size(t)
    local s = 0
    if not t then
        return s
    end
    for _, v in pairs(t) do
        if v ~= nil then
            s = s + 1
        end
    end
    return s
end

function table.clone(t, nometa)
    local u = {}

    if not nometa then
        setmetatable(u, getmetatable(t))
    end

    for i, v in pairs(t) do
        if type(v) == "table" then
            u[i] = table.clone(v, nometa)
        else
            u[i] = v
        end
    end

    return u
end

function table.isEmpty(t)
    return not t or not next(t)
end

local function printConstTable(t)
    print("---------------- Constants Table Error -----------------") --@DEL
    for k, v in pairs(t) do
        print(k, v) --@DEL
    end
end

function table.clear(t)
    if t ~= nil then
        for k, v in pairs(t) do
            t[k] = nil
        end
    end
end

function table.const(t)
    if __RESTRICT_BEAN then
        local const = {}
        local metadata = {
            __o = t,
            __index = function(a, k)
                local v = t[k]
                if nil == v then
                    printConstTable(t)
                    error("fail to retrieve undefined key '" .. k .. "' from a constants table.", 2)
                end
                return v
            end,
            __newindex = function(a, k, b)
                printConstTable(t)
                error("fail to modify a constants table with key of '" .. k .. "'", 2)
            end
        }
        setmetatable(const, metadata)
        return const
    else
        return t
    end
end

table.class = table.const

function table.serialize(t)
    local result = ""
    local function serialize()
        result = _json.encode(t)
    end
    local ret, err = pcall(serialize)
    if not ret then
        console.error(err)
    end
    return result
end

function table.deserialize(str, jsonNullToLuaNil)
    local result
    local function deserialize_cjson()
        result = _json.decode(str)
    end
    pcall(deserialize_cjson)

    if result == _jsonNull then
        result = nil
    end

    local function doNull(tb)
        for k, v in pairs(tb) do
            if type(v) == "table" then
                doNull(v)
            elseif v == _jsonNull then
                tb[k] = nil
            end
        end
    end
    if result and jsonNullToLuaNil then
        doNull(result)
    end
    return result
end

function table.isJsonNull(value)
    return value == _jsonNull
end

---@overload fun(t:table):function
---@generic V
---@param t table<any, V> | V[]
---@param comp fun(a:V, b:V):boolean
function table.sortByValue(t, comp)
    local tmp = {}
    for k, v in pairs(t) do
        table.insert(tmp, { key = k, value = v })
    end
    table.sort(
            tmp,
            function(a, b)
                return comp(a.value, b.value)
            end
    )
    local index = 0
    return function()
        index = index + 1
        if tmp[index] then
            return tmp[index].key, tmp[index].value
        end
    end
end

---@param t1 any[]
---@param t2 any[]
---@return table return an array that contains all elements in 't1' and 't2'
function table.merge(t1, t2)
    local ret = table.clone(t1, true)
    for _, v in pairs(t2) do
        table.insertIfNotExist(ret, v)
    end
    return ret
end

function table.keys(t)
    local keys = {}
    for k, _ in pairs(t) do
        keys[#keys + 1] = k
    end
    return keys
end

--- 兼容性配置
function table.maxn(t)
    local maxn = 0
    for i in pairs(t) do
        maxn = type(i) == "number" and i > maxn and i or maxn
    end
    return maxn
end

function table.shuffle(list)
    for i = #list, 1, -1 do
        local n = math.random(i)
        list[i], list[n] = list[n], list[i]
    end
    return list
end

function table.existsIf(t, func)
    if not t then
        return false
    end

    for i, v in pairs(t) do
        if func(v) then
            return true, v
        end
    end
    return false, nil
end

function table.find(t, func)
    for k, v in pairs(t) do
        if func(v) then
            return v
        end
    end
end

function table.map(tab, func)
    local newtab = {}
    for k, v in pairs(tab) do
        newtab[k] = func(k, v)
    end
    return newtab
end

function table.select(tab, func)
    local newtab = {}
    for k, v in pairs(tab) do
        if func(k, v) then
            newtab[k] = v
        end
    end
    return newtab
end

function table.sub( tb, from, to )
	from = from or 1
	to = to or #(tb)
	local ntb = { }
	for ii = from, to do
		table.insert( ntb, tb[ii] )
	end
	return ntb
end

function table.len(tab)
    local count = 0
    for _, v in pairs(tab) do
        count = count + 1
    end
    return count
end

function table.removeIfExist(t, v)
    if t then
        local i = table.indexOf(t, v)
        if i then return table.remove(t, i) end
        for k, v_ in pairs(t) do
            if v_ == v then t[k] = nil; return v_; end
        end
    end
end

function table.removev(tb, value, key)
	for k, v in next, tb do
		if (key and v[key] == value) or (not key and v==value) then table.remove(tb, k) return end
	end
end

---@param to List
---@param source List
function table.join(to, source)
    if not source or not to then
        return
    end

    for k, value in ipairs(source) do
        table.insert(to, value)
    end
    return to
end

function table.ASC(a,b) return a<b end
function table.asc(k) return function(a,b) return a[k]<b[k] end end
function table.DESC(a,b) return a>b end
function table.desc(k) return function(a,b) return a[k]>b[k] end end

function table.ifind(t, v, key, from, ending)
	if v == nil then return nil, nil end
	from = from or 1
	ending = ending or #(t)
	if key then
		for i = from, ending do
			if t[i][key] == v then return i, t[i] end
		end
	else
		for i = from, ending do
			if t[i] == v then return i, t[i] end
		end
	end
	return nil, nil
end

function table.kvfind(t, v, key)
    if v == nil then return nil, nil end
    if key then
        for kk, vv in pairs(t) do
            if vv[key] == v then
                return kk, vv
            end
        end
    else
        for kk, vv in pairs(t) do
            if vv == v then
                return kk, vv
            end
        end
    end
    return nil, nil
end

local function hequal(tb1 ,tb2)
	if table.count(tb1) ~= table.count(tb2) then return false; end
	for k1, v1 in next, tb1 do
		if not table.equal(v1, tb2[k1]) then return false; end
	end
	return true;
end

function table.equal(tb1, tb2)
	local kd1, kd2 = type(tb1), type(tb2)
	if kd1 ~= kd2 then return false end
	if kd1 == 'table' then return hequal(tb1, tb2) end
	return tb1 == tb2
end

function table.reverse( t, func )
	local r = {}
	for k, v in next, t do
		r[v] = func and func(k) or k
	end
	return r
end