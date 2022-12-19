
local CameraMoveByTimeAction = class(BaseFrameAction, "CameraMoveByTimeAction")

function CameraMoveByTimeAction:Create(params, finishCallback)
    local instance = CameraMoveByTimeAction.new(params, finishCallback)
    return instance
end

function CameraMoveByTimeAction:ctor(params, finishCallback)
    self.name = "CameraMoveByTimeAction"
    self.finishCallback = finishCallback
    self.started = false
    self.params = params
    self.moves = params.Moves
end

function CameraMoveByTimeAction:Awake()

    self.index = 1
    self:NextPoint()
end

function CameraMoveByTimeAction:NextPoint()
    local function onFinish()
        self.index = self.index + 1
        if self.index > #self.moves then
            self.isFinished = true
        else
            self:NextPoint()
        end
    end
    local move = self.moves[self.index]
    local point = move.Point
    local duration = move.Duration or 1.5
    local size = move.CameraSize or PredefinedCameraSize.ZoomClosest
    local person = move.Person
    if person then
        local player = GetPers(person)
        if player and player.transform then
            point = player.transform.position
        else
            console.assert(false, person .. " not found")
        end
    end

    MoveCameraLogic.Instance():MoveCameraToLook2(Vector3(point.x, point.y, point.z), duration, size, onFinish)
end

function CameraMoveByTimeAction:Update()
    if not self.started then
        self.started = true
        self:Awake()
    end
end

function CameraMoveByTimeAction:Reset()
    self.started = false
    self.isFinished = false
end

return CameraMoveByTimeAction