local KeyEventProcessor = {
    Enable = false,
    logic = nil
}

function KeyEventProcessor.Start(vKey)
    if not KeyEventProcessor.Enable then
        console.print("KeyEventProcessor Disabled") --@DEL
        return
    end


    if App.scene and (App.scene:IsParkourCity() or App.scene:IsMowCity()) then
        return
    end

    if KeyEventProcessor.ProhibitedCloseWindow() then
        KeyEventProcessor.ShowPanel()
        return
    end

    local panelVO = PanelManager.getTopPanelVOForNavigation()
    if panelVO then
        console.print("AutoClose:" ..panelVO.classPath or "") --@DEL
        PanelManager.closePanel(panelVO)
    else
        KeyEventProcessor.ShowPanel()
    end
end

function KeyEventProcessor.ProhibitedCloseWindow()
    if GameUtil.IsBlockAllActive() then
        return true
    end

    if App.scene and App.scene:IsNotSameMainCity() then
        return true
    end

    if App.mapGuideManager:HasRunningGuide() then
        return true
    end

    if App:IsScreenPlayActive() then
        return true
    end

    --if App.scene and App.scene:IsMainCity() and not App.popupQueue:IsFinished() then
    --    return true
    --end
    return false
end

function KeyEventProcessor.ShowPanel()
    if not KeyEventProcessor.logic then
        KeyEventProcessor.logic = require("Game.Processors.GameExitPanelLogic")
    end
    KeyEventProcessor.logic:ToggleState()
end

return KeyEventProcessor