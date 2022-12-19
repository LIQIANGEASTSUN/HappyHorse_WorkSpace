---@class RegionManager
local RegionManager = class(nil, "RegionManager")
local Rect = require("MainCity.Data.Rect")
local Region = require("MainCity.Data.Region")

function RegionManager:ctor(sceneId)
    local cfgPath = "Configs.Maps." .. sceneId .. ".regions"
    self.regionGroup = include(cfgPath)

    ---List<RegionMeta>
    self.regionMetas = self.regionGroup.regionMetas
    ---List<RectMeta>
    self.rectMetas = self.regionGroup.rectMetas

    ---@type Dictionary<int, Region> key:区域编号
    self.regions = {}
    ---@type Dictionary<int, Rect> key:区块编号
    self.rects = {}
    self.triggerPoints = {}

    self.isFinish = true
end

function RegionManager:Init(data)
    local linkIslands = data.linkIslands or {}
    --先初始化区块, 后面区域初始化查找相应的区块并绑定
    for _, rectMeta in ipairs(self.rectMetas) do
        self.rects[rectMeta.id] = Rect.new(rectMeta)
    end
    for _, regionMeta in ipairs(self.regionMetas) do
        local rects = {}
        for _, rId in ipairs(regionMeta.rectIDs) do
            table.insert(rects, self.rects[rId])
        end
        local region = Region.new(regionMeta, rects)
        if table.exists(linkIslands, regionMeta.id) then
            region:SetLinked(true)
        else
            local triggerPoints = regionMeta.triggerPoints
            for _, point in ipairs(triggerPoints) do
                self:AddTriggerPoint(point, regionMeta.id)
            end
        end
        self.regions[regionMeta.id] = region
    end

    for _, region in pairs(self.regions) do
        if not region.initialized then
            region:Init()
        end
    end
end

function RegionManager:AddTriggerPoint(point, regionId)
    local x, z = point[1], point[2]
    if not self.triggerPoints[x] then
        self.triggerPoints[x] = {}
    end
    if not self.triggerPoints[x][z] then
        self.triggerPoints[x][z] = {}
    end
    table.insert(self.triggerPoints[x][z], regionId)
end
function RegionManager:RmvTriggerPoint(point, regionId)
    local x, z = point[1], point[2]
    if not self.triggerPoints[x] then
        return
    end
    if not self.triggerPoints[x][z] then
        return
    end
    table.removeIfExist(self.triggerPoints[x][z], regionId)
    if #self.triggerPoints[x][z] == 0 then
        self.triggerPoints[x][z] = nil
    end
    if table.count(self.triggerPoints[x]) == 0 then
        self.triggerPoints[x] = nil
    end
end
function RegionManager:TriggerPoint(x, z)
    if not self.triggerPoints[x] then
        return
    end
    local regionIds = self.triggerPoints[x][z]
    if not regionIds then
        return
    end
    for _, regionId in ipairs(regionIds) do
        local region = self:FindRegion(regionId)
        if not region:IsLinked() then
            region:OnRegionLinked()

            local triggerPoints = region.meta.triggerPoints
            for _, point in ipairs(triggerPoints) do
                self:RmvTriggerPoint(point, region.id)
            end
        end
    end
end

---@param region_id number
---@return Region
function RegionManager:FindRegion(region_id)
    if region_id then
        return self.regions[region_id]
    end
end

---@return Rect
function RegionManager:FindRect(rect_id)
    return self.rects[rect_id]
end

---is this tile available(open) in regions
---@param x number
---@param y number
---@return boolean, boolean @the first value means open or not the
--- second value means contains in or not
function RegionManager:IsGridOpened(x, z)
    ---@param region Region
    for _, region in pairs(self.regions) do
        local contains, open = region:ContainsGrid(x, z)
        if contains then
            return open, true
        end
    end
end

---@return Region
---@param positoin Vector3 世界坐标
function RegionManager:GetRegionByGrid(x, z)
    for _, region in pairs(self.regions) do
        if region:ContainsGrid(x, z) then
            return region
        end
    end
end

function RegionManager:DrawGizmos()
    for _, region in pairs(self.regions) do
        region:DrawGizmos()
    end

    for _, rect in pairs(self.rects) do
        rect:DrawGizmos()
    end
end

function RegionManager:OnDestroy()
    if self.regions then
        for _, region in pairs(self.regions) do
            region:OnDestroy()
        end
    end
end
return RegionManager
