local BaseAction = require "MainCity.Character.AI.Action.PetAction.BaseAction"
---@class Sleepy:BasePetAction
local Sleepy = class(BaseAction)
local sleepAnim = "rest"
local wakeupAnim = "takeoff"

local randDurationMin = 15
local randDurationMax = 25
local nextPosDuration  --下一个随机动作间隔时长

local NextActions = {
    "StandIdle",
    "Idle"
}

function Sleepy:OnEnter()
    BaseAction.OnEnter(self)
    self.waking = false
    self:PlayAnimation(sleepAnim)
    self.randAnimTs = Time.time --记录上次随机动画时刻
    nextPosDuration = Random.Range(randDurationMin, randDurationMax)
end

function Sleepy:SetHeight()
    self.brain.body:SetHeight(0)
end

function Sleepy:OnTick()
    if self.waking then
        return
    end

    local curPos = self:GetTargetCurPos()
    local orgPos = self:GetTargetOrgPos()
    if curPos ~= orgPos then
        self:Wakeup()
    else
        --玩家无移动时间超过N秒
        if Time.time - self.randAnimTs > nextPosDuration then
            local actionName = NextActions[math.random(#NextActions)]
            self.brain:ChangeAction(actionName)
        end
    end
end

function Sleepy:Wakeup()
    if self.waking then
        return
    end
    self.waking = true

    local duration = self:GetAnimDuration(wakeupAnim)
    self:PlayAnimation(wakeupAnim)
    self.wakingTimer =
        WaitExtension.SetTimeout(
        function()
            self.wakingTimer = nil
            if self.active then
                self.brain:ChangeAction("Idle")
            end
        end,
        duration
    )
end

function Sleepy:OnExit()
    BaseAction.OnExit(self)
    if self.wakingTimer then
        WaitExtension.CancelTimeout(self.wakingTimer)
        self.wakingTimer = nil
    end
end

return Sleepy
