
--- @class MoveTo:BaseFrameAction
MoveTo = class(BaseFrameAction, "MoveTo")

function MoveTo:Create(transform, toPosition, maxFrameCount, finishCallback)
    local instance = MoveTo.new(maxFrameCount, finishCallback, transform, toPosition)
    return instance
end

function MoveTo:ctor(maxFrameCount, finishCallback, transform, toPosition)
    self.maxFrameCount = maxFrameCount
    self.finishCallback = finishCallback
    self.transform = transform
    self.originalPos = ToLuaVector2(transform.localPosition)
    self.diffPos = LuaVector2(toPosition.x - self.originalPos.x, toPosition.y - self.originalPos.y)
    self.toPosition = toPosition
end

function MoveTo:Update()
    self.currentFrameCount = self.currentFrameCount + 1
    if self.currentFrameCount >= self.maxFrameCount then
        self.isFinished = true
    end

    if Runtime.CSNull(self.transform) then
        return
    end
    if self.isFinished then
        self.transform:SetLocalPosition(self.toPosition)
    else
        local div = self.currentFrameCount/self.maxFrameCount
        local x = div * self.diffPos.x + self.originalPos.x
        local y = div * self.diffPos.y + self.originalPos.y
        -- local pos = self.currentFrameCount / self.maxFrameCount * self.diffPos + self.originalPos
        self.transform:SetLocalPosition(x,y,0)
    end
end

function MoveTo:Reset()
    self.currentFrameCount = 0
    self.isFinished = false
end