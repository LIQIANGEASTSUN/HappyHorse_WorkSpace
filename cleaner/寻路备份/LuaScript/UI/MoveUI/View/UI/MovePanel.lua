--insertWidgetsBegin
--    btn_confirm    btn_cancel
--insertWidgetsEnd
local MoveInteraction = require "MainCity.Interaction.MoveInteraction"
--insertRequire
local _MovePanelBase = require "UI.MoveUI.View.UI.Base._MovePanelBase"

---@class MovePanel:_MovePanelBase
local MovePanel = class(_MovePanelBase)

function MovePanel:ctor()
    self.orgInteraction = App.scene.interaction
    if self.orgInteraction then
        self.orgInteraction:UnRegisterListeners()
    end

    self.currentInteraction = MoveInteraction.new()
    self.currentInteraction:RegisterListeners()
    self.currentInteraction:SetOperator(self)
    App.scene.interaction = self.currentInteraction

    self.putGridX = nil
    self.putGridZ = nil
    
    ---@type BaseAgent
    self.editingAgent = self.orgInteraction.editingAgent
end

function MovePanel:onAfterBindView()
end

function MovePanel:refreshUI()
end

function MovePanel:onAfterShowPanel()
    sendNotification(CONST.GLOBAL_NOFITY.Lock_Camera, false)
    MessageDispatcher:AddMessageListener(MessageType.Global_After_Show_Panel, self.Cancel, self)
    MessageDispatcher:AddMessageListener(MessageType.Global_Drama_Start, self.Cancel, self)
    MessageDispatcher:AddMessageListener(MessageType.Global_Guide_Start, self.Cancel, self)

    if App.screenPlayActive then
        --return self:OnDramaStart()
        self:Cancel()
        return
    end
    local panelVo = PanelManager.getTopPanelVO()
    if panelVo and panelVo ~= self.panelVO then
        return self:Cancel()
    end
end

function MovePanel:Confirm()
    self.isConfirm = true
    self.editingAgent:ExitEditMode(true)
    self.currentInteraction:UnRegisterListeners()
    PanelManager.closePanel(self.panelVO)
end

function MovePanel:Cancel()
    self.isCancel = true
    self.editingAgent:ExitEditMode(false)
    self.currentInteraction:UnRegisterListeners()
    PanelManager.closePanel(self.panelVO)
end

function MovePanel:SetPosition(position)
    if not position then
        return
    end

    local x, z = App.scene.mapManager:ToLocal(position)
    if self.putGridX == x and self.putGridZ == z then
        return
    end
    self.putGridX, self.putGridZ = x, z
    local pos = App.scene.mapManager:ToWorld(x, z)
    self.editingAgent:SetPosition(pos)
    local valid = self.editingAgent.data:CheckBuildingRationality()
    self:SetConfirmInteractable(valid)
end

function MovePanel:SetConfirmInteractable(interactable)
    if Runtime.CSValid(self.btn_confirm) then
        self.btn_confirm.Interactable = interactable
    end
end

---------------------------------EVENTS---------------------------------
function MovePanel:HandleDragBoundary(input)
    return self.isMoving
end
---@param input CustomInput
function MovePanel:HandleDragBegin(input)
    self.isMoving = false
    local function check(info)
        local hitCollider = info.collider
        if Runtime.CSValid(hitCollider) and hitCollider.name == self.editingAgent:GetId() then
            return true
        end
    end

    if check(input.hit) then
        self.isMoving = true
        local agentPos = self.editingAgent:GetWorldPosition()
        self.pressOffset = agentPos:Flat() - input.worldPosition
        return true
    end

    local hitCount = input:GetHitCount()
    if hitCount > 1 then
        for i = 1, hitCount - 1 do
            local hitInfo = input:GetHitInfo(i)
            if check(hitInfo) then
                self.isMoving = true
                return true
            end
        end
    end

    -- console.error("drag screen only") --@DEL
    return self.isMoving
end
---@param input CustomInput
function MovePanel:HandleDrag(input)
    if not self.isMoving then
        return
    end
    local agentPos = input.worldPosition + self.pressOffset
    self:SetPosition(agentPos)
    return true
end
function MovePanel:HandleDragEnd(input)
    if self.isMoving then
        local pos = input.worldPosition + self.pressOffset
        self:SetPosition(pos)
    end
    self.isMoving = false
end
function MovePanel:HandleClick(input)
    self:SetPosition(input.worldPosition)
end

function MovePanel:destroy()
    _MovePanelBase.destroy(self)
    App.scene.interaction = self.orgInteraction
    self.currentInteraction:UnRegisterListeners()
    MessageDispatcher:RemoveMessageListener(MessageType.Global_After_Show_Panel, self.Cancel, self)
    MessageDispatcher:RemoveMessageListener(MessageType.Global_Drama_Start, self.Cancel, self)
    MessageDispatcher:RemoveMessageListener(MessageType.Global_Guide_Start, self.Cancel, self)
    self.orgInteraction:RegisterListeners()
end

return MovePanel
