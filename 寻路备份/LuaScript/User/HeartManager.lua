HeartManager = {
    speed = 1,              --恢复速度
    energyExtraTime = 0,    --等价默认CD(90秒)下已经消耗的时间
}

local EnergyState = {
    Recovering = 1,
    Full = 2
}

function HeartManager:Init(energyValueTime)
    self.energyValueTime = energyValueTime
    self:SyncEnergy(function()
        self:UpDate()
    end)
    self:RegisterListener()
end

function HeartManager:UpDate()
    if self.timer then
        WaitExtension.CancelTimeout(self.timer)
        self.timer = nil
    end
    self.timer =WaitExtension.InvokeRepeating(function()
        self:CheckState()
    end, 0, 1)
end

function HeartManager:CheckState()
    local hasCount = AppServices.User:GetItemAmount(ItemId.ENERGY)
    local maxCount = self:GetMaxCount()
    -- console.lh("hasCount: ", hasCount, "maxCount: ", maxCount)  --@DEL
    if hasCount >= maxCount then
        self:SwitchState(EnergyState.Full)
    else
        self:SwitchState(EnergyState.Recovering)
    end
end

function HeartManager:SwitchState(state)
    if state == EnergyState.Full then
        -- console.lh("SwitchState: Full")  --@DEL
        self:OnEnterFullState()
    elseif state == EnergyState.Recovering then
        -- console.lh("SwitchState: Recovering")  --@DEL
        self:OnEnterRecoveringState()
    end
end

function HeartManager:OnEnterFullState()
    self.energyValueTime = 0
end

function HeartManager:OnEnterRecoveringState()
    if self.energyValueTime == 0 then
        self.energyValueTime = TimeUtil.ServerTime()
    end
    local recoverTime = self:GetRecoverTime()
    local deltaTime = TimeUtil.ServerTime() - self.energyValueTime
    -- console.lh("energyValueTime:", self.energyValueTime)  --@DEL
    if self.tempRecoverTime then
        -- console.lh("tempRecoverTime:", self.tempRecoverTime)  --@DEL
    end
    -- console.lh("recoverTime:", recoverTime)  --@DEL
    -- console.lh("deltaTime:", deltaTime)  --@DEL
    if deltaTime >= recoverTime then
        self.tempRecoverTime = nil
        local hasCount = AppServices.User:GetItemAmount(ItemId.ENERGY)
        local count = math.floor(deltaTime / recoverTime)
        self.energyValueTime = self.energyValueTime + count * recoverTime
        -- console.lh("next energyValueTime:", self.energyValueTime)  --@DEL
        -- console.lh("addCount:", count) --@DEL
        local newCount = hasCount + count
        local maxCount = self:GetMaxCount()
        -- console.lh("newCount:", newCount)  --@DEL
        if newCount >= maxCount then
            self:SetValue(maxCount, maxCount - hasCount)
            self:SwitchState(EnergyState.Full)
        else
            self:SetValue(newCount, count)
        end
    end
end

function HeartManager:GetRecoverTime()
    if self.tempRecoverTime then
        -- console.lh("GetRecoverTime tempRecoverTime:", self.tempRecoverTime) --@DEL
        return self.tempRecoverTime
    end
    -- console.lh("GetRecoverTime speed:", self.speed) --@DEL
    return AppServices.Meta:GetEnergyCdTime() / self.speed
end

function HeartManager:SyncEnergy(callback)
    local function onFailed(eCode)
        ErrorHandler.ShowErrorPanel(eCode)
        Runtime.InvokeCbk(callback)
    end

    local function onSuc(result)
        if not result then
            Runtime.InvokeCbk(callback)
            return
        end
        if result.cur then
            -- console.lh("energy Request cur: ", result.cur) --@DEL
            AppServices.User:SetPropNumber(ItemId.ENERGY, result.cur)
        end
        if result.limit then
            -- console.lh("energy Request limit: ", result.limit) --@DEL
            self.maxCount = result.limit
        end
        if result.speed then
            -- console.lh("energy Request speed: ", result.speed) --@DEL
            self.speed = result.speed
        end
        if result.energyValueTime then
            self.energyValueTime = result.energyValueTime // 1000
            -- console.lh("energy Request energyValueTime: ", self.energyValueTime) --@DEL
        end
        if result.energyExtraTime then
            self.energyExtraTime = result.energyExtraTime // 1000
            -- console.lh("energy Request energyExtraTime: ", self.energyExtraTime) --@DEL
            local cfgCD = AppServices.Meta:GetEnergyCdTime() --同步后不需要考虑速度，与服务器约定使用初始配置值进行处理计算
            local delayTime = math.ceil((cfgCD - self.energyExtraTime) / self.speed)
            self.tempRecoverTime = delayTime
            -- console.lh("energy Request tempRecoverTime: ", self.tempRecoverTime) --@DEL
        end
        self:RefreshWidget()
        Runtime.InvokeCbk(callback)
    end

    Net.Coremodulemsg_1023_Energy_Request(nil, onFailed, onSuc)
end

function HeartManager:GetMaxCount()
    if not self.maxCount then
        local level = AppServices.User:GetCurrentLevelId()
        return AppServices.Meta:GetLevelConfig(level).energy or 99999
    end
    -- console.lh("GetMaxCount: ", self.maxCount) --@DEL
    return self.maxCount
end

function HeartManager:SetValue(value, addValue)
    if not App.scene then
        return
    end
    AppServices.User:SetPropNumber(ItemId.ENERGY, value, ItemGetMethod.AddEnergyByTime)
    self:RefreshWidget(addValue)
end

function HeartManager:RefreshWidget(addValue)
    local widget = App.scene:GetWidget(CONST.MAINUI.ICONS.EnergyIcon)
    if widget then
        local showValue
        if addValue then
            local cacheValue
            if widget.GetValue then
                cacheValue = widget:GetValue()
            end
            showValue = cacheValue and (cacheValue + addValue)
        end
        widget:SetValue(showValue)
    end
end

function HeartManager:GetLeftTime()
    return self:GetRecoverTime() + self.energyValueTime - TimeUtil.ServerTime()
end

function HeartManager:GetRecoverSpeed()
    return self.speed
end

---@param state number 月卡状态类型
function HeartManager:OnMonCardEvent(state)
    -- console.lh("OnMonCardEvent", state) --@DEL
    if state == MonCardState.Lock or state == MonCardState.NotPurchased then
        return
    end
    -- console.lh("----------------------------------------------------------------------------")  --@DEL
    self:SyncEnergy()
end

function HeartManager:RegisterListener()
    MessageDispatcher:AddMessageListener(MessageType.Activity_GoldPass_ReceiveReward, self.SyncEnergy, self)
    MessageDispatcher:AddMessageListener(MessageType.Activity_On_Activity_End, self.SyncEnergy, self)
    MessageDispatcher:AddMessageListener(MessageType.Global_After_Player_Levelup, self.SyncEnergy, self)
    MessageDispatcher:AddMessageListener(MessageType.MonCard_RefreshState, self.OnMonCardEvent, self)
end

function HeartManager:RemoveListener()
    MessageDispatcher:RemoveMessageListener(MessageType.Activity_GoldPass_ReceiveReward, self.SyncEnergy, self)
    MessageDispatcher:RemoveMessageListener(MessageType.Activity_On_Activity_End, self.SyncEnergy, self)
    MessageDispatcher:RemoveMessageListener(MessageType.Global_After_Player_Levelup, self.SyncEnergy, self)
    MessageDispatcher:RemoveMessageListener(MessageType.MonCard_RefreshState, self.OnMonCardEvent, self)
end
