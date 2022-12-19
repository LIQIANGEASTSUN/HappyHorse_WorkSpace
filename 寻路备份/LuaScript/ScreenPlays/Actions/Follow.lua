
local Follow = class(BaseFrameAction, "Follow")

function Follow:Create(player, target, offset, finishCallback)
    local instance = Follow.new(player, target, offset, finishCallback)
    return instance
end

function Follow:ctor(player, target, offset, finishCallback)
    self.name = "Follow"
    self.finishCallback = finishCallback
    self.started = false
    self.player = player
    self.target = target
    self.offset = offset
end

function Follow:Awake()
    local function OnDestination()
        self.isFinished = true
        self.player.transform:LookAt(self.target.transform)
        self.target.transform:LookAt(self.player.transform)
    end

    if self.target.transform then
        self.player:PlayAnimation("walk")
        local dest = self.target.transform.position
        self.player:MoveTo(Vector3(dest.x + self.offset.x, dest.y + self.offset.y, dest.z + self.offset.z), OnDestination)
    else
        self.isFinished = true
    end
end

function Follow:Update()
    if not self.started then
        self.started = true
        self:Awake()
    end
end

function Follow:Reset()
    self.started = false
    self.isFinished = false
end

return Follow