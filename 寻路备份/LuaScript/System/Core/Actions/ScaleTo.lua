
--- @class ScaleTo:BaseFrameAction
ScaleTo = class(BaseFrameAction, "ScaleTo")

function ScaleTo:ctor(maxFrameCount, finishCallback, transform, toScale)
    self.maxFrameCount = maxFrameCount
    self.finishCallback = finishCallback
    self.transform = transform
    self.toScale = toScale
end

function ScaleTo:Create(transform, toScale, maxFrameCount, finishCallback)
    local instance = ScaleTo.new(maxFrameCount, finishCallback, transform, toScale)
    return instance
end

function ScaleTo:Update()
    self.currentFrameCount = self.currentFrameCount + 1
    if self.currentFrameCount >= self.maxFrameCount then
        self.isFinished = true
    end

    if Runtime.CSNull(self.transform) then
        return
    end
    if self.currentFrameCount == 1 then
        --self.transform:DOScale(self.toScale,self.maxFrameCount/CONST.GAME.FRAME_RATE)
        self.originalScale = self.transform.localScale
        self.diffScale = Vector3(self.toScale.x or 0, self.toScale.y or 0, self.toScale.z or 0) - self.transform.localScale
    end
    if self.isFinished then
        self.transform:SetLocalScale(self.toScale.x or 0,self.toScale.y or 0,self.toScale.z or 0)
    else
        local scale = self.currentFrameCount / self.maxFrameCount * self.diffScale + self.originalScale
        self.transform:SetLocalScale(scale)
    end

end

function ScaleTo:Reset()
    self.currentFrameCount = 0
    self.isFinished = false
    self.diffScale = nil
end