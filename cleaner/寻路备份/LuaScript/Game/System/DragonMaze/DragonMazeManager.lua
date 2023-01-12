---
--- Created by Betta.
--- DateTime: 2022/3/29 14:39
---
---@field count number
---@field finishLevel number
---@field endTime number
---@field buyCount  number
---@field lastEnterLevel number
---@class DragonMazeInfoResponse

local SubDragonMazeManager = require("Game.System.DragonMaze.SubDragonMazeManager")
---@class DragonMazeManager
local DragonMazeManager = {}

function DragonMazeManager:Init()
    self.dragonTypeMazeCfg = {}
    self.mazeInfoAry = nil
    ---@type SubDragonMazeManager[]
    self.subManager = {}
    self.exitAgentId = nil
    self.freeCount = tonumber(AppServices.Meta:GetConfigMetaValue("DragonMazeOpen"))
    self.spendCount = table.deserialize(AppServices.Meta:GetConfigMetaValue("DragonMazeOpenBuy"))
    self.dragonMazeSweepSpeedup = tonumber(AppServices.Meta:GetConfigMetaValue("dragonMazeSweepSpeedup"))
    self.dragonMazeSweepCD = tonumber(AppServices.Meta:GetConfigMetaValue("dragonMazeSweepCD"))
    self.lastEnterMazeType = 1

    if self:IsUnlock() then
        self:ProcessUnlock()
    else
        MessageDispatcher:AddMessageListener(MessageType.Global_OnUnlock, self.Unlock, self)
    end

    local cfgArray = {}
    local cfgDic = AppServices.Meta.metas.DragonMazeTemplate
    for id, cfg in pairs(cfgDic) do
        id = tonumber(id)
        if id then
            cfgArray[id] = cfg
        end
    end
    for _, cfg in ipairs(cfgArray) do
        local cfgs = self.dragonTypeMazeCfg[cfg.dragonType]
        if cfgs == nil then
            cfgs = {}
            self.dragonTypeMazeCfg[cfg.dragonType] = cfgs
        end
        table.insert(cfgs, cfg)
    end
    for k, cfgAry in ipairs(self.dragonTypeMazeCfg) do
        self.subManager[k] = SubDragonMazeManager.new(k, cfgAry)
    end
end

local mt = {
    ---@param t DragonMazeManager23
    __index = function(t, k)
        if SubDragonMazeManager[k] ~= nil then
            local CallSubManager = function(_, dragonType, ...)
                if dragonType == nil then
                    return
                end
                local subDragonMazeManager = t.subManager[dragonType]
                if subDragonMazeManager then
                    return subDragonMazeManager[k](subDragonMazeManager, ...)
                end
            end
            return CallSubManager
        --[[elseif rawget(t, k .. "Sync") then
            local CallSync = function(_, callback, ...)
                if rawget(t, "mazeInfoAry") then
                    return t[k .. "Sync"](t, ...)
                else
                    local params = {...}
                    local func = function()
                        if rawget(t, "mazeInfoAry") then
                            table.insert(params, t[k .. "Sync"](t, ...))
                        end
                        Runtime.InvokeCbk(callback, table.unpack(params))
                    end
                    t:DragonMazeInfoRequest(t[k .. "Sync"], func)
                end
            end
            return CallSync--]]
        end
        return nil
    end
}
setmetatable(DragonMazeManager, mt)

function DragonMazeManager:IsUnlock()
    --return true
    return AppServices.Unlock:IsUnlock("dragonmaze")
end

function DragonMazeManager:Unlock(key)
    if key == "dragonmaze" then
        self:ProcessUnlock()
        MessageDispatcher:RemoveMessageListener(MessageType.Global_OnUnlock, self.Unlock, self)
    end
end

function DragonMazeManager:ProcessUnlock()
    self:DragonMazeInfoRequest()
    WaitExtension.InvokeRepeating(
        function()
            for _, sub in ipairs(self.subManager) do
                sub:RefreshTime()
            end
        end,
        10,
        10
    )
end

function DragonMazeManager:HasCanBuy()
    if not self.shopDataMap then
        return false
    end
    for key, value in pairs(self.shopDataMap) do
        local config = AppServices.Meta:Category("DragonMazeShopTemplate")[key]
        local selectConfig = config.shop_item[value.pIndex + 1]
        local hasCount = AppServices.User:GetItemAmount(selectConfig[4])
        if hasCount >= selectConfig[3] then
            return true
        end
    end
    return false
end

function DragonMazeManager:CheckShopGuide()
    if App.mapGuideManager:HasComplete(GuideIDs.GuideMazeShop) then
        return
    end

    if App.scene:GetSceneType() ~= SceneType.Maze then
        return
    end

    if not self.shopDataMap then
        local function requestCallback(result)
            if not result then
                return
            end
            self:CheckShopGuide()
        end

        AppServices.DragonMaze:DragonMazeShopInfoRequest(requestCallback)
        return
    end

    if not self:HasCanBuy() then
        return
    end

    local function idleDo()
        App.mapGuideManager:StartSeries(GuideIDs.GuideMazeShop)
    end

    local function checkFunc()
        local leftBottom = App.scene.view.rootView.layout:BottomLeft()
        return leftBottom.anchoredPosition.y > 6
    end

    PopupManager:CallWhenIdle(idleDo, checkFunc)
end
local playMazeEnterDramaKey = "playMazeEnterDramaKey"
function DragonMazeManager:NeedPlayDrama()
    return not AppServices.User.Default:GetKeyValue(playMazeEnterDramaKey, false) and
        not App.mapGuideManager:HasComplete("GuideMazeEnterUI")
end

function DragonMazeManager:OpenUI()
    if not self:IsUnlock() then
        return
    end
    --解锁了 但是还没播过剧情
    if self:NeedPlayDrama() then
        return
    end

    local func = function()
        PanelManager.showPanel(GlobalPanelEnum.DragonMazeEnterPanel)
        --PanelManager.showPanel(GlobalPanelEnum.DragonMazeEnterPanel, {creatures = {2064, 2062}})
    end
    if self.mazeInfoAry ~= nil then
        func()
    else
        self:DragonMazeInfoRequest(func)
    end
end

function DragonMazeManager:OpenShop()
    local function requestCallback(result)
        if not result then
            return
        end
        PanelManager.showPanel(GlobalPanelEnum.MazeShopPanel)
    end

    self:DragonMazeShopInfoRequest(requestCallback)
end

function DragonMazeManager:GetMazeInfo(dragonType, callback, ...)
    local params = {...}
    local func = function()
        if self.mazeInfoAry ~= nil then
            table.insert(params, self.subManager[dragonType].mazeInfo)
        end
        Runtime.InvokeCbk(callback, table.unpack(params))
    end
    if self.mazeInfoAry ~= nil then
        func()
    else
        self:DragonMazeInfoRequest(func)
    end
end

function DragonMazeManager:DragonMazeInfoRequest(callback, ...)
    local params = {...}
    local function onSuccess(response)
        self.mazeInfoAry = response.mazeInfos
        for _, mazeinfo in ipairs(self.mazeInfoAry) do
            if self.subManager[mazeinfo.type] then
                self.subManager[mazeinfo.type]:SetMazeInfo(mazeinfo)
            end
        end
        table.insert(params, self.mazeInfoAry)
        Runtime.InvokeCbk(callback, table.unpack(params))
    end
    local function onFailed(errorCode)
        ErrorHandler.ShowErrorPanel(errorCode)
        Runtime.InvokeCbk(callback, table.unpack(params))
    end
    Net.Dragonmazemodulemsg_26806_DragonMazeInfoV23_Request({}, onFailed, onSuccess)
end

function DragonMazeManager:IsInMaze(creatureId)
    for _, sub in ipairs(self.subManager) do
        if sub:IsInMaze(creatureId) then
            return true
        end
    end
    return false
end

function DragonMazeManager:GetShopDataById(id)
    if not self.shopDataMap then
        return
    end
    return self.shopDataMap[id]
end

function DragonMazeManager:DragonMazeShopInfoRequest(callback, force)
    local function onSuccess(response)
        self.shopDataMap = {}
        for index, value in ipairs(response.products) do
            local data = {
                id = value.id,
                buyCount = value.count,
                pIndex = value.pIndex
            }
            self.shopDataMap[value.id] = data
        end

        Runtime.InvokeCbk(callback, true)
    end

    local function onFailed(errorCode)
        ErrorHandler.ShowErrorPanel(errorCode)
        Runtime.InvokeCbk(callback, false)
    end

    if self.shopDataMap and not force then
        Runtime.InvokeCbk(callback, true)
    end

    Net.Dragonmazemodulemsg_26804_DragonMazeShopInfo_Request(nil, onFailed, onSuccess)
end

function DragonMazeManager:BuyMazeShopProductRequest(id, count, callback)
    local function onSuccess(response)
        local shopData = self.shopDataMap[id]
        if shopData then
            shopData.buyCount = shopData.buyCount + count
        end

        Runtime.InvokeCbk(callback, true, count)
    end
    local function onFailed(errorCode)
        ErrorHandler.ShowErrorPanel(errorCode)
        Runtime.InvokeCbk(callback, false)
    end
    Net.Dragonmazemodulemsg_26805_BuyMazeShopProduct_Request({id = id, count = count}, onFailed, onSuccess)
end

function DragonMazeManager:GetExitAgentPos()
    local agent = App.scene.objectManager:GetAgent(self.exitAgentId)
    if agent then
        return agent:GetAnchorPosition()
    end
    return Vector3(0, 0, 0)
end

function DragonMazeManager:CanQuickPass(callback, ...)
    local params = {...}
    local func = function()
        for _, sub in ipairs(self.subManager) do
            if sub:IsFinishFirst() and not sub:IsQuickPassCD() and not sub:IsOpen() then
                table.insert(params, true)
                Runtime.InvokeCbk(callback, table.unpack(params))
                return true
            end
        end
        table.insert(params, false)
        Runtime.InvokeCbk(callback, table.unpack(params))
        return false
    end
    if self.mazeInfoAry ~= nil then
        return func()
    else
        self:DragonMazeInfoRequest(func)
    end
end

function DragonMazeManager:HasOpen(callback)
    local func = function()
        for _, sub in ipairs(self.subManager) do
            if sub:IsOpen() then
                Runtime.InvokeCbk(callback, true)
                return
            end
        end

        Runtime.InvokeCbk(callback, false)
    end
    if self.mazeInfoAry ~= nil then
        return func()
    else
        self:DragonMazeInfoRequest(func)
    end
end

function DragonMazeManager:CheckMazeUpLevelPop()
    if self.mazeInfoAry == nil or App.scene:GetCurrentSceneId() ~= "city" then
        return false
    end
    for index, sub in ipairs(self.subManager) do
        if sub.showedLevel ~= sub.mazeInfo.finishLevel then
            return true, index
        end
    end
    return false
end

function DragonMazeManager:OnMazeUpLevelPop(finishCallback)
    PanelManager.showPanel(GlobalPanelEnum.DragonMazeEnterPanel, {finishCallback = finishCallback})
end

return DragonMazeManager
