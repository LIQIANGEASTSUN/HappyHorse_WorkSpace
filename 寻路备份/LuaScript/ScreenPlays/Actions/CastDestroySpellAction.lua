
local CastDestroySpellAction = class(BaseFrameAction, "CastDestroySpellAction")

function CastDestroySpellAction:Create(params, finishCallback)
    local instance = CastDestroySpellAction.new(params, finishCallback)
    return instance
end

function CastDestroySpellAction:ctor(params, finishCallback)
    self.name = "CastDestroySpellAction"
    self.finishCallback = finishCallback
    self.params = params
    self.person = params.Person
    self.duration = params.Duration or 1
    self.started = false
end

function CastDestroySpellAction:Awake()
    self.destPosition = self.params.DestPosition
    if self.params.DestPerson then
        local person = GetPers(self.params.DestPerson)
        console.assert(person)
        self.destPosition = person:GetPosition()
    end

    local function hitCallback()
        self.isFinished = true
    end
    local animName     = "disappear_magic"
    local playerAction = Actions.PlayAnimationAction:Create(self.person, animName)
    local spellAction  = Sequence:Create()
    spellAction:Append(Actions.DestroySpellFlyTo:Create(self.destPosition, self.duration or 1, 1.3))
    local spawn = Spawn:Create()
    spawn:Append(playerAction)
    spawn:Append(spellAction)
    local sequence = Sequence:Create(hitCallback)
    sequence:Append(Actions.LookAtPositionAction:Create(self.person, self.destPosition, 0.4))
    sequence:Append(spawn)
    App.scene:AddFrameAction(sequence)
end

function CastDestroySpellAction:Update()
    if not self.started then
        self.started = true
        self:Awake()
    end
end

function CastDestroySpellAction:Reset()
    self.started = false
    self.isFinished = false
end

return CastDestroySpellAction