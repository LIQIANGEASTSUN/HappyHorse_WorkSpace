---
--- Created by Betta.
--- DateTime: 2021/9/9 18:56
---
---@class GiftCD
local GiftCD = class(nil, "GiftCD")

function GiftCD:ctor()
    self.CDAry = {}
    self.processID = nil
    self.OnCDEndID = nil
    local function OnAppPause(isPause)
        if isPause then
            return
        end
        self:_ProcessCD()
    end
    self.OnAppPause = OnAppPause
    App:AddAppOnPauseCallback(self.OnAppPause)
end

function GiftCD:AddCD(CD, data, callback, cls)
    if self.processID == nil then       --在_ProcessCD中会重置self.processID
        self.processID = WaitExtension.SetTimeout(
        function ()
            self:_ProcessCD()
        end , 1)
    end
    for i, v in ipairs(self.CDAry) do
        if CD < v.CD then
            table.insert(self.CDAry, i, {CD = CD, data = data, callback = callback, cls = cls})
            return
        end
    end
    self.CDAry[#self.CDAry + 1] = {CD = CD, data = data, callback = callback, cls = cls}
end

function GiftCD:_ProcessCD()
    self.processID = nil
    if self.OnCDEndID ~= nil then
        WaitExtension.CancelTimeout(self.OnCDEndID)
        self.OnCDEndID = nil
    end
    if #self.CDAry > 0 then
        self.OnCDEndID = WaitExtension.SetTimeout(
        function()
            self:_CDEnd()
        end,
        self.CDAry[1].CD - TimeUtil.ServerTime())
    end
end

function GiftCD:_CDEnd()
    self.OnCDEndID = nil
    if #self.CDAry > 0 then
        local CDInfo = self.CDAry[1]
        table.remove(self.CDAry, 1)
        Runtime.InvokeCbk(CDInfo.callback, CDInfo.cls, CDInfo.data)
        self:_ProcessCD()
    end
end

return GiftCD
