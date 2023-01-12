--[[
    @ Action Desc:  移动到目标路径点
    @ Require Params:
        string:{}
        int:{}
]]
local superCls = require("MainCity.Character.AI.Base.BDActionBase")
local MoveTo = class(superCls, "AI.Action.MoveTo")

function MoveTo:OnStart()
    self.isMoving = false
    self.isFinished = false
end

function MoveTo:OnUpdate()
    if self.isMoving then
        return BDTaskStatus.Running
    elseif self.isFinished then
        return BDTaskStatus.Success
    end

    local param0 = self:GetStringParam(0)
    local value = table.deserialize(param0)
    if not value then
        return BDTaskStatus.Success
    end
    local avatar = self:GetGameObject()
    local height = avatar.transform.position.y
    local nextWayPointPos = Vector3(value[1], value[2], value[3])
    nextWayPointPos = nextWayPointPos:Flat(height)
    local speed = self:GetNumParam(0)
    if speed == 0 then
        speed = nil
    end

    local function OnDestination()
        self:_OnMoveEnd()
    end

    self.isMoving = true
    self.lookTween = GameUtil.DoLookAt(
        avatar.transform,
        nextWayPointPos,
        0.3,
        function()
            self.lookTween = nil
            if not self.isMoving then
                return
            end
            self:Move(nextWayPointPos, speed, OnDestination)
        end
    )
    return BDTaskStatus.Running
end

function MoveTo:Move(tarPos, speed, callback)
    local entity = self:GetEntity()
    if not entity then
        return
    end
    local curPos = entity.gameObject:GetPosition()

    local dis = tarPos:FlatDistance(curPos)
    speed = speed or entity:GetSpeed()
    local time = dis / speed
    self.moveTween = entity.gameObject.transform:DOMove(tarPos, time)
    self.moveTween:SetEase(Ease.Linear)
    self.moveTween.onComplete = function()
        self.moveTween = nil
        callback()
    end
end

function MoveTo:_OnMoveEnd()
    self.isFinished = true
    self.isMoving = false
end

function MoveTo:OnConditionalAbort()
    local entity = self:GetEntity()
    entity.gameObject.transform:DOKill()
end

function MoveTo:OnEnd()
    self.isMoving = false
    self.isFinished = false
end

function MoveTo:OnDestroy()
    if self.lookTween then
        self.lookTween:Kill()
        self.lookTween = nil
    end
    if self.moveTween then
        self.moveTween:Kill()
        self.moveTween = nil
    end
end

function MoveTo:OnPause(paused)
    if paused then
        if self.isMoving then
            local entity = self:GetEntity()
            entity.gameObject.transform:DOKill()
        end
        self.isMoving = false
        self.isFinished = true
    end
end

return MoveTo
