local BaseAction = require "Cleaner.Entity.Animals.Actions.BaseAction"
---@class Idle : BaseAction
local Idle = class(BaseAction)

function Idle:OnEnter(params)
    -- console.tprint(self.entity.gameObject, "In Action: Idle") --@DEL
    self.entity:PlayFlyIdle()
    if params and params.noWait then
        self:MoveToRandomPosition()
    else
        self:Wait()
    end
    self.entity:RegisterEvent(
        self,
        EntityEvent.click,
        function()
            self:OnClick()
        end
    )
end

function Idle:OnClick()
    if self.canClick then
        self.entity:PlayClick()
    end
end

function Idle:MoveToRandomPosition()
    local originPos = self.entity:GetBornPos()
    local range = self.entity:GetAttribute(Attribute.patrolrange)
    local position = originPos + Vector3(Random.Range(0, range), 0, Random.Range(0, range))
    self.entity:MoveTo(
        position,
        function()
            self:Wait()
        end
    )
end

function Idle:Wait()
    self.canClick = true
    self:StopTimer()
    local cfg = self.entity:GetAniCfg()
    local WaitMinSecond, WaitMaxSecond = cfg.flyTime[1], cfg.flyTime[2]
    local sec = math.random(WaitMinSecond, WaitMaxSecond)
    self:PlayRandomIdle()
    self:StartTimer(
        sec,
        function()
            if Runtime.CSNull(self.entity.gameObject) then
                return
            end
            self.timer = nil
            self:TryCollect()
        end
    )
end

function Idle:PlayRandomIdle()
    local cfg = self.entity:GetAniCfg()
    if not cfg or not cfg.showProbability or cfg.showProbability == 0 then
        return
    end
    if math.random() > cfg.showProbability then
        return
    end
    self.entity:PlayRandomIdle()
end

function Idle:StartTimer(sec, callback)
    self.timer = WaitExtension.SetTimeout(callback, sec)
end

function Idle:StopTimer()
    if self.timer then
        WaitExtension.CancelTimeout(self.timer)
        self.timer = nil
    end
end

function Idle:OnExit()
    BaseAction.OnExit(self)
    self:StopTimer()
    self.entity:UnregisterEvent(self, EntityEvent.click)
end

return Idle
