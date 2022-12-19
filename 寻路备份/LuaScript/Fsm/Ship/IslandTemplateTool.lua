
---@class IslandTemplateTool
local IslandTemplateTool = {
    islandIds = {},
    homelandId = nil,
}

function IslandTemplateTool:GetHomelandId()
    if not self.homelandId then
        self:GetAllIsland()
    end
    return self.homelandId
end

function IslandTemplateTool:GetType(islandId)
    local key = tostring(islandId)
    local data = self:GetData(key)
    if data then
        return data.type
    end

    return IslandTemplateType.Homeland
end

function IslandTemplateTool:GetAllIsland()
    if #self.islandIds > 0 then
        return self.islandIds
    end

    local config = AppServices.Meta:Category("IslandTemplate")
    for _, data in pairs(config) do
        if data.type == IslandTemplateType.Island then
            table.insert(self.islandIds, data.sn)
        elseif data.type == IslandTemplateType.Homeland then
            self.homelandId = data.sn
        end
    end

    table.sort(self.islandIds, function(a, b)
        return tonumber(a) < tonumber(b)
    end)

    return self.islandIds
end

function IslandTemplateTool:IsValid(islandId)
    local key = tostring(islandId)
    local data = self:GetData(key)
    if not data then
        return false
    end
    return true
end

function IslandTemplateTool:GetData(key)
    local config = AppServices.Meta:Category("IslandTemplate")
    return config[tostring(key)]
end

function IslandTemplateTool:GetPosData(islandId)
    local data = self:GetData(islandId)
    local shipPos = Vector3(data.shipPos[1], 0, data.shipPos[2])
    local playerPos = Vector3(data.bornPos[1], 0, data.bornPos[2])
    local shipDir = Vector3(data.shipDir[1], 0, data.shipDir[2])
    return shipPos, playerPos, shipDir
end

function IslandTemplateTool:GetHomelandPos(islandId)
    local key = tostring(islandId)
    if not self:IsValid(islandId) then
        self:GetAllIsland()
        key = self.homelandId
    end
    return self:GetPosData(key)
end

function IslandTemplateTool:GetIslandPos(islandId)
    local key = tostring(islandId)
    if not self:IsValid(islandId) then
        self:GetAllIsland()
        key = self.islandIds[1]
    end
    return self:GetPosData(key)
end

return IslandTemplateTool