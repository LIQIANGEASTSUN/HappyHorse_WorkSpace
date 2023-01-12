---@class BaseInteractionLogic@地图交互事件处理逻辑基类
local BaseInteractionLogic = class(nil, "BaseInteractionLogic")

function BaseInteractionLogic:ctor()
    self.inputMgr = CS.InputManager.Instance
    self.inputMgr:SetShakeThreshold(1)
    self.active = true
    self.shakeEnabled = true
end

function BaseInteractionLogic:RegisterDragScreenListener()
    self.inputMgr:AddDragListener(
        function(input)
            if not self.active then
                return
            end
            self:DragScreen(input)
        end,
        function(input)
            if not self.active then
                return
            end
            self:DragScreen(input)
        end,
        function(input)
            if not self.active then
                return
            end
            self:DragScreen(input)
        end
    )
end
function BaseInteractionLogic:RegisterDragListener()
    self.inputMgr:AddDragListener(
        function(input)
            if not self.active then
                return
            end
            self:OnDragging(input)
        end,
        function(input)
            if not self.active then
                return
            end
            self:OnDragBegin(input)
        end,
        function(input)
            if not self.active then
                return
            end
            self:OnDragEnd(input)
        end
    )
end

function BaseInteractionLogic:RegisterClickListener()
    self.inputMgr:AddClickListener(
        function(input)
            if not self.active then
                return
            end
            self:OnClick(input)
        end
    )
end
function BaseInteractionLogic:RegisterLongPressListener()
    self.inputMgr:AddLongPressListener(
        function(input)
            if not self.active then
                return
            end
            self:OnLongPress(input)
        end,
        function()
            if not self.active then
                return
            end
            self:OnCancelPress()
        end
    )
end
function BaseInteractionLogic:RegisterScaleListener()
    self.inputMgr:AddScaleListener(
        function(input)
            if not self.active then
                return
            end
            self:OnZoomCamera(input.scale)
        end
    )
end
function BaseInteractionLogic:RegisterKeyListener()
    self.inputMgr:AddUpDownListener(
        function(input)
            if not self.active then
                return
            end
            self:OnMouseDown(input)
        end,
        function(input)
            if not self.active then
                return
            end
            self:OnMouseUp(input)
        end
    )
end
function BaseInteractionLogic:RegisterRoamListener()
    self.inputMgr:AddRoamListener(
        function(input)
            if not self.active then
                return
            end
            self:OnDragBoundary(input)
        end
    )
end

function BaseInteractionLogic:RegisterShakeListener()
    self.inputMgr:AddShakeListener(
        function()
            self:OnShake()
        end
    )
end

function BaseInteractionLogic:UnRegisterListeners()
    self.inputMgr:AddShakeListener()
    self.inputMgr:AddDragListener()
    self.inputMgr:AddLongPressListener()
    self.inputMgr:AddClickListener()
    self.inputMgr:AddScaleListener()
    self.inputMgr:AddUpDownListener()
    self.inputMgr:AddRoamListener()
end

---------------------------------------------摇一摇---------------------------------------------
function BaseInteractionLogic:SetShakeActive(active)
    self.shakeEnabled = active
    if not active then
        self.lockShakeStack = RuntimeContext.TRACE_BACK()
    end
end
function BaseInteractionLogic:GetShakeActive()
    if not self.shakeEnabled then
    -- console.error("Shake Blocked By:", self.lockShakeStack) --@DEL
    end

    return self.shakeEnabled
end

function BaseInteractionLogic:SetActive(active)
    self.active = active
end
function BaseInteractionLogic:GetActive()
    return self.active
end

function BaseInteractionLogic:CancelInput()
    self.inputMgr:CancelInput()
    -- self.inputMgr.state = 5
    -- self.inputMgr
end

function BaseInteractionLogic:Destroy()
    self.active = nil
end

return BaseInteractionLogic
