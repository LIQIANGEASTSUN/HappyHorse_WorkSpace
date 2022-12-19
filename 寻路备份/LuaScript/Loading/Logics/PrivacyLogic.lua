-- 隐私声明/获取面板
local PrivacyLogic = {}

function PrivacyLogic:Start(contaniner, callback)
    self.container = contaniner
    self.callback = callback

    if RuntimeContext.UNITY_IOS then
        return self:iOSProcessor()
    elseif RuntimeContext.UNITY_ANDROID then
        return self:AndroidProcessor()
    else
        return Runtime.InvokeCbk(self.callback)
    end
end

function PrivacyLogic:AndroidProcessor()
    local LocalDevice = require "User.LocalDevice"
    local pendingStatus = LocalDevice:GetValue(LocalDevice.Enum.PENDING_PRIVACY_ANDROID)
    local confirmedStatus = LocalDevice:GetValue(LocalDevice.Enum.CONFIRM_PRIVACY_ANDROID)

    if (App.firstLaunch and not confirmedStatus) or pendingStatus then
        LocalDevice:SetValue(LocalDevice.Enum.PENDING_PRIVACY_ANDROID, true, true)
        local callback = function()
            LocalDevice:SetValue(LocalDevice.Enum.PENDING_PRIVACY_ANDROID, false)
            LocalDevice:SetValue(LocalDevice.Enum.CONFIRM_PRIVACY_ANDROID, true, true)
            Runtime.InvokeCbk(self.callback)
        end
        PanelManager.showPanel(GlobalPanelEnum.PrivacyPanel, {callback  = callback})
    else
        Runtime.InvokeCbk(self.callback)
    end
end

function PrivacyLogic:iOSProcessor()
    local function GetSystemVersion(default_val)
        local ret = string.match(BCore.SystemVersion(), "%d+.%d")
        return ret or default_val
    end

    local version = GetSystemVersion("99.99")
    if version < "14.5" or not CS.AppTrackingAuthorization.NeedRequestAppTracking()then
        Runtime.InvokeCbk(self.callback)
        return
    end

    local ins = GameObject("AppTrackingAuthorization")
    ins:SetParent(self.container, false)

    local com = ins:AddComponent(typeof(CS.AppTrackingAuthorization))
    com.CallBackDelegate = function()
        Runtime.InvokeCbk(self.callback)
    end
end

return PrivacyLogic