local PlaySoundAction = class(BaseFrameAction, "PlaySoundAction")

function PlaySoundAction:Create(params,finishCallback)
    local instance = PlaySoundAction.new(params, finishCallback)
    return instance
end

function PlaySoundAction:ctor(params,finishCallback)
    self.name = "PlaySoundAction"
    self.finishCallback = finishCallback
    self.soundPath = params.SoundPath
    self.duration = params.Duration or -1
    self.loop = params.Loop == true
end

function PlaySoundAction:Awake()
    if not self.soundPath then
        self.isFinished = true
        return
    end
    if self.duration > 0 then
        self.timeId = WaitExtension.SetTimeout(function()
            if self.loop then
                App.audioManager:StopAudio(self.soundPath)
            end
            self.timeId = nil
            self.isFinished = true
        end,self.duration)
    end
    App.audioManager:PlayEffectAudio(self.soundPath,not self.loop, self.loop)
    if not self.timeId then
        self.isFinished = true
    end
end

function PlaySoundAction:Update()
    if not self.started then
        self.started = true
        self:Awake()
    end
end

function PlaySoundAction:Reset()
    self.isFinished = false
    self.started = false
    if self.timeId then
        WaitExtension.CancelTimeout(self.timeId)
        self.timeId = nil
    end
end

return PlaySoundAction