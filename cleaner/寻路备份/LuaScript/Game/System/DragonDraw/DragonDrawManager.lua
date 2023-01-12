---
--- Created by Betta.
--- DateTime: 2022/5/9 11:46
---
---@class DragonDrawManager  抽卡管理器
local DragonDrawManager = class(nil, "DragonDrawManager")
DragonDrawManager.OpenNewDragonDraw = "OpenNewDragonDraw"

function DragonDrawManager:ctor()
    self._DragonDrawInfo_Request = false
    self.times = 0
    self.noMustItemTimes = 0
    self._onePrice = 0
    self.tenPrice = 0
    self.startTimeId = nil
    self.endTimeId = nil
    self.meta = AppServices.Meta:Category("DragonDrawTemplate")
    local dragonDrawBPPrice = table.deserialize(AppServices.Meta:GetConfigMetaValue("dragonDrawBPPrice"))
    self.BPCurrencyId = tostring(dragonDrawBPPrice[1])
    self.BPPrice = dragonDrawBPPrice[2]
    --[[local getData = function(sec)
        local dateTable = os.date("*t", sec)
        local str = string.format("%s-%s-%s %s:%s:%s", dateTable.year, dateTable.month, dateTable.day, dateTable.hour, dateTable.min, dateTable.sec)
        console.error(str)
        return str
    end
    self.meta = {
        {id = 1, startTime ="2022-5-6 19:00:00", endTime =  getData(TimeUtil.ServerTime() - 20), drawDrop = {{1001,40},{1001,380},4001},mustReward ={30008,5}, dragonId = 141031},
        {id = 1, startTime =getData(TimeUtil.ServerTime() + 20), endTime = getData(TimeUtil.ServerTime() + 2000), drawDrop = {{1001,40},{1001,380},4001},mustReward ={30008,5}, dragonId = 141502},
    }--]]
    if self:IsUnlock() then
        self:InitCfg()
        self:OnInitActivity()
    else
        MessageDispatcher:AddMessageListener(MessageType.Global_OnUnlock, self.OnUnlock, self)
    end
end

function DragonDrawManager:IsUnlock()
    return AppServices.Unlock:IsUnlock("dragondraw")
end

function DragonDrawManager:IsValid()
    return self._DragonDrawInfo_Request
end

function DragonDrawManager:OnUnlock(key)
    if key == "dragondraw" then
        self:InitCfg()
        self:OnInitActivity()
    end
end

function DragonDrawManager:OnCheckEntrance()
    if App.scene:GetCurrentSceneId() ~= "city" then
        return
    end
end

function DragonDrawManager:InitCfg()
    self.cfg = nil
    local time = TimeUtil.ServerTime()
    local minTime
    local mincfg
    for id, cfg in pairs(self.meta) do
        local endTime = tonumber(cfg.endTime) or 0
        local startTime = tonumber(cfg.startTime) or 0
        if endTime > time then --还没超过结束
            local startTimeDiff = startTime - time
            if startTimeDiff > 0 then   --还没开始
                if not minTime then
                    minTime = startTimeDiff
                    mincfg = cfg
                elseif startTimeDiff < minTime then
                    minTime = startTimeDiff
                    mincfg = cfg
                end
            else
                self.cfg = cfg
                break
            end
        end
    end
    if self.cfg ~= nil then
        self:TickEndTime(self.cfg)
        self.drawConfig = self.cfg.drawDrop
        self.oneCurrencyId = tostring(self.drawConfig[1][1])
        self._onePrice = self.drawConfig[1][2]
        self.tenCurrencyId = tostring(self.drawConfig[2][1])
        self.tenPrice = self.drawConfig[2][2]
        self.upItemId = self.cfg.mustReward[1]
        self.mustCount = self.cfg.mustReward[2]
        self.mustDrawCount = self.cfg.mustReward[3]
        self.upDragon = self.cfg.dragonId
        self.dropId = self.drawConfig[3]
    elseif mincfg ~= nil then
        self:TickStartTime(mincfg)
    end
    if self.cfg == nil then
        self.drawConfig = table.deserialize(AppServices.Meta:GetConfigMetaValue("activityForecastDrop"))
        self.oneCurrencyId = tostring(self.drawConfig[1][1])
        self._onePrice = self.drawConfig[1][2]
        self.tenCurrencyId = tostring(self.drawConfig[2][1])
        self.tenPrice = self.drawConfig[2][2]
        self.dropId = self.drawConfig[3]
    end
end

function DragonDrawManager:GetTime()
    if self.cfg ~= nil then
        return tonumber(self.cfg.endTime)
    end
    return 0
end

function DragonDrawManager:TickStartTime(nextUpCfg)
    if self.startTimeId ~= nil then
        WaitExtension.CancelTimeout(self.startTimeId)
        self.startTimeId = nil
    end
    local startTime = tonumber(nextUpCfg.startTime)
    self.startTimeId = WaitExtension.InvokeRepeating(function()
        if TimeUtil.ServerTime() >= startTime then
            WaitExtension.CancelTimeout(self.startTimeId)
            self.startTimeId = nil
            self:OpenUpDraw(nextUpCfg)
        end
    end, 0, 1)
end

function DragonDrawManager:TickEndTime(upCfg)
    if self.endTimeId ~= nil then
        WaitExtension.CancelTimeout(self.endTimeId)
        self.endTimeId = nil
    end
    local endTime = tonumber(upCfg.endTime)
    self.endTimeId = WaitExtension.InvokeRepeating(function()
        if TimeUtil.ServerTime() >= endTime then
            WaitExtension.CancelTimeout(self.endTimeId)
            self.endTimeId = nil
            self:CloseUpDraw()
        end
    end, 0, 1)
end

function DragonDrawManager:OpenUpDraw(upCfg)
    self:InitCfg()
    if self.cfg ~= nil then
        MessageDispatcher:SendMessage(MessageType.DragonDrawUpChange)
    end
end

function DragonDrawManager:CloseUpDraw()
    local cfg = self.cfg
    self:InitCfg()
    if self.cfg ~= cfg then
        MessageDispatcher:SendMessage(MessageType.DragonDrawUpChange)
    end
end

function DragonDrawManager:IsUpDraw()
    return self.cfg ~= nil
end

---初始化数据
function DragonDrawManager:OnInitActivity(finishCallback)
    local function onSuc(response)
        self._DragonDrawInfo_Request = true
        if response then
            self.times = response.times
            self.noMustItemTimes = response.noMustItemTimes
        end
        Runtime.InvokeCbk(finishCallback, response)
        if not App.mapGuideManager:HasComplete(GuideConfigName.GuideDragonDraw) then
            PopupManager:CallWhenIdle(function()
                App.mapGuideManager:StartSeries(GuideConfigName.GuideDragonDraw)
            end)
        end
    end

    local function onFail(eCode)
        ErrorHandler.ShowErrorPanel(eCode)
        Runtime.InvokeCbk(finishCallback)
    end
    Net.Dragondrawmodulemsg_27401_DragonDrawInfo_Request({}, onFail, onSuc)
end

function DragonDrawManager:Drag(isTen, callback)
    local currencyid
    local price
    local count
    local goldpass = false
    if isTen then
        goldpass = ActivityServices.GoldPass:IsDataNotEmpty() and ActivityServices.GoldPass:IsUnlockPass()
        if goldpass then
            currencyid = self.BPCurrencyId
            price = self.BPPrice
        else
            currencyid = self.tenCurrencyId
            price = self.tenPrice
        end
        count = 10
    else
        currencyid = self.oneCurrencyId
        price = self:GetOnePrice()
        count = 1
    end
    local needCount = AppServices.User:GetItemAmount(currencyid)
    if needCount < price and currencyid == ItemId.DIAMOND then
        require("Game.Processors.RequestIAPProcessor").Start(
        function()
            Runtime.InvokeCbk(callback)
            PanelManager.closePanel(GlobalPanelEnum.DragonDrawPanel)
            PanelManager.showPanel(GlobalPanelEnum.MoneyShopPanel, {source = "DragonAssistPanel"})
        end,
        function()
            Runtime.InvokeCbk(callback)
        end
        )
        return
    end
    local function onSuc(response)
        self.times = self.times + count
        AppServices.User:UseItem(currencyid, price, ItemUseMethod.DragonDraw)
        if response then
            self.noMustItemTimes = response.noMustItemTimes
            for _, item in ipairs(response.items) do
                local itemId = item.itemTemplateId
                local amount = item.count
                if itemId == ItemId.EXP then
                    AppServices.User:AddExp(amount, ItemGetMethod.DragonDraw)
                elseif ItemId.IsDragon(itemId) then
                    AppServices.MagicalCreatures:AddDragonByItem(itemId,nil, nil, nil, 2)
                else
                    AppServices.User:AddItem(itemId, amount, ItemGetMethod.DragonDraw)
                end
            end
            if count == 10 then
                MessageDispatcher:SendMessage(MessageType.DragonDrawTenTimes)
            end
        end
        Runtime.InvokeCbk(callback, response)
    end

    local function onFail(eCode)
        ErrorHandler.ShowErrorPanel(eCode)
        Runtime.InvokeCbk(callback)
    end
    local params = {count = count}
    if self.cfg ~= nil then
        params.drawId = self.cfg.id
    end
    if isTen then
        params.goldpass = goldpass
    end
    Net.Dragondrawmodulemsg_27402_DragonDraw_Request(params, onFail, onSuc)
end

function DragonDrawManager:OpenUI()
    if self:IsValid() then
        PanelManager.showPanel(GlobalPanelEnum.DragonDrawPanel)
    end
end

function DragonDrawManager:GetOnePrice()
    if self.times == 0 then
        return 0
    end
    return self._onePrice
end

function DragonDrawManager:IsActivityAvailable()
    if not self.cfg then
        return
    end
    local startTime = tonumber(self.cfg.startTime)
    local endTime = tonumber(self.cfg.endTime)
    local curTime = TimeUtil.ServerTime()
    return startTime <= curTime and curTime <= endTime
end

---抽龙不是抽龙基因
function DragonDrawManager:IsDragDragon()
    if not self.cfg then
        return true
    end
    return self.cfg.activityUI ~= 1
end

return DragonDrawManager.new()