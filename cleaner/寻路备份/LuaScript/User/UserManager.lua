require "Utils.FileUtil"

local dataPath = {
    DailyData = "User.Data.DailyData",
    LocalDailyData = "User.Data.LocalDailyData",
    TaskData = "User.Data.TaskData",
    AdsEnergyData = "User.Data.AdsEnergyData",
    MapGiftData = "User.Data.MapGiftData",
    Default = "User.UserDefault",
    SubscribeData = "User.Data.SubscribeData"
}
---@class UserManager
local UserManager = {
    isDirty = false,
    localdefault = nil, -- 存储于本地的默认值
    ---@type UserDefault
    Default = nil,
    ---@type DailyData
    DailyData = nil,
    ---@type LocalDailyData
    LocalDailyData = nil,
    ---@type TaskData
    TaskData = nil,
    ---@type AdsEnergyData
    AdsEnergyData = nil,
    ---@type MapGiftData
    MapGiftData = nil,
    ---@type SubscribeData
    SubscribeData = nil
}
setmetatable(
    UserManager,
    {
        __index = function(t, k)
            if dataPath[k] then
                local inst = include(dataPath[k])
                rawset(t, k, inst)
                return inst
            end
        end
    }
)

local filename = "user.dat"
function UserManager:InitFromData(src)
    self.data = {}
    self.data.uid = src.uid or RuntimeContext.DEVICE_ID
    self.data.nickName = src.nickName or "GuestUser"
    self.data.sex = src.sex or false
    self.data.diamondNumber = src.diamondNumber or 0
    self.data.coinNumber = src.coinNumber or 0
    self.data.level = src.level or 1
    self.data.heartNumber = src.heartNumber or 0
    self.data.heartStartTime = src.heartStartTime or -1
    self.data.starNumber = src.starNumber or 0
    self.data.itemList = src.itemList or {}
    self.data.createTime = src.createTime or 0
    self.data.alterNameCnt = src.alterNameCnt or 0
    self.data.payCount = src.payCount or 0
    self.data.infiniteHeartTime = src.infiniteHeartTime or 0
    self.data.updateTime = src.updateTime or 0
    self.data.compensateState = src.compensateState or 0

    self.data.openMagicNum = src.openMagicNum or 0
    self.data.collectionInfo = src.collectionInfo or {}

    self.data.PiggyBankInfo = src.PiggyBankInfo or {}
    -- 判断空字符串
    if src.registVersion and not string.isEmpty(src.registVersion) then
        self.data.registVersion = src.registVersion
    elseif not self.data.registVersion then
        self.data.registVersion = "1.0.0"
    end

    self.data.shopInfo = src.shopInfo or {}

    -- LogicContext.UID        = self.data.uid
    LogicContext.UserName = self.data.nickName

    self:InitLanguage()

    --广告离线数据
    self.data.ads = src.ads

    self.data.failureOffer1Purchased = src.failureOffer1Purchased or false

    --AdsManager.Instance():Initialize(self.data.ads)

    -- local monthRewardData = {}
    -- monthRewardData.remedytimes = 1 -- 补签次数
    -- monthRewardData.signDays = {[2] = 1} -- 哪一天签到了
    -- monthRewardData.getSums = {[1] = 1}--已领取的累积奖励id
    -- self.data.monthReward = monthRewardData

    self.data.previousEnterTime = src.previousEnterTime or TimeUtil.ServerTime()
    self.data.totalRecharge = src.totalRecharge or 0 --历史总充值(美分)

    self.data.exp = src.exp or 0
    self.data.usedItems = src.usedItems
    self.data.lastRechargeTime = src.lastRechargeTime
    self.data.timeZone = src.timeZone
    self.data.backReward = src.backReward

    self:SetUserData(src)
    self:InitEquipInfo(src.msg.equipInfo)
end

-- Cleaner Start --------------------------------------------------
function UserManager:SetUserData(src)
    local msg = src.msg
    if not msg then
        return
    end
    self.data.uid = src.uid or RuntimeContext.DEVICE_ID

    -- 玩家信息
    self.data.pid = msg.humanInfo.pid
    self.data.name = msg.humanInfo.name
    self.data.level = msg.humanInfo.level or 1

    self:SetPetInfo(msg.petInfo)
    self:SetAllItemInfo(msg.itemInfo)

    self.data.island = msg.sceneInfo.island

    self:SetRemoveBuildings(msg.sceneInfo)
    self:SetAllProduction(msg.sceneInfo)

    self.data.unLockIslandMap = {}
    self:SetAllUnlockIsland(msg.sceneInfo)

    self.data.linkIslandMap = {}
    self:SetAllLinkIsland(msg.sceneInfo)

    self:SetTaskInfo(msg.taskInfo)

    --console.error("测试用")
    --local pet = {id = 2, type = 2, level = 2, up = 0}
    --self:SetPet(pet)
end

function UserManager:GetPlayerLevel()
    return self.data.level
end

function UserManager:GetPlayerIslandInfo()
    return self.data.island
end

function UserManager:SetPlayerIslandInfo(island)
    self.data.island = island
end

function UserManager:InitEquipInfo(info)
    self.data.equips = info.equips
end

-- pet ---------------------------------------------------
function UserManager:SetPetInfo(petInfo)
    self.data.pets = {}
    if not petInfo or not petInfo.pets then
        return
    end

    for _, pet in pairs(petInfo.pets) do
        self:SetPet(pet)
    end
end

function UserManager:SetPet(pet)
    local cache = self.data.pets[pet.id]
    if cache then
        cache.id = pet.id
        cache.type = pet.type
        cache.level = pet.level
        cache.up = pet.up
    else
        self.data.pets[pet.id] = pet
    end
end

function UserManager:GetPets()
    return self.data.pets
end

function UserManager:GetPet(petId)
    return self.data.pets[petId]
end

function UserManager:GetPetWithType(type)
    local result = nil
    for _, pet in pairs(self.data.pets) do
        if pet.type == type then
            result = pet
        end
    end

    return result
end
-----------------------------------------------------------
---@return DEquip
function UserManager:GetVaccumInfo()
    for _, value in pairs(self.data.equips) do
        if value.up == 1 then
            return value
        end
    end
end
function UserManager:GetEquip(id)
    for _, value in pairs(self.data.equips) do
        if value.id == id then
            return value
        end
    end
end
function UserManager:SetEquipInfo(equipInfo)
    self.isDirty = true
end
function UserManager:GetVaccumInfos()
    return self.data.equips
end
-- Item ---------------------------------------------------
-- 道具信息
function UserManager:SetAllItemInfo(itemInfo)
    self.data.items = {}
    if not itemInfo or not itemInfo.items then
        return
    end

    for _, item in pairs(itemInfo.items) do
        --self:SetItem(item)
        self:SetPropNumber(item.sn, item.num)
    end
end
-----------------------------------------------------------

function UserManager:SetRemoveBuildings(sceneInfo)
    self.data.removeBuildings = {}
    if not sceneInfo.removeBuildings then
        return
    end

    for _, id in pairs(sceneInfo.removeBuildings) do
        self:AddRemoveBuilding(id)
    end
end

function UserManager:AddRemoveBuilding(id)
    self.data.removeBuildings[tostring(id)] = true
end

function UserManager:IsBuildingRemove(id)
    if self.data.removeBuildings[tostring(id)] then
        return true
    end
    return false
end

--- FoodFactoryAgent
function UserManager:SetAllProduction(sceneInfo)
    self.data.productions = {}
    if not sceneInfo.production then
        return
    end

    for _, data in pairs(sceneInfo.production) do
        self:SetProduction(data)
    end
end

function UserManager:SetProduction(data)
    if data then
        self.data.productions[data.id] = data
    end
end

function UserManager:GetProduction(id)
    return self.data.productions[id]
end

function UserManager:RemoveProduction(id)
    self.data.productions[id] = nil
end

-- 产品状态
function UserManager:ProductionStatue(production)
    if not production or production.status ~= 1 then
        return ProductionStatus.None
    end

    if production.status == ProductionStatus.Finish then
        return ProductionStatus.Finish
    end

    local time = TimeUtil.ServerTime()
    if production.endTime > time then
        return ProductionStatus.Doing
    end
    return ProductionStatus.Finish
end

function UserManager:SetAllUnlockIsland(sceneInfo)
    if not sceneInfo or not sceneInfo.unlockIslands then
        return
    end

    for _, islandId in pairs(sceneInfo.unlockIslands) do
        self:SetUnlockIsland(islandId)
    end
end

function UserManager:SetUnlockIsland(islandId)
    self.data.unLockIslandMap[islandId] = true
end

-- 岛屿是否解锁
function UserManager:IsUnlockIsland(islandId)
    return self.data.unLockIslandMap[islandId]
end

function UserManager:SetAllLinkIsland(sceneInfo)
    if not sceneInfo or not sceneInfo.linkIslands then
        return
    end

    for _, islandId in pairs(sceneInfo.linkIslands) do
        self:SetLinkIsland(islandId)
    end
end

function UserManager:SetLinkIsland(islandId)
    self.data.linkIslandMap[islandId] = true
end

-- 岛屿是否连接到家园
function UserManager:IsLinkHomeland(islandId)
    return self.data.linkIslandMap[islandId]
end

-- linkIslands
---
-- task
---初始化任务信息
function UserManager:SetTaskInfo(taskInfo)
    taskInfo = taskInfo or {}
    local tasks = {
        progress = taskInfo.progress or {},
        finish = taskInfo.finish or {}
    }
    self.data.tasks = tasks
end

function UserManager:GetTaskInfo()
    return self.data.tasks
end

function UserManager:GetTaskProgress(taskSn)
    local tasks = self.data.tasks
    if not tasks then
        tasks = {}
        self.data.tasks = tasks
    end
    if not tasks.progress then
        tasks.progress = {}
    end
    local _, progress = table.ifind(tasks.progress, taskSn, "key")
    return progress
end

function UserManager:SetTaskFinish(taskSn)
    local tasks = self.data.tasks
    if not tasks then
        tasks = {}
        self.data.tasks = tasks
    end
    if not tasks.finish then
        tasks.finish = {}
    end
    table.insertIfNotExist(tasks.finish, taskSn)
    if table.isEmpty(tasks.progress) then
        return
    end
    table.removev(tasks.progress, taskSn, "key")
end

function UserManager:UpdateTaskProgress(taskSn, count)
    local tasks = self.data.tasks
    if not tasks then
        tasks = {}
        self.data.tasks = tasks
    end
    if not tasks.progress then
        tasks.progress = {}
    end
    local idx = table.ifind(tasks.progress, taskSn, "key")
    if not idx then
        table.insert(tasks.progress, {key = taskSn, value = count})
    else
        tasks.progress[idx].value = count
    end
end
-- Cleaner End --------------------------------------------

function UserManager:ReadData()
    local rawData = FileUtil.ReadFromUserFile(filename)
    local data
    if rawData then
        data = table.deserialize(rawData)
    end

    if not data then
        data = {}
    end
    return data
end

function UserManager:InitLanguage()
    -- local language = FileUtil.ReadFromFile(FileUtil.GetPersistentPath() .. "/lang.dat")
    local language = LogicContext.Language
    self.language = language or "en"
end
function UserManager:GetLanguage()
    if not self.language then
        self.isDirty = true
        self:InitLanguage()
    end
    return self.language
end
function UserManager:SetLanguage(lang)
    if lang ~= self.language then
        self.language = lang
        LogicContext.Language = lang
    end
end

function UserManager:SyncData(data)
    self:InitFromData(data)
    self:WriteToFile()
end

function UserManager:TryInitFromFile()
    local rawData = FileUtil.ReadFromUserFile(filename)
    local data
    if rawData then
        data = self:decode(table.deserialize(rawData))
    end

    if not data then
        return false
    end

    self:InitFromData(data)
    return true
end

function UserManager:encode()
    local data = {
        data = self.data
    }
    return data
end
function UserManager:decode(src)
    local data
    --封装新数据, 兼容老数据
    if src and src.data then
        data = src.data
    else
        -- 老数据
        data = src
    end
    return data
end

function UserManager:WriteToFile()
    self.isDirty = false
    --[[
    local data = self:encode()
    local jsonStr = table.serialize(data)
    FileUtil.SaveWriteUserFile(jsonStr, filename)
    ]]
end

function UserManager:GetCreateTime()
    return math.floor((self.data.createTime or 0) / 1000)
end

function UserManager:GetUid()
    return self.data.uid
end

function UserManager:SetUid(uid)
    self.isDirty = true
    self.data.uid = uid
    LogicContext.UID = self.data.uid
end

function UserManager:GetCurrentLevelId()
    local maxLevel = AppServices.Meta:GetMaxLevel()
    return math.min(self.data.level, maxLevel)
end

function UserManager:RollbackLevelId(rollbackLevel)
    console.error("Warn!!! Level Roll Back !!! old", self.data.level, "new is ", rollbackLevel)
    self.data.level = rollbackLevel
end

---相同functype的所有道具数量总和 刨除传入的这个
--[[
function UserManager:GetPropTotalNumberWithSameFuncType(itemId)
    local itemsWithSameFuncType = AppServices.Meta:GetItemsWithSameFuncType(itemId)
    local totalNumber = 0
    for _, value in ipairs(itemsWithSameFuncType) do
        if value.id ~= itemId then
            totalNumber = totalNumber --+ self:GetPropNumber(value.id)
        end
    end
    return totalNumber
end
--]]
---设置道具数量
function UserManager:SetPropNumber(id, num, method, subMethod)
    local itemId = tostring(id)
    --console.assert(itemId and type(num) == "number" and num >= 0)
    self.isDirty = true
    local oldCount = 0
    --[[
    -- local isTimeLimit = ItemId.IsTimeLimit(itemId)
    local totalNumber = self:GetPropTotalNumberWithSameFuncType(itemId)
    local numLimit = AppServices.Meta:GetItemLimit(itemId)
    local maxDelta = numLimit - totalNumber
    if num > maxDelta and numLimit > 0 then
        AppServices.UITextTip:Show(Runtime.Translate("ui_item_num_limit"))
        num = maxDelta
    end
    --]]
    if self.data.itemList[itemId] then
        oldCount = self.data.itemList[itemId].count
        self.data.itemList[itemId].count = num
    end

    if num == 0 then
        self.data.itemList[itemId] = nil
    elseif not self.data.itemList[itemId] then
        self.data.itemList[itemId] = {itemId = itemId, count = num}
    end

    self.buildingCount = nil

    if oldCount == num then
        return
    end
    local diffNum = num - oldCount
    if diffNum > 0 then
        MessageDispatcher:SendMessage(MessageType.Global_After_AddItem, itemId, diffNum)
    elseif diffNum < 0 then
        self:AddUsedCount(itemId, -diffNum)
        MessageDispatcher:SendMessage(MessageType.Global_After_UseItem, itemId, -diffNum)
    end
    self:reportItem(itemId, diffNum, method, subMethod)
end

--[[
    @desc: 添加道具
    --@itemId: 道具配置ID
	--@amount: 道具数量

    @return:
]]
function UserManager:AddItem(id, count, method, subMethod)
    local itemId = tostring(id)

    --[[
    if itemId == ItemId.EXP then
        self:AddExp(count, method)
        return
    end
    if ItemId.IsDragon(itemId) then
        console.lj("通过AddItem添加龙,直接返回") --@DEL
        return
    end

    if ItemId.IsSkin(itemId) then
        AppServices.SkinLogic:CheckNewSkins(itemId)
    end

    local funcType = AppServices.Meta:GetItemFuncType(id)

    if funcType == 1 then -- 直接加体力
        local funcParam = AppServices.Meta:GetItemFuncParam(id)
        self:AddItem(ItemId.ENERGY, funcParam * count, method, subMethod)
        MessageDispatcher:SendMessage(MessageType.Global_After_AddItem, itemId, count)
        return
    elseif funcType == 9 then -- 通过道具加道具
        local funcParam = AppServices.Meta:GetItemFuncParamById(id)
        self:AddItem(funcParam[1], funcParam[2] * count, method, subMethod)
        MessageDispatcher:SendMessage(MessageType.Global_After_AddItem, itemId, count)
        return
    end
    --]]
    print("add Prop ", itemId, count) --@DEL
    self:SetPropNumber(itemId, self:GetItemAmount(itemId) + count, method, subMethod)
end

function UserManager:UseItem(id, count, method, subMethod)
    local itemId = tostring(id)
    console.assert(itemId)
    local cnt = 0
    local item = self.data.itemList[itemId]
    if item then
        cnt = item.count
    end
    if cnt < count then
        console.error("道具己用完或数量不足! item = ", itemId, " ,current:", cnt, " ,tryUse:", count) --@DEL
        return false
    end
    self.isDirty = true

    cnt = cnt - count
    if cnt == 0 then
        self.data.itemList[itemId] = nil
    else
        item.count = cnt
    end
    self:AddUsedCount(itemId, count)
    MessageDispatcher:SendMessage(MessageType.Global_After_UseItem, itemId, count)
    self:reportItem(itemId, -count, method, subMethod)
    return true
end

function UserManager:GetItemAmount(id)
    local itemId = tostring(id)
    console.assert(itemId)
    if self.data.itemList[itemId] then
        local count = self.data.itemList[itemId].count
        -- if ItemId.IsTimeLimit(itemId) then
        --     --剔除掉过期的道具
        --     local nowTime = TimeUtil.ServerTimeMilliseconds()
        --     local cdTimes = self.data.itemList[itemId].cdTimes
        --     local trimCount = 0
        --     for _, v in ipairs(cdTimes) do
        --         if nowTime >= v then
        --             count = count - 1
        --             trimCount = trimCount + 1
        --         end
        --     end
        --     self.data.itemList[itemId].count = count
        --     while trimCount > 0 do
        --         table.remove(cdTimes, 1)
        --         trimCount = trimCount - 1
        --     end
        -- end
        return count
    end
    return 0
end

function UserManager:IsInItemList(itemId)
    if self.data and self.data.itemList[itemId] then
        return true
    end
    return false
end

function UserManager:GetItemsList()
    return self.data.itemList
end

-------------------------------------------------------------------------------------
function UserManager:ModifyNickName(newName, successCallback, failCallback)
    for _, v in pairs(CONST.GAME.NpcAlias) do
        if v == newName then
            ErrorHandler.ShowErrorMessage(Runtime.Translate("modify_name_illegal"))
            return
        end
    end

    local function onSuccess()
        self.isDirty = true
        self.data.alterNameCnt = self.data.alterNameCnt + 1
        self:SetNickName(newName)
        AppServices.EventDispatcher:dispatchEvent(GlobalEvents.MODIFY_NAME, newName)
        Runtime.InvokeCbk(successCallback)
    end
    local function onFail(errorCode)
        Runtime.InvokeCbk(failCallback)
        ErrorHandler.ShowErrorPanel(errorCode)
    end
    Net.Coremodulemsg_1008_AlterPlayerName_Request({playerName = newName}, onFail, onSuccess)
end

function UserManager:GetNickName()
    return self.data.nickName
end

function UserManager:SetNickName(nickName)
    self.isDirty = true
    self.data.nickName = nickName
    LogicContext.UserName = nickName
end

function UserManager:AddPayCount(count)
    self.isDirty = true
    self.data.payCount = self.data.payCount + count
end

function UserManager:GetCollectionInfo()
    return self.data.collectionInfo
end

function UserManager:SetCollectionInfo(data)
    self.isDirty = true
    self.data.collectionInfo = data
end

function UserManager:SaveCollectionInfo(buildingId, addNum, addProgress)
    self.isDirty = true

    if not self.data.collectionInfo[buildingId] then
        self.data.collectionInfo[buildingId] = {num = 0, progress = 0}
    end

    addNum = addNum or 0
    addProgress = addProgress or 0

    local info = self.data.collectionInfo[buildingId]
    info.num = info.num + addNum
    info.progress = info.progress + addProgress
end

function UserManager:GetShopInfo(id)
    local default = {shopId = id, first = false}
    if (self.data.shopInfo == nil) then
        return default
    end
    for _, v in pairs(self.data.shopInfo) do
        if v.shopId == id then
            return v
        end
    end
    return default
end

function UserManager:SetShopInfo(id, isFirst)
    for _, v in pairs(self.data.shopInfo) do
        if v.shopId == id then
            self.isDirty = true
            v.first = isFirst
            return
        end
    end
end

function UserManager:RecordTotalRecharge(rechargeVal)
    self.data.totalRecharge = self.data.totalRecharge + rechargeVal
    console.print(string.format("add total recharge:%d,total recharge:%d", rechargeVal, self.data.totalRecharge)) --@DEL
end

--充值小于5美元的用户
function UserManager:IsLowRechargedUser()
    console.print("total recharge:", self.data.totalRecharge) --@DEL
    return self.data.totalRecharge < 500
end

--和后端同步道具
function UserManager:SyncItems(itemMsgs, itemChangeNum, method, subMethod)
    local function _SyncItem(itemId, count, index)
        local item = {}
        item.itemId = itemId
        item.count = count
        item.cdTimes = {}
        local old = self.data.itemList[itemId]
        local oldNum = old and old.count or 0
        local newNum = item.count
        if item.count == 0 then
            self.data.itemList[itemId] = nil
        else
            self.data.itemList[itemId] = item
        end
        local limit = AppServices.Meta:GetItemLimit(itemId)
        if limit > 0 and item.count >= limit then
            AppServices.UITextTip:Show(Runtime.Translate("ui_item_num_limit"))
        end
        if ItemId.IsSkin(itemId) then
            AppServices.SkinLogic:CheckNewSkins(itemId)
        end
        if oldNum ~= newNum then
            local diffNum = newNum - oldNum
            if itemChangeNum and itemChangeNum[index] then
                local serverDiffNum = itemChangeNum[index]
                if serverDiffNum ~= diffNum then
                    console.error("前后端道具同步数量不一致", " id " .. itemId, "后端变化 " .. serverDiffNum, "前端变化 " .. diffNum) --@DEL
                    diffNum = serverDiffNum
                end
            end
            if diffNum > 0 then
                MessageDispatcher:SendMessage(MessageType.Global_After_AddItem, itemId, diffNum)
            elseif diffNum < 0 then
                self:AddUsedCount(itemId, -diffNum)
                MessageDispatcher:SendMessage(MessageType.Global_After_UseItem, itemId, -diffNum)
            end
            self:reportItem(itemId, diffNum, method, subMethod)
        end
    end

    local index = 1
    for _, itemMsg in ipairs(itemMsgs) do
        local itemId = itemMsg.itemTemplateId
        local count = itemMsg.count
        _SyncItem(itemId, count, index)
        index = index + 1
    end
end

function UserManager:GetExp()
    return self.data.exp
end

function UserManager:RollbackExp(rollbackExp)
    console.error("Warn!!! Exp Roll Back !!! old", self.data.level, "new is ", rollbackExp)
    self.data.exp = rollbackExp
end

function UserManager:AddExp(delta, source)
    self:GetOldExp()
    console.lzl("AddExp_Log old", self.data.exp, "add", delta, "source", source) --@DEL
    self.data.exp = self.data.exp + delta
    self:reportItem(ItemId.EXP, delta, source)
    return self:LevelUp(source)
end

function UserManager:LevelUp(source)
    local levelMeta = AppServices.Meta:GetLevelConfig(self.data.level)
    local info = {}
    local isLvUp = false
    while self.data.exp >= levelMeta.exp do
        if self:IsMaxLevel() then --升级时如果是最高级，执行等级上限处理
            self:HandleMaxLevel(levelMeta, source)
            return isLvUp
        end

        self.data.level = self.data.level + 1
        DcDelegates:Log(SDK_EVENT["level_" .. self.data.level])
        DcDelegates:LogFacebook(SDK_EVENT["level_" .. self.data.level])
        console.lzl("AddExp_Log LevelUp", self.data.level) --@DEL
        isLvUp = true
        self.data.exp = self.data.exp - levelMeta.exp
        local level = self.data.level
        levelMeta = AppServices.Meta:GetLevelConfig(level)
        local logReward = {}
        for _, value in ipairs(levelMeta.levelUpReward) do
            local itemId = tostring(value[1])
            local itemCount = value[2]
            AppServices.User:AddItem(itemId, itemCount, ItemGetMethod.levelReward)
            table.insert(logReward, {itemId, itemCount})
        end
        logReward = CONST.RULES.ConvertLogItem(logReward)
        local dragonCountDic = {}
        local creatures = AppServices.MagicalCreatures:GetAllCreatures()
        for _, creature in ipairs(creatures) do
            dragonCountDic[creature.templateId] = (dragonCountDic[creature.templateId] or 0) + 1
        end
        local dragonCount = {}
        for id, count in pairs(dragonCountDic) do
            table.insert(dragonCount, {id, count})
        end
        dragonCount = CONST.RULES.ConvertLogItem(dragonCount)
        DcDelegates:Log(
            SDK_EVENT.front_level,
            {
                level = self.data.level,
                reward = logReward,
                sceneId = App.scene:GetCurrentSceneId(),
                energyCount = AppServices.User:GetItemAmount(ItemId.ENERGY),
                diamondCount = AppServices.User:GetItemAmount(ItemId.DIAMOND),
                goldCount = AppServices.User:GetItemAmount(ItemId.COIN),
                dragonCount = dragonCount
            }
        )
        --console.error("front_level",  self.data.level, logReward, App.scene:GetCurrentSceneId(), AppServices.User:GetItemAmount(ItemId.ENERGY), AppServices.User:GetItemAmount(ItemId.DIAMOND), AppServices.User:GetItemAmount(ItemId.COIN), dragonCount)
        MessageDispatcher:SendMessage(MessageType.Global_After_Player_Levelup, self.data.level)
        table.insert(info, level)
    end
    AppServices.ExpLogic:LevelUpLogic(info, source)
    return isLvUp
end

function UserManager:IsMaxLevel()
    local maxLevel = AppServices.Meta:GetMaxLevel()
    local userLevel = self:GetCurrentLevelId()
    return userLevel == maxLevel
end

function UserManager:HandleMaxLevel(levelCfg, source)
    local overflowExp = self:GetExp() - levelCfg.exp
    self.data.exp = levelCfg.exp
    local expMgr = AppServices.ExpLogic

    local function changeExpToCoins()
        if overflowExp > 0 then
            local changeRatio = AppServices.Meta:Category("ConfigTemplate").maxLevelExpExchangeGold.value
            local coinCnt = overflowExp * tonumber(changeRatio)
            local cnt = math.max(math.floor(coinCnt), 1)
            self:AddItem(ItemId.COIN, cnt, ItemGetMethod.expExchangeGold)
        end
    end

    local function showFullLevelTip()
        local info = {}
        table.insert(info, self:GetCurrentLevelId())
        expMgr:LevelUpLogic(info, source, true)
    end

    local function refreshExpItem(cbk)
        expMgr:SetFullLevelUI(cbk)
    end

    if self.oldExp < levelCfg.exp then --是否第一次达上限,是则额外显示提示,并刷新UI
        changeExpToCoins()
        refreshExpItem(showFullLevelTip)
    else
        changeExpToCoins()
    end
end

function UserManager:GetOldExp()
    self.oldExp = self:GetExp()
end

function UserManager:AddUsedCount(itemId, num)
    local count = self:GetUsedCount(itemId)
    count = count + num
    console.warn(nil, "AddUsedCount => ID:", itemId, " Current:", count, " Add:", num) --@DEL
    self:SetUsedCount(itemId, count)
end
function UserManager:GetUsedCount(itemId)
    if not self.data.usedItems then
        return 0
    end
    return self.data.usedItems[itemId] or 0
end
function UserManager:SetUsedCount(itemId, count)
    if not self.data.usedItems then
        self.data.usedItems = {}
    end
    self.data.usedItems[itemId] = count
    self.isDirty = true
end

function UserManager:GetFbAccount()
    return self.fbAccount or ""
end

function UserManager:SetFbAccount(account)
    self.fbAccount = account
end

function UserManager:HaveFbAccount()
    return self.fbAccount ~= nil
end

function UserManager:SetFbAccessToken(accessToken)
    self.fbAccessToken = accessToken
end

function UserManager:GetFbAccessToken()
    return self.fbAccessToken or ""
end

---
function UserManager:SetUserGroup(value)
    self.userGroup = value
end

function UserManager:GetUserGroup()
    if not self.userGroup then
        if App.response and App.response.adsIncentive and App.response.adsIncentive.adsGroup then
            self.userGroup = App.response.adsIncentive.adsGroup
        else
            self.userGroup = ""
        end
    end

    return self.userGroup
end

function UserManager:SetFbBindReward(fbBindReward)
    self.fbBindReward = fbBindReward
end

function UserManager:GetFbBindReward()
    return self.fbBindReward ~= nil and self.fbBindReward == 1
end

function UserManager:MarkLastRechargeTime()
    self.data.lastRechargeTime = TimeUtil.ServerTime()
end

function UserManager:GetLastRechargeTime()
    return self.data.lastRechargeTime
end

function UserManager:reportItem(itemId, change, method, subMethod)
    local count = math.abs(change)
    local changeType = change > 0 and 1 or -1
    local itemCfg = AppServices.Meta:GetItemMeta(itemId)
    local remain = ItemId.IsExp(itemId) and self:GetExp() or self:GetItemAmount(itemId)
    local params = {
        itemId = itemId,
        remain = remain,
        type = changeType,
        method = method,
        subMethod = subMethod,
        change = change,
        count = count,
        itemId_type_id = itemCfg.type,
        itemId_type_name = itemCfg.name
    }
    if not method then
        console.lzl("report Item ", table.serialize(params)) --@DEL
    end
    if itemId == "1003" then
        console.warn(nil, "体力统计: Remain:", remain, " , Change: ", change) --@DEL
    end
    DcDelegates:Log(SDK_EVENT.front_reportItem, params)
end

function UserManager:GetTimeZone()
    return self.data.timeZone or 0
end

function UserManager:SetLimiteTimeProduct(msg)
    if not self.limitTimeProducts then
        self.limitTimeProducts = {}
    end
    if not msg then
        return
    end
    for _, product in ipairs(msg) do
        if product.productType then
            self.limitTimeProducts[product.productType] = {
                productType = product.productType,
                expiryTime = product.expiryTime / 1000,
                process = product.process
            }
        end
    end
end
function UserManager:GetLimiteTimeProduct(type)
    if not self.limitTimeProducts then
        return
    end

    if not type then
        return self.limitTimeProducts
    end

    if not self.limitTimeProducts[type] then
        return
    end
    return self.limitTimeProducts[type]
end

function UserManager:GetRecyclableItemDatas()
    local Meta = AppServices.Meta
    local kv = Meta:Category("ConfigTemplate")["recycleDefaultPercentage"]
    local percent = tonumber(kv.value) --出售百分比
    local datas = {}
    for id, item in pairs(self.data.itemList) do
        if item.count > 0 then --背包中有的
            local meta = Meta:GetItemMeta(id)
            if meta.recycleItem and #meta.recycleItem > 0 then --可被回收的
                local data = {
                    meta = meta,
                    select = math.round(item.count * percent)
                }
                table.insert(datas, data)
            end
        end
    end
    return datas
end

return UserManager
