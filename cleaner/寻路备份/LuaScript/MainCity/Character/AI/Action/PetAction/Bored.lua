local BaseAction = require "MainCity.Character.AI.Action.PetAction.BaseAction"
---@class Bored:BasePetAction
local Bored = class(BaseAction)
local sleepAnim = "rest_down"
local wakeupAnim = "rest_up"

function Bored:OnEnter()
    BaseAction.OnEnter(self)
    self.waking = false
    self:PlayAnimation(sleepAnim)
end

function Bored:OnTick()
    if self.waking then
        return
    end

    local curPos = self:GetTargetCurPos()
    local orgPos = self:GetTargetOrgPos()
    if curPos ~= orgPos then
        self:Wakeup()
    end
end

function Bored:Wakeup()
    if self.waking then
        return
    end
    self.waking = true

    local duration = self:GetAnimDuration(wakeupAnim)
    self:PlayAnimation(wakeupAnim)
    self.wakingTimer =
        WaitExtension.SetTimeout(
        function()
            if self.active then
                self.brain:ChangeAction("Idle")
            end
        end,
        duration
    )
end

function Bored:OnExit()
    BaseAction.OnExit(self)
    if self.wakingTimer then
        WaitExtension.CancelTimeout(self.wakingTimer)
        self.wakingTimer = nil
    end
end

return Bored
