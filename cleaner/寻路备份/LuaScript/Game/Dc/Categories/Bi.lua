local bi = DcDelegates:GetDelegate(DelegateNames.BI)
if bi then
    return bi
else
    local inst = setmetatable({}, {
        __index = function()
            return function() end
        end
    })
    return inst
end