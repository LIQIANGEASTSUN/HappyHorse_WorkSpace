
local LookAtPerson = class(BaseFrameAction, "LookAtPerson")

function LookAtPerson:Create(lhsPerson, rhsPerson, duration, finishCallback)
    local instance = LookAtPerson.new(lhsPerson, rhsPerson, duration, finishCallback)
    return instance
end

function LookAtPerson:ctor(lhsPerson, rhsPerson, duration, finishCallback)
    self.name = "LookAtPerson"
    self.finishCallback = finishCallback
    self.started = false

    self.lhsPerson = lhsPerson
    self.rhsPerson = rhsPerson

    self.duration = duration or 0
end

function LookAtPerson:Awake()
    self.lhsPerson = GetPers(self.lhsPerson)
    self.rhsPerson = GetPers(self.rhsPerson)
    local pos = self.rhsPerson.transform.position
    pos.y = 0
    self.lhsPerson.transform:DOLookAt(pos, self.duration):OnComplete(function () self.isFinished = true end)
end

function LookAtPerson:Update(dt)
    if not self.started then
        self.started = true
        self:Awake()
    end
end

function LookAtPerson:Reset()
    self.started = false
    self.isFinished = false
end

return LookAtPerson