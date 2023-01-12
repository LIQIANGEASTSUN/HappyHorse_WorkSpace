Rotate = class(BaseFrameAction,"Rotate")

function Rotate:Create(transform,rotateEuler,maxFrameCount,finishCallback)
    local instance = Rotate.new(transform,rotateEuler,maxFrameCount,finishCallback)
    return instance
end

function Rotate:ctor(transform,rotateEuler,maxFrameCount,finishCallback)
    self.transform = transform
    self.rotateEuler = rotateEuler
    self.maxFrameCount = maxFrameCount
    self.finishCallback = finishCallback

end

function Rotate:Update()
    self.currentFrameCount  = self.currentFrameCount+1
    if self.currentFrameCount>self.maxFrameCount then
        self.isFinished = true
    end

    if self.currentFrameCount == 1 then
        self.delta = self.rotateEuler/self.maxFrameCount
    end

    if Runtime.CSNull(self.transform) then
        return
    end

    self.transform.eulerAngles = self.transform.eulerAngles+self.delta
end

function Rotate:Reset()
    self.currentFrameCount = 0
    self.isFinished = false
end