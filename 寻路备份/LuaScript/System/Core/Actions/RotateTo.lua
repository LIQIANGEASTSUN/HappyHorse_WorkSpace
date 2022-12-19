--- @class RotateTo:BaseFrameAction
RotateTo = class(BaseFrameAction, "RotateTo")

function RotateTo:ctor(maxFrameCount, finishCallback, transform, toAngle, isClockwise)
    self.maxFrameCount = maxFrameCount
    self.finishCallback = finishCallback
    self.transform = transform
    --0~359
    self.toAngle = toAngle
    self.isClockwise = isClockwise
end

function RotateTo:Create(transform, toAngle, isClockwise, maxFrameCount, finishCallback)
    local instance = RotateTo.new(maxFrameCount, finishCallback, transform, toAngle, isClockwise)
    return instance
end

function RotateTo:Update()
    self.currentFrameCount = self.currentFrameCount + 1
    if self.currentFrameCount >= self.maxFrameCount then
        self.isFinished = true
    end

    if Runtime.CSNull(self.transform) then
        return
    end

    local originalAngleZ = self.transform.localEulerAngles.z
    if self.currentFrameCount == 1 then
        if self.isClockwise then
            if originalAngleZ < self.toAngle then
                originalAngleZ = originalAngleZ + 360
            end
            self.diffAngle = (originalAngleZ - self.toAngle) / self.maxFrameCount
        else
            if originalAngleZ > self.toAngle then
                originalAngleZ = originalAngleZ - 360
            end
            self.diffAngle = (self.toAngle - originalAngleZ) / self.maxFrameCount
        end
    end

    if self.isFinished then
        self.transform:SetLocalEulerAngleZ(self.toAngle)
    else
        if self.isClockwise then
            GameUtil.SetLocalEulerAnglesZ_Add(self.transform, -self.diffAngle)
        else
            GameUtil.SetLocalEulerAnglesZ_Add(self.transform, self.diffAngle)
        end
    end
end

function RotateTo:Reset()
    self.currentFrameCount = 0
    self.isFinished = false
    self.diffAngle = nil
end
