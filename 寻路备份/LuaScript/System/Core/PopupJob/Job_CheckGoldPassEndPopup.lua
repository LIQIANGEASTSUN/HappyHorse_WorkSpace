--------------------Job_CheckGoldPassEndPopup
local Job_CheckGoldPassEndPopup = {}

function Job_CheckGoldPassEndPopup:Init(priority)
    self.name = priority
end

function Job_CheckGoldPassEndPopup:CheckPop()
    if ActivityServices.GoldPass:IsInActivityTime() then
        return false
    end

    self.endTime = AppServices.User.Default:GetKeyValue("PopupAfterGoldPassEnd", 0)
    if self.endTime == 0 then
        return false
    end
    return true
end

function Job_CheckGoldPassEndPopup:Do(finishCallback)
    --读取配置中最晚结束的通行证id
    local cfgs = AppServices.Meta:Category("ActivityTemplate")
    local targetId
    local targetEndTime
    for id, cfg in pairs(cfgs) do
        if cfg.type == ActivityType.GoldPass then
            local endTs = tonumber(cfg.endTime) * 1000
            local startTs = tonumber(cfg.startTime) * 1000
            if self.endTime > startTs then
                if not targetEndTime then
                    targetEndTime = endTs
                    targetId = id
                elseif targetEndTime < endTs and endTs < TimeUtil.ServerTime() * 1000 then
                    targetEndTime = endTs
                    targetId = id
                end
            end
        end
    end

    local ret =
        pcall(
        function()
            include(string.format("UI/PanelRegisters/PanelRegister_GoldPassEndPanel%s", targetId))
        end
    )
    if not ret then
        return Runtime.InvokeCbk(finishCallback)
    end

    local pcb =
        PanelCallbacks:Create(
        function()
            Runtime.InvokeCbk(finishCallback)
        end
    )
    PanelManager.showPanel(GlobalPanelEnum.GoldPassEndPanel, nil, pcb)
end

return Job_CheckGoldPassEndPopup
