---@type MoveCameraLogic
MoveCameraLogic = class(nil, "MoveCameraLogic")
local Camera = Camera

---@type MoveCameraLogic
local instance
---@return MoveCameraLogic
function MoveCameraLogic.Instance(create)
    if not instance and create then
        instance = MoveCameraLogic.new()
    end
    return instance
end
function MoveCameraLogic.Destroy()
    if not instance then
        return
    end
    instance:OnDestroy()
    instance = nil
end

function MoveCameraLogic:GetCamera(callback)
    if Runtime.CSValid(self.camera) then
        Runtime.InvokeCbk(callback, self.camera)
    else
        self.setCameraListeners = self.setCameraListeners or {}
        table.insert(self.setCameraListeners, callback)
    end
end

function MoveCameraLogic:SetCamera(camera)
    self.camera = camera
    if self.setCameraListeners then
        console.terror(self.camera, ".........................set camera") --@DEL
        while #self.setCameraListeners > 0 do
            local listener = table.remove(self.setCameraListeners)
            Runtime.InvokeCbk(listener, self.camera)
        end
    -- for i = #self.setCameraListeners, 1, -1 do
    --     table.remove(self.setCameraListeners, i)
    -- end
    end
end

function MoveCameraLogic:GetCameraFlatPosition()
    if Runtime.CSValid(self.camera) then
        local p = self.camera.transform.position
        local startPosition = Vector3(p.x, p.y, p.z)
        startPosition = startPosition:Flat()
        return startPosition
    end
end

function MoveCameraLogic:GetCameraPosition()
    if Runtime.CSValid(self.camera) then
        local p = self.camera.transform.position
        return p
    end
end

function MoveCameraLogic:Init(position, min, max)
    local camera = Camera.main
    if not camera then
        console.error("未在场景中找到摄像机!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!") --@DEL
        return
    else
        -- console.terror(camera, "MainCamera:", camera.nearClipPlane)
        -- camera.nearClipPlane = -50
        -- camera.farClipPlane = 300
    end
    position = position or Vector3(43, 40, -47)
    self:SetCamera(camera)

    --console.warn(camera, '===========MoveCameraLogic:Init()================= Camera is ', camera.name)

    self.CS_CameraFollow = camera.gameObject:GetOrAddComponent(typeof(CS.BetaGame.CameraFollow))

    self.CS_CameraLogic = CS.CameraMoveLogicManager.Instance
    self.CS_CameraLogic:InitializeMoveCameraVariable(camera, position, min, max)
    self.CS_CameraLogic:SetCameraSizeChangeCallback(
        function(size)
            MessageDispatcher:SendMessage(MessageType.Global_Camera_Size_Changed, size)
        end
    )
    local size = AppServices.Meta:GetConfigMetaValue("mainCameraSize", 50)
    if size then
        size = table.deserialize(size)
    else
        size = {2.6, 5}
    end
    self.minMaxSize = size
    self:SetCameraMinMaxSize(20, 60)
    self.blockWhenMove = true
end

---缩放相机大小
---@param scale number
function MoveCameraLogic:ZoomCamera(scale)
    if self.CS_CameraLogic then
        self.CS_CameraLogic:ZoomCamera(scale)
    end
end
---设定相机大小
function MoveCameraLogic:SetCameraSize(size)
    if self.CS_CameraLogic then
        self.CS_CameraLogic:SetCameraSize(size)
    end
end

function MoveCameraLogic:SetCameraMinMaxSize(min, max)
    self.CS_CameraLogic:SetCameraMinMaxSize(min, max)
end

---设置相机焦点
---@param position Vector3 @相机视野中心点
---@param smooth boolean @相机平滑移动
---@param duration number 相机移动时长
---@param cameraSize number 相机大小
function MoveCameraLogic:SetFocusOnPoint(position, smooth, duration, cameraSize, callback)
    position = position or Vector3.zero
    if smooth == nil then
        smooth = true
    end
    duration = duration or 0.65
    cameraSize = cameraSize or 5.0
    -- console.print("MoveCameraLogic:SetFocusOnPoint => ", position:ToString()) --@DEL
    self:StopFollow()
    self.CS_CameraLogic:MoveCameraToLook(position, smooth, duration, cameraSize, callback)
end

function MoveCameraLogic:MoveCameraToLook2(position, duration, cameraSize, callback, linear)
    position = position or Vector3.zero
    duration = duration or 0
    cameraSize = cameraSize or 0
    if self.blockWhenMove then
        Util.BlockAll(duration, "CS_CameraLogic")
    end
    self:StopFollow()
    self.CS_CameraLogic:MoveCameraToLook2(
        position,
        duration,
        cameraSize,
        function()
            Runtime.InvokeCbk(callback)
            --PanelManager.showPanel(GlobalPanelEnum.WorldMapPanel)
        end,
        linear or false
    )
end

function MoveCameraLogic:SetBlockWhenMove(value)
    self.blockWhenMove = value
end

function MoveCameraLogic:MoveCameraAlongPath(waypoints, callback)
    self:StopFollow()
    self.CS_CameraLogic:MoveCameraAlongPath(waypoints, callback)
end

function MoveCameraLogic:StopFollow()
    if not self.CS_CameraFollow then
        self:Init()
    end
    self.CS_CameraFollow:StopFocus()
end

function MoveCameraLogic:StartFollowOnTransform(trans, size, callback)
    local function onFinish()
        self.CS_CameraFollow:SetFocusOnTransform(trans)
        if callback then
            callback()
        end
    end
    self:StopFollow()
    self.CS_CameraLogic:MoveCameraToLook(trans.position, true, 0.65, size, onFinish)
end

--- 拖动相机
---@param deltapos Vector3 手指滑动差值(屏幕)
function MoveCameraLogic:MoveCamera(deltapos, over)
    if over == nil then
        over = false
    end

    -- console.print("MoveCameraLogic:MoveCamera => ", deltapos:ToString()) --@DEL
    self.CS_CameraLogic:MoveCamera(deltapos, over)
end
function MoveCameraLogic:StopMoveCamera()
    self.CS_CameraLogic:StopMoveCamera()
end

--- 相机拖动漫游
---@param worldpos Vector3 @射线检测到的世界坐标
function MoveCameraLogic:RoamCamera(worldpos)
    return self.CS_CameraLogic:RoamCamera(worldpos)
end

function MoveCameraLogic:ScreenToWorldDelta(screen_delta)
    return self.CS_CameraLogic:ScreenToWorldDelta(screen_delta)
end

function MoveCameraLogic:GetLookPosition()
    local camera = Camera.main
    if Runtime.CSValid(camera) then
        local position = camera:GetPosition()
        return position:Flat()
    end
end

function MoveCameraLogic:OnDestroy()
    if self.CS_CameraLogic then
        self.CS_CameraLogic:Destroy()
    end
    self.CS_CameraLogic = nil
    self.CS_CameraFollow = nil
end
