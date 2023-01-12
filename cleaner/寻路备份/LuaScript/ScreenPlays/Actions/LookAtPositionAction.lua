
local LookAtPositionAction = class(BaseFrameAction, "LookAtPositionAction")

function LookAtPositionAction:Create(person, toPosition, duration, finishCallback)
    local instance = LookAtPositionAction.new(person, toPosition, duration, finishCallback)
    return instance
end

function LookAtPositionAction:ctor(person, toPosition, duration, finishCallback)
    self.name = "LookAtPositionAction"
    self.finishCallback = finishCallback
    self.started = false

    self.person = person
    self.toPosition = toPosition

    self.duration = duration or 0
end

function LookAtPositionAction:Awake()

    self.person = GetPers(self.person)
    self.toPosition.y = self.person.renderObj.transform.position.y
    GameUtil.DoLookAt(self.person.transform, self.toPosition, self.duration, function () self.isFinished = true end)
end

function LookAtPositionAction:Update(dt)
    if not self.started then
        self.started = true
        self:Awake()
    end
end

function LookAtPositionAction:Reset()
    self.started = false
    self.isFinished = false
end

return LookAtPositionAction