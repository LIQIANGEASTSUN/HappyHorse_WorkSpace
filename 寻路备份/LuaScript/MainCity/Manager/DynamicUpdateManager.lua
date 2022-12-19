---@class DynamicUpdateManager
local DynamicUpdateManager = {
    lastTime = os.time(),
    cdTime = 3600 * 6
}

if RuntimeContext.VERSION_DEVELOPMENT then
    DynamicUpdateManager.cdTime = 15
end

function DynamicUpdateManager:IsEnable()
    if os.time() - self.lastTime > self.cdTime and not App.processor then
        return true
    end
    return false
end

function DynamicUpdateManager:Start()
    if not self:IsEnable() then return end

    local widgetsMenu = App.scene:GetWidget(CONST.MAINUI.ICONS.HRWidgetsMenu)
    if not widgetsMenu or Runtime.CSNull(widgetsMenu.gameObject) then
        return
    end

    self.lastTime = os.time()

    local updatingButton = nil

    local processor = CS.BetaGame.InGameUpdateProcessorAsync(function(success)
        console.print("InGameUpdateProcessorAsync result:", success) --@DEL
        App.processor = nil
        AppServices.EventDispatcher:dispatchEvent(SystemEvent.UPDATING_FINISHED, {result = success})

        local widgetsMenu = App.scene:GetWidget(CONST.MAINUI.ICONS.HRWidgetsMenu)
        if not widgetsMenu or Runtime.CSNull(widgetsMenu.gameObject) then
            return
        end
        widgetsMenu:RemoveButton(CONST.MAINUI.ICONS.UpdatingButton)
    end,
    function(progress, processbytes, totalbytes)
        if not updatingButton and Runtime.CSValid(widgetsMenu.gameObject) then
            -- 需要更新了再创建动更icon
            updatingButton = require "UI.Components.UpdatingButton":Create()
            widgetsMenu:AddButton(CONST.MAINUI.ICONS.UpdatingButton, updatingButton)
        end
        local content = string.format("%.2fMB/%.2fMB", processbytes/1000000, totalbytes/1000000)
        AppServices.EventDispatcher:dispatchEvent(SystemEvent.UPDATING_PROGRESS, {val=progress, info=content})
    end)

    --local content = '{"host":"http://10.0.102.236:5000/platforms/StandaloneWindows64","version":"12.1.1887","update":true,"md5":"02cb15af7cd38cffd3e96ff08b1dba0f"}'
    --processor:Start(content)
    processor:Start()
    App.processor = processor
end

return DynamicUpdateManager