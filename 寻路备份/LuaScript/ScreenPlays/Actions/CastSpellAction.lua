
local CastSpellAction = class(BaseFrameAction, "CastSpellAction")

function CastSpellAction:Create(params, finishCallback)
    local instance = CastSpellAction.new(params, finishCallback)
    return instance
end

function CastSpellAction:ctor(params, finishCallback)
    self.name = "CastSpellAction"
    self.finishCallback = finishCallback
    self.params = params
    self.person = params.Person
    self.duration = params.Duration or 1
    self.isFirstMagic = params.IsFirstMagic
    self.isFloat = params.IsFloat
    self.started = false
    self.isTimeline = params.IsTimeline
end

function CastSpellAction:Awake()
    self.destPosition = self.params.DestPosition
    if self.params.DestPerson then
        local person = GetPers(self.params.DestPerson)
        console.assert(person)
        self.destPosition = person:GetPosition()
    end

    local function hitCallback()
        self.isFinished = true
    end
    local animName = "magic_common"
    local delay = 2.1
    if self.isFirstMagic then
        animName = "magic_common_first"
        delay = 5.2
    elseif self.isFloat then
        animName = "magic_float_magic_common"
        delay = 2.1
    end

    if self.isTimeline then
        local sequence = Sequence:Create(hitCallback)
        sequence:Append(Actions.SpellFlyTo:Create(Vector3(self.destPosition.x, self.destPosition.y, self.destPosition.z), self.duration or 1))
        App.scene:AddFrameAction(sequence)
    else
        local playerAction = Actions.PlayAnimationAction:Create(self.person, animName)
        local spellAction = Sequence:Create()
        --spellAction:Append(DelayS:Create(delay))
        spellAction:Append(Actions.SpellFlyTo:Create(Vector3(self.destPosition.x, self.destPosition.y, self.destPosition.z), self.duration or 1, delay))
        local spawn = Spawn:Create()
        spawn:Append(playerAction)
        spawn:Append(spellAction)
        local sequence = Sequence:Create(hitCallback)
        sequence:Append(Actions.LookAtPositionAction:Create(self.person, Vector3(self.destPosition.x, self.destPosition.y, self.destPosition.z), 0.4))
        local function CreateBook()
            local bookSingle = CharacterManager.Instance():Get("MagicBookSingle")
            if not bookSingle then
                bookSingle = CharacterManager.Instance():CreateByName("MagicBookSingle")
            end
            local bookObj = bookSingle.renderObj
            local playerObj = GetPers("Player").renderObj
            bookObj.transform.position = playerObj.transform.position
            bookObj.transform:LookAt(playerObj.transform.position + playerObj.transform.forward)

            bookObj:SetActive(true)
            local bookSequence = Sequence:Create(function()
                bookObj:SetActive(false)
                CharacterManager.Instance():RemoveByName("MagicBookSingle")
            end)
            bookSequence:Append(Actions.PlayAnimationAction:Create("MagicBookSingle", "defaultIdle"))
            bookSequence:Append(Actions.DelayS:Create(2.5))
            App.scene:AddFrameAction(bookSequence)
        end
        sequence:Append(CallFunc:Create(CreateBook))
        sequence:Append(spawn)
        App.scene:AddFrameAction(sequence)
    end
end

function CastSpellAction:Update()
    if not self.started then
        self.started = true
        self:Awake()
    end
end

function CastSpellAction:Reset()
    self.started = false
    self.isFinished = false
end

return CastSpellAction