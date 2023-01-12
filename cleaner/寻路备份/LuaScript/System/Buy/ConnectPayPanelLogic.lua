---@class ConnectPayPanelLogic
local ConnectPayPanelLogic = {

}
function ConnectPayPanelLogic:Initialize()
    local go = BResource.InstantiateFromAssetName(CONST.ASSETS.G_CONNECTING_PAY_PANEL)
    self.go = go
    GameObject.DontDestroyOnLoad(self.go)
    self.mask = self.go:FindGameObject("ConnectingPanel/Mask")
    self.spine = self.go:FindGameObject("ConnectingPanel/Spine")
    self.spineBg = find_component(go, "ConnectingPanel/Image", Image)
    self.tip = find_component(go, "ConnectingPanel/Text", Text)
end

function ConnectPayPanelLogic:ShowPanel(state)
    self.go:SetActive(true)
    self:ShowConnectingText(state)
    Util.BlockAll(-1, "Pay")
end

local PayState = {
    ---支付中
    PAYMENTING = 1,
    ---验证订单中
    VERIFYING = 2,
}
---显示转圈圈
function ConnectPayPanelLogic:ShowConnectingText(state)
    if state == PayState.PAYMENTING then
        if RuntimeContext.UNITY_IOS then
            self.tip.text = Runtime.Translate("UI_wait_pay_ios")
            return
        end

        if RuntimeContext.UNITY_ANDROID then
            self.tip.text = Runtime.Translate("UI_wait_pay_android")
            return
        end
        return
    end

    if state == PayState.VERIFYING then
        self.tip.text = Runtime.Translate("UI_wait_send_items")
        return
    end
end

function ConnectPayPanelLogic:ClosePanel()
    self.go:SetActive(false)
    Util.BlockAll(0, "Pay")
end

ConnectPayPanelLogic:Initialize()

return ConnectPayPanelLogic
