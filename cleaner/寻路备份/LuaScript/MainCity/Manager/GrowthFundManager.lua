---未解锁
---未购买
---购买未收取
---已收取
local GrowthFundItemState = {
    lock = 1,
    nomal = 2,
    active = 3,
    received = 4
}

---@class GrowthFundManager
local GrowthFundManager = {
    --已领取id
    rewardIdList = {},
    --可领取id
    activeIdList = {},
    --为开启id
    lockIdList = {},
    ItemList = {},
    meta = {},
    isBuy = false,
    goodId = "25",
    state = GrowthState.lock,
    rewardTotal = {}
    --itemMaxCount = 0,
}
local config = AppServices.Meta:Category("GrowthFundTemplate")
function GrowthFundManager:GetItemState(id)
    return self.ItemList[id].state
end

--成长基金管理器处理功能开启流程：
--先检查开启，未开启则走开启流程
--监听补单，如果触发补单，走补单激活流程
--不存在补单，则走队列激活流程
function GrowthFundManager:Init()
    self.unLock = AppServices.Unlock:IsUnlock("growthfund")
    if not self.unLock then
        MessageDispatcher:AddMessageListener(MessageType.Global_OnUnlock, self.Process_UnLock, self)
    else
        self:Start()
    end
end
--解析全局数据
--奖励总计，奖励最大数量
--解析出每个item数据，状态
--整合列表，可领取与未开放列表，总数据列表
function GrowthFundManager:BuidlItemConfig()
    local function BuildItem(meta)
        local item = {}
        item.meta = meta
        item.id = meta.id
        item.InitState = function(_item)
            local id = _item.id
            if AppServices.User:GetCurrentLevelId() < tonumber(id) then
                return GrowthFundItemState.lock
            end

            if string.isEmpty(self.shopId) then
                return GrowthFundItemState.nomal
            end

            if self:IsReceived(id) then
                return GrowthFundItemState.received
            end

            return GrowthFundItemState.active
        end
        item.OnQuit = function(_item)
            if not _item.state then
                return
            end
            if _item.state == GrowthFundItemState.active then
                table.removeIfExist(self.activeIdList, _item.id)
            elseif _item.state == GrowthFundItemState.lock then
                table.removeIfExist(self.lockIdList, _item.id)
            end
        end
        item.OnEnter = function(_item, newState)
            _item.state = newState
            if _item.state == GrowthFundItemState.active then
                table.insertIfNotExist(self.activeIdList, _item.id)
            elseif _item.state == GrowthFundItemState.received then
                table.insertIfNotExist(self.rewardIdList, _item.id)
            elseif _item.state == GrowthFundItemState.lock then
                table.insertIfNotExist(self.lockIdList, _item.id)
            end
        end
        item.SwitchState = function(_item, newState)
            if _item.state == newState then
                return
            end
            _item:OnQuit()
            _item:OnEnter(newState)
        end
        return item
    end

    local function BuildRewardTotal(fundReward)
        for _, reward in ipairs(fundReward) do
            local id = tostring(reward[1])
            local num = reward[2]
            if not self.rewardTotal[id] then
                self.rewardTotal[id] = num
            else
                self.rewardTotal[id] = self.rewardTotal[id] + num
            end
        end
    end

    for index, meta in pairs(config) do
        --item数据
        local item = BuildItem(meta)
        local state = item:InitState()
        item:SwitchState(state)
        self.ItemList[meta.id] = item
        --奖励总计
        BuildRewardTotal(meta.fundReward)
    end
end

function GrowthFundManager:InitState()
    if string.isEmpty(self.shopId) then
        return GrowthState.noBuy
    end

    if #self.rewardIdList == self:GetDataLenth() then
        return GrowthState.finish
    end

    return GrowthState.hasBuy
end

function GrowthFundManager:SwitchState(newState)
    if self.state == newState then
        return
    end

    self.state = newState
    MessageDispatcher:SendMessage(MessageType.GrowthFund_RefreshState, self.state)
end

function GrowthFundManager:InitServerdata()
    --1 初始化服务器信息
    if not App.response or not App.response.growthFund then
        return
    end

    if App.response.growthFund.rewardIds then
        for _, id in ipairs(App.response.growthFund.rewardIds) do
            table.insert(self.rewardIdList, id)
        end
    end

    self.shopId = App.response.growthFund.shopId or ""
end
--加载月卡常驻逻辑
function GrowthFundManager:Start()
    local function ReissuePurchaseLogic(info)
        if not info or not info.data then
            return
        end

        if self.productId ~= info.data.productId then
            return
        end
        self:Process_Reissue(info.data.productId)
    end

    --1 初始化服务器信息
    self:InitServerdata()
    self:SwitchState(self:InitState())
    --2 初始化本地数据
    self:BuidlItemConfig()

    --3 监听补单
    if self.state == GrowthState.noBuy then
        self.productId = AppServices.ProductManager:GetProductId(self.goodId)
        AppServices.EventDispatcher:addObserver(self, GlobalEvents.ReissuePurchase, ReissuePurchaseLogic)
    end

    if #self.lockIdList > 0 then
        MessageDispatcher:AddMessageListener(MessageType.Global_After_Player_Levelup, self.OnPlayerLevelUp, self)
    end
end

function GrowthFundManager:OnPlayerLevelUp()
    local curLevel = AppServices.User:GetCurrentLevelId()
    local needFreshUI = false
    local localData = AppServices.User.Default:GetKeyValue("growth", {})
    for index, item in pairs(self.ItemList) do
        if item.state == GrowthFundItemState.lock and tonumber(item.id) <= curLevel then
            if self.state == GrowthState.hasBuy then
                item:SwitchState(GrowthFundItemState.active)
                table.insert(localData, item.id)
                needFreshUI = true
            -- elseif self.state == GrowthState.noBuy then
            --    item:SwitchState(GrowthFundItemState.nomal)
            end
        end
    end

    if needFreshUI then
        AppServices.User.Default:SetKeyValue("growth", localData, true)
        MessageDispatcher:SendMessage(MessageType.GrowthFund_RefreshState, self.state)
    end
end

function GrowthFundManager:Process_UnLock()
    self.unLock = AppServices.Unlock:IsUnlock("growthfund")
    if self.unLock then
        self:Start()
        MessageDispatcher:RemoveMessageListener(MessageType.Global_OnUnlock, self.Process_UnLock, self)
    end
end

--补单激活流程，根据补单ID选择
function GrowthFundManager:Process_Reissue(productId)
    --刷新购买状态
    self.shopId = productId
    self:SwitchState(GrowthState.hasBuy)
    --刷新item状态
    for key, item in pairs(self.ItemList) do
        local state = item:InitState()
        item:SwitchState(state)
    end
    -- Runtime.InvokeCbk(onSuc)
    sendNotification("BuyGrouwthFundPackSuc")
end

--index == "-1" 全部领取
function GrowthFundManager:DoRecieve(index, _onFail, _onSuc)
    local function onFail(error)
        console.lj(error) --@DEL
    end

    local function onSuc()
        --刷新item数据和状态
        local result = {}
        if index ~= "-1" then
            local item = self.ItemList[index]
            local reward = item.meta.fundReward
            for _, value in ipairs(reward) do
                local id = value[1]
                local num = value[2]
                result[id] = num
            end
            item:SwitchState(GrowthFundItemState.received)
        else
            while #self.activeIdList > 0 do
                local item = self.ItemList[self.activeIdList[1]]
                local reward = item.meta.fundReward
                for _, value in ipairs(reward) do
                    local id = value[1]
                    local num = value[2]
                    if not result[id] then
                        result[id] = num
                    else
                        result[id] = result[id] + num
                    end
                end
                item:SwitchState(GrowthFundItemState.received)
            end
        end
        if #self.rewardIdList == self:GetDataLenth() then
            self:SwitchState(GrowthState.finish)
        end
        --刷新UI
        Runtime.InvokeCbk(_onSuc, result)
    end
    Net.Growthfundmodulemsg_27201_ReceiveReward_Request({rewardId = index}, onFail, onSuc)
end

function GrowthFundManager:IsReceived(id)
    local index = table.indexOf(self.rewardIdList, id)
    return index and index > 0
end

function GrowthFundManager:IsBuy()
    return not string.isEmpty(self.shopId)
end

function GrowthFundManager:GetItemData(id)
    return self.ItemList[id]
end

function GrowthFundManager:GetDataLenth()
    if not self.itemMaxCount then
        self.itemMaxCount = table.count(config)
    end
    return self.itemMaxCount
end

function GrowthFundManager:GetAcitveLenth()
    return #self.activeIdList
end

function GrowthFundManager:GetFirstTarget()
    --还未购买默认1
    if self.state == GrowthState.noBuy then
        return 1
    end

    --没有可领取的默认1
    if #self.activeIdList == 0 then
        table.sort(
            self.lockIdList,
            function(a, b)
                return tonumber(a) < tonumber(b)
            end
        )
        return tonumber(self.lockIdList[1])
    end

    --返回可领取列表的第一个
    table.sort(
        self.activeIdList,
        function(a, b)
            return tonumber(a) < tonumber(b)
        end
    )
    return tonumber(self.activeIdList[1])
end

function GrowthFundManager:Buy(onSuc)
    local function NetSuc()
        --刷新购买状态
        self.shopId = self.productId
        self:SwitchState(GrowthState.hasBuy)
        --刷新item状态
        for key, item in pairs(self.ItemList) do
            local state = item:InitState()
            item:SwitchState(state)
        end
       -- Runtime.InvokeCbk(onSuc)
        if #self.activeIdList > 2 then
            table.sort(
                self.activeIdList,
                function(a, b)
                    return tonumber(a) < tonumber(b)
                end
            )
        end
        if #self.lockIdList > 2 then
            table.sort(
                self.lockIdList,
                function(a, b)
                    return tonumber(a) < tonumber(b)
                end
            )
        end
       sendNotification("BuyGrouwthFundPackSuc")
    end

    AppServices.ProductManager:StartPay(self.productId, "GrowthFund", nil, NetSuc)
end

function GrowthFundManager:GetAllRewardCount(id)
    return self.rewardTotal[id] or 0
end

function GrowthFundManager:GetGrowthFundState()
    return self.state
end

function GrowthFundManager:PopCheckShow(finishCallback)
    local function checkState()
        if self.state == GrowthState.noBuy then
            console.lj("基金强弹：状态:未购买") --@DEL
            return true
        end

        if self.state == GrowthState.hasBuy then
            if #self.activeIdList > 0 then
                console.lj("基金强弹：状态:已购买，且未领取") --@DEL
                return true
            end
            console.lj("基金强弹：状态:已购买，且都已领取") --@DEL
        end
        console.lj("基金强弹：状态:不强弹") --@DEL
        return false
    end

    local function CheckMission()
        local localData = AppServices.User.Default:GetKeyValue("GrowthFundSecPopup", {false, false})
        console.lj("基金强弹：本地存档:"..table.tostring(localData)) --@DEL
        --先检查第一个条件
        if not localData[1] then
            local mission = AppServices.Meta:GetConfigMetaValue("GrowthFundFirstPopup")
            local isFinish = AppServices.Task:IsTaskFinish(mission)
            console.lj("基金强弹：任务1完成:"..tostring(isFinish)) --@DEL
            if isFinish and checkState() then
                localData[1] = true
                AppServices.User.Default:SetKeyValue("GrowthFundSecPopup", localData, true)
                console.lj("基金强弹：强弹1") --@DEL
                return true
            end
        end

        if not localData[2] then
            local mission = AppServices.Meta:GetConfigMetaValue("GrowthFundSecPopup")
            local isFinish = AppServices.Task:IsTaskFinish(mission)
            console.lj("基金强弹：任务2完成:"..tostring(isFinish)) --@DEL
            if isFinish and self.state == GrowthState.noBuy then
                console.lj("基金强弹：强弹2") --@DEL
                localData[2] = true
                AppServices.User.Default:SetKeyValue("GrowthFundSecPopup", localData, true)
                return true
            end
        end
        console.lj("基金强弹：状态:不强弹") --@DEL
        return false
    end


--[[
    if not checkState() then
        Runtime.InvokeCbk(finishCallback)
        return
    end
]]
    if not CheckMission() then
        Runtime.InvokeCbk(finishCallback)
        return
    end

    PanelManager.showPanel(GlobalPanelEnum.GrowthFundPanel, {popCb = finishCallback})
end

function GrowthFundManager:PopCheck()
    local function checkState()
        if self.state == GrowthState.noBuy then
            console.lj("基金强弹：状态:未购买") --@DEL
            return AppServices.ProductManager:CheckFetch()
        end

        if self.state == GrowthState.hasBuy then
            if #self.activeIdList > 0 then
                console.lj("基金强弹：状态:已购买，且未领取") --@DEL
                return true
            end
            console.lj("基金强弹：状态:已购买，且都已领取") --@DEL
        end
        console.lj("基金强弹：状态:不强弹") --@DEL
        return false
    end

    local localData = AppServices.User.Default:GetKeyValue("GrowthFundSecPopup", {false, false})
    console.lj("基金强弹：本地存档:"..table.tostring(localData)) --@DEL
    --先检查第一个条件
    if not localData[1] then
        local mission = AppServices.Meta:GetConfigMetaValue("GrowthFundFirstPopup")
        local isFinish = AppServices.Task:IsTaskFinish(mission)
        console.lj("基金强弹：任务1完成:"..tostring(isFinish)) --@DEL
        if isFinish and checkState() then
            localData[1] = true
            AppServices.User.Default:SetKeyValue("GrowthFundSecPopup", localData, true)
            console.lj("基金强弹：强弹1") --@DEL
            return true
        end
    end

    if not localData[2] then
        local mission = AppServices.Meta:GetConfigMetaValue("GrowthFundSecPopup")
        local isFinish = AppServices.Task:IsTaskFinish(mission)
        console.lj("基金强弹：任务2完成:"..tostring(isFinish)) --@DEL
        if isFinish and AppServices.ProductManager:CheckFetch() and self.state == GrowthState.noBuy then
            console.lj("基金强弹：强弹2") --@DEL
            localData[2] = true
            AppServices.User.Default:SetKeyValue("GrowthFundSecPopup", localData, true)
            return true
        end
    end
    console.lj("基金强弹：状态:不强弹") --@DEL
    return false
end

function GrowthFundManager:PopDo(finishCallback)
    PanelManager.showPanel(GlobalPanelEnum.GrowthFundPanel, {popCb = finishCallback})
end

function GrowthFundManager:GetUnRecievedIds()
    if not self:IsBuy() then
        return nil,nil
    end
    --如果都领取了则不返回
    local endId = self:GetDataLenth()
    if #self.rewardIdList == endId then
        return nil,nil
    end

    --如果还有未领取的，返回第一个和总列表最后一个
    if #self.activeIdList > 0 then
        return self.activeIdList[1],self.ItemList[tostring(endId)].id
    end

    --如果还有未解锁的，返回第一个和总列表最后一个
    if #self.lockIdList > 0 then
        return self.lockIdList[1],self.ItemList[tostring(endId)].id
    end

    return nil,nil
end

--GrowthFundManager:Awake()
return GrowthFundManager
