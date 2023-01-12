local Character = require 'MainCity.Character.Base.Character'
local PlayAnimationAction = class(BaseFrameAction, "PlayAnimationAction")

function PlayAnimationAction:Create(name, anim, finishCallback)
    local instance = PlayAnimationAction.new(name, anim, finishCallback)
    return instance
end

function PlayAnimationAction:DontIdle(value)
    self.dontIdle = value
end

function PlayAnimationAction:ctor(name, anim, finishCallback)
    self.name = "PlayAnimationAction"
    self.started = false
    self.finishCallback = finishCallback

    self.anim = anim
    self.person = name
    self.secs = 0
    self.dontIdle = true
end

function PlayAnimationAction:Update()
    if not self.started then
        self.started = true
        self:Awake()
    end
    if Time.time - self.timestamp >= self.secs then
        if not self.dontIdle then
            self.character:PlayAnimation(Character.defaultIdleName)
        end
        self.isFinished = true
    end
end

function PlayAnimationAction:Awake()
    self.timestamp = Time.time

    self.character = GetPers(self.person)

    if type(self.character['PlayAnimation_' .. self.anim]) == "function" then
        self.secs = self.character['PlayAnimation_' .. self.anim](self.character) or 0

    elseif string.ends(self.anim, Character.idleSuffix) then
        self.character:PlayAnimation(self.anim)
        self.dontIdle = true -- 如果本身就是idle了，自然不用回到idle
        self.isFinished = true
    else
        local secs = self.character:PlayAnimation(self.anim)
        if not secs then
            secs = AnimatorEx.GetClipLength(self.character.renderObj, self.anim)
        end
        self.secs = secs
    end
end

function PlayAnimationAction:Reset()
    self.started = false
    self.isFinished = false
    self.timestamp = Time.time
end

return PlayAnimationAction