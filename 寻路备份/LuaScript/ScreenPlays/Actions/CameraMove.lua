--[[
    没发现有使用
]]
local CameraMove = class(BaseFrameAction, "CameraMove")

function CameraMove:Create(params, finishCallback)
    local instance = CameraMove.new(params, finishCallback)
    return instance
end

function CameraMove:ctor(params, finishCallback)
    self.name = "CameraMove"
    self.finishCallback = finishCallback
    self.started = false
    self.params = params
    self.moves = params.Moves
end

function CameraMove:Awake()

    self.index = 1
    self:NextPoint()
end

function CameraMove:NextPoint()
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
    local duration = move.Duration or 1
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
    local update = true
    if duration <= 0 then
        update = false
    end
    MoveCameraLogic.Instance():SetFocusOnPoint(Vector3(point.x, point.y, point.z), update, duration, size, onFinish)
end

function CameraMove:Update()
    if not self.started then
        self.started = true
        self:Awake()
    end
end

function CameraMove:Reset()
    self.started = false
    self.isFinished = false
end

return CameraMove