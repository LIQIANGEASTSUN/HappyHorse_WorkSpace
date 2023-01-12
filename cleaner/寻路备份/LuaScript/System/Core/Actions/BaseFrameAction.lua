---@class BaseFrameAction
BaseFrameAction = class(nil, "BaseFrameAction")

function BaseFrameAction:ctor(maxFrameCount, finishCallback)
    self.maxFrameCount = maxFrameCount
    self.currentFrameCount = 0
    self.isFinished = false
    self.finishCallback = finishCallback
end

function BaseFrameAction:Update()
    console.assert(false, 'Must override')
end

function BaseFrameAction:IsFinished()
    return self.isFinished
end

function BaseFrameAction:SetFinished()
    self.isFinished = true
end

function BaseFrameAction:SetFinishCallback(callback)
    self.finishCallback = callback
end

function BaseFrameAction:CallFinishCallback()
    Runtime.InvokeCbk(self.finishCallback)
end

function BaseFrameAction:Reset()
    print("WARNING1: implement Reset() to use this action in Repeat!!!!") --@DEL
end

function BaseFrameAction:SetTag(tag)
    self.tag = tag
end

function BaseFrameAction:GetTag()
    return self.tag
end
