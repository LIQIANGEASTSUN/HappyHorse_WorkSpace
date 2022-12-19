---
--- Created by Betta.
--- DateTime: 2021/11/10 18:52
---

---@class EggToTaskType
---@field taskType number
---@field cfg table
---@field progress table
---@field activeCount number

---@type table<number, EggToTaskType>
local EggToTaskType =
{
    [1] = {taskType = MissionType.UseEnergy, cfg = {TaskNeed = {Num =  20}}, progress = {}},
    [2] = {taskType = MissionType.Order, cfg = {TaskNeed = {Num =  1}}},
    [3] = {taskType = MissionType.BreedCount, cfg = {TaskNeed = {Num =  1}}},
    [4] = {taskType = MissionType.TimeOrder, cfg = {TaskNeed = {Num =  1}}},
    [5] = {taskType = MissionType.CommissionRewardCount, cfg = {TaskNeed = {Num =  1}}},
    [6] = {taskType = MissionType.GoldOrderCount, cfg = {TaskNeed = {Num =  1}}},
}
local ActiveEggItem = require("Game.System.ActiveEgg.ActiveEggItem")
---@class ActiveEggManager
local ActiveEggManager = {}

function ActiveEggManager:Init()
    self.configTemplate = AppServices.Meta.metas.ConfigTemplate
    self.speedUpCost = tonumber(self.configTemplate["SpeedUpProduction"].value)
    EggToTaskType[1].cfg.TaskNeed.Num = tonumber(self.configTemplate["activeEggEnergyParam"].value)  --特殊处理，需要的能量处理
    ---@type SubTaskBase[]
    self.subtasks = {}
    ---@type table<number, ActiveEggItem>
    self.eggArray = nil
    ---@type string[]
    self.receivedSystems = nil
    ---@type ActiveEggItem[]
    self.systemEggArray = {}
    self._requestSystemEggCB = {}
    self._requestSystemEgg = false
    self._requestInfoCB = {}
    self._requestInfo = false


    if self:IsUnlock() then
        self:_RequestInfo()
        self:_ProcessUnlock()
    else
        MessageDispatcher:AddMessageListener(MessageType.Global_OnUnlock, self._Unlock, self)
    end
    --MessageDispatcher:AddMessageListener(MessageType.Global_After_UseItem, self.OnTrigger, self)
end

--[[function ActiveEggManager:OnTrigger(id, num)
    if tostring(id) ~= ItemId.ENERGY then
        return
    end
    console.error("使用体力：", num)
end--]]

function ActiveEggManager:IsUnlock()
    return AppServices.Unlock:IsUnlock("activeEgg")
end

function ActiveEggManager:_ProcessUnlock()
    --self:_InitTask()
end

function ActiveEggManager:_Unlock(key)
    if key == "activeEgg" then
        self:_RequestInfo()
        self:_ProcessUnlock()
        MessageDispatcher:RemoveMessageListener(MessageType.Global_OnUnlock,self._Unlock,self)
    end
end

function ActiveEggManager:_InitTask(cumulativeEnergy)
    if self.subtasks ~= nil and #self.subtasks > 0 then
        return
    end
    local canCol = false
    for _, egg in ipairs(self.eggArray) do
        if egg:CanColActive() then
            canCol = true
        end
    end
    if canCol == false then
        console.dk("没有彩蛋可收集积分") --@DEL
        return
    end
    console.dk("彩蛋开始收集积分") --@DEL
    cumulativeEnergy = cumulativeEnergy or 0
    EggToTaskType[1].progress = {cumulativeEnergy}  --特殊处理，消耗能量设置
    local activeGetway = table.deserialize(self.configTemplate["activeGetway"].value)
    for k, v in ipairs(activeGetway) do
        local taskData = EggToTaskType[v[1]]
        taskData.activeCount = v[2]
        self:_CreatedTask(taskData, k, EggToTaskType[v[1]].progress)
    end
    MessageDispatcher:AddMessageListener(MessageType.Task_OnSubTaskFinish, self._OnTaskFinish, self)
end

function ActiveEggManager:_ClearTask()
    if self.subtasks ~= nil then
        for _, subTask in pairs(self.subtasks) do
            subTask:destory()
        end
    end
    self.subtasks = {}
    MessageDispatcher:RemoveMessageListener(MessageType.Task_OnSubTaskFinish, self._OnTaskFinish, self)
end

function ActiveEggManager:_OnTaskFinish(taskKind, taskId, tlpId)
    if taskKind ~= TaskKind.ActiveEgg then
        return
    end
    local taskData = EggToTaskType[taskId]
    if taskData ~= nil then
        local subEntity = self.subtasks[taskId]
        if subEntity ~= nil then
            local mul = math.floor(subEntity:GetProgress() / subEntity:GetTotal())
            local progress = {}
            progress[1] = subEntity:GetProgress() - (subEntity:GetTotal() * mul)
            self:_CreatedTask(taskData, taskId, progress)
            self:_AddActive(taskData.activeCount * mul)
            console.dk(string.format("彩蛋获得活跃+%s, source:%s", taskData.activeCount * mul, taskId)) --@DEL
        else
            console.error('彩蛋未找到完成的任务', taskData.taskType)
        end
    end
end

function ActiveEggManager:_CreatedTask(taskData, k, progress)
    if taskData then
        local TaskTypes = require("Task.TaskTypes")
        local sub_class = TaskTypes[taskData.taskType]
        if sub_class then
            local subEntity = sub_class.new(TaskKind.ActiveEgg, k, k, taskData.cfg, progress, true)
            self.subtasks[k] = subEntity
            subEntity:RegisterListener()
        else
            console.error('彩蛋 Sub Task Type Not Found', taskData.taskType)
        end
    else
        console.error("新增加的获取活跃途径没有处理：", k)
    end
end

function ActiveEggManager:_CreateEggs(eggsInfo)
    if self.eggArray ~= nil then
        for _, egg in ipairs(self.eggArray) do
            egg:Release()
        end
    end
    self.eggArray = {}
    for _, eggInfo in ipairs(eggsInfo) do
        local egg = ActiveEggItem.new(eggInfo)
        self.eggArray[#self.eggArray + 1] = egg
    end
end

function ActiveEggManager:_CreateSystemEgg(eggInfo)
    local egg = ActiveEggItem.new(eggInfo)
    self.systemEggArray[#self.systemEggArray + 1] = egg
end

function ActiveEggManager:_RequestInfo(onResponse)
    self._requestInfoCB[#self._requestInfoCB + 1] = onResponse
    if self._requestInfo then
        return
    end
    self._requestInfo = true
    local function onFail(errorCode)
        console.dk("活跃彩蛋获取事数据失败" .. errorCode) --@DEL
        ErrorHandler.ShowErrorPanel(errorCode)
        for _, cb in ipairs(self._requestInfoCB) do
            Runtime.InvokeCbk(cb, false)
        end
        self._requestInfoCB = {}
        self._requestInfo = false
    end
    local function onSucess(response)
        self:_CreateEggs(response.eggs)
        self:_ClearTask()
        self:_InitTask(response.cumulativeEnergy)
        console.dk(self:tostring()) --@DEL
        for _, cb in ipairs(self._requestInfoCB) do
            Runtime.InvokeCbk(cb, true)
        end
        self._requestInfoCB = {}
        self._requestInfo = false
    end
    Net.Activeeggmodulemsg_26201_ActiveEggInfo_Request({}, onFail, onSucess)
end

---像服务器请求系统彩蛋数据
function ActiveEggManager:_RequestSystemEgg(onResponse)
    self._requestSystemEggCB[#self._requestSystemEggCB + 1] = onResponse
    if self._requestSystemEgg then
        return
    end
    self._requestSystemEgg = true
    local function onFail(errorCode)
        console.dk("活跃彩蛋系统彩蛋获取事数据失败" .. errorCode) --@DEL
        ErrorHandler.ShowErrorPanel(errorCode)
        for _, cb in ipairs(self._requestSystemEggCB) do
            Runtime.InvokeCbk(cb, false)
        end
        self._requestSystemEggCB = {}
        self._requestSystemEgg = false
    end
    local function onSucess(response)
        self.receivedSystems = {}
        for _, systemId in ipairs(response.receivedSystems) do
            self.receivedSystems[#self.receivedSystems + 1] = systemId
        end
        self.systemEggArray = {}
        for _, egg in ipairs(response.systemEggs) do
            self:_CreateSystemEgg(egg)
        end
        for _, cb in ipairs(self._requestSystemEggCB) do
            Runtime.InvokeCbk(cb, true)
        end
        self._requestSystemEggCB = {}
        self._requestSystemEgg = false
    end
    Net.Activeeggmodulemsg_26204_ActiveEggSystemInfo_Request({}, onFail, onSucess)
end

function ActiveEggManager:_AddActive(activeCount)
    local tempCount = activeCount
    local clientOpen = false
    local totalActive = 0
    for _, egg in ipairs(self.eggArray) do
        totalActive = totalActive + egg.info.cur
        if egg:CanColActive() and activeCount > 0 then
            activeCount = egg:CollectActive(activeCount)
            if not egg:CanColActive() then
                clientOpen = true
                egg:SetOpen()
            end
        end
    end
    local canCol = false
    for _, egg in ipairs(self.eggArray) do
        if egg:CanColActive() then
            canCol = true
        end
    end
    ---活跃值满了，不再获得活跃值
    if canCol == false then
        self:_ClearTask()
    end
    ---刷新界面，有活跃值满的先和服务器同步再刷新界面
    local activeChange
    if activeCount <= 0 then
        activeChange = tempCount
    else
        activeChange = tempCount - activeCount
    end
    local weight = App.scene:GetWidget(CONST.MAINUI.ICONS.ActiveEggsButton)
    if clientOpen then
        self:_RequestInfo(function(suc)
            if suc then
                local totalActive2 = 0
                for _, egg in ipairs(self.eggArray) do
                    totalActive2 = totalActive2 + egg.info.cur
                end
                if activeChange ~= totalActive2 - totalActive then
                   weight:AdjustingEggDatas()
                end
            end
        end)
    end
    if weight then
        weight:RefreshUI(activeChange)
    end
    console.dk(self:tostring()) --@DEL
end

function ActiveEggManager:_OnCDEnd(eggId)
    --[[---@type ActiveEggItem
    local minIDegg
    for _, egg in ipairs(self.eggArray) do
        if egg:IsClose() then
            if minIDegg == nil or egg.info.eggId < minIDegg.info.eggId then
                minIDegg = egg
            end
        end
    end
    if minIDegg ~= nil then
        minIDegg:SetWaitCD()
    end
    self:_InitTask()--]]
    ---切到后台后再切到前台可能有多个彩蛋都刷新cd了，不自己计算了，直接向服务器请求
    self:_RequestInfo(function()
        MessageDispatcher:SendMessage(MessageType.Active_Egg_CD_Refrash, eggId)
    end)
end

function ActiveEggManager:GetEgg(id)
    for _, egg in ipairs(self.eggArray) do
        if egg.info.eggId == id then
            return egg
        end
    end
    return nil
end

function ActiveEggManager:GetEggArray(callback)
    if self.eggArray == nil then
        if self:IsUnlock() then
            self:_RequestInfo(function(success)
                if success then
                    Runtime.InvokeCbk(callback, self.eggArray)
                else
                    Runtime.InvokeCbk(callback, nil)
                end
            end)
        else
            Runtime.InvokeCbk(callback, nil)
        end
    else
        Runtime.InvokeCbk(callback, self.eggArray)
    end
    --console.error("ActiveEggManager:GetEggArray", AppServices.ActiveEggManager:tostring())
    return self.eggArray
end

function ActiveEggManager:OpenEgg(id, onResponse)
    local egg = self:GetEgg(id)

    local function onFail(errorCode)
        console.dk("活跃彩蛋打开失败" .. errorCode) --@DEL
        self:_MarkEggsRequestOpen({id}, self.eggArray, false)
        ErrorHandler.ShowErrorPanel(errorCode)
        Runtime.InvokeCbk(onResponse, false)
    end
    local function onSucess(response)
        self:_MarkEggsRequestOpen({id}, self.eggArray, false)
        --local rewards = {}
        for _, item in ipairs(response.rewards) do
            local itemId = item.itemTemplateId
            local amount = item.count
            if itemId == ItemId.EXP then
                AppServices.User:AddExp(amount, "OpenActiveEgg")
            else
                local type
                if egg ~= nil then
                    type = egg.info.type
                end
                AppServices.User:AddItem(itemId, amount, ItemGetMethod.OpenActiveEgg, type)
            end
            --local rwd = {ItemId = itemId, Amount = amount}
            --rewards[#rewards + 1] = rwd
        end
        --[[PanelManager.showPanel(GlobalPanelEnum.CommonRewardPanel, {rewards = rewards}, PanelCallbacks:Create(function()
            self.state = AdsBombManagerState.idle
            self:OutEnter()
        end))--]]
        self:_CreateEggs(response.eggs)
        self:_InitTask()
        Runtime.InvokeCbk(onResponse, true, response.rewards)
    end
    if egg == nil then
        console.error("活跃彩蛋打开失败，没找到这个蛋：", id)
        Runtime.InvokeCbk(onResponse, false)
        return
    end
    if not egg:CanOpen() then
        console.error("活跃彩蛋打开失败，不可打开状态：", egg.info.status)
        Runtime.InvokeCbk(onResponse, false)
        return
    end
    self:_MarkEggsRequestOpen({id}, self.eggArray, true)
    Net.Activeeggmodulemsg_26203_ActiveEggOpen_Request({eggIds = {id}}, onFail, onSucess)
end

function ActiveEggManager:GetCDCost(id)
    local egg = self:GetEgg(id)
    if egg == nil then
        console.error("活跃彩蛋计算钻石失败，没找到这个蛋：", id)
        return 0
    end
    if not egg:CanSkipCD() then
        console.error("活跃彩蛋计算钻石失败，状态：", egg.info.status)
        return 0
    end
    return math.ceil((egg.openTime - TimeUtil.ServerTime()) / 60 * self.speedUpCost)
end

function ActiveEggManager:ClearCD(id, onResponse)
    local function onFail(errorCode)
        console.dk("活跃彩蛋冷却加速失败" .. errorCode) --@DEL
        ErrorHandler.ShowErrorPanel(errorCode)
        Runtime.InvokeCbk(onResponse, false)
    end
    local function onSucess(response)
        if response.retCode ~= nil and response.retCode ~= 0 then
            ErrorHandler.ShowErrorPanel(errorCode)
            Runtime.InvokeCbk(onResponse, false)
        end
        self:_CreateEggs(response.eggs)
        if response.cost ~= nil then
            AppServices.User:UseItem(ItemId.DIAMOND, response.cost, ItemUseMethod.ActiveEgg)
        end
        self:_InitTask()
        Runtime.InvokeCbk(onResponse, true)
    end
    local egg = self:GetEgg(id)
    if egg == nil then
        console.error("活跃彩蛋冷却加速失败，没找到这个蛋：", id)
        Runtime.InvokeCbk(onResponse, false)
        return
    end
    if not egg:CanSkipCD() then
        console.error("活跃彩蛋冷却加速失败，状态：", egg.info.status)
        Runtime.InvokeCbk(onResponse, false)
        return
    end
    local diamond = self:GetCDCost(id)
    Net.Activeeggmodulemsg_26202_ActiveEggDiamondCD_Request({eggId = id, diamond = diamond}, onFail, onSucess)
end

---返回已经领取系统彩蛋的系统id数组
function ActiveEggManager:SystemEggStates(onResponse)
    if self.receivedSystems == nil then
        self:_RequestSystemEgg(function(suc)
            Runtime.InvokeCbk(onResponse, suc, self.receivedSystems)
        end)
    else
        Runtime.InvokeCbk(onResponse, true, self.receivedSystems)
    end
end
function ActiveEggManager:CanGetSystemEgg(systemID)
    if self.receivedSystems == nil then
        console.error("系统彩蛋信息未初始化")
        return false
    end
    local unlock = AppServices.Unlock:IsUnlock(systemID)
    local got = table.exists(self.receivedSystems, systemID)
    return unlock and not got
end
---返回是否有可以领取的系统彩蛋
function ActiveEggManager:HaveGetSystemEgg()
    local eggSystemArray = self:GetEggSystemArray()
    for index, eggSystem in ipairs(eggSystemArray) do
        if self:CanGetSystemEgg(eggSystem.id) then
            return index
        end
    end
    return nil
end
---判断是否有可领取的系统彩蛋或者可开启的系统彩蛋,为红点提供
function ActiveEggManager:HaveSystemEgg(callback)
    if self.receivedSystems == nil then
        if self:IsUnlock() then
            self:_RequestSystemEgg(function(suc)
                if suc then
                    Runtime.InvokeCbk(callback, self:HaveSystemEggNoRequest() or self:HaveGetSystemEgg() ~= nil)
                else
                    Runtime.InvokeCbk(callback, false)
                end
            end)
        else
            Runtime.InvokeCbk(callback, false)
        end
    else
        Runtime.InvokeCbk(callback, self:HaveSystemEggNoRequest() or self:HaveGetSystemEgg() ~= nil)
    end
end
---判断是否有开开启的系统彩蛋
function ActiveEggManager:HaveSystemEggNoRequest()
    if self.receivedSystems == nil then
        console.error("系统彩蛋信息未初始化")
        return false
    end
    if self.systemEggArray == nil or #self.systemEggArray == 0 then
        return false
    end
    return true
end
---返回已经领取的系统彩蛋
function ActiveEggManager:ExistSystemEggArray(onResponse)
    if self.receivedSystems == nil then
        self:_RequestSystemEgg(function(suc)
            Runtime.InvokeCbk(onResponse, suc, self.systemEggArray)
        end)
    else
        Runtime.InvokeCbk(onResponse, true, self.systemEggArray)
    end
end
---领取系统彩蛋
function ActiveEggManager:GetSystemEggArray(systemId, onResponse)
    local function onFail(errorCode)
        console.dk("活跃彩蛋领取系统彩蛋失败" .. errorCode) --@DEL
        ErrorHandler.ShowErrorPanel(errorCode)
        Runtime.InvokeCbk(onResponse, false)
    end
    local function onSucess(response)
        self.systemEggArray = {}
        for _, egg in ipairs(response.systemEggs) do
            self:_CreateSystemEgg(egg)
        end
        table.insert(self.receivedSystems, systemId)
        Runtime.InvokeCbk(onResponse, true, self.systemEggArray)
    end
    if self.receivedSystems == nil then
        console.error("活跃彩蛋领取系统彩蛋失败，系统彩蛋信息未初始化")
        Runtime.InvokeCbk(onResponse, false)
        return
    end
    if self:HaveSystemEggNoRequest() then
        console.error("活跃彩蛋领取系统彩蛋失败，有未开启的系统彩蛋")
        Runtime.InvokeCbk(onResponse, false)
        return
    end
    if AppServices.Unlock:IsUnlock(systemId) == false then
        console.error("活跃彩蛋领取系统彩蛋失败，系统未开启:", systemId)
        Runtime.InvokeCbk(onResponse, false)
        return
    end
    if table.indexOf(self.receivedSystems, systemId) ~= nil then
        console.error("活跃彩蛋领取系统彩蛋失败，系统彩蛋已领取：", systemId)
        Runtime.InvokeCbk(onResponse, false)
        return
    end
    Net.Activeeggmodulemsg_26205_ActiveEggSystemReceive_Request({systemId = systemId}, onFail, onSucess)
end
---@return ActiveEggItem
function ActiveEggManager:_GetSystemEgg(eggid)
    for _, egg in ipairs(self.systemEggArray) do
        if egg.info.eggId == eggid then
            return egg
        end
    end
end
---打开系统彩蛋
function ActiveEggManager:OpenSystemEggs(eggIds, onResponse)
    local function onFail(errorCode)
        console.dk("活跃彩蛋打开系统彩蛋失败" .. errorCode) --@DEL
        self:_MarkEggsRequestOpen(eggIds, self.systemEggArray, false)
        ErrorHandler.ShowErrorPanel(errorCode)
        Runtime.InvokeCbk(onResponse, false)
    end
    local function onSucess(response)
        self:_MarkEggsRequestOpen(eggIds, self.systemEggArray, false)
        --local rewards = {}
        for index, eggreward in ipairs(response.eggRewards) do
            for _, item in ipairs(eggreward.rewards) do
                local itemId = item.itemTemplateId
                local amount = item.count
                if itemId == ItemId.EXP then
                    AppServices.User:AddExp(amount, "OpenSystemEgg")
                else
                    local egg = self:_GetSystemEgg(eggIds[index])
                    local type
                    if egg ~= nil then
                        type = egg.info.type
                    end
                    AppServices.User:AddItem(itemId, amount, ItemGetMethod.OpenSystemEgg, type)
                end
                --local rwd = {ItemId = itemId, Amount = amount}
                --rewards[#rewards + 1] = rwd
            end
        end
        local indexAry = {}
        for index, egg in ipairs(self.systemEggArray) do
            if table.indexOf(eggIds, egg.info.eggId) ~= nil then
                indexAry[#indexAry + 1] = index
            end
        end
        for i = #indexAry, 1, -1 do
            table.remove(self.systemEggArray, indexAry[i])
        end
        Runtime.InvokeCbk(onResponse, true, response.eggRewards)
    end
    self:_MarkEggsRequestOpen(eggIds, self.systemEggArray, true)
    Net.Activeeggmodulemsg_26206_ActiveEggSystemOpen_Request({eggIds = eggIds}, onFail, onSucess)
end
---获取有彩蛋的系统数组
function ActiveEggManager:GetEggSystemArray()
    if self.eggSystemArray == nil then
        self.eggSystemArray = {}
        local systemOpenTemplate = AppServices.Meta:Category("SystemOpenTemplate")
        for _, item in pairs(systemOpenTemplate) do
            if tonumber(item.sequese) > 0 and #item.rewardEgg > 0 then
                local m = true
                for index, eggSystemArray in ipairs(self.eggSystemArray) do
                    if tonumber(item.sequese) < tonumber(eggSystemArray.sequese) then
                        table.insert(self.eggSystemArray, index, item)
                        m = false
                        break
                    end
                end
                if m then
                    table.insert(self.eggSystemArray, item)
                end
            end
        end
    end
    return self.eggSystemArray
end

---@param eggArray ActiveEggItem[]
function ActiveEggManager:_MarkEggsRequestOpen(eggids, eggArray, request)
    for _, egg in ipairs(eggArray) do
        if table.indexOf(eggids, egg.info.eggId) ~= nil then
            egg.request_open = request
        end
    end
end

function ActiveEggManager:tostring()
    local ret = "eggs:\n"
    for _, egg in ipairs(self.eggArray) do
        ret = ret .. string.format("id:%s, type:%s, state:%s, cur:%s, cd:%s \n", egg.info.eggId, egg.info.type, egg.info.status, egg.info.cur, egg.info.cd)
    end
    ret = ret .. "receivedSystems:\n"
    if self.receivedSystems ~= nil then
        for _, systemid in ipairs(self.receivedSystems) do
            ret = ret .. systemid .. ","
        end
    end
    ret = ret .. "\n systemeggs: \n"
    for _, egg in ipairs(self.systemEggArray) do
        ret = ret .. string.format("id:%s, type:%s, state:%s, cur:%s, cd:%s \n", egg.info.eggId, egg.info.type, egg.info.status, egg.info.cur, egg.info.cd)
    end
    return ret
end

return ActiveEggManager