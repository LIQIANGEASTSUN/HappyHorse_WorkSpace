--[[
    @ Action Desc: 面向目标
    @ Require Params:
        string:{}
        int:{}
]]
local superCls = require("MainCity.Character.AI.Base.BDActionBase")
local FaceTo = class(superCls, "AI.Action.FaceTo")

function FaceTo:OnStart()
    self.m_turnTime = 1
    self.isRuning = false
    self.isFinished = false
    self.m_interrupted = false
end

function FaceTo:OnUpdate()
    if self.m_interrupted then
        return BDTaskStatus.Failure
    elseif self.isRuning then
        return BDTaskStatus.Running
    elseif self.isFinished then
        return BDTaskStatus.Success
    end

    self.isRuning = true

    local param = self:GetStringParam(0)
    local value = table.deserialize(param)
    if not value then
        return BDTaskStatus.Success
    end
    local go = self:GetGameObject()
    local position = Vector3(value[1], value[2], value[3])
    local dir = position - go:GetPosition()
    dir = dir:Flat()
    local from = go.transform.rotation
    local to = Quaternion.LookRotation(dir)

    self.tween =
        LuaHelper.FloatSmooth(
        0,
        1,
        self.m_turnTime,
        function(t)
            if Runtime.CSValid(go) then
                local rotation = Quaternion.Slerp(from, to, t)
                go.transform.rotation = rotation
            end
        end,
        function()
            self.isFinished = true
            self.isRuning = false
            self.tween = nil
        end
    )
    -- self.tween = go.transform:DOLookAt(position, self.m_turnTime)
    -- self.tween.onComplete =
    return BDTaskStatus.Running
end

function FaceTo:OnPause(paused)
    if paused then
        if self.tween then
            self.tween:Kill(false)
            self.tween = nil
        end
        self.m_interrupted = true
    end
end

function FaceTo:OnEnd()
    self.isRuning = false
    self.isFinished = false
    self.m_interrupted = false
end

return FaceTo
