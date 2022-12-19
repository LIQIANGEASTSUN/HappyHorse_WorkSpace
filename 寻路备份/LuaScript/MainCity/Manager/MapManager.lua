---@class MapManager
local MapManager = class(nil, "MapManager")
local RegionManager = require("Maincity.Manager.RegionManager")
local changingGrids = {}
local index = 0
local TileType = TileType
local Bit = require "Utils.bitOp"

function MapManager:ctor(sceneId)
    changingGrids = {}
    index = 0 --@DEL
    self.sceneId = sceneId
    ---@type Vector2 @地图大小
    self.mapSize = nil
    self.gridSize = 0.5

    ---@type Vector3 @地图原点位置(世界坐标)
    self.mapOrigin = nil

    ---地图格子类型二维数组
    self.typeMap = nil
    ---@type dictionary<int, int[]> 格子状态二维数组
    self.stateMap = {}
    ---@type dictionary<int, BaseAgent[]> 障碍物数组 key=>[x, z] 为格子坐标, value => BaseAgent
    self.objMap =
        setmetatable(
        {},
        {
            __index = function(tb, key)
                local col =
                    setmetatable(
                    {},
                    {
                        __index = function(t, k)
                            local cel = {}
                            rawset(t, k, cel)
                            return cel
                        end
                    }
                )
                rawset(tb, key, col)
                return col
            end
        }
    )

    ---关联格子二维数组, key => [x, z] 为格子坐标, value => list:[(x,z), (x,z)...]为关联格子坐标
    self.relatedMap = {}
    ---障碍物消耗基础奖励信息
    self.objRewardInfos = {}

    ---@type RegionManager
    self.regionManager = RegionManager.new(self.sceneId)
end

function MapManager:InitLocal(data)
    local layout = CONST.RULES.LoadMapLayout(self.sceneId)
    self.mapSize = layout.mapSize
    self.gridSize = layout.gridSize
    local origin = layout.Anchor
    self.mapOrigin = Vector3(origin[1], origin[2], origin[3])
    local anchorMin = layout.Min
    self.cameraAnchorMin = Vector3(anchorMin[1], anchorMin[2], anchorMin[3])
    local anchorMax = layout.Max
    self.cameraAnchorMax = Vector3(anchorMax[1], anchorMax[2], anchorMax[3])

    ---初始化地图:
    --地形
    self.typeMap = layout.types
    --格子关联
    for _, relation in pairs(layout.gridRelations) do
        local x = relation.grid[1]
        local z = relation.grid[2]
        if not self.relatedMap[x] then
            self.relatedMap[x] = {}
        end
        self.relatedMap[x][z] = relation.relatedGrids
    end
    --记录原始开放格子
    self.openGrids = layout.openGrids
    self.regionManager:Init(data)
end

function MapManager:InitServer(data)
    --默认开启格子
    for _, open in pairs(self.openGrids) do
        local x = open[1]
        local z = open[2]
        local state = CleanState.clearing
        self:SetState(x, z, state)
    end
    -- self.cleanTipManager:Start()
    index = 1 --@DEL
end

function MapManager:GetCameraAnchor()
    return self.cameraAnchorMin, self.cameraAnchorMax
end

---获取格子类型, 因为lua下标从1开始, 地图坐标位置需要偏移+1
function MapManager:GetGridType(x, z)
    if x and z and self.typeMap[x + 1] then
        return self.typeMap[x + 1][z + 1] or TileType.none
    end
    return TileType.none
end

---地块属性是否为可通过
function MapManager:IsPassable(x, z)
    if x and z and self.typeMap[x + 1] then
        local t = self.typeMap[x + 1][z + 1]
        return t and Bit.And(t, TileType.pass) > 0
    end
    return false
end
---地块属性是否为可放置
function MapManager:IsGridPlacable(x, z)
    if x and z and self.typeMap[x + 1] then
        local t = self.typeMap[x + 1][z + 1]
        return t and Bit.And(t, TileType.place) > 0
    end
end

-----------------------------格子相关逻辑-----------------------------
---@return BaseAgent[]
function MapManager:GetObjects(x, z)
    return {table.unpack(self.objMap[x][z])}
end
function MapManager:HasObjects(x, z)
    return #self.objMap[x][z] > 0
end

---@param agent BaseAgent 将障碍物按占地大小写入二维地图, 方便查找
function MapManager:InsertObject(agent)
    local sx, sz = agent:GetSize()
    if sx > 0 and sz > 0 then
        local x, z = agent:GetMin()
        ---超出地图边界, 返回空
        if x < 0 or x >= self.mapSize[1] then
            return
        end
        if z < 0 or z >= self.mapSize[2] then
            return
        end
        for i = x, x + sx - 1 do
            for j = z, z + sz - 1 do
                table.insert(self.objMap[i][j], agent)
            end
        end
    end
end
---@param agent BaseAgent
function MapManager:CleanPrevious(agent)
    local sx, sz = agent.data:GetMetaSize(agent.data.cache_flip)
    if sx > 0 and sz > 0 then
        local x, z = agent.data._xMin, agent.data._zMin
        for i = x, x + sx - 1 do
            for j = z, z + sz - 1 do
                local objs = self.objMap[i][j]
                table.removeIfExist(objs, agent)
            end
        end
    end
end
---@param agent BaseAgent
function MapManager:RemoveObject(agent)
    local sx, sz = agent:GetSize()
    if sx > 0 and sz > 0 then
        local x, z = agent:GetMin()
        for i = x, x + sx - 1 do
            for j = z, z + sz - 1 do
                local objs = self.objMap[i][j]
                table.removeIfExist(objs, agent)
            end
        end
    end
end

function MapManager:GetState(x, z)
    ---超出地图边界, 返回空
    if x < 0 or x >= self.mapSize[1] or z < 0 or z >= self.mapSize[2] then
        return
    end
    if self.stateMap[x] then
        return self.stateMap[x][z] or CleanState.locked
    end
    return CleanState.locked
end

function MapManager:SetBlockState(x, sx, z, sz, state, index)
    if sx == 1 and sz == 1 then
        return self:SetState(x, z, state)
    end
    index = index or 0
    if index >= sx * sz then
        return
    end
    local i = x + (index % sx)
    local j = z + (index // sx)
    index = index + 1
    return self:SetState(i, j, state), self:SetBlockState(x, sx, z, sz, state, index)
    -- for i = x, x + sx - 1 do
    --     for j = z, z + sz - 1 do
    --         self:SetState(i, j, state)
    --     end
    -- end
end

function MapManager:SetState(x, z, state)
    local orgState = self:GetState(x, z)
    if not orgState or state <= orgState then
        return
    end

    if not self.stateMap[x] then
        self.stateMap[x] = {}
    end
    self.stateMap[x][z] = state

    table.insert(changingGrids, {x, z}) --@DEL

    if state == CleanState.prepare then
        return self:HandlePrepare(x, z, state)
    elseif state == CleanState.clearing then
        return self:HandleClearing(x, z, state)
    elseif state == CleanState.cleared then
        return self:HandleCleared(x, z, state)
    end
end

function MapManager:HandlePrepare(x, z, state)
    local objs = {table.unpack(self.objMap[x][z])}
    if #objs > 0 then
        for i = #objs, 1, -1 do
            local obj = objs[i]
            if obj and obj.alive then
                obj:SetState(state)
            end
        end
    -- return self:HandleObjectsState(objs, state, #objs)
    end
end
function MapManager:HandleClearing(x, z, state)
    local objs = {table.unpack(self.objMap[x][z])}
    if #objs > 0 then
        for i = #objs, 1, -1 do
            local obj = objs[i]
            if obj and obj.alive then
                obj:SetState(state)
            end
        end
        -- self:HandleObjectsState(objs, state, #objs)
        -- -- self.cleanTipManager:Trigger(x, z)
        --触发格子间连锁反应需要当前格子的状态值大于准备阶段
        return self:OnStateChanged(x, z, state)
    else --如果没有障碍物, 就自动变成消除后状态
        return self:SetState(x, z, CleanState.cleared)
    end
end
function MapManager:HandleCleared(x, z, state)
    local objs = {table.unpack(self.objMap[x][z])}
    if #objs > 0 then --如果有障碍物, 判断障碍物已全部消除
        --如果障碍物没有完全清除, 格子状态不能变更为已消除状态, 同时不能更改上面的其它障碍物
        for i = #objs, 1, -1 do
            local obj = objs[i]
            if not obj:IsComplete() then
                self.stateMap[x][z] = CleanState.clearing
                return self:HandleClearing(x, z, CleanState.clearing)
            end
        end

        for i = #objs, 1, -1 do
            local obj = objs[i]
            if obj and obj.alive then
                obj:SetState(state)
            end
        end
    -- self:HandleObjectsState(objs, state, #objs)
    end
    self.regionManager:TriggerPoint(x, z)
    return self:OnStateChanged(x, z, state)
end
function MapManager:HandleObjectsState(objs, state, index)
    local obj = objs[index]
    index = index - 1
    if not obj then
        return
    end
    if obj and obj.alive then
        return obj:SetState(state), self:HandleObjectsState(objs, state, index)
    end
end

function MapManager:OnStateChanged(x, z, state)
    local psb = self:IsPassable(x, z)
    local grids = self:GetRelatedGrids(x, z)
    -- for _, grid in pairs(grids) do
    --     self:ChangeRelatedGrid(grid[1], grid[2], state, psb)
    -- end
    local index = 0
    return self:Frac(grids, state, psb, index)
end
function MapManager:Frac(grids, state, psb, index)
    index = index + 1
    if index > #grids then
        return
    end
    local grid = grids[index]
    return self:Frac(grids, state, psb, index), self:ChangeRelatedGrid(grid[1], grid[2], state, psb)
end

---触发关联格子状态变更
function MapManager:ChangeRelatedGrid(x, z, driverState, driverPassable)
    --1.如果触发者为可通过格子, 被传染格子上没有障碍物, 不改变状态
    --2.如果触发者为不可通过格子(水面, 山, 栅栏), 而自己为可通过格子, 则不改变状态
    if driverPassable then
        if driverState < CleanState.cleared then
            if #self.objMap[x][z] == 0 then
                -- console.print("触发者为可通过格子, 被传染格子上没有障碍物, 不改变状态! x:", x, " z:", z)
                return
            end
        end
    else
        local psb = self:IsPassable(x, z)
        if psb then
            -- console.print("触发者为不可通过格子(水面, 山, 栅栏), 而自己为可通过格子! x:", x, " z:", z)
            return
        end
    end
    return self:SetState(x, z, driverState - 1)
end

function MapManager:GetRelatedGrids(x, z)
    if self.relatedMap[x] and self.relatedMap[x][z] then
        return self.relatedMap[x][z]
    end

    local grids = {
        {x - 1, z}, --Left
        {x, z + 1}, --Top
        {x + 1, z}, --Right
        {x, z - 1} --Bottom
    }
    self.relatedMap[x] = self.relatedMap[x] or {}
    self.relatedMap[x][z] = grids
    return grids
end
---获取障碍物周围的所有格子
---@param circle 周围格子的圈数
function MapManager:GetAroundGrids(x, z, circle)
    local grids
    if circle and circle > 0 then
        grids = {}
        local sx, sz = x - circle, z - circle --左下角起始坐标
        local num = circle * 2 + 1 --一行的格子个数
        for i = 1, num do
            for j = 1, num do
                local gx, gz = sx + (i - 1), sz + (j - 1)
                if not (gx == x and gz == z) then
                    table.insert(grids, {x = gx, z = gz})
                end
            end
        end
    end
    return grids
end
---------------------------------------------------------------------
---检测建筑所在地块是否可放置
---检测建筑是否超出地图边界
---@param agent BaseAgent
---@return number @返回错误级别 0:没有错误 1:不可放置 2:超出地图边界
function MapManager:CheckBuildingPosValid(agent)
    local data = agent.alive and agent.data
    if not data then
        return 2
    end
    local xMin, zMin = data:GetMin()
    local size_x, size_z = data:GetSize()
    -- before collision detection, detect if the building is out of map completely
    if xMin + size_x <= 0 or zMin + size_z <= 0 or xMin > self.mapSize[1] or zMin > self.mapSize[2] then
        data:ClearGridRationality()
        return 2
    end

    local ret = 0
    for x = 0, size_x - 1 do
        for z = 0, size_z - 1 do
            local xNew = x + xMin
            local zNew = z + zMin
            --判断建筑所占地图块是否可摆放
            local placable = self:IsGridPlacable(xNew, zNew)
            if placable then
                --地块已被其他建筑占据
                local objs = self.objMap[xNew][zNew]
                if #objs == 0 then
                    data:SetGridRationality(x, z, true)
                else
                    local blocked = false
                    for _, obj in pairs(objs) do
                        if obj ~= agent and obj:BlockBuilding() then
                            ret = 1
                            blocked = true
                            data:SetGridRationality(x, z, false)
                            break
                        end
                    end
                    if not blocked then
                        local open = self.regionManager:IsGridOpened(xNew, zNew)
                        if open then
                            data:SetGridRationality(x, z, true)
                        else
                            ret = 1
                            data:SetGridRationality(x, z, false)
                        end
                    end
                end
            else
                ret = 1
                data:SetGridRationality(x, z, false)
            end
        end
    end

    return ret
end
---------------------------------------------------------------------
--- 根据传入格子相对地图位置计算出相对应的世界坐标
---@param x number
---@param z number
---@return Vector3 world position
function MapManager:ToWorld(x, z)
    local pos_x = x * self.gridSize + self.mapOrigin.x
    local pos_z = z * self.gridSize + self.mapOrigin.z
    return Vector3(pos_x, 0, pos_z)
end

function MapManager:ToLocal(position)
    position = position:Flat()
    local x = math.round((position.x - self.mapOrigin.x) / self.gridSize)
    local z = math.round((position.z - self.mapOrigin.z) / self.gridSize)
    return x, z
end

function MapManager:IsRegionLinked(regionId)
    local region = self.regionManager:FindRegion(regionId)
    return region and region:IsLinked()
end

function MapManager:FindRegionByPos(position)
    local x, z = self:ToLocal(position)
    return self.regionManager:GetRegionByGrid(x, z)
end
function MapManager:GetRegionByGrid(x, z)
    return self.regionManager:GetRegionByGrid(x, z)
end

function MapManager:GetAutoBuild(data)
    if not self.autoBuildLogic then
        local AutoBuildLogic = require("MainCity.Logic.AutoBuildLogic")
        self.autoBuildLogic = AutoBuildLogic.new(self)
    end
    return self.autoBuildLogic:FindWith(data)
end
function MapManager:CanBuildOnGrid(x, z, agent)
    local placable = self:IsGridPlacable(x, z)
    if placable then
        --地块已被其他建筑占据
        local objs = self.objMap[x][z]
        if #objs == 0 then
            return true
        else
            for _, obj in pairs(objs) do
                if obj ~= agent and obj:BlockBuilding() then
                    return false
                end
            end
        end
    else
        return false
    end
end

if RuntimeContext.VERSION_DEVELOPMENT then
    local Gizmos = CS.UnityEngine.Gizmos
    local TileTypeColor = {
        [TileType.place_pass] = Color(0, 1, 0, 0.6), --passable
        [TileType.pass] = Color(1, 1, 0, 0.6), --pass
        [TileType.place] = Color(0, 1, 1, 0.6), --place
        [TileType.none] = Color(0, 0, 0, 0.5) --none
    }
    local TileStateColor = {
        [0] = Color(0, 0, 0, 0.7), --locked(black)
        [1] = Color(1, 1, 0, 0.7), --prepare(yellow)
        [2] = Color(0, 0, 1, 0.7), --clearing(blue)
        [3] = Color(0, 1, 0, 0.7) --cleared(green)
    }
    function MapManager:DrawGizmos()
        if not self.mapOrigin then
            return
        end
        if CS.GizmosUtil.showMap then
            local size = Vector3(0.9, 0.01, 0.9) * self.gridSize
            for x = 0, self.mapSize[1] - 1 do
                for z = 0, self.mapSize[2] - 1 do
                    local type = self:GetGridType(x, z)
                    if type ~= TileType.none then
                        local center = self:ToWorld(x, z)
                        Gizmos.color = TileTypeColor[type]
                        Gizmos.DrawCube(center, size)
                    end
                end
            end
        end

        if CS.GizmosUtil.showMapState then
            local size = Vector3(0.9, 0.01, 0.9) * self.gridSize

            for x = 0, self.mapSize[1] - 1 do
                for z = 0, self.mapSize[2] - 1 do
                    local type = self:GetGridType(x, z)
                    if type ~= TileType.none then
                        local center = self:ToWorld(x, z)
                        local state = self:GetState(x, z)
                        Gizmos.color = TileStateColor[state]
                        Gizmos.DrawCube(center, size)
                    end
                end
            end
        end

        if self.regionManager then
            self.regionManager:DrawGizmos()
        end
        if index ~= 0 and index < #changingGrids then
            local speed = 1
            index = index + speed
            index = math.min(index, #changingGrids)

            local count = index
            local step = 30.0
            local ccc = 0
            while count > 0 and count > index - step do
                ccc = ccc + 1
                local grid = changingGrids[count]
                local center = self:ToWorld(grid[1], grid[2])
                count = count - 1
                local alpha = (index - count) / step
                alpha = 1 - alpha
                Gizmos.color = Color(1, 1, 0, alpha)
                Gizmos.DrawCube(center, Vector3(0.5, 0.5, 0.5))
            end
            if ccc < step then
            end
        end
    end
end

function MapManager:OnDestroy()
    ---@type number[] @地图大小
    self.mapSize = nil
    ---@type Vector3 @地图原点位置(世界坐标)
    self.mapOrigin = nil

    ---地图二维数组
    self.typeMap = nil
    -- if self.cleanTipManager then
    --     self.cleanTipManager:Destory()
    --     self.cleanTipManager = nil
    -- end

    if self.regionManager then
        self.regionManager:OnDestroy()
        self.regionManager = nil
    end
end

return MapManager
