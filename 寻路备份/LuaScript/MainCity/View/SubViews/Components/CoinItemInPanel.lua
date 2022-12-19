local SuperCls = require "UI.Components.CoinItem"

---@class CoinItemInPanel:CoinItem
local CoinItemInPanel = class(SuperCls)

function CoinItemInPanel:CreateWithGameObject(gameObject)
    local instance = CoinItemInPanel.new()
    instance:InitWithGameObject(gameObject)
    return instance
end

function CoinItemInPanel:SetInteractable(value)
end

function CoinItemInPanel:ShowEnterAnim(instant, finishCallback)
    self:Refresh()
end

function CoinItemInPanel:ShowExitAnim(instant, finishCallback, distance)
end

function CoinItemInPanel:ShowAds(value)
    if Runtime.CSNull(self.go_ads) then
        self.go_ads = self.gameObject:FindGameObject("go_ads")
        local function OnClick_btn_ads(go)
          -- PanelManager.showPanel(GlobalPanelEnum.LuckyTurntablePanel)
           if not App.popupQueue:IsFinished() then
              ErrorHandler.ShowErrorMessage(Runtime.Translate("ads_Tips_text"))
              return
           end
           PanelManager.showPanel(GlobalPanelEnum.LuckyTurntablePanel,{reShowName = GlobalPanelEnum.MoneyShopPanel, reShowParam = {selectIndex = MoneyShopPage.Extra}})
       end
       Util.UGUI_AddButtonListener(self.go_ads, OnClick_btn_ads, {noAudio = true})
    end

    self.go_ads:SetActive(value)
end

return CoinItemInPanel
