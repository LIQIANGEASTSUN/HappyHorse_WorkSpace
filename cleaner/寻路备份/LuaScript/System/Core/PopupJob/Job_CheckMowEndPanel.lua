--------------------Job_CheckMowEndPanel
local Job_CheckMowEndPanel = {}

function Job_CheckMowEndPanel:Init(priority)
    self.name = priority
end

function Job_CheckMowEndPanel:CheckPop()
    if ActivityServices.Mow:IsInActivityTime() then
        return false
    end

    local endTime = AppServices.User.Default:GetKeyValue("MowEndPanel", 0)
    if endTime == 0 then
        return false
    end

    return true
end

function Job_CheckMowEndPanel:Do(finishCallback)
    local pcb = PanelCallbacks:Create(function()
        Runtime.InvokeCbk(finishCallback)
    end)
    PanelManager.showPanel(GlobalPanelEnum.MowEndPanel, nil, pcb)
end

return Job_CheckMowEndPanel