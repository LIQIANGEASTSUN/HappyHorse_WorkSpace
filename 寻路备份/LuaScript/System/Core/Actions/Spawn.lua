--- @class Spawn:BaseFrameAction
Spawn = class(BaseFrameAction, "Spawn")

function Spawn:Create(finishCallback)
    local instance = Spawn.new(finishCallback)
    return instance
end

function Spawn:ctor(finishCallback)
    self.name = "Spawn"
    self.finishCallback = finishCallback
    self.actions = {}
    self.started = false
    self.currentIndex = 1
end

function Spawn:Awake()
    self.runningList = {}
    for k, v in ipairs(self.actions) do
        table.insert(self.runningList, v)
    end
end

function Spawn:Append(action)
    table.insert(self.actions, action)
end

function Spawn:Update()
    if not self.started then
        self.started = true
        self:Awake()
    end

    local isFinished = true
    local needRefreshList = false

    for i=1, #self.runningList do
        local action = self.runningList[i]
        if not action:IsFinished() then
            action:Update()
            isFinished = false
        else
            --print("in Spawn finish", action.name) --@DEL
            needRefreshList = true
            action:CallFinishCallback()
        end
    end

    self.isFinished = isFinished

    -- 减少GC
    if needRefreshList then
        local runningList = {}
        for i, action in ipairs(self.runningList) do
            if not action:IsFinished() then
                table.insert(runningList, action)
            end
        end
        self.runningList = runningList
    end
end

function Spawn:GetInnerActions()
    return self.actions
end

function Spawn:Reset()
    self.started = false
    self.isFinished = false
    self.runningList = {}
end