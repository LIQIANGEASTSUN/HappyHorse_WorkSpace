---@class ErrorMessagePanel:BasePanel
local ErrorMessagePanel = class(BasePanel, "ErrorMessagePanel")

function ErrorMessagePanel:Create()
    local instance = ErrorMessagePanel.new()
    instance:Init()
    return instance
end

function ErrorMessagePanel:Init()
    self.gameObject = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_ERROR_MESSAGE_PANEL)
    self.btn_ok = self.gameObject:FindGameObject("btn_ok")
    self.text_message = self.gameObject.transform:Find("text_message").gameObject:GetComponent(typeof(Text))
    self.animator = self.gameObject:AddComponent(typeof(Animator))
    self.animator.runtimeAnimatorController = App.commonAssetsManager:GetAsset(CONST.ASSETS.G_ANIMATOR_PANEL)

    UIEventListener.GetButton(
        self.btn_ok,
        function()
            CS.Bridge.Feature.PlayPreset(3)
            App.audioManager:PlayEffectAudio(CONST.AUDIO.Interface_Click, false)
            self:Close()
        end
    )
    --insertDeclareBtn
    --text
    Runtime.Localize(self.btn_ok:FindGameObject("Text"), "ui_common_ok")
end

function ErrorMessagePanel:SetCloseCallback(callback)
    self.closeCallback = callback
end

function ErrorMessagePanel:HideButton(hide)
    self.btn_ok:SetActive(not hide)
end

function ErrorMessagePanel:SetText(text)
    self.text_message.text = text
end

function ErrorMessagePanel:Show()
    if not App.scene or not App.scene.noticeCanvas then
        return
    end
    self.gameObject.transform:SetParent(App.scene.noticeCanvas.transform, false)
    self.animator:Play("PanelIn")
end

function ErrorMessagePanel:Close()
    if self.isDisposed then
        return Runtime.InvokeCbk(self.closeCallback)
    end

    self.animator:Play("PanelOut")
    WaitExtension.SetTimeout(
        function()
            self.isDisposed = true
            Runtime.CSDestroy(self.gameObject)
            self.gameObject = nil
            Runtime.InvokeCbk(self.closeCallback)
        end,
        0.433
    )
end

return ErrorMessagePanel
