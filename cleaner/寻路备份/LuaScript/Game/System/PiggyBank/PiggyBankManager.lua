---
--- Created by Betta.
--- DateTime: 2022/5/11 18:01
---
---@class PiggyBankManager
local PiggyBankManager = {}
local checkGiftId = {21, 22, 23}
function PiggyBankManager:Init()
    local piggyBankInfo = App.response.piggyBankInfo
    self.bankId = piggyBankInfo.bankId
    self.starTime = piggyBankInfo.startTime / 1000
    self.energy = piggyBankInfo.energy
    self.bougth = piggyBankInfo.bought
    if self:IsOpen() then
        self._cfg = self:GetCfg()
        self.energy = math.min(self.energy, self._cfg.energyNum)
    end
    self._firstPopupQueue = true
    MessageDispatcher:AddMessageListener(MessageType.Gift_Close, self.OnGiftClose, self)
    MessageDispatcher:AddSubMessageListener(MessageType.Global_After_UseItem, self.OnUseEnergy, self, ItemId.ENERGY)
    MessageDispatcher:AddMessageListener(MessageType.DAY_SPAN, self.OnDayRefresh, self)
    AppServices.EventDispatcher:addObserver(self,GlobalEvents.ReissuePurchase,function(info)
        self._cfg = AppServices.Meta:Category("PiggyBankTemplate")[self.bankId]
        if not self._cfg then
            return false
        end
        local id = self._cfg.shopId
        local productId = AppServices.ProductManager:GetProductId(id)
        if info and info.data and info.data.productId == productId and self._cfg.energyNum <= self.energy then
            self.bougth = true
            if self:CanUpdate() then
                self:UpdateIdRequest()
            else
                MessageDispatcher:SendMessage(MessageType.PiggyBankRefresh)
            end
        end
    end)

end

function PiggyBankManager:OnUseEnergy(_, count)
    if self:IsOpen() then
        local cfg = self:GetCfg()
        self.energy = math.min(self.energy + count * cfg.energyMethod[2], cfg.energyNum)
        MessageDispatcher:SendMessage(MessageType.PiggyBankRefresh)
    end
end

function PiggyBankManager:OnDayRefresh()
    if self:CanBuy() then
        PopupManager:CallWhenIdle(function()
            self:PopUI()
        end)
    end
end

function PiggyBankManager:CheckPopupQueue()
    if self._firstPopupQueue then
        return true
    end
end

function PiggyBankManager:OnPopupQueue(finishCallback)
    if self._firstPopupQueue then
        self._firstPopupQueue = false
        if self:IsInCD() then
            self:StartTick()
        end
        if self:CanBuy() then
            self:PopUI(finishCallback)
        elseif self:CanOpen() then
            if self:CanUpdate() then
                self:UpdateIdRequest(function(response)
                    if response then
                        self:PopUI(finishCallback)
                    else
                        Runtime.InvokeCbk(finishCallback)
                    end
                end)
            else
                self:StartRequest(function(response)
                    if response then
                        self:TryShowUI(finishCallback)
                    else
                        Runtime.InvokeCbk(finishCallback)
                    end
                end)
            end
        else
            Runtime.InvokeCbk(finishCallback)
        end
    else
        Runtime.InvokeCbk(finishCallback)
    end
    MessageDispatcher:SendMessage(MessageType.PiggyBankRefresh)
end

function PiggyBankManager:StartTick()
    if self.ticker then
        return
    end
    self.ticker = WaitExtension.InvokeRepeating(function()
        if not self:IsInCD() and not self:CanOpen() then
            WaitExtension.CancelTimeout(self.ticker)
            AppServices.GiftManager:TryAddGift(checkGiftId)
            MessageDispatcher:SendMessage(MessageType.PiggyBankRefresh)
        end
    end, 0, 1)
end

local FirstShowDaily = "PiggyBankFirstShowDaily"
function PiggyBankManager:PopUI(finishCallback)
    local FirstShowDailyTime = AppServices.User.Default:GetKeyValue(FirstShowDaily, 0)
    if not TimeUtil.InSameRefreshDay(FirstShowDailyTime) then
        self:TryShowUI(finishCallback)
        AppServices.User.Default:SetKeyValue(FirstShowDaily, TimeUtil.ServerTime(), true)
    else
        Runtime.InvokeCbk(finishCallback)
    end
end

function PiggyBankManager:TryShowUI(finishCallback)
    ---虽然已经在队列里了，但是引导完成的时候可能界面还打开着，例如航海订单引导，所以还是需要callwhenidle
    if PanelManager.isShowingAnyPanel() then
        Runtime.InvokeCbk(finishCallback)
        PopupManager:CallWhenIdle(function()
            PanelManager.showPanel(GlobalPanelEnum.PiggyBankPanel)
        end)
    else
        PanelManager.showPanel(GlobalPanelEnum.PiggyBankPanel, {closeCallback = function() Runtime.InvokeCbk(finishCallback) end })
    end
end

function PiggyBankManager:OnGiftClose(instance)
    if table.indexOf(checkGiftId, tonumber(instance.config.id))== nil then
        return
    end
    if self:CanOpen() then
        self:StartRequest(function(response)
            if response then
                PopupManager:CallWhenIdle(function()
                    self:TryShowUI()
                end)
            end
        end)
    end
end

function PiggyBankManager:GetCfg()
    if self._cfg and self._cfg.id == self.bankId then
        return self._cfg
    end
    self._cfg =  AppServices.Meta:Category("PiggyBankTemplate")[self.bankId]
    if not self._cfg then
        console.error("小猪银行配置为nil", self.bankId)
    end
    return self._cfg
end

function PiggyBankManager:ShowEnterIcon()
    if self._firstPopupQueue then   --弹队列前不显示，因为处理队列会判断商品信息是否拉取成功。
        return false
    end
    if self:IsOpen() then
        return true
    end
    if self:IsInCD() then
        return true
    end
    return false
end

function PiggyBankManager:IsInCD()
    self._cfg = AppServices.Meta:Category("PiggyBankTemplate")[self.bankId]
    if not self._cfg then
        return false
    end
    if self.starTime + self._cfg.eventTime * 60 <= TimeUtil.ServerTime() then
        return false
    end
    return true
end

function PiggyBankManager:IsOpen()
    self._cfg = AppServices.Meta:Category("PiggyBankTemplate")[self.bankId]
    if not self._cfg then
        return false
    end
    if self.bougth then
        return false
    end
    if self.starTime + self._cfg.eventTime * 60 <= TimeUtil.ServerTime() then
        return false
    end
    return true
end

function PiggyBankManager:CanOpen()
    if self:IsOpen() then
        return false
    end
    local piggyOpened = true   --小猪存钱罐开启过
    for _, giftId in ipairs(checkGiftId) do
        local giftCloseTime = AppServices.GiftManager:GetGiftCloseTime(giftId)
        if giftCloseTime > TimeUtil.ServerTime() then   --礼包开启中
            return false
        end
        if self.starTime == nil or self.starTime < giftCloseTime then   --比任何一个礼包关闭时间早，证明这个礼包后没开启过存钱罐
            piggyOpened = false
        end
    end
    if piggyOpened and self:CanUpdate() == false then
        return false
    end
    return true
end

function PiggyBankManager:CanUpdate()
    if not self.bougth then
        return false
    end
    self._cfg = AppServices.Meta:Category("PiggyBankTemplate")[self.bankId]
    if not self._cfg then
        return false
    end
    if self._cfg.energyNum > self.energy then
        return false
    end
    if self:IsLastID(self.bankId) then
        return false
    end
    if self.starTime + self._cfg.eventTime * 60 <= TimeUtil.ServerTime() then
        return false
    end
    return true
end

function PiggyBankManager:IsLastID(id)
    local cfg = AppServices.Meta:Category("PiggyBankTemplate")[id]
    if not cfg then
        return true
    end
    return tonumber(cfg.nextId) == 0
end

function PiggyBankManager:StartRequest(callback)
    local startBankId = "1"
    local serverTime = TimeUtil.ServerTime()
    local function onSuc(response)
        self.bankId = startBankId
        self.energy = 0
        self.starTime = serverTime
        self.bougth = false
        Runtime.InvokeCbk(callback, response)
        MessageDispatcher:SendMessage(MessageType.PiggyBankRefresh)
        self:StartTick()
    end

    local function onFail(eCode)
        ErrorHandler.ShowErrorPanel(eCode)
        Runtime.InvokeCbk(callback)
    end
    Net.Piggybankmodulemsg_27601_PiggyBankStart_Request({bankId = startBankId}, onFail, onSuc)
end

function PiggyBankManager:UpdateIdRequest(callback)
    local cfg = self:GetCfg()
    local serverTime = TimeUtil.ServerTime()
    local function onSuc(response)
        self.bankId = cfg.nextId
        self.energy = 0
        self.starTime = serverTime
        self.bougth = false
        Runtime.InvokeCbk(callback, response)
        MessageDispatcher:SendMessage(MessageType.PiggyBankRefresh)
    end

    local function onFail(eCode)
        ErrorHandler.ShowErrorPanel(eCode)
        Runtime.InvokeCbk(callback)
    end
    Net.Piggybankmodulemsg_27602_PiggyBankUpdateId_Request({}, onFail, onSuc)
end

function PiggyBankManager:CanBuy()
    if self:IsOpen() then
        local cfg = self:GetCfg()
        return cfg.energyNum <= self.energy and not self.bougth
    end
    return false
end

function PiggyBankManager:Buy(finishCallback)
    if not self:CanBuy() then
        Runtime.InvokeCbk(finishCallback, false)
        return
    end
    local cfg = self:GetCfg()
    local shopid = cfg.shopId
    local productId = AppServices.ProductManager:GetProductId(shopid)
    local function onSuc()
        self.bougth = true
        Runtime.InvokeCbk(finishCallback, true)
        local CanUpdate = self:CanUpdate()
        if CanUpdate then
            self:UpdateIdRequest()
        else
            MessageDispatcher:SendMessage(MessageType.PiggyBankRefresh)
        end
        PanelManager.closePanel(GlobalPanelEnum.PiggyBankPanel)
        AppServices.ProductManager:ShowReward(productId, function()
            if CanUpdate then
                self:TryShowUI()
            end
        end)
    end

    local function onFail(failReason)
        Runtime.InvokeCbk(finishCallback, false)
        ErrorHandler.ShowErrorMessage(Runtime.Translate("purchase.fail.text", {reason = failReason or ""}))
    end

    AppServices.ProductManager:StartPay(productId, "PiggyBank", onFail, onSuc)
end

PiggyBankManager:Init()

return PiggyBankManager
