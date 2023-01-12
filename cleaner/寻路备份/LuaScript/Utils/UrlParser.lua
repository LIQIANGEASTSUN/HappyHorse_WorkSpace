local UrlParser = {}

-- parse string to table for UrlSchemeSDK
function UrlParser.parseUrlScheme(url)
    if type(url) ~= "string" or string.len(url) <= 0 then
        return {}
    end
    local res, parser = {}, {}
    for v in string.gmatch(url, "[^:/?&]+") do
        table.insert(parser, v)
    end
    if #parser == 0 or string.lower(parser[1]) ~= "townest" then
        return res
    end
    table.remove(parser, 1)
    if #parser == 0 then
        return res
    end
    res.method = parser[1]
    table.remove(parser, 1)
    if #parser == 0 then
        return res
    end
    res.para = {}
    while #parser > 0 do
        local _, _, key, value = string.find(parser[1], "([%w_]+)=([%w-_%%.,]+)")
        if key and value then
            if string.find(value, ",") then
                res.para[key] = string.split(value, ",")
            else
                res.para[key] = value
            end
        end
        table.remove(parser, 1)
    end
    return res
end

return UrlParser