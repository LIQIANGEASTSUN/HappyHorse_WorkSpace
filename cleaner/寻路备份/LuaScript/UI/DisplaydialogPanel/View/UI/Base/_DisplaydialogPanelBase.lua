--insertRequire

---@class _DisplaydialogPanelBase:BasePanel
local _DisplaydialogPanelBase = class(BasePanel)

function _DisplaydialogPanelBase:ctor()
    self.gameObject = nil
    self.proxy = nil
    --insertCtor
    self.img_lost = nil
end

function _DisplaydialogPanelBase:setProxy(proxy)
    self.proxy = proxy
    --setProxy
end

function _DisplaydialogPanelBase:bindView()
    if (self.gameObject ~= nil) then
        --insertInit
        local goConfirm = find_component(self.gameObject, "Connect_platform/btnConfirm")
        local goCancel = find_component(self.gameObject, "Connect_platform/btnCancel")
        local txtContent = find_component(self.gameObject, "lbDesc", Text)
        --insertInitComp
        txtContent.text = self.arguments.message
        --insertOnClick

        if self.arguments.showConfirm then
            Util.UGUI_AddButtonListener(
                goConfirm,
                function()
                    PanelManager.closePanel(self.panelVO)
                    Runtime.InvokeCbk(self.arguments.onConfirm)
                end
            )
            Runtime.Localize(goConfirm:FindGameObject("Text"), "ui_common_confirm")
        else
            goConfirm:SetActive(false)
        end
        if self.arguments.showCancel then
            Util.UGUI_AddButtonListener(
                goCancel,
                function()
                    PanelManager.closePanel(self.panelVO)
                    Runtime.InvokeCbk(self.arguments.onCancel)
                end
            )
            Runtime.Localize(goCancel:FindGameObject("Text"), "ui_common_cancel")
        else
            goCancel:SetActive(false)
        end
    end
end

--insertSetTxt

return _DisplaydialogPanelBase
