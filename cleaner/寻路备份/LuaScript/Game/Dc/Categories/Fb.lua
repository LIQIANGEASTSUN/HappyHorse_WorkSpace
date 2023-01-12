local fb = DcDelegates:GetDelegate(DelegateNames.Facebook)
if fb then
    return fb
else
    local inst = setmetatable({}, {
        __index = function()
            return function() end
        end
    })
    return inst
end