---
--- Created by Betta.
--- DateTime: 2021/9/8 16:43
---
---@class GiftTemplate
---@field id string
---@field group number
---@field priority number
---@field CD number
---@field showTime number
---@field level number
---@field publicCD number
---@field popUpTimes number
---@field popUpCD number

---@class GiftServerInfo
---@field id string
---@field triggerTime number
---@field lastBoughtTime number

local fileName = "gift.dat"

local GiftCD = require("Game.System.Gift.GiftCD")
local develop = false

---@class GiftManager
local GiftManager = {}

function GiftManager:Init()
    ---@type table<number, GiftTemplate>
    self.giftConfigs = AppServices.Meta:Category("GiftTemplate")
    ---@type table<number, GiftInstanceBase>
    self.giftIntanceConfigs = {}
    self.autoOpenEventCfg = {}
    self.groupCD = {}
    ---@type table<number, GiftInstanceBase> @key is group
    self.giftInstance = {}
    --self.openCDAry = {}
    ---@type table<number, GiftServerInfo> @key is id
    self.serverInfo = {}
    ---@type GiftCD
    self.cd = GiftCD.new()
    ---@type table<number, number> @key is id
    self.popUpTimeDic = {}
    self._getGiftInfoRequest = false
    self._onPopupQueueWait = nil
    self._firstPopupQueue = true
    self._firstChangeScene = true
    self._userItemAddGiftID = nil
    self._requestGiftIDSet = {}
    self._isNewScene = false

    if develop then
        return
    end
    MessageDispatcher:AddMessageListener(MessageType.Global_After_Scene_Loaded, self.OnChangeScene, self)
    MessageDispatcher:AddMessageListener(MessageType.EnergyDiscountBuffEnd, self.OnEnergyDiscountBuffEnd, self)
end

function GiftManager:OnChangeScene(sceneId)
    if self._firstChangeScene then
        self._firstChangeScene = false
        self:_OnLoginAddGift()
    end
    self:OnCheckOpenActivityTask(sceneId)
end

function GiftManager:OnCheckOpenActivityTask(sceneId)
    if sceneId ~=  App.scene:GetCurrentSceneId() then
        return
    end
    self._isNewScene = false
    local taskMgr = AppServices.Task
    local sceneCfg = AppServices.Meta:GetSceneCfg(sceneId)
    local tasks
    if sceneCfg and (sceneCfg.type == SceneType.Activity or sceneCfg.type == SceneType.LevelMapActivity) then
        tasks = taskMgr:GetActivitySceneTasks(sceneId)
    else
        tasks = taskMgr:GetSceneTasks(sceneId)
    end
    --console.error(sceneId .. "tasks is nil ", tasks == nil)
    if tasks then
        self._isNewScene = true
        --console.error("tasks count ", #tasks)
        for _, taskId in ipairs(tasks) do
            if taskMgr:IsTaskFinish(taskId) then
                self._isNewScene = false
                break
            end
        end
    end
    --console.error("isnewScene,", self._isNewScene)
    if self._isNewScene then
        self:_OnEnterNewSceneAddGift()
    end
end

function GiftManager:OnEnergyDiscountBuffEnd()
    self:TryAddGift({440})
end

function GiftManager:GiftInfoRequest()
    local onFail = function(errorCode)
        console.dk("礼包开启失败，服务器获取出事数据失败") --@DEL
    end
    local onSucess = function(response)
        if develop then
            return
        end
        self._getGiftInfoRequest = true
        self:InitServerdata(response.giftInfos)
        self:InitAutoOpenEvent()
        self:ReadDataFromLocal()
        MessageDispatcher:AddMessageListener(MessageType.Global_After_Player_Levelup, self._OnLevelChangeAddGift, self)
        MessageDispatcher:AddMessageListener(MessageType.Global_After_UseItem, self._OnUseItemAddGift, self)
        if self._onPopupQueueWait ~= nil then
            self._onPopupQueueWait()
        end

    end
    --if RuntimeContext.IAP_ENABLE then
        Net.Giftmodulemsg_25801_GiftInfo_Request({}, onFail, onSucess)
    --end
    --[[
    require("Game.Processors.RequestIAPProcessor").Start(function()
        Net.Giftmodulemsg_25801_GiftInfo_Request({}, onFail, onSucess)
    end,
    function()
        console.dk("礼包开启失败，支付功能请求失败") --@DEL
    end)
    ]]
end

function GiftManager:InitAutoOpenEvent()
    for k, v in pairs(self.giftConfigs) do
        local instance = require("Game.System.Gift.GiftInstance.GiftInstance_" .. v.id).new(v)
        local openTimeAry = instance:AutoOpenEvent()
        for _, openTime in ipairs(openTimeAry) do
            if self.autoOpenEventCfg[openTime] == nil then
                self.autoOpenEventCfg[openTime] = {}
            end
            self.autoOpenEventCfg[openTime][k] = v
        end
        self.giftIntanceConfigs[k] = instance
    end
end

function GiftManager:InitServerdata(giftInfos)
    ---@param v GiftServerInfo
    for _, v in ipairs(giftInfos) do
        local config = self.giftConfigs[v.id]
        if config ~= nil then
            self.serverInfo[v.id] = v
            v.triggerTime = v.triggerTime / 1000
            v.lastBoughtTime = v.lastBoughtTime / 1000
            local closeTime = self:GetGiftCloseTime(v.id)
            if closeTime > TimeUtil.ServerTime() then       --礼包还打开着
                ---@type GiftInstanceBase
                local instance = require("Game.System.Gift.GiftInstance.GiftInstance_" .. v.id).new(config)
                self.giftInstance[instance.config.group] = instance
                self:AddShowCD(v.triggerTime + instance.config.showTime * 3600, instance)
                instance:Open()
            else
                if config.CD > 0 and closeTime + config.CD * 3600 > TimeUtil.ServerTime() then
                    self:AddCD(closeTime + config.CD * 3600, config.id)
                end
                if closeTime + config.publicCD * 3600 > TimeUtil.ServerTime() then
                    self.groupCD[config.group] = closeTime + config.publicCD * 3600
                    self:AddGroupCD(closeTime + config.publicCD * 3600, config.group)
                end
            end

        end
    end
    --self:_OnLoginAddGift()
    --self:_OnLoginShowGift()
end
---@param giftConfig GiftTemplate
function GiftManager:Check(giftConfig)
    if giftConfig == nil then
        console.dk("giftConfig is nil") --@DEL
        return false
    end
    ---等级是否满足
    if AppServices.User:GetCurrentLevelId() < giftConfig.level then
        console.dk("礼包等级未达到 id:" .. giftConfig.id) --@DEL
        return false
    end
    ---检查打开次数是否超上限
    if self.serverInfo[giftConfig.id] and giftConfig.CD < 0 then
        console.dk("礼包打开次数超上限 id:" .. giftConfig.id) --@DEL
        return false
    end
    ---检查是否在关闭cd中
    if self.serverInfo[giftConfig.id] and giftConfig.CD > 0 then
        local closeTime = self:GetGiftCloseTime(giftConfig.id)
        if TimeUtil.ServerTime() - closeTime < giftConfig.CD * 3600  then
            console.dk(string.format("礼包在关闭cd中, id:%s", giftConfig.id)) --@DEL
            return false
        end
    end
    ---检查是否有打开的同类型
    if self.giftInstance[giftConfig.group] then
        console.dk(string.format("礼包有打开的同类型, id:%s, openID:%s", giftConfig.id, self.giftInstance[giftConfig.group].config.id)) --@DEL
        return false
    end
    ---检查是否有同类型在公共cd中
    if self.groupCD[giftConfig.group] then
        console.dk(string.format("礼包在同类型在公共cd中, id:%s", giftConfig.id)) --@DEL
        return false
    end
    return true
end

function GiftManager:HaveOpenInfo(giftID)
    giftID = tostring(giftID)
    return self.serverInfo[giftID] ~= nil
end

function GiftManager:GetGiftCloseTime(giftID)
    giftID = tostring(giftID)
    if self.serverInfo[giftID] == nil then
        console.dk("serverInfo not contain id:", giftID) --@DEL
        return 0
    end
    if self.giftConfigs[giftID] == nil then
        console.dk("giftConfigs not contain id:", giftID) --@DEL
        return 0
    end
    local info = self.serverInfo[giftID]
    local closeTime = info.lastBoughtTime
    if info.lastBoughtTime < info.triggerTime then
        local giftConfig = self.giftConfigs[giftID]
        closeTime = info.triggerTime + giftConfig.showTime * 3600
    end
    return closeTime
end

---@param isLast number  是否购买的最后一次
function GiftManager:IsBoughtGift(giftID, isLast)
    if isLast == nil then
        isLast = true
    end
    giftID = tostring(giftID)
    if self.serverInfo[giftID] == nil then
        return false
    end
    if isLast then
        return self.serverInfo[giftID].lastBoughtTime > self.serverInfo[giftID].triggerTime
    else
        return self.serverInfo[giftID].lastBoughtTime > 0   --买过，不是最后一次买的
    end
end

function GiftManager:IsTriggerGift(giftID)
    giftID = tostring(giftID)
    if self.serverInfo[giftID] == nil then
        return false
    end
    return true
end
---@param instance GiftInstanceBase
function GiftManager:RecordBuyGift(instance)
    if instance == nil then
        return
    end
    if self.serverInfo[instance.config.id] ~= nil then
        self.serverInfo[instance.config.id].lastBoughtTime = TimeUtil.ServerTime()
    end
    self:_OnGiftClose(instance)
end
function GiftManager:ShowLog(giftId, method)
    DcDelegates:Log(SDK_EVENT.gift_show, {
        giftId = giftId,
        energyCount = AppServices.User:GetItemAmount(ItemId.ENERGY),
        diamondCount = AppServices.User:GetItemAmount(ItemId.DIAMOND),
        goldCount  = AppServices.User:GetItemAmount(ItemId.COIN),
        method = method
    })
end
function GiftManager:_AddGift(giftConfigs)
    if giftConfigs == nil then
        return
    end
    ---@type table<number, GiftInstanceBase>
    local openInstance = {}
    for k, v in pairs(giftConfigs) do
        if self:Check(v) then
            ---@type GiftInstanceBase
            local instance = openInstance[v.group]
            if instance == nil or v.priority > instance.config.priority then
                instance = self.giftIntanceConfigs[k]
                if instance:Check() then
                    instance = require("Game.System.Gift.GiftInstance.GiftInstance_" .. v.id).new(v)
                    openInstance[v.group] = instance
                end
            end
        end
    end
    for k, v in pairs(openInstance) do
        self:_AddInstance(v)
    end
end

function GiftManager:_AddGiftByGroup(giftConfigs, giftGroup)
    if giftConfigs == nil then
        return
    end
    ---@type GiftInstanceBase
    local openInstance = nil
    for k, v in pairs(giftConfigs) do
        if v.group == giftGroup and self:Check(v) then
            if openInstance == nil or v.priority > openInstance.config.priority then
                local instance = self.giftIntanceConfigs[k]
                if instance:Check() then
                    instance = require("Game.System.Gift.GiftInstance.GiftInstance_" .. v.id).new(v)
                    openInstance = instance
                end
            end
        end
    end
    if openInstance ~= nil then
        self:_AddInstance(openInstance)
    end
end

function GiftManager:_AddGiftByID(giftConfigs, giftID, isManula)
    if giftConfigs == nil then
        return
    end
    local config = giftConfigs[giftID]
    if self:Check(config) then
        local instance = self.giftIntanceConfigs[giftID]
        if instance:Check() then
            instance = require("Game.System.Gift.GiftInstance.GiftInstance_" .. giftID).new(config)
            self:_AddInstance(instance)
        end
    end
end

---begin 开启礼包的时机
---升级触发
function GiftManager:_OnLevelChangeAddGift()
    self:_AddGift(self.autoOpenEventCfg[GIFT_OPEN_TIME.OnLevelUp])
end
function GiftManager:_OnUseItemAddGift()
    if self._userItemAddGiftID ~= nil then
        return
    end
    self._userItemAddGiftID = WaitExtension.SetTimeout(function()
        self._userItemAddGiftID = nil
        self:_AddGift(self.autoOpenEventCfg[GIFT_OPEN_TIME.OnUseItem])
    end, 1)
end
---礼包结束触发
function GiftManager:_OnGiftCloseAddGift()
    self:_AddGift(self.autoOpenEventCfg[GIFT_OPEN_TIME.OnGiftClose])
end

---外部按钮触发
function GiftManager:TryAddGift(giftIDArray)
    if develop then
        return
    end
    local openInstance = {}
    for _, giftID in ipairs(giftIDArray) do
        giftID = tostring(giftID)
        local config = self.giftConfigs[giftID]
        if self:Check(config) then
            ---@type GiftInstanceBase
            local instance = openInstance[config.group]
            if instance == nil or config.priority > instance.config.priority then
                instance = self.giftIntanceConfigs[giftID]
                if instance:Check() then
                    instance = require("Game.System.Gift.GiftInstance.GiftInstance_" .. giftID).new(config)
                    openInstance[config.group] = instance
                end
            end
        end
    end
    for k, v in pairs(openInstance) do
        self:_AddInstance(v)
    end
end

function GiftManager:_OnLoginAddGift()
    if self._getGiftInfoRequest then
        self:_AddGift(self.autoOpenEventCfg[GIFT_OPEN_TIME.OnLogin])
    end
end

function GiftManager:_OnEnterNewSceneAddGift()
    --console.error("_OnEnterNewSceneAddGift")
    --self:TryAddGift({24})
    self:_AddGift(self.autoOpenEventCfg[GIFT_OPEN_TIME.OnChangeNewScene])
end

---倒计时开启
function GiftManager:_OnOpenCDEndAddGift(giftID)
    self:_AddGiftByID(self.giftConfigs, giftID, false)
end
---公共CD倒计时开启
function GiftManager:_OnGroupCDEndAddGift(giftGroup)
    self.groupCD[giftGroup] = nil
    self:_AddGiftByGroup(self.autoOpenEventCfg[GIFT_OPEN_TIME.OnGroupCDEnd], giftGroup)
end
---
function GiftManager:_OnSelfCDEndAddGift(giftID)
    self:_AddGiftByID(self.autoOpenEventCfg[GIFT_OPEN_TIME.OnSelfCDEnd], giftID, false)
end
---end
---begin 显示礼包界面时机
---切换到家园场景
function GiftManager:_OnLoginShowGift(finishCallback)
    self:_TryShowGift(1, finishCallback)
end

function GiftManager:_OnEnterHomeShowGift(finishCallback)
    self:_TryShowGift(2, finishCallback)
end
---end
function GiftManager:OnPopupQueue(finishCallback)
    local function DoPopupQueue()
        self._onPopupQueueWait = nil
        if self._isNewScene then
            self:_OnEnterNewSceneAddGift()
        end
        if self._firstPopupQueue then
            self._firstPopupQueue = false
            self:_OnLoginShowGift(finishCallback)
            self:_OnLoginAddGift()
        elseif App.scene:GetCurrentSceneId() == "city" then
            self:_OnEnterHomeShowGift(finishCallback)
        else
            Runtime.InvokeCbk(finishCallback)
        end
    end

    if self._getGiftInfoRequest == false then
        self._onPopupQueueWait = DoPopupQueue
    else
        DoPopupQueue()
    end
end
---指定的礼包自动弹窗触发
function GiftManager:TryShowGift(giftIDArray, finishCallback)
    if giftIDArray == nil then
        return
    end
    for index, id in ipairs(giftIDArray) do
        giftIDArray[index] = tostring(id)
    end
    ---@type GiftInstanceBase[]
    local showGiftAry = {}
    for _, instance in pairs(self.giftInstance) do
        if table.indexOf(giftIDArray, instance.config.id) ~= nil and instance:CheckPopUP() then--and  instance:CheckPopUP() then
            if GlobalPanelEnum[instance:GetPanelName()] ~= nil then
                showGiftAry[#showGiftAry + 1] = instance
            end
        end
    end
    local showGiftIndex = 1
    local showGiftFunc = nil
    showGiftFunc = function()
        if showGiftIndex <= #showGiftAry then
            local instance = showGiftAry[showGiftIndex]
            --closeInstance = instance
            showGiftIndex = showGiftIndex + 1

            self:_OpenUI(instance, 2, showGiftFunc)
        else
            Runtime.InvokeCbk(finishCallback)
        end
    end
    showGiftFunc()
end
---固定的自动弹窗触发
function GiftManager:_TryShowGift(popFlag, finishCallback)
    ---虽然已经在队列里了，但是引导完成的时候可能界面还打开着，例如航海订单引导，所以还是需要callwhenidle
    if PanelManager.isShowingAnyPanel() then
        Runtime.InvokeCbk(finishCallback)
        PopupManager:CallWhenIdle(function()
            self:_ShowGift(popFlag, nil)
        end)
    else
        self:_ShowGift(popFlag, finishCallback)
    end
end
---轮播图会弹窗，切场景和进游戏的固定弹窗都取消。
function GiftManager:_ShowGift(popFlag, finishCallback)
    ---@type GiftInstanceBase[]
    local showGiftAry = {}
    for _, instance in pairs(self.giftInstance) do
        if table.indexOf(instance:GetPopFlag(), popFlag) ~= nil and  instance:CheckPopUP() and GiftFrameType["Gift" .. instance.config.id] == nil then
            if GlobalPanelEnum[instance:GetPanelName()] ~= nil then
                showGiftAry[#showGiftAry + 1] = instance
            end
        end
    end
    local showGiftIndex = 1
    local showGiftFunc = nil
    showGiftFunc = function()
        if showGiftIndex <= #showGiftAry then
            local instance = showGiftAry[showGiftIndex]
            --closeInstance = instance
            showGiftIndex = showGiftIndex + 1

            self:_OpenUI(instance, 2, showGiftFunc)
        else
            Runtime.InvokeCbk(finishCallback)
        end
    end
    showGiftFunc()
end

function GiftManager:PopCheck()
    local check = function(popFlag)
        for _, instance in pairs(self.giftInstance) do
            if table.indexOf(instance:GetPopFlag(), popFlag) ~= nil and  instance:CheckPopUP() and GiftFrameType["Gift" .. instance.config.id] == nil then
                if GlobalPanelEnum[instance:GetPanelName()] ~= nil then
                    return true
                end
            end
        end
    end
    if PanelManager.isShowingAnyPanel() then
        PopupManager:CallWhenIdle(function()
            self:_ShowGift(popFlag, nil)
        end)
        return false
    else
        if self._firstPopupQueue then
            return check(1)
        elseif App.scene:GetCurrentSceneId() == "city" then
            return check(2)
        else
            return false
        end
    end
end

function GiftManager:PopDo(finishCallback)
    if self._firstPopupQueue then
        self._firstPopupQueue = false
        self:_OnLoginShowGift(finishCallback)
    elseif App.scene:GetCurrentSceneId() == "city" then
        self:_OnEnterHomeShowGift(finishCallback)
    else
        Runtime.InvokeCbk(finishCallback)
    end
end

function GiftManager:_OpenUI(instance, method, showGiftFunc)
    if instance == nil then
        return
    end
    if instance.shopType == CurrencyType.Money then
        if AppServices.ProductManager:CheckFetch() then
            instance:CountPopUp()
            if GiftFrameType["Gift" .. instance.config.id] then
                PanelManager.showPanel(GlobalPanelEnum.GiftFramePanel, {source = "Gift",index = GiftFrameType["Gift" .. instance.config.id]})
            else
                PanelManager.showPanel(GlobalPanelEnum[instance:GetPanelName()], {instance = instance, showNextGiftFunc = showGiftFunc})
            end
            self:ShowLog(instance.config.id, method)
        else
            return Runtime.InvokeCbk(showGiftFunc)
        end
    else
        instance:CountPopUp()
        if GiftFrameType["Gift" .. instance.config.id] then
            PanelManager.showPanel(GlobalPanelEnum.GiftFramePanel, {source = "Gift",index = GiftFrameType["Gift" .. instance.config.id]})
        else
            PanelManager.showPanel(GlobalPanelEnum[instance:GetPanelName()], {instance = instance, showNextGiftFunc = showGiftFunc})
        end
        self:ShowLog(instance.config.id, method)
    end
end
---@param instance GiftInstanceBase
function GiftManager:_AddInstance(instance)
    if instance == nil then
        console.dk("请求礼包失败,instance == nil") --@DEL
        return
    end
    if self._requestGiftIDSet[instance.config.group] then
        console.dk("请求礼包失败,正在请求:"..instance.config.id .. "/"..self._requestGiftIDSet[instance.config.group].config.id) --@DEL
        return
    end
    if instance:GetOpenTime() > TimeUtil.ServerTime() then
        console.dk(string.format("请求礼包失败,延迟开启 openTime:%s, sTime:%s",instance:GetOpenTime(), TimeUtil.ServerTime()) ) --@DEL
        self:AddOpenCD(instance:GetOpenTime(), instance.config.id)
        return
    end

    self._requestGiftIDSet[instance.config.group] = instance
    local onFail = function(errorCode)
        self._requestGiftIDSet[instance.config.group] = nil
        console.dk("请求礼包失败" .. errorCode) --@DEL
        ErrorHandler.ShowErrorPanel(errorCode)
    end
    local onSucess = function(endresponse)
        self._requestGiftIDSet[instance.config.group] = nil
        self.serverInfo[instance.config.id] = {id = instance.config.id, triggerTime = TimeUtil.ServerTime(), lastBoughtTime = 0}
        self.giftInstance[instance.config.group] = instance
        self:AddShowCD(TimeUtil.ServerTime() + instance.config.showTime * 3600, instance)
        instance:Open()
        if not instance.donotShowUI and GlobalPanelEnum[instance:GetPanelName()] ~= nil then
            PopupManager:CallWhenIdle(function()
                if instance.popTimes == 0 then      ---在游戏开始的时候触发添加礼包，很可能已经在强弹队列里显示过了，这里在显示会造成打开两次的bug现象。
                    self:_OpenUI(instance, 2, nil)
                end
            end)
        end
    end
    Net.Giftmodulemsg_25802_TriggerGift_Request({id =instance.config.id}, onFail, onSucess)
    --console.error("添加礼包" .. instance.config.id)
end
---@param instance GiftInstanceBase
function GiftManager:_OnGiftClose(instance)
    if instance == nil then
        return
    end
    if self.giftInstance[instance.config.group] ~= instance then    --很可能自身显示时间到了关闭的时候已经由于购买而提前关闭了
        return
    end
    instance:Close()
    self.giftInstance[instance.config.group] = nil
    if instance.config.CD > 0 then
        self:AddCD(TimeUtil.ServerTime() + instance.config.CD * 3600, instance.config.id)
    end
    self.groupCD[instance.config.group] = TimeUtil.ServerTime() + instance.config.publicCD * 3600
    self:AddGroupCD(TimeUtil.ServerTime() + instance.config.publicCD * 3600, instance.config.group)
    self:_OnGiftCloseAddGift(instance.config.group)
end
---begin cd处理
---延迟开启
function GiftManager:AddOpenCD(openCD, giftID)
    self.cd:AddCD(openCD, giftID, self._OnOpenCDEndAddGift, self)
end
---自身时间
function GiftManager:AddCD(CD, giftID)
    self.cd:AddCD(CD, giftID, self._OnSelfCDEndAddGift, self)
end
---组cd
function GiftManager:AddGroupCD(CD, giftGroup)
    self.cd:AddCD(CD, giftGroup, self._OnGroupCDEndAddGift, self)
end
---开启时间
function GiftManager:AddShowCD(CD, instance)
    self.cd:AddCD(CD, instance, self._OnGiftClose, self)
end
---end

--读取本地数据
function GiftManager:ReadDataFromLocal()
    local rawData = FileUtil.ReadFromUserFile(fileName)
    if rawData == nil then
        return
    end
    local data = table.deserialize(rawData)
    if data then
        local dataDic = {}
        for _, v in ipairs(data) do
            dataDic[v.id] = v
        end
        for _, instance in pairs(self.giftInstance) do
            if dataDic[instance.config.id] ~= nil then
                instance.popTime = dataDic[instance.config.id].popTime
                instance.popTimes = dataDic[instance.config.id].popTimes
            end
        end
    end
end

--保存到本地数据
function GiftManager:WriteToFile()
    local data = {}
    for _, instance in pairs(self.giftInstance) do
        data[#data + 1] = {id = instance.config.id, popTimes = instance.popTimes, popTime = instance.popTime}
    end
    FileUtil.SaveWriteUserFile(table.serialize(data), fileName)
end

--单双号的礼包内容不同
function GiftManager:IsOddGift()
    if self.isodd ~= nil then
        return self.isodd
    end
    local ascii0 = string.byte("0")
    local ascii9 = string.byte("9")
    local asciiid = string.byte(LogicContext.UID, string.len(LogicContext.UID))
    if asciiid >= ascii0 and asciiid <= ascii9 then
        self.isodd = (asciiid - ascii0) % 2 == 1
    else
        local asciim = string.byte("m")
        self.isodd = asciiid <= asciim
    end
    return self.isodd
end

function GiftManager:MoneyBuy(instance, successCallback, rewardCallback)
    local config = instance.shopConfig
    local productId = AppServices.ProductManager:GetProductId(config.id)
    local function NetSuc()
        Runtime.InvokeCbk(successCallback)

        AppServices.ProductManager:ShowReward(productId, rewardCallback)
        self:RecordBuyGift(instance)
    end
    AppServices.ProductManager:StartPay(productId,"GiftNew",nil,NetSuc)
end

function GiftManager:DiamondBuy(instance, successCallback, rewardCallback)
    local goodsConfig = instance.shopConfig
    if goodsConfig ~= nil and AppServices.User:GetItemAmount(ItemId.DIAMOND) >= goodsConfig.price then
        local price = goodsConfig.price
        local function onSuccess()
            local flyDiamondSuccess = function()
                Util.BlockAll(0, "DiamondPurchase_Request")
                AppServices.DiamondLogic:UseDiamond(price, nil, ItemUseMethod.gift,goodsConfig.id)

                local rwds = {}
                for i, v in pairs(goodsConfig.itemIds) do
                    table.insert(rwds, {ItemId = v[1], Amount = v[2]})
                    AppServices.User:AddItem(v[1], v[2], ItemGetMethod.Gift,goodsConfig.id)
                end

                local pcb = PanelCallbacks:Create(
                function()
                    --AppServices.GiftManager:RecordBuyGift(panel.arguments.instance)
                    Runtime.InvokeCbk(rewardCallback)
                end
                )
                Runtime.InvokeCbk(successCallback)
                self:RecordBuyGift(instance)
                PanelManager.showPanel(GlobalPanelEnum.CommonRewardPanel,{rewards = rwds},pcb)
            end
            local diamondItem = AppServices.DiamondLogic:GetView()
            diamondItem:SetDiamondWithAnimation(AppServices.User:GetItemAmount(ItemId.DIAMOND) - price)
            flyDiamondSuccess()
        end
        local function onFailed(errorCode)
            Util.BlockAll(0, "DiamondPurchase_Request")
            ErrorHandler.ShowErrorPanel(errorCode)
        end
        Util.BlockAll(-1, "DiamondPurchase_Request")
        Net.Coremodulemsg_1020_DiamondPurchase_Request({shopId = goodsConfig.id}, onFailed, onSuccess)
    end
end

function GiftManager:GetGiftInstance(giftID)
    local config = self.giftConfigs[giftID]
    if config ~= nil  then
        local instance = self.giftInstance[config.group]
        if instance and instance.config.id == giftID then
            return instance
        end
    end
    return nil
end

GiftManager:Init()

return GiftManager
