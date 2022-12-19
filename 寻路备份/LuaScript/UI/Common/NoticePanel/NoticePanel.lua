NoticePanel = class(BasePanel, "NoticePanel")

function NoticePanel:Create()
    local instance = NoticePanel.new()
    instance:Init()
    return instance
end

function NoticePanel:Init()
    self.gameObject = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_NOTICE_PANEL)
    self.text = self.gameObject.transform:Find('text_message'):GetComponent(typeof(Text))
    self.animator = self.gameObject:AddComponent(typeof(Animator))
end

function NoticePanel:SetText(text)
    self.text.text = text
end

function NoticePanel:Show(closeCallback, delay)
    self.gameObject.transform:SetParent(App.scene.noticeCanvas.transform, false)
    self.closeCallback = closeCallback
    --self.fader:FadeIn(0.25)
    self.animator:Play("PanelIn")
    self.timerId = WaitExtension.SetTimeout(function()
        self.timerId = nil
        self:Close()
    end, delay or 1)
end

function NoticePanel:Close()
    if self.timerId then
        WaitExtension.CancelTimeout(self.timerId)
        self.timerId = nil
    end
    if self.isDisposed then
        return Runtime.InvokeCbk(self.closeCallback)
    end
    --
    --self.fader:FadeOut(0.25, function()
    --    self.isDisposed = true
    --    Runtime.CSDestroy(self.gameObject)
    --    self.gameObject = nil
    --    Runtime.InvokeCbk(self.closeCallback)
    --end)
    self.animator:Play("PanelOut")
    WaitExtension.SetTimeout(function ()
        self.isDisposed = true
        Runtime.CSDestroy(self.gameObject)
        self.gameObject = nil
        Runtime.InvokeCbk(self.closeCallback)
    end,0.433)
end