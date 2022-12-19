
local ChannelBtnItem = {}

--渠道状态
ChannelState = {
    UnActive = 1,
    UnBind = 2,
    Bind = 3
}

--账号类型（关联账号）
AccountType = {
    GUEST = 0,
    FACEBOOK = 1,
    LEDOU = 2,
    APPLE = 4
}

function ChannelBtnItem:Create(Root, name, sourcePanel)
    self.gameObject = Root:FindGameObject(name)
    self.c2_firstFbReward = find_component(self.gameObject, "btn_ChannelLogin/c2_firstFbReward")
    Runtime.Localize(self.gameObject:FindGameObject("btn_ChannelLogin/Text"), "ui_appleid_signin2")
    Util.UGUI_AddButtonListener(self.gameObject, function()
        if App.loginLogic:IsTestMode() then
            local message = "测试账号模式下不能使用绑定账号"
            AppServices.UITextTip:Show(message)
            return
        end
        PanelManager.showPanel(GlobalPanelEnum.ChannelPanel, {sourcePanel = sourcePanel})
    end)
end

function ChannelBtnItem:Hide()
    self.gameObject:SetActive(false)
end

return ChannelBtnItem