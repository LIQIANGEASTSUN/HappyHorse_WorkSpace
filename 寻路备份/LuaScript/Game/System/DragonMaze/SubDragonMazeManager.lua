---
--- Created by Betta.
--- DateTime: 2022/9/2 14:57
---

---@class SubDragonMazeManager
local SubDragonMazeManager = class(nil, "SubDragonMazeManager")

function SubDragonMazeManager:ctor(type, mazeCfgAry)
    self.mazeType = type
    ---@type DragonMazeInfoResponse
    self.mazeInfo = {type = type, finishLevel = 0, endTime = 0, lastEnterLevel = 0, quickPassEndTime = 0}
    self.showedLevel = 0
    self.mazeCfgAry = mazeCfgAry
    self.mazeDragonIdAry = nil
end

--返回当前在的迷宫层数，或者可以打开的迷宫层数
function SubDragonMazeManager:GetMazeLevel()
    if self.mazeInfo == nil then
        return 0
    end
    if self:IsOpen() == false then
        local level = self.mazeInfo.finishLevel + 1
        local mazeCfg = self:GetMazeCfg(level)
        if not mazeCfg then
            level = self.mazeInfo.finishLevel
        end
        return level
    else
        return self.mazeInfo.lastEnterLevel
    end
end

function SubDragonMazeManager:SetMazeInfo(mazeInfo)
    self.mazeInfo = mazeInfo
    self.showedLevel = mazeInfo.finishLevel
end

function SubDragonMazeManager:OnShow()
    self.showedLevel = self.mazeInfo.finishLevel
end

function SubDragonMazeManager:GetMazeCfg(level)
    return self.mazeCfgAry[tonumber(level)]
end

function SubDragonMazeManager:OpenOrEnterMazeRequest(creatures)
    if self.mazeInfo == nil then
        console.warn(nil, "迷宫消息没有请求")
        return
    end
    local isOpen = self:IsOpen()
    local params = {}
    local function onSuccess(response)
        AppServices.DragonMaze.lastEnterMazeType = self.mazeType
        self.mazeInfo.endTime = response.endTime
        if isOpen == false then
            --[[if self.mazeInfo.count > 0 then
                self.mazeInfo.count = self.mazeInfo.count - 1
            else
                --self.mazeInfo.buyCount = self.mazeInfo.buyCount + 1
                if params.diamonds ~= nil then
                    AppServices.User:UseItem(ItemId.DIAMOND, params.diamonds, ItemUseMethod.buy_dragon_maze_count)
                end
            end--]]
            self.mazeDragonIdAry = creatures
            for _, id in ipairs(creatures) do
                local creature = AppServices.MagicalCreatures:GetCreatureByCreatureId(id)
                if creature ~= nil then
                    creature.mazeEndTime = response.endTime // 1000
                end
            end
            MessageDispatcher:SendMessage(MessageType.OpenDragonMaze)
        end
        self.mazeInfo.lastEnterLevel = params.level
        AppServices.Jump.changeSceneById(
        self:GetMazeCfg(params.level).sceneId,
        function(state)
            --[[if state then
            PopupManager:CallWhenIdle(function()
                AppServices.MagicalCreatures:RequestSelectExploreRelicDragons(body.sceneId, body.creatureIds)
            end)
        end--]]
        end
        )
    end
    local function onFailed(errorCode)
        ErrorHandler.ShowErrorPanel(errorCode)
    end
    if isOpen == false then
        params.creatures = creatures
        --if self.mazeInfo.count <= 0 and self.mazeInfo.buyCount >= #self.spendCount then
        --    return
        --end
        --if self.mazeInfo.count <= 0 and self.mazeInfo.buyCount < #self.spendCount then
        --    params.diamonds = self.spendCount[self.mazeInfo.buyCount + 1]
        --end
        local level = self.mazeInfo.finishLevel + 1
        if self:GetMazeCfg(level) then
            params.level = level
        else
            params.level = self.mazeInfo.finishLevel
        end
    else
        params.level = self.mazeInfo.lastEnterLevel
    end
    params.type = self.mazeType
    --[[local have = AppServices.User:GetItemAmount(ItemId.DIAMOND)
    if params.diamonds and have < params.diamonds then
        AppServices.Jump.JumpShop(
        2,
        GlobalPanelEnum.DragonMazeEnterPanel,
        function()
            PanelManager.showPanel(GlobalPanelEnum.DragonMazeEnterPanel)
        end
        )
    else--]]
        Net.Dragonmazemodulemsg_26802_OpenOrEnterMaze_Request(params, onFailed, onSuccess)
    --end
end

function SubDragonMazeManager:DragonMazeEndRequest(callback)
    if self.mazeInfo == nil then
        console.warn(nil, "迷宫消息没有请求")
        return
    end
    local function onSuccess(response)
        self.mazeInfo.endTime = 0
        self:MazeFail()
        Runtime.InvokeCbk(callback, true)
    end
    local function onFailed(errorCode)
        ErrorHandler.ShowErrorPanel(errorCode)
        Runtime.InvokeCbk(callback, false)
    end
    Net.Dragonmazemodulemsg_26803_DragonMazeEnd_Request({type = self.mazeType}, onFailed, onSuccess)
end

function SubDragonMazeManager:QuickPassDragonMazeRequest(creatureids, callback)
    local function onSuccess(response)
        self.mazeInfo.quickPassEndTime = response.cdEndTime
        local creatures = response.creatures
        if creatures then
            for _, v in ipairs(creatures) do
                AppServices.MagicalCreatures:SyncEntityData(v)
            end
        end
        if response.items then
            for _, item in ipairs(response.items) do
                local itemId = item.itemTemplateId
                local amount = item.count
                if itemId == ItemId.EXP then
                    AppServices.User:AddExp(amount, ItemGetMethod.DragonDraw)
                elseif ItemId.IsDragon(itemId) then
                    AppServices.MagicalCreatures:AddDragonByItem(itemId,nil, nil, nil, 2)
                else
                    AppServices.User:AddItem(itemId, amount, ItemGetMethod.dragon_maze_quick_pass)
                end
            end
        end
        MessageDispatcher:SendMessage(MessageType.OpenDragonMaze)
        Runtime.InvokeCbk(callback, true, response)
    end
    local function onFailed(errorCode)
        ErrorHandler.ShowErrorPanel(errorCode)
        Runtime.InvokeCbk(callback, false)
    end
    if self:IsOpen() then
        return
    end
    if self:IsQuickPassCD() then
        return
    end
    local params = {}
    params.creatures = creatureids
    params.level = self.mazeInfo.finishLevel
    params.type = self.mazeType
    Net.Dragonmazemodulemsg_26807_QuickPassDragonMaze_Request(params, onFailed, onSuccess)
end

function SubDragonMazeManager:FinishQuickPassCDRequest()
    local params = {}
    params.type = self.mazeType
    params.cost = self:CalculateQuickPassCDCost()
    local function onSuccess(response)
        self.mazeInfo.quickPassEndTime = 0
        AppServices.User:UseItem(ItemId.DIAMOND, params.cost, ItemUseMethod.dragon_maze_quick_pass_cd)
    end
    local function onFailed(errorCode)
        ErrorHandler.ShowErrorPanel(errorCode)
    end
    if not self:IsQuickPassCD() then
        return
    end
    local have = AppServices.User:GetItemAmount(ItemId.DIAMOND)
    if params.cost and have < params.cost then
        AppServices.Jump.JumpShop(
        2,
        GlobalPanelEnum.DragonMazeEnterPanel,
        function()
            PanelManager.showPanel(GlobalPanelEnum.DragonMazeEnterPanel)
        end
        )
    else
        Net.Dragonmazemodulemsg_26808_FinishQuickPassCD_Request(params, onFailed, onSuccess)
    end
end

function SubDragonMazeManager:GetInMazeDragons()
    if self.mazeDragonIdAry == nil then
        self.mazeDragonIdAry = {}
        local datas = AppServices.MagicalCreatures:GetDragonsByAttributeTypeAndMinLevel(self.mazeType, 1)
        for _, v in ipairs(datas) do
            if v.mazeEndTime and v.mazeEndTime > TimeUtil.ServerTime() then
                table.insert(self.mazeDragonIdAry, v.creatureId)
            end
        end
    end
    return self.mazeDragonIdAry
end

function SubDragonMazeManager:IsInMaze(creatureId)
    return table.exists(self:GetInMazeDragons(), creatureId)
end

function SubDragonMazeManager:IsOpen()
    if self.mazeInfo == nil then
        console.warn(nil, "迷宫消息没有请求")
        return false
    end
    return self.mazeInfo.endTime > TimeUtil.ServerTime() * 1000
end

function SubDragonMazeManager:RefreshTime()
    if self.mazeInfo and self.mazeInfo.endTime > 0 and not self:IsOpen() then
        self.mazeInfo.endTime = 0
        self:MazeFail()
        MessageDispatcher:SendMessage(MessageType.DragonMazeTimeOver, self.mazeType)
    end
end

function SubDragonMazeManager:MazeFail()
    local mazeDragonIdAry = self:GetInMazeDragons()
    for _, id in ipairs(mazeDragonIdAry) do
        local creature = AppServices.MagicalCreatures:GetCreatureByCreatureId(id)
        if creature ~= nil then
            creature.mazeEndTime = 0
        end
    end
    self.mazeDragonIdAry = {}
    local items = AppServices.User:GetItemsList()
    local delItemIdAry = {}
    for itemId, item in pairs(items) do
        local itemMeta = AppServices.Meta:GetItemMeta(itemId)
        if itemMeta and tostring(itemMeta.sceneId) == tostring(-self.mazeType) then
            delItemIdAry[#delItemIdAry + 1] = itemId
        end
    end
    for _, itemId in ipairs(delItemIdAry) do
        AppServices.User:SetPropNumber(itemId, 0)
    end
end

function SubDragonMazeManager:MazeSuccess()
    local lastFinishLevel = self.mazeInfo.finishLevel
    self.mazeInfo.finishLevel = self.mazeInfo.lastEnterLevel
    self.mazeInfo.endTime = 0
    local mazeDragonIdAry = self:GetInMazeDragons()
    for _, id in ipairs(mazeDragonIdAry) do
        local creature = AppServices.MagicalCreatures:GetCreatureByCreatureId(id)
        if creature ~= nil then
            creature.mazeEndTime = 0
        end
    end
    self.mazeDragonIdAry = {}
    local items = AppServices.User:GetItemsList()
    local delItemIdAry = {}
    for itemId, item in pairs(items) do
        local itemMeta = AppServices.Meta:GetItemMeta(itemId)
        if itemMeta and tostring(itemMeta.sceneId) == tostring(-self.mazeType) then
            delItemIdAry[#delItemIdAry + 1] = itemId
        end
    end
    for _, itemId in ipairs(delItemIdAry) do
        AppServices.User:SetPropNumber(itemId, 0)
    end
    MessageDispatcher:SendMessage(MessageType.DragonMazeSuccess, self.mazeInfo.finishLevel, lastFinishLevel)
end
---是否是第一次通关
function SubDragonMazeManager:IsFirstOpen()
    if self.mazeInfo and self.mazeInfo.finishLevel >= self.mazeInfo.lastEnterLevel then
        return false
    end
    return true
end
---是否通关最后一关
function SubDragonMazeManager:IsFinishLast()
    if self.mazeInfo and self.mazeInfo.finishLevel >= #self.mazeCfgAry then
        return true
    end
    return false
end
---是否通关第一关
function SubDragonMazeManager:IsFinishFirst()
    if self.mazeInfo and self.mazeInfo.finishLevel > 0 then
        return true
    end
    return false
end
---
function SubDragonMazeManager:IsQuickPassCD()
    if self.mazeInfo and self.mazeInfo.quickPassEndTime > TimeUtil.ServerTime() * 1000 then
        return true
    end
    return false
end
function SubDragonMazeManager:CalculateQuickPassCDCost()
    local difftime = math.max(0, self.mazeInfo.quickPassEndTime / 1000 - TimeUtil.ServerTime())
    return math.ceil((difftime / 60) * AppServices.DragonMaze.dragonMazeSweepSpeedup)
end
return SubDragonMazeManager
