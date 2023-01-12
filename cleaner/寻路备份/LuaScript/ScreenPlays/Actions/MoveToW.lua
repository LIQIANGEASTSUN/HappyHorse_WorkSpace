
local MoveToW = class(BaseFrameAction, "MoveToW")

function MoveToW:Create(player, toPosition, finishCallback)
    local instance = MoveToW.new(player, toPosition, finishCallback)
    return instance
end

function MoveToW:ctor(player, toPosition, finishCallback)
    self.name = "MoveToW"
    self.finishCallback = finishCallback
    self.started = false
    self.player = player
    self.destination = toPosition
end

function MoveToW:Awake()
    local function OnSearchCbk(result)
        if not result then
            self.player:SetPosition(self.destination)
            self.isFinished = true
        end
    end

    local function OnDestination()
        self.isFinished = true
    end
    self.player:MoveTo(self.destination, OnDestination, OnSearchCbk)
end

function MoveToW:Update()
    if not self.started then
        self.started = true
        self:Awake()
    end
end

function MoveToW:Reset()
    self.started = false
    self.isFinished = false
end

return MoveToW