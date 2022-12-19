--- @class Repeat:BaseFrameAction
Repeat = class(BaseFrameAction, "Repeat")

function Repeat:Create(times, finishCallback)
    local instance = Repeat.new(times, finishCallback)
    return instance
end

function Repeat:ctor(times, finishCallback)
    self.times = times
    self.finishCallback = finishCallback
    self.currentTime = 1
end

function Repeat:SetInnerAction(action)
    self.innerAction = action
end

function Repeat:Awake()
    self.currentTime = 1
end

function Repeat:ResetInnerActions(action)
    if action.Reset then
        action:Reset()
    end
    if not action.GetInnerActions then
        return
    end
    local innerActions = action:GetInnerActions()
    if innerActions then
        for k, v in pairs(innerActions) do
            self:ResetInnerActions(v)
        end
    end
end

function Repeat:Update()
    if not self.started then
        self:Awake()
        self.started = true
    end
    if self.innerAction:IsFinished() then
        self.innerAction:CallFinishCallback()
        self.currentTime = self.currentTime + 1
        if self.currentTime > self.times then
            self.isFinished = true
            return
        else
            self:ResetInnerActions(self.innerAction)
        end
    end
    self.innerAction:Update()
end

function Repeat:GetInnerActions()
    return self.innerAction
end
