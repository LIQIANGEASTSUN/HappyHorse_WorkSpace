local SuperCls = require "UI.Components.HomeSceneTopIconBase"

---@class HeartItem:HomeSceneTopIconBase
local HeartItem = class(SuperCls)

function HeartItem:Create()
    local gameObject = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_HOMESCENE_HEARTITEM)
    return HeartItem:CreateWithGameObject(gameObject)
end

function HeartItem:CreateWithGameObject(gameObject)
    local instance = HeartItem.new()
    instance:InitWithGameObject(gameObject)
    return instance
end

function HeartItem:InitWithGameObject(gameObject)
    self.gameObject = gameObject
    self.transform = self.gameObject.transform
    self.text_number = gameObject:FindComponentInChildren("text_number", typeof(Text))
    -- self.button = self.gameObject:GetComponent(typeof(Button))
    self.btn_add = gameObject:FindGameObject("btn_add")
    -- self.go_imgInfinite = gameObject:FindGameObject("img_infinite")
    self.flickerAnimator = gameObject:FindComponentInChildren("img_heart", typeof(Animator))
    self.img_heart = self.gameObject:FindComponentInChildren("img_heart", typeof(Image))
    -- self.go_imgInfinite:SetActive(false)
    self.animator_add = self.btn_add:GetComponent(typeof(Animator))
    self.goGlow = self.gameObject:FindGameObject("HeartItem_glow")
    self.goGlow2 = self.gameObject:FindGameObject("img_heart_mask")
    self.Interactable = true
    --几种状态: 满的、未满cd回复体力、空的可够买体力、无限体力时间倒计时
    self.heartRecoverCd = 60
    self.value = AppServices.User:GetItemAmount(ItemId.ENERGY)
    self.img_times = find_component(self.gameObject, "img_heart/times")
    self.img_arrow = find_component(self.gameObject, "img_heart/arrow", Image)
    self:SetValue(self.value)
    Util.UGUI_AddButtonListener(self.btn_add, self.OnAddBtnClick, self)
    self:RegisterListeners()
end

---刷新数值显示
function HeartItem:RefreshUI(value)
    self:RefreshCount(value)
end

function HeartItem:OnAddBtnClick()
    if not self.Interactable then
        return
    end
    if not App.globalFlags:CanClick() then
        return
    end
    App.globalFlags:SetClickFlag()
    PanelManager.showPanel(GlobalPanelEnum.PowerShopPanel, {source = "EnergyIcon"})
    DcDelegates:Log(SDK_EVENT.mainUI_button, {buttonName = "getEnergy"})
end

function HeartItem:SetInteractable(value)
    self.Interactable = value
    --self.btn_add.gameObject:SetActive(value)
    if value then
        self.animator_add:SetTrigger("In")
    else
        self.animator_add:SetTrigger("Out")
    end
end

function HeartItem:OnHit()
    self.flickerAnimator:SetTrigger("shake")
    App.audioManager:PlayEffectAudio(CONST.AUDIO.Interface_sound_acquire_resource)
end

function HeartItem:PlayGetBuffAnimation()
    --goGlow上带个Animator
    self.goGlow:SetActive(true)
    self.goGlow2:SetActive(true)
    self.goGlow:SetTimeOut(
        function()
            self.goGlow:SetActive(false)
            self.goGlow2:SetActive(false)
        end,
        1.1
    )
end

---设置缓存数值并刷新
---不传value的时候相当于刷新到当前数值
function HeartItem:SetValue(value)
    value = value or AppServices.User:GetItemAmount(ItemId.ENERGY)
    if value < 0 then
        value = 0
    end
    self.value = value
    self:RefreshCount(value)
end
---获取缓存数值
function HeartItem:GetValue()
    return self.value
end

---刷新显示数值
---@param limitValue number 用来播放上限值增加动画用的
function HeartItem:RefreshCount(value, limitValue)
    if Runtime.CSNull(self.text_number) then
        return
    end

    if Runtime.CSValid(self.img_times) and Runtime.CSValid(self.img_arrow) then
        local times = HeartManager:GetRecoverSpeed()
        self.img_times:SetActive(times > 1)
        self.img_arrow:SetActive(times > 1)
    end

    value = value or self:GetValue()
    if value < 0 then
        value = 0
    end
    local maxCount = limitValue or HeartManager:GetMaxCount()
    local countStr = tostring(value) .. "/" .. tostring(maxCount)
    if value <= 5 then
        self.text_number.text = "<color=#FF0000>" .. countStr .."</color>"
        return
    end

    local isGoldColor = self:IsTxtGoldColor()
    if not isGoldColor then
        self.text_number.text = Runtime.formatStringColor(countStr, UICustomColor.white)
        return
    end

    local curStr = Runtime.formatStringColor(value, UICustomColor.white)
    local maxStr = Runtime.formatStringColor(maxCount, UICustomColor.gold)
    self.text_number.text = curStr .. "/" .. maxStr
end

function HeartItem:IsTxtGoldColor()
    local obtained
    if ActivityServices.GoldPass:IsDataNotEmpty() then
        obtained = ActivityServices.GoldPass:IsSpecialRewardObtained(GoldPassRewardKind.MaxEnergy)
    end
    if obtained then
        return true
    end
    local invalid = AppServices.MonCard:CheckValid()
    local info = AppServices.MonCard:GetConfigInfo()
    if invalid and info and info.heartMaxUp and info.heartMaxUp > 0 then
        obtained = true
    end
    return obtained
end

function HeartItem:ShowLimitIncreAnim(from, to)
    if Runtime.CSNull(self.text_number) then
        return
    end
    local tmp
    if to < 0 then
        to = 0
    end
    LuaHelper.FloatSmooth(from,to,0.65,function(value)
            local cur = math.floor(value)
            if tmp == cur then
                return
            end
            tmp = cur
            self:RefreshCount(nil, cur)
        end
    )
end

function HeartItem:Refresh()
    -- self:RefreshCount()
    self:SetValue()
end

function HeartItem:ShowEnterAnim(...)
    self:Refresh()
    SuperCls.ShowEnterAnim(self, ...)
end
function HeartItem:ShowExitAnim(instant, ...)
    if instant then
        self:Refresh()
    end
    SuperCls.ShowExitAnim(self, instant, ...)
end

---刷新显示数值(改变动画)
function HeartItem:TweenToCount(to)
    if not to then
        console.terror(self.gameObject, "设置显示数值为空值!!") --@DEL
        return
    end
    local from = self:GetValue()
    if from == to then
        return
    end
    self.value = to

    local tmp
    LuaHelper.FloatSmooth(
        from,
        to,
        0.65,
        function(value)
            local cur = math.floor(value)
            if tmp == cur then
                return
            end
            tmp = cur
            self:RefreshCount(cur)
        end
    )
end

function HeartItem:TweenToCurrentCount()
    local currentCount = AppServices.User:GetItemAmount(ItemId.ENERGY)
    self:TweenToCount(currentCount)
end

function HeartItem:GetMainIconGameObject()
    return self.img_heart.gameObject
end

function HeartItem:CheckRefresh(activityInfo)
    if activityInfo.activityId == ActivityServices.GoldPass:GetActivityId() then
        self:RefreshCount()
    end
end

function HeartItem:GetIconGO()
    return self.img_heart
end

function HeartItem:RegisterListeners()
    self:AddListener(MessageType.Activity_On_Activity_Response, "CheckRefresh")
end

function HeartItem:AddListener(messageType, funcName)
    if not self._registers then
        self._registers = {}
    end
    if not self._registers[messageType] then
        self._registers[messageType] = funcName
        MessageDispatcher:AddMessageListener(messageType, self[funcName], self)
    end
end

function HeartItem:RemoveListener(messageType)
    if not self._registers then
        return
    end
    if not self._registers[messageType] then
        return
    end

    local funcName = self._registers[messageType]
    self._registers[messageType] = nil
    MessageDispatcher:RemoveMessageListener(messageType, self[funcName], self)
end

function HeartItem:UnregisterAllListeners()
    if not self._registers then
        return
    end
    for messageType, _ in pairs(self._registers) do
        self:RemoveListener(messageType)
    end
    self._registers = nil
end

function HeartItem:Dispose()
    self:UnregisterAllListeners()
    SuperCls.Dispose(self)
end

return HeartItem
