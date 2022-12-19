--[[
    @ Action Desc: 附加特效
    @ Require Params:
        string:{特效名称,挂点名称}
        int:{pos.x,pos.y,pos.z}
]]
local superCls = require("MainCity.Character.AI.Base.BDActionBase")
local DoFade = class(superCls, "AI.Action.DoFade")

function DoFade:OnStart()
    self.isPlayEnd = false
    self.isPlaying = false
end

function DoFade:OnUpdate()
    if self.isPlaying then
        return BDTaskStatus.Running
    elseif self.isPlayEnd then
        return BDTaskStatus.Success
    end

    local toVal = self:GetNumParam(0)
    local duration = self:GetNumParam(1)
    local id = self:GetStringParam(0)
    local tween
    if id == "dragon" then
        local entity = self:GetEntity()
        entity:SetBlockDrag(true)
        entity:SetBlockClick(true)
        tween = entity:TweenAlpha(toVal, duration)
    else
        local go = self.treeBlackboard[id]
        tween = GameUtil.DoFade(go, toVal, duration)
    end
    if not tween then
        console.error("DoFade failed") --@DEL
        return BDTaskStatus.Failure
    end
    self.tween = tween
    self.isPlaying = true
    tween.onComplete = function()
        self.tween = nil
        self.isPlaying = false
        self.isPlayEnd = true
    end
    return BDTaskStatus.Running
end

function DoFade:OnEnd()
    local entity = self:GetEntity()
    local toValue = self:GetNumParam(0)
    if entity and toValue > 0.5 then
        entity:SetBlockDrag(false)
        entity:SetBlockClick(false)
    end
    self.isPlayEnd = false
    self.isPlaying = false
    if self.tween then
        self.tween:Kill()
        self.tween = nil
    end
end

function DoFade:Revert()
    local id = self:GetStringParam(0)
    local entity = self:GetEntity()
    if entity then
        entity:SetBlockDrag(false)
        entity:SetBlockClick(false)
    end
    if not self.isPlayEnd and self.tween then
        self.tween:Kill()
        self.tween = nil
    end
    local toValue = self:GetNumParam(0)
    if toValue < 0.5 then
        if id == "dragon" then
            local entity = self:GetEntity()
            entity:TweenAlpha(1, 0)
        else
            local go = self.treeBlackboard[id]
            GameUtil.DoFade(go, 1, 0)
        end
    end
end

function DoFade:OnPause(paused)
    if paused then
        self:Revert()
    end
end

function DoFade:OnDestroy()
    self:Revert()
    superCls.OnDestroy(self)
end

return DoFade
