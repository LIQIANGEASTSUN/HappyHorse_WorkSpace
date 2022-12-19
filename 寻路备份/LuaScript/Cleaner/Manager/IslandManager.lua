---@type IslandTemplateTool
local IslandTemplateTool = require "Fsm.Ship.IslandTemplateTool"

---@type IslandManager
local IslandManager = {
    -- 解锁的岛屿
    unlcokIslandMap = {},
    -- 岛屿进度
    islandProgressMap = {},

    shipDockLevel = 1,
}

function IslandManager:Init()

    self:RegisterEvent()

    self:ReCalculateAllIsland()
end

function IslandManager:InIsland()
    local islandId = AppServices.User:GetPlayerIslandInfo()
    local type = IslandTemplateTool:GetType(islandId)
    local isIsland = (type == IslandTemplateType.Island)
    return isIsland, islandId
end

-- 岛屿可以出航
function IslandManager:EnableSailling(islandId)
    if not self:IsUnLock(islandId) then
        return false
    end

    local islinkHomeland = AppServices.User:IsLinkHomeland(islandId)
    return not islinkHomeland
end

function IslandManager:EnableLinkHomeland(islandId)
    if not self:IsUnLock(islandId) then
        return false
    end

    local progress = self:GetIslandProgress(islandId)
    return progress >= 1
end

function IslandManager:GetShipDockInfo()
    local id = self.shipDockId
    local sn = self.shipDockSn
    local level = self.shipDockLevel
    return id, sn, level
end

-- 岛屿解锁
function IslandManager:IsUnLock(islandId)
    local result = self.unlcokIslandMap[islandId]
    if result then
        return true
    end

    local type = IslandTemplateTool:GetType(islandId)
    if type == IslandTemplateType.Homeland then
        return true
    end

    local metaData = IslandTemplateTool:GetData(islandId)
    if not metaData then
        return false
    end

    local unlockCondition = metaData.unlockCondition
    if not unlockCondition or #unlockCondition <= 0 then
        return true
    end

    result = true
    for _, data in pairs(unlockCondition) do
        if data[1] == IslandUnlockCondition.ShipDock_Level then
            result = self:CheckShipyardLevel(data)
        elseif data[1] == IslandUnlockCondition.Pre_island then
            result = self:PreIslandComplete(data)
        end

        if not result then
            break
        end
    end

    self.unlcokIslandMap[islandId] = result
    return result
end

function IslandManager:CheckShipyardLevel(data)
    return self.shipDockLevel >= tonumber(data[2])
end

function IslandManager:PreIslandComplete(data)
    local preIslandId = data[2]
    local islinkHomeland = AppServices.User:IsLinkHomeland(preIslandId)
    if islinkHomeland then
        return islinkHomeland
    end

    return self:CheckIslandProgress(data)
end

function IslandManager:CheckIslandProgress(data)
    local preIslandId = data[2]
    local progress = self:GetIslandProgress(preIslandId)
    return progress >= 1
end

function IslandManager:GetIslandProgress(islandId)
    if not self.islandProgressMap[islandId] then
        return 0
    end
    return self.islandProgressMap[islandId]
end

function IslandManager:BuildingRemove(id)
    self:ReCalculateAllIsland(id)
end

function IslandManager:ReCalculateAllIsland(removeBuildId)
    local ids = IslandTemplateTool:GetAllIsland()
    for _, id in pairs(ids) do
        self:CalculateIslandProgress(id, removeBuildId)
    end
end

function IslandManager:CalculateIslandProgress(islandId, removeBuildId)
    local progress = self:GetIslandProgress(islandId)
    if progress >= 1 then
        return
    end

    local islandConfig = IslandTemplateTool:GetData(islandId)
    local bossIds = islandConfig.bossId
    if not bossIds or #bossIds <= 0 then
        self.islandProgressMap[islandId] = 1
        return
    end

    local modify = false
    local totalCount = #bossIds
    local removeCount = 0
    for _, bossId in pairs(bossIds) do
        local isRemove = AppServices.User:IsBuildingRemove(bossId)
        if isRemove then
            removeCount = removeCount + 1
        end
        if removeBuildId and tonumber(removeBuildId) == bossId then
            modify = true
        end
    end

    progress = removeCount / totalCount
    self.islandProgressMap[islandId] = progress

    if modify then
        MessageDispatcher:SendMessage(MessageType.IslandProgressChange, islandId, progress)
    end
end

function IslandManager:ShipDockLevel(id, sn, level)
    self.shipDockId = id
    self.shipDockSn = sn
    self.shipDockLevel = level
end

function IslandManager:Release()
    self:UnRegisterEvent()
end

function IslandManager:RegisterEvent()
    MessageDispatcher:AddMessageListener(MessageType.BuildingRemove, self.BuildingRemove, self)
    MessageDispatcher:AddMessageListener(MessageType.ShipDockLevel, self.ShipDockLevel, self)
end

function IslandManager:UnRegisterEvent()
    MessageDispatcher:RemoveMessageListener(MessageType.BuildingRemove, self.BuildingRemove, self)
    MessageDispatcher:RemoveMessageListener(MessageType.ShipDockLevel, self.ShipDockLevel, self)
end

return IslandManager