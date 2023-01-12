--insertRequire

---@class AndroidPrivacyView
local AndroidPrivacyView = {}

function AndroidPrivacyView:Create(go, callback)
    self:Init(go, callback)
end

function AndroidPrivacyView:Init(go, callback)
    self.go = go
    self.callback = callback

    go:FindComponentInChildren("lbTitle", typeof(Text)).text = Runtime.Translate('ui_privacy_panel_title')
    go:FindComponentInChildren("lbDesc", typeof(Text)).text = Runtime.Translate('ui_privacy_panel_desc')

    -- 使用条款
    self.btnItems = go:FindGameObject("Connect_platform/btnItems")
    self.btnItems:FindComponentInChildren("Text", typeof(Text)).text = Runtime.Translate('ui_settings_termofuse')
    Util.UGUI_AddEventListener(self.btnItems, "onClick", function()
        CS.UnityEngine.Application.OpenURL("https://privacy.betta-games.net/")
    end)

    -- 隐私政策
    self.btnPolicy = go:FindGameObject("Connect_platform/btnPolicy")
    self.btnPolicy:FindComponentInChildren("Text", typeof(Text)).text = Runtime.Translate('ui_settings_privacypolicy')
    Util.UGUI_AddEventListener(self.btnPolicy, "onClick", function()
        CS.UnityEngine.Application.OpenURL("https://privacy.betta-games.net/")
    end)

    -- 确认
    self.btnConfirm = go:FindGameObject("Connect_platform/btnConfirm")
    self.btnConfirm:FindComponentInChildren("Text", typeof(Text)).text = Runtime.Translate('idleaccelerate_ok')
    Util.UGUI_AddEventListener(self.btnConfirm, "onClick", function()
        Runtime.InvokeCbk(callback)
    end)
end

function AndroidPrivacyView:Destroy()
    self.go:SetActive(false)
    Runtime.CSDestroy(self.go)
end

--@params 控制gitTips的显隐
function AndroidPrivacyView:Show(isShow)
    self.gitTips:SetActive(isShow)
end

return AndroidPrivacyView