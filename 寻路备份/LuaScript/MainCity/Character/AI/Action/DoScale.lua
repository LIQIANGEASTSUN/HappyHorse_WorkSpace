--[[
    @ Action Desc: 附加特效
    @ Require Params:
        string:{特效名称,挂点名称}
        int:{pos.x,pos.y,pos.z}
]]
local superCls = require("MainCity.Character.AI.Base.BDActionBase")
local DoScale = class(superCls, "AI.Action.DoScale")

function DoScale:OnStart()
    self.isPlayEnd = false
    self.isPlaying = false
    self.isZoomOut = true
end

function DoScale:OnUpdate()
    if self.isPlaying then
        return BDTaskStatus.Running
    elseif self.isPlayEnd then
        return BDTaskStatus.Success
    end

    local duration = self:GetNumParam(0)
    local id = self:GetStringParam(0)
    local param = self:GetStringParam(1)
    local value = table.deserialize(param)
    local toVal = Vector3(value[1], value[2], value[3])
    self.isZoomOut = value[1] < 1 or value[2] < 1 or value[3] < 1
    local tween
    if id == "dragon" then
        local entity = self:GetEntity()
        entity:SetBlockDrag(true)
        entity:SetBlockClick(true)
        tween = entity.transform:DOScale(toVal, duration)
    else
        local go = self.treeBlackboard[id]
        tween = GameUtil.DoScale(go, toVal, duration)
    end
    if not tween then
        console.error("DoScale failed") --@DEL
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

function DoScale:OnEnd()
    local entity = self:GetEntity()
    if entity then
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

function DoScale:OnDestroy()
    local id = self:GetStringParam(0)
    if not self.isPlayEnd and self.tween then
        self.tween:Kill()
        self.tween = nil
    end
    if self.isZoomOut then
        if id == "dragon" then
            local entity = self:GetEntity()
            if entity then
                entity:SetBlockDrag(false)
                entity:SetBlockClick(false)
                entity.transform:SetLocalScale(Vector3.one)
            end
        else
            local go = self.treeBlackboard[id]
            go:SetLocalScale(Vector3.one)
        end
    end
    superCls.OnDestroy(self)
end

function DoScale:OnPause(paused)
    if paused then
        local id = self:GetStringParam(0)
        if not self.isPlayEnd and self.tween then
            self.tween:Kill()
            self.tween = nil
        end
        if self.isZoomOut then
            if id == "dragon" then
                local entity = self:GetEntity()
                if entity then
                    entity:SetBlockDrag(false)
                    entity:SetBlockClick(false)
                    entity.transform:SetLocalScale(Vector3.one)
                end
            else
                local go = self.treeBlackboard[id]
                go:SetLocalScale(Vector3.one)
            end
        end
    end
end

return DoScale
