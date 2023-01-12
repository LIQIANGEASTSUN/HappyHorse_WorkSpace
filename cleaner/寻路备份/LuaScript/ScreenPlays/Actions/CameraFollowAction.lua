
---@class CameraFollowAction:BaseFrameAction
local CameraFollowAction = class(BaseFrameAction, "CameraFollowAction")

function CameraFollowAction:Create(params, finishCallback)
    local instance = CameraFollowAction.new(params, finishCallback)
    return instance
end

function CameraFollowAction:ctor(params, finishCallback)
    self.name = "CameraFollowAction"
    self.finishCallback = finishCallback
    self.started = false
    self.person = params.person
    self.size = params.size
end

function CameraFollowAction:Awake()
    MoveCameraLogic.Instance()
    local trans = GetPers(self.person).renderObj.transform
    MoveCameraLogic.Instance():StartFollowOnTransform(trans, self.size, function() self.isFinished = true end)
end


function CameraFollowAction:Update()
    if not self.started then
        self.started = true
        self:Awake()
    end
end

function CameraFollowAction:Reset()
    self.started = false
    self.isFinished = false
end

return CameraFollowAction