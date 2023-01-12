local SuperCls = require "UI.Components.HomeSceneTopIconBase"
---@class DiamondItem:HomeSceneTopIconBase
local DiamondItem = class(SuperCls)

---@return DiamondItem
function DiamondItem:Create()
    local gameObject = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_HOMESCENE_DIAMONDITEM)
    return DiamondItem:CreateWithGameObject(gameObject)
end

function DiamondItem:CreateWithGameObject(gameObject)
    local instance = DiamondItem.new()
    instance:InitWithGameObject(gameObject)
    return instance
end

function DiamondItem:InitWithGameObject(gameObject)
    self.gameObject = gameObject
    self.text_number = gameObject:FindComponentInChildren("text_number", typeof(Text))
    self.tf_diamond = gameObject.transform:Find("img_diamond")
    self.icon_animator = self.tf_diamond:GetComponent(typeof(Animator))
    self.animator_add = gameObject:FindComponentInChildren("btn_add", typeof(Animator))
    self.redDot = gameObject:FindGameObject("btn_add/reddot")
    self.newDot = gameObject:FindGameObject("btn_add/newdot")
    self.noAudio = true
    self:HandleRedDot()
    Util.UGUI_AddButtonListener(gameObject, self.OnAddBtnClick, self)
    self.Interactable = true
    self.number = 0
end

function DiamondItem:OnAddBtnClick()
    --if not App.globalFlags:CanClick() then
    --    return
    --end
    --App.globalFlags:SetClickFlag()

    AppServices.DiamondLogic:SetHasClickWhenFirstOpen()
    if self.Interactable then
        if App.loginLogic:IsLoggedIn() then
            require("Game.Processors.RequestIAPProcessor").Start(function()
                PanelManager.showPanel(GlobalPanelEnum.MoneyShopPanel, {source = "DiamondIcon"})
            end)
        else
            ErrorHandler.ShowErrorMessage(Translate("no.network.message"))
        end
        DcDelegates:Log(SDK_EVENT.mainUI_button, {buttonName = "diamondShop"})
    else
        print("DiamondItem:Interactable is false!!!") --@DEL
    end
end

function DiamondItem:SetInteractable(value)
    self.Interactable = value
    if value then
        self.animator_add:SetTrigger("In")
    else
        self.animator_add:SetTrigger("Out")
    end
end

function DiamondItem:SetDiamondNumber(val)
    if val < 0 then
        val = 0
    end
    if Runtime.CSValid(self.text_number) then
        self:StopValueWithAnimation()
        self.text_number.text = tostring(math.floor(val))
    end
    self.number = val
end

function DiamondItem:SetDiamondWithAnimation(toValue, animFinishCallback, animationDelay)
    if toValue < 0 then
        toValue = 0
    end
    self:ShowValueWithAnimation(self.text_number, self.number, toValue, animationDelay, animFinishCallback)
    self.number = toValue
end

function DiamondItem:GetDiamondPosition()
    return self.tf_diamond.position
end
function DiamondItem:GetMainIconGameObject()
    return self.tf_diamond.gameObject
end

function DiamondItem:GetIconGO()
    return self.tf_diamond.gameObject
end

function DiamondItem:OnHit()
    self.icon_animator:SetTrigger("add")
    App.audioManager:PlayEffectAudio(CONST.AUDIO.Interface_sound_acquire_gems)
end

function DiamondItem:SetValue(value)
    self:SetDiamondNumber(value)
end

function DiamondItem:GetValue()
    return self.number
end

function DiamondItem:HandleRedDot()
    if Runtime.CSNull(self.redDot) then
        return
    end
end

function DiamondItem:Refresh(valueWithAnimation, animationDelay)
    if self.number == AppServices.User:GetItemAmount(ItemId.DIAMOND) then
        return
    end
    if valueWithAnimation then
        self:SetDiamondWithAnimation(AppServices.User:GetItemAmount(ItemId.DIAMOND), nil, animationDelay)
    else
        self:SetDiamondNumber(AppServices.User:GetItemAmount(ItemId.DIAMOND))
    end
    self:HandleRedDot()
end

function DiamondItem:ShowEnterAnim(instant, finishCallback)
    self:HandleRedDot()
    SuperCls.ShowEnterAnim(self, instant, finishCallback)
end

function DiamondItem:Dispose()
    SuperCls.Dispose(self)
end

return DiamondItem
