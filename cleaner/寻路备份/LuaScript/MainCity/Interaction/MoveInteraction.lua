local base = require "MainCity.Interaction.InteractionLogic.BaseInteractionLogic"
---@class MoveInteraction : BaseInteractionLogic
local MoveInteraction = class(base, "MoveInteraction")

function MoveInteraction:Update()
    if self.active then
        self.inputMgr:Update()
    end
end
function MoveInteraction:OnGUI()
    if self.inputMgr and self.inputMgr.OnGUI then
        self.inputMgr:OnGUI()
    end
end

function MoveInteraction:SetOperator(operator)
    self.operator = operator
end

function MoveInteraction:RegisterListeners()
    self:RegisterClickListener()
    self:RegisterRoamListener()
    self:RegisterScaleListener()
    self:RegisterDragListener()

    self.inputMgr:Awake()
end
function MoveInteraction:UnRegisterListeners()
    self.inputMgr:AddShakeListener()
    self.inputMgr:AddDragListener()
    self.inputMgr:AddClickListener()
    self.inputMgr:AddScaleListener()
    self.inputMgr:AddRoamListener()
end

function MoveInteraction:OnZoomCamera(scale)
    if App.mapGuideManager:IsScaleScreenDisabled() then
        return
    end

    MoveCameraLogic.Instance():ZoomCamera(scale)
end

---@param input CustomInput
function MoveInteraction:OnDragBoundary(input)
    if App.mapGuideManager:IsDragScreenDisabled() then
        return
    end
    if self.operator and self.operator:HandleDragBoundary(input) then
        local position = input.worldPosition
        MoveCameraLogic.Instance():RoamCamera(position)
    end
end

---@param input CustomInput
function MoveInteraction:OnDragBegin(input)
    if App.mapGuideManager:IsDragScreenDisabled() then
        return
    end
    if self.operator and self.operator:HandleDragBegin(input) then
        return
    end
end

---@param input CustomInput
function MoveInteraction:OnDragging(input)
    if App.mapGuideManager:IsDragScreenDisabled() then
        return
    end

    if self.operator and self.operator:HandleDrag(input) then
        return
    end
    self:DragScreen(input.worldDelta)
end

---@param input CustomInput
function MoveInteraction:OnDragEnd(input)
    if App.mapGuideManager:IsDragScreenDisabled() then
        return
    end

    if self.operator and self.operator:HandleDragEnd(input) then
        return
    end
    self:DragScreen(input.worldDelta, true)
end

function MoveInteraction:OnClick(input)
    if self.operator and self.operator:HandleClick(input) then
        return
    end
end

----------------------------------------相机移动----------------------------------------
function MoveInteraction:DragScreen(worldDelta, over)
    MoveCameraLogic.Instance():MoveCamera(worldDelta, over)
end
--------------------------------------------测试画线--------------------------------------------
function MoveInteraction:DrawGizmos()
end

function MoveInteraction:InEdit()
    return true
end

return MoveInteraction
