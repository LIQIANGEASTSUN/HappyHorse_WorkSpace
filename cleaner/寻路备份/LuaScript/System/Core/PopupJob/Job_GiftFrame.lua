--------------------Job_GiftFrame
local Job_GiftFrame = {}

function Job_GiftFrame:Init(priority)
    self.name = priority
end

function Job_GiftFrame:CheckPop()
    return AppServices.GiftFrameManager:PopCheck()
end

function Job_GiftFrame:Do(finishCallback)
    local pcb =
        PanelCallbacks:Create(
        function()
            finishCallback()
        end
    )

    AppServices.ProductManager:CheckFetchAll(
        function(result)
            if result then
                PanelManager.showPanel(GlobalPanelEnum.GiftFramePanel, {source = "Popqueue"}, pcb)
            else
                Runtime.InvokeCbk(finishCallback)
            end
        end
    )
end

return Job_GiftFrame
