
local LookAtRotate = class(BaseFrameAction, "LookAtRotate")

function LookAtRotate:Create(person, eular, duration, finishCallback)
    local instance = LookAtRotate.new(person, eular, duration, finishCallback)
    return instance
end

function LookAtRotate:ctor(person, eular, duration, finishCallback)
    self.name = "LookAtRotate"
    self.finishCallback = finishCallback
    self.started = false
    self.duration = duration or 0
	self.Person = person
	self.Eular = eular
end

function LookAtRotate:Awake()
    self.Person = GetPers(self.Person)



    self.Person.transform:DORotate(self.Eular, self.duration):OnComplete(function () self.isFinished = true end)
end

function LookAtRotate:Update(dt)
    if not self.started then
        self.started = true
        self:Awake()
    end
end

function LookAtRotate:Reset()
    self.started = false
    self.isFinished = false
end

return LookAtRotate