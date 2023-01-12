
local WaitFinishAction = class(BaseFrameAction, "WaitFinishAction")

function WaitFinishAction:Create(startFunc, checkFinishFunc, finishCallback)
    local instance = WaitFinishAction.new(startFunc, checkFinishFunc, finishCallback)
    return instance
end

function WaitFinishAction:ctor(startFunc, checkFinishFunc, finishCallback)
    self.name = "WaitFinishAction"
    self.finishCallback = finishCallback

    self.startFunc, self.checkFinishFunc = startFunc, checkFinishFunc
    self.started = false
end

function WaitFinishAction:Awake()
    self.startFunc()
end

function WaitFinishAction:Update()
    if not self.started then
        self.started = true
        self:Awake()
    end
    if self.checkFinishFunc() then
        self.isFinished = true
    end
end

function WaitFinishAction:Reset()
    self.started = false
    self.isFinished = false
end

return WaitFinishAction