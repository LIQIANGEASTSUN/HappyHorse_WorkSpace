
TestMission = class(BaseFrameAction, "TestMission")

function TestMission:Create(index, secs, finishCallback)
    local instance = TestMission.new(index, secs, finishCallback)
    return instance
end

function TestMission:ctor(index, secs, finishCallback)
    local function localFunc()
        print(string.format("%s finishCallback...", tostring(self.index))) --@DEL
        if finishCallback then
            finishCallback()
        end
    end
    self.finishCallback = localFunc
    self.index = index
    self.started = false
    self.secs = secs
end

function TestMission:Awake()
    self.timestamp = Time.time
end

function TestMission:Update()
    if not self.started then
        self.started = true
        self:Awake()
    end
    print("mission " .. self.index .. " update") --@DEL
    if Time.time - self.timestamp >= self.secs then
        print(string.format("%s is Finished...", tostring(self.index))) --@DEL
        self.isFinished = true
    end
end

function TestMission:Reset()
    self.timestamp = Time.time
    self.isFinished = false
    self.started = false
end