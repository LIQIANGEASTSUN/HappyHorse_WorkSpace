
local DelayS = class(BaseFrameAction, "DelayS")

function DelayS:Create(secs, finishCallback)
    local instance = DelayS.new(secs, finishCallback)
    return instance
end

function DelayS:ctor(secs, finishCallback)
    self.name = "DelayS"
    self.finishCallback = finishCallback

    self.started = false
    self.secs = secs
end

function DelayS:Awake()
    self.timestamp = Time.time
end

function DelayS:Update()
    if not self.started then
        self.started = true
        self:Awake()
    end
    if Time.time - self.timestamp >= self.secs then
        self.isFinished = true
    end
end

function DelayS:Reset()
    self.started = false
    self.isFinished = false
end

return DelayS