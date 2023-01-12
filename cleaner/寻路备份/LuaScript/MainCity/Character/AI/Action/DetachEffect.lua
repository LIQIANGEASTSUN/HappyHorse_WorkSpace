--[[
    @ Action Desc:移除模型
    @ Require Params:
        string:{模型名称}
        int:{}
]]
local superCls = require("MainCity.Character.AI.Base.BDActionBase")
local DetachEffect = class(superCls, "DetachEffect")

function DetachEffect:OnUpdate()
    local id = self:GetStringParam(0)
    local go = self.treeBlackboard[id]
    if Runtime.CSValid(go) then
        go:SetParent(nil)
        local position = go:GetPosition()
        position = position:Flat()
        go:SetPosition(position)
        return BDTaskStatus.Success
    end

    return BDTaskStatus.Failure
end

return DetachEffect
