--- @class CallFunc:BaseFrameAction
CallFunc = class(BaseFrameAction, "CallFunc")

function CallFunc:Create(finishCallback)
    local instance = CallFunc.new(finishCallback)
    return instance
end

function CallFunc:ctor(finishCallback)
    self.finishCallback = finishCallback
    self.isFinished = true
end

function CallFunc:Update()
end

function CallFunc:Reset()
end
