Delay = class(BaseFrameAction, "Delay")

function Delay:ctor(delayFrames, finishCallback)
    self.maxFrameCount = delayFrames
    self.finishCallback = finishCallback
end

function Delay:Create(delayFrames, finishCallback)
    local instance = Delay.new(delayFrames, finishCallback)
    return instance
end


function Delay:Update()
    self.currentFrameCount = self.currentFrameCount + 1
    if self.currentFrameCount > self.maxFrameCount then
        self.isFinished = true
    end
end

function Delay:Reset()
    self.currentFrameCount = 0
    self.isFinished = false
end