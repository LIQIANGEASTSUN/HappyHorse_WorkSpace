local CameraMoveAlongPathAction = class(BaseFrameAction, "CameraMoveAlongPathAction")

function CameraMoveAlongPathAction:Create(params, finishCallback)
    local instance = CameraMoveAlongPathAction.new(params, finishCallback)
    return instance
end

function CameraMoveAlongPathAction:ctor(params, finishCallback)
    self.name = "CameraMoveAlongPathAction"
    self.finishCallback = finishCallback
    self.started = false
    self.params = params
    self.moves = params.Moves
    self.duration = params.Duration
end

function CameraMoveAlongPathAction:Awake()
    local wayPoints = Vector3List()
    for i, v in ipairs(self.moves) do
        wayPoints:AddItem(ToVector3(v))
    end
    MoveCameraLogic.Instance():MoveCameraAlongPath(wayPoints, self.duration, function() self.isFinished = true end)
end


function CameraMoveAlongPathAction:Update()
    if not self.started then
        self.started = true
        self:Awake()
    end
end

function CameraMoveAlongPathAction:Reset()
    self.started = false
    self.isFinished = false
end

return CameraMoveAlongPathAction