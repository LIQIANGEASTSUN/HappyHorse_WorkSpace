--------------------Job_CheckParkourEndPanel
local Job_CheckParkourEndPanel = {}

function Job_CheckParkourEndPanel:Init(priority)
    self.name = priority
end

function Job_CheckParkourEndPanel:CheckPop()
    if ActivityServices.Parkour:IsInActivityTime() then
        return false
    end

    local endTime = AppServices.User.Default:GetKeyValue("ParkourEndPanel", 0)
    if endTime == 0 then
        return false
    end

    return true
end

function Job_CheckParkourEndPanel:Do(finishCallback)
    local pcb = PanelCallbacks:Create(function()
        Runtime.InvokeCbk(finishCallback)
    end)
    PanelManager.showPanel(GlobalPanelEnum.ParkourEndPanel, nil, pcb)
end

return Job_CheckParkourEndPanel