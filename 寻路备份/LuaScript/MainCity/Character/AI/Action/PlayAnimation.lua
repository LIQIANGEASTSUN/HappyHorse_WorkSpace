--[[
    @ Action Desc: 角色播放动画
    @ Require Params:
        string:{动画片段名称}
        int:{}
]]
local superCls = require("MainCity.Character.AI.Base.BDActionBase")
local PlayAnimation = class(superCls, "AI.Action.PlayAnimation")

function PlayAnimation:OnStart()
    self.isPlayEnd = false
    self.isPlaying = false
end

function PlayAnimation:OnUpdate()
    if self.isPlaying then
        return BDTaskStatus.Running
    elseif self.isPlayEnd then
        return BDTaskStatus.Success
    end

    self.isPlaying = true
    local aniName = self:GetStringParam(0)
    local entity = self:GetEntity()

    entity:PlayAnimation(
        aniName,
        function()
            self.isPlaying = false
            self.isPlayEnd = true
        end
    )
    return BDTaskStatus.Running
end

function PlayAnimation:OnEnd()
    self.isPlayEnd = false
    self.isPlaying = false
end

return PlayAnimation
