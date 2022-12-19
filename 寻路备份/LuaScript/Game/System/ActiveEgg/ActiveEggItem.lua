---
--- Created by Betta.
--- DateTime: 2021/11/11 16:08
---
---@class ActiveEggItemState
local ActiveEggItemState =
{
    Open = 0,
    Done = 1,
    CD = 2,
    Close = 3,
}
---@class ActiveEggItemInfo
---@field eggId number
---@field type number
---@field status ActiveEggItemState
---@field cur number
---@field max number
---@field cd number

---@class ActiveEggItem
local ActiveEggItem = class(nil, "ActiveEggItem")

function ActiveEggItem:ctor(info)
    ---@type ActiveEggItemInfo
    self.info = info
    self.info.cd = self.info.cd / 1000
    self.openTime = TimeUtil.ServerTime() + self.info.cd
    self.waitID1 = nil
    self.request_open = false   --记录是否正在请求开蛋
    local function OnAppPause(isPause)
        if isPause then
            return
        end
        if self.info.status == ActiveEggItemState.CD then
            self:_WaitCD()
        end
    end
    self.OnAppPause = OnAppPause
    App:AddAppOnPauseCallback(self.OnAppPause)
    if self.info.status == ActiveEggItemState.CD then
        self:_WaitCD()
    end
end

function ActiveEggItem:_WaitCD()
    if self.waitID1 ~= nil then
        WaitExtension.CancelTimeout(self.waitID1)
        self.waitID1 = nil
    end
    self.waitID1 = WaitExtension.SetTimeout(function()
        self.waitID1 = nil
        self.info.status = ActiveEggItemState.Done
        AppServices.ActiveEggManager:_OnCDEnd(self.info.eggId)
    end,
    self.openTime - TimeUtil.ServerTime())
end

function ActiveEggItem:CanOpen()
    return self.info.status == ActiveEggItemState.Open
end

function ActiveEggItem:CanSkipCD()
    return self.info.status == ActiveEggItemState.CD
end

function ActiveEggItem:CanColActive()
    return self.info.status == ActiveEggItemState.Done and self.info.cur < self.info.max
end

function ActiveEggItem:IsClose()
    return self.info.status == ActiveEggItemState.Close
end

function ActiveEggItem:CollectActive(activeCount)
    if activeCount <= 0 then
        return
    end
    if self.info.cur >= self.info.max then
        return activeCount
    end
    self.info.cur = self.info.cur + activeCount
    local ret = self.info.cur - self.info.max
    self.info.cur = math.min(self.info.max, self.info.cur)
    return ret
end

function ActiveEggItem:SetOpen()
    --self.info.status = ActiveEggItemState.Open
end

function ActiveEggItem:SetWaitCD()
     local configTemplate = AppServices.Meta.metas.ConfigTemplate
    self.info.status = ActiveEggItemState.CD
    self.info.cd = tonumber(configTemplate["activeEggCD"].value)
    self.openTime = TimeUtil.ServerTime() + self.info.cd
    self:_WaitCD()
end

function ActiveEggItem:Release()
    App:RemoveAppOnPauseCallback(self.OnAppPause)
    if self.waitID1 ~= nil then
        WaitExtension.CancelTimeout(self.waitID1)
        self.waitID1 = nil
    end
end

return ActiveEggItem
