---@class UserCoinLogic
local UserCoinLogic = {
    count = 0, --AppServices.User:GetItemAmount(ItemId.COIN)
    exCount = 0,
    isExit = true,
    isStart = false,
}

---@param coinItem CoinItem
function UserCoinLogic:BindView(coinItem)
    self.coinItem = coinItem
    if self.coinItem then
        self.coinItem:SetCoinNumber(AppServices.User:GetItemAmount(ItemId.COIN))
    end
end
function UserCoinLogic:GetView(eVal)
    if type(self.coinItem.GetView) == "function" then
        return self.coinItem:GetView(eVal)
    end
    return self.coinItem
end

function UserCoinLogic:SetCoin(value)
    AppServices.User:SetCoin(value)
    self:RefreshCoinNumber()
end

function UserCoinLogic:AddCoin(count,needRefresh)
    AppServices.User:AddCoin(count)
    if needRefresh then
        self:RefreshCoinNumber() -- 在这刷新下
    end
end

function UserCoinLogic:UseCoin(count)
    self:SetCoin(AppServices.User:GetItemAmount(ItemId.COIN) - count)
end

function UserCoinLogic:UnbindView()
    self.coinItem = nil
end

function UserCoinLogic:RefreshCoinNumber(isExPlay)
    local coinNumber = AppServices.User:GetItemAmount(ItemId.COIN)
    if coinNumber == self.count then
        return
    end
    if self.coinItem then
        self.coinItem:SetCoinNumber(AppServices.User:GetItemAmount(ItemId.COIN))
        -- if self.count > coinNumber then
        --     App.audioManager:PlayEffectAudio(CONST.AUDIO.Interface_PayCoin)
        -- elseif self.count < coinNumber then
        --     App.audioManager:PlayEffectAudio(CONST.AUDIO.Interface_GetCoin)
        -- end

        if isExPlay then
           self.coinItem.autoHideAfterExitOnce = true
        end
    end

    self.count = coinNumber
end

function UserCoinLogic:SetExCount(count,cb)
    if count <= 0 then
        return
    end
    self.exCount = self.exCount + count

    self:StartShowExAnim(cb)
    self.delay = 0
end

function UserCoinLogic:StartShowExAnim(cb)
    -- body
    local frequen = 0.2
    local function onTick()
        self.delay = self.delay + frequen
        self.coinItem:SetExValue(self.exCount)
        if self.delay > 1.4 then
            if self.timerId then
                WaitExtension.CancelTimeout(self.timerId)
            end

            self.timerId = nil
            self.isEndPlayAnim = false
            self.delay = 0
            self:RefreshCoinNumber(true)

            self.exitTime = WaitExtension.SetTimeout(function()
                if self.isStart then
                    self.isExit = true
                    self.coinItem:ShowExitAnim()
                    Runtime.InvokeCbk(cb)
                end
            end, 0.5)

        elseif self.delay > 1 then
            if not self.isEndPlayAnim then
                self.exCount = 0
                self.coinItem:PlayExAnim(false)
                self.isEndPlayAnim = true
            end
        end
    end
    self.coinItem:SetExValue(self.exCount)
    if not self.timerId or self.isEndPlayAnim then
        self.coinItem.gameObject:SetActive(true)
        if self.isExit then
            self.coinItem:ShowEnterAnim()
            self.isStart = true
        end
        self.coinItem:PlayExAnim(true)
        self.isEndPlayAnim = false
        if self.exitTime then
            WaitExtension.CancelTimeout(self.exitTime)
        end
    end
    if not self.timerId then
       self.timerId = WaitExtension.InvokeRepeating(onTick, 0, frequen)
    end
end

function UserCoinLogic:AddViewNumber(number)
    self.count = self.count + number
    if self.coinItem then
        self.coinItem:SetCoinNumber(self.count)
    end
    -- if number < 0 then
    --     App.audioManager:PlayEffectAudio(CONST.AUDIO.Interface_PayCoin)
    -- else
    --     App.audioManager:PlayEffectAudio(CONST.AUDIO.Interface_GetCoin)
    -- end
end

function UserCoinLogic:GetExValue()
    return self.exCount
end

return UserCoinLogic