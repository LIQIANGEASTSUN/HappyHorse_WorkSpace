local SuperCls = require "UI.Components.HomeSceneTopIconBase"
---@class CoinItem:HomeSceneTopIconBase
local CoinItem = class(SuperCls)

function CoinItem:Create()
    local gameObject = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_HOMESCENE_COINITEM)
    return CoinItem:CreateWithGameObject(gameObject)
end

function CoinItem:CreateWithGameObject(gameObject)
    local instance = CoinItem.new()
    instance:InitWithGameObject(gameObject)
    return instance
end

function CoinItem:InitWithGameObject(gameObject)
    self.gameObject = gameObject
    self.text_number = gameObject:FindGameObject("text_number"):GetComponent(typeof(Text))
    self.text_numberReduce = gameObject:FindGameObject("text_number1"):GetComponent(typeof(Text))
    self.text_numberAdd = gameObject:FindGameObject("add/text_number_add"):GetComponent(typeof(Text))
    self.img_coin = gameObject:FindGameObject("img_coin")
    self.transform = gameObject.transform
    self.animator_icon = self.img_coin:GetComponent(typeof(Animator))
    self.animator_reduce_text = self.text_numberReduce:GetComponent(typeof(Animator))
    self.animator_add = gameObject:FindGameObject("add"):GetComponent(typeof(Animator))
    self.Interactable = true
    self.number = 0
    local function OnClick_btn_add(go)
        self:OnClick()
    end
    Util.UGUI_AddButtonListener(self.gameObject, OnClick_btn_add, {noAudio = true})
end

function CoinItem:OnClick()
    if not App.globalFlags:CanClick() then
        return
    end
    App.globalFlags:SetClickFlag()
    if self.Interactable then
        PanelManager.showPanel(GlobalPanelEnum.MoneyShopPanel, {selectIndex = MoneyShopPage.Coin,source = "GoldIcon"})
    end
end

function CoinItem:SetCoinNumber(value, playReduceAnimation)
    --self.text_number.text = tostring(value)
    if not value then
        return
    end
    local diff = value - self:GetValue()
    self.number = value
    self:StopValueWithAnimation()
    self.text_number.text = value
    if diff < 0 and playReduceAnimation then
        self.text_numberReduce.text = diff
        self.animator_icon:SetTrigger("shake")
        self.animator_reduce_text:SetTrigger("shake")
    end
end

function CoinItem:SetInteractable(value)
    self.Interactable = value
end

function CoinItem:GetIconTransform()
    return self.img_coin.transform
end

function CoinItem:GetIconGO()
    return self.img_coin
end

function CoinItem:OnHit()
    self.animator_icon:SetTrigger("shake")
    App.audioManager:PlayEffectAudio(CONST.AUDIO.Interface_sound_acquire_coins)
end

function CoinItem:SetValue(value)
    if not value then
        self:Refresh()
    else
        self:SetCoinNumber(value)
    end
end

function CoinItem:GetValue()
    return self.number
end

function CoinItem:GetMainIconGameObject()
    return self.img_coin
end

function CoinItem:SetExValue(value)
    self.text_numberAdd.text = "+" .. value
end

function CoinItem:Refresh(valueWithAnimation, animationDelay)
    if self.number == AppServices.User:GetItemAmount(ItemId.COIN) then
        return
    end
    if valueWithAnimation then
        self:ShowValueWithAnimation(self.text_number, self.number, AppServices.User:GetItemAmount(ItemId.COIN), animationDelay)
        self.number = AppServices.User:GetItemAmount(ItemId.COIN)
    else
        self:SetCoinNumber(AppServices.User:GetItemAmount(ItemId.COIN))
    end
end

function CoinItem:PlayExAnim(isIn)
    if isIn then
        self.animator_add:SetTrigger("in")
    else
        self.animator_add:SetTrigger("out")
    end
end

return CoinItem
