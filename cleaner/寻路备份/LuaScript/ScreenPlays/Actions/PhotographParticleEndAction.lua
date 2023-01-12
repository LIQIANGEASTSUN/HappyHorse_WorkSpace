---@class PhotographParticleEndAction:BaseFrameAction
local PhotographParticleEndAction = class(BaseFrameAction, "PhotographParticleEndAction")

function PhotographParticleEndAction:Create(params, finishCallback)
    local instance = PhotographParticleEndAction.new(params, finishCallback)
    return instance
end

function PhotographParticleEndAction:ctor(params, finishCallback)
    self.name = "PhotographParticleEndAction"
    self.finishCallback = finishCallback
    self.params = params
end

function PhotographParticleEndAction:Awake()
    local name1 = "E_photo_shan"
    local name2 = "E_photograph"
    if self.params == 2 then
        name1 = "E_photo_shan_2"
        name2 = "E_photograph2"
    end
    local blink = GameObject.Find(name1)
    local particle = GameObject.Find(name2)

    Runtime.CSDestroy(blink)
    Runtime.CSDestroy(particle)

    self.isFinished = true
end

function PhotographParticleEndAction:Update()
    if not self.started then
        self.started = true
        self:Awake()
    end
end

function PhotographParticleEndAction:Reset()
    self.started = false
    self.isFinished = false
end

return PhotographParticleEndAction