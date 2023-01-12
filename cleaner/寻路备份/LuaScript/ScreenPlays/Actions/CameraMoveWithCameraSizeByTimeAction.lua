
local CameraMoveWithCameraSizeByTimeAction = class(BaseFrameAction, "CameraMoveWithCameraSizeByTimeAction")

function CameraMoveWithCameraSizeByTimeAction:Create(params, finishCallback)
    local instance = CameraMoveWithCameraSizeByTimeAction.new(params, finishCallback)
    return instance
end

function CameraMoveWithCameraSizeByTimeAction:ctor(params, finishCallback)
    self.name = "CameraMoveWithCameraSizeByTimeAction"
    self.finishCallback = finishCallback
    self.started = false
    self.params = params
    -- self.moves = params.Moves
end

function CameraMoveWithCameraSizeByTimeAction:Awake()
    MoveCameraLogic.Instance():GetCamera(function(camera)
        self.camera = camera
        self:AwakeEx()
    end)
end

function CameraMoveWithCameraSizeByTimeAction:UpdateCamera()
    self.curTime = self.curTime + Time.deltaTime
    local curIndexTime = self.timetb[self.index]

    if not curIndexTime then
        self.isFinished = true
        return
    end
    if self.curTime >= curIndexTime then
        self.index = self.index + 1
        curIndexTime = self.timetb[self.index]
        if self.index > #self.timetb then
            self.isFinished = true
            return
        end
    end
    local cameraLogicIns = MoveCameraLogic.Instance()
    if self.index == 1 then -- cameraSize缩放到中间目标
        local size = math.lerp(self._fromCameraSize, self._maxCameraSize, self.curTime / curIndexTime)
        cameraLogicIns:SetCameraSize(size)
    elseif self.index == 2 then -- cameraSize不动
    elseif self.index == 3 then -- cameraSize到最终目标值
        local lastTime = self.timetb[self.index - 1]
        local time = self.curTime - lastTime
        local per = time / (curIndexTime - lastTime)
        local size = math.lerp(self._maxCameraSize, self._targetCameraSize, per)
        cameraLogicIns:SetCameraSize(size)
    end
    local _fromPoint, _targetPoint = self._fromPoint, self._targetPoint
    self.camera.transform.position = Vector3.Lerp(_fromPoint, _targetPoint, self.curTime / self.duration);
end

function CameraMoveWithCameraSizeByTimeAction:AwakeEx()
    local move = self.params
    local point = move.Point
    local duration = move.Duration or 1.5
    self.duration = duration
    local cameraSizeFreezeTime = move.CameraSizeFreezeTime
    self.cameraSizeFreezeTime = cameraSizeFreezeTime
    local moveTime = (duration - cameraSizeFreezeTime) / 2
    self.moveTime1 = moveTime
    self.timetb = {
        [1] = moveTime,
        [2] = moveTime + cameraSizeFreezeTime,
        [3] = duration
    }
    self.index = 1
    self._fromCameraSize = self.camera.orthographicSize
    self._maxCameraSize = move.CameraSize or PredefinedCameraSize.ZoomFarthest
    self._targetCameraSize = move.TargetCameraSize or PredefinedCameraSize.ZoomFarthest
    local curPos = MoveCameraLogic.Instance():GetCameraPosition()
    self._fromPoint = Vector3(curPos.x, curPos.y, curPos.z)
    self._targetPoint = Vector3(point.x, point.y, point.z)
    self.curTime = 0
    self.startedEx = true
end

function CameraMoveWithCameraSizeByTimeAction:Update()
    if not self.started then
        self.started = true
        self:Awake()
    end
    if not self.startedEx or self.isFinished then
        return
    end
    self:UpdateCamera()
end

function CameraMoveWithCameraSizeByTimeAction:Reset()
    self.started = false
    self.startedEx = false
    self.isFinished = false
end

return CameraMoveWithCameraSizeByTimeAction