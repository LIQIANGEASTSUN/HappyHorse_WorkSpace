local BDBlackboradCouple = class(nil, "BDBlackboradCouple")
function BDBlackboradCouple:ctor(a, b)
    self.blackboardA = a
    self.blackboardB = b
end

function BDBlackboradCouple:SetAnotherValue(board, key, val)
    if not board or not key then
        return
    end
    local b = board == self.blackboardA and self.blackboardB or self.blackboardA
    b[key] = val
end

return BDBlackboradCouple
