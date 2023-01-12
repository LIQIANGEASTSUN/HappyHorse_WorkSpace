--insertWidgetsBegin
--insertWidgetsEnd

--insertRequire
local _ShipIslandLeavePanelBase = require "UI.ShipSailing.ShipIslandLeavePanel.View.UI.Base._ShipIslandLeavePanelBase"

---@class ShipIslandLeavePanel:_ShipIslandLeavePanelBase
local ShipIslandLeavePanel = class(_ShipIslandLeavePanelBase)

function ShipIslandLeavePanel:ctor()

end

function ShipIslandLeavePanel:onAfterBindView()

end

function ShipIslandLeavePanel:refreshUI()
    AppServices.PlayerJoystickManager:SetActiveRock(false)
end

function ShipIslandLeavePanel:Leave(value)
    PanelManager.closePanel(GlobalPanelEnum.ShipIslandLeavePanel)
    if value then
        MessageDispatcher:SendMessage(MessageType.GoToHomeland, value)
    end

    if not value then
        AppServices.PlayerJoystickManager:SetActiveRock(true)
    end
end

return ShipIslandLeavePanel
