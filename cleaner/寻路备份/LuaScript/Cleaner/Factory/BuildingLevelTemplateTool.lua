---@class BuildingLevelTemplateTool
local BuildingLevelTemplateTool = {
    factoryTable = nil,
}

function BuildingLevelTemplateTool:GetKey(sn, level)
    if not self.factoryTable then
        self:ReadTable()
    end

    local buildData = self.factoryTable[tostring(sn)]
    if not buildData then
        return ""
    end
    return buildData[level]
end

function BuildingLevelTemplateTool:GetConfig(sn, level)
    local key = self:GetKey(sn, level)
    local config = AppServices.Meta:Category("BuildingLevelTemplate")
    return config[tostring(key)]
end

function BuildingLevelTemplateTool:ReadTable()
    self.factoryTable = {}

    local config = AppServices.Meta:Category("BuildingLevelTemplate")
    for _, data in pairs(config) do
        local buildId = tostring(data.building)
        local buildData = self.factoryTable[buildId]
        if not buildData then
            buildData = {}
            self.factoryTable[buildId] = buildData
        end

        buildData[data.level] = data.sn
    end
end

function BuildingLevelTemplateTool:EnableUp(data)
    if (not data.upgradeCost) or (#data.upgradeCost <= 0) then
        return UpgradeEnableType.MaxLevel
    end

    local enougth = AppServices.ItemCostManager:IsItemEnougth(data.upgradeCost)
    if not enougth then
        return UpgradeEnableType.ItemNotEnougth
    end

    local roleLevel = data.roleLevel
    local playerLevel = AppServices.User:GetPlayerLevel()
    if playerLevel < roleLevel then
        return UpgradeEnableType.PlayerLevelSmall
    end

    return UpgradeEnableType.Enable
end

function BuildingLevelTemplateTool:CreateProductionData(id, level, sn)
    local data = {}
    data.id = id
    data.level = level

    data.recipe = {}
    sn = AppServices.BuildingLevelTemplateTool:GetKey(sn, data.level)
    local configData = AppServices.Meta:Category("BuildingLevelTemplate")[tostring(sn)]
    for _, v in pairs(configData.material) do
        local dintInt = {key = v[1], value = v[2]}
        table.insert(data.recipe, dintInt)
    end

    -- 秒
    data.startTime = TimeUtil.ServerTime()
    data.endTime = TimeUtil.ServerTime() + configData.time

    data.outItem = {}
    for _, v in pairs(configData.production) do
        local dintInt = {key = v[1], value = v[2]}
        table.insert(data.outItem, dintInt)
    end

    return data
end

return BuildingLevelTemplateTool