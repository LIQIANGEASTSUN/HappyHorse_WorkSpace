--- 建筑移动合理性指示器
---
---@type GridRationalityIndicator
local GridRationalityIndicator = {
    ---编辑中建筑指示集(父物体)
    moveIndicatorRoot = nil,
    ---可操作建筑指示集(父物体)
    frameIndicatorRoot = nil,
    ---可摆放地块指示集(父物体)
    grassIndicatorRoot = nil,
    ---@type GridRect[]
    grassIndicators = {},
    placingIndicators = {},
    arrow_left = nil,
    arrow_right = nil,
    arrow_forward = nil,
    arrow_back = nil,
    grassIndicatorInited = false,
    alive = true
}
--建筑占格指示器
local GridPrefab = "Prefab/UI/CityBuilder/BuildingOperator/building_grid.prefab"
--箭头指示器
local ArrowPrefab = "Prefab/UI/CityBuilder/BuildingOperator/building_move_arrow.prefab"
local GridBGPrefab = "Prefab/UI/CityBuilder/BuildingOperator/Prefabs/bg.prefab"
local FramePrefab = "Prefab/UI/CityBuilder/BuildingOperator/Prefabs/movable.prefab"
local GridRect = require "MainCity/Logic/GridRect"
local pull_up = Vector3(0, 0.1, 0)

local GridColor = {
    ValidColor = Color(0, 1, 0, 0.63),
    InvalidColor = Color(1, 0, 0, 0.63)
}

function GridRationalityIndicator:Init()
    self.moveIndicatorRoot = GameUtil.CreateWorldCanvas("MovingBuildingIndicator")
    self.moveIndicatorRoot.layer = CS.UnityEngine.LayerMask.NameToLayer("UI")
    self.moveIndicatorRoot:SetPosition(0, 0.1, 0)
    local raycaster = find_component(self.moveIndicatorRoot, nil, GraphicRaycaster)
    Runtime.CSDestroy(raycaster)

    self.frameIndicatorRoot = GameUtil.CreateWorldCanvas("BuildingFramesIndicator")
    raycaster = find_component(self.frameIndicatorRoot, nil, GraphicRaycaster)
    Runtime.CSDestroy(raycaster)

    self.grassIndicatorRoot = GameUtil.CreateWorldCanvas("UsableGridIndicator")
    raycaster = find_component(self.grassIndicatorRoot, nil, GraphicRaycaster)
    Runtime.CSDestroy(raycaster)
    self.grassIndicatorRoot:SetActive(false)

    local function CreateArrow(eulerAngles)
        local arrow = {}
        arrow.renderObj = BResource.InstantiateFromAssetName(ArrowPrefab, self.moveIndicatorRoot, false)
        if arrow.renderObj then
            arrow.renderObj:SetEulerAngle(eulerAngles)
            arrow.sprite = arrow.renderObj:GetComponent(typeof(Image))
            arrow.renderObj:SetActive(false)
        end
        return arrow
    end

    self.arrow_left = CreateArrow(Vector3(90, 0, 90))
    self.arrow_right = CreateArrow(Vector3(90, 90, 0))
    self.arrow_forward = CreateArrow(Vector3(90, 0, 0))
    self.arrow_back = CreateArrow(Vector3(-90, 0, 0))
    self.initialized = true
end

---@param buildingData AgentData
---@param state number @错误级别: 0.正常 1.一般异常 2.超出地图异常
function GridRationalityIndicator:Show(state, buildingData)
    if not self.alive then
        return
    end
    if not self.initialized then
        self:Init()
    end

    self:RecycleBuildingGrids()
    self:RecycleMoveFrames()

    if self.grassIndicatorInited then
        self.grassIndicatorRoot:SetActive(true)
    else
        self.grassIndicatorInited = true

        self.grassIndicators = {}
        local ts = CS.System.DateTime.Now --@DEL
        local regionMgr = App.scene.mapManager.regionManager
        for k, region in pairs(regionMgr.regions) do
            self:FillRegion(region, region.bounds)
        end
        console.hjs(nil, "generate rects cost:", (CS.System.DateTime.Now - ts).TotalSeconds) --@DEL

        ts = CS.System.DateTime.Now --@DEL
        Runtime.CSDestroy(self.grassIndicatorRoot)
        self.grassIndicatorRoot = nil
        self.grassIndicatorRoot = GameUtil.CreateWorldCanvas("UsableGridIndicator")
        self.grassIndicatorRoot:SetActive(true)
        for _, indicator in pairs(self.grassIndicators) do
            indicator:Initialize(GridBGPrefab, self.grassIndicatorRoot)
        end
        console.hjs(nil, "create bg cost:", (CS.System.DateTime.Now - ts).TotalSeconds) --@DEL
    end

    --建筑摆放处是否有不合理格子存在?
    local map = App.scene.mapManager

    if buildingData then
        local min_x, min_z = buildingData:GetMin()
        local size_x, size_z = buildingData:GetSize()

        for x = 0, size_x - 1 do
            for z = 0, size_z - 1 do
                local grid = self:GetGrid()

                if state == 2 then
                    grid.sprite.color = GridColor.InvalidColor
                else
                    if buildingData:GetGridRationality(x, z) then
                        grid.sprite.color = GridColor.ValidColor
                    else
                        grid.sprite.color = GridColor.InvalidColor
                    end
                end
                local position = map:ToWorld(min_x + x, min_z + z) + pull_up
                grid.renderObj:SetPosition(position)
            end
        end

        local offset = -0.3
        local min = map:ToWorld(min_x - 1, min_z - 1)
        local max = map:ToWorld(min_x + size_x, min_z + size_z)
        local center = (min + max) / 2

        self.arrow_left.renderObj:SetActive(true)
        self.arrow_left.renderObj:SetPosition(min.x - offset, 0.1, center.z)
        self.arrow_right.renderObj:SetActive(true)
        self.arrow_right.renderObj:SetPosition(max.x + offset, 0.1, center.z)
        self.arrow_forward.renderObj:SetActive(true)
        self.arrow_forward.renderObj:SetPosition(center.x, 0.1, max.z + offset)
        self.arrow_back.renderObj:SetActive(true)
        self.arrow_back.renderObj:SetPosition(center.x, 0.1, min.z - offset)
        if state > 0 then
            self.moveIndicatorRoot.layer = CS.UnityEngine.LayerMask.NameToLayer("UI")
        else
            self.moveIndicatorRoot.layer = CS.UnityEngine.LayerMask.NameToLayer("Default")
        end
    end
end

function GridRationalityIndicator:Hide()
    if not self.arrow_left then
        return
    end

    if Runtime.CSNull(self.arrow_left.renderObj) then
        return
    end

    if Runtime.CSNull(self.frameIndicatorRoot) then
        return
    end

    self:RecycleBuildingGrids()
    self:RecycleMoveFrames()
    self.arrow_left.renderObj:SetActive(false)
    self.arrow_right.renderObj:SetActive(false)
    self.arrow_forward.renderObj:SetActive(false)
    self.arrow_back.renderObj:SetActive(false)

    self.grassIndicatorRoot:SetActive(false)
end
--------------------------------建筑地块合理性指示--------------------------------
function GridRationalityIndicator:CreateNewGrid()
    local grid = {}
    grid.renderObj = BResource.InstantiateFromAssetName(GridPrefab, self.moveIndicatorRoot, false)

    grid.sprite = grid.renderObj:GetComponent(typeof(Image))
    grid.used = false
    grid.renderObj:SetActive(false)

    table.insert(self.placingIndicators, grid)
    return grid
end
function GridRationalityIndicator:GetGrid()
    for k, grid in pairs(self.placingIndicators) do
        if not grid.used and Runtime.CSValid(grid.renderObj) then
            grid.renderObj:SetActive(true)
            grid.used = true
            return grid
        end
    end

    local _grid = self:CreateNewGrid()
    _grid.used = true
    _grid.renderObj:SetActive(true)
    return _grid
end
---回收并隐藏正在的移动建筑下所有的高亮地块
function GridRationalityIndicator:RecycleBuildingGrids()
    for key, grid in pairs(self.placingIndicators) do
        if grid.used and Runtime.CSValid(grid.renderObj) then
            grid.used = false
            grid.renderObj:SetActive(false)
        end
    end
end
--------------------------------区域可摆放地块指示--------------------------------
---@param region Region
function GridRationalityIndicator:FillRegion(region, bounds)
    if not region:IsLinked() then
        return
    end
    local mapmgr = App.scene.mapManager
    for x = bounds.xMin, bounds.xMax do
        local zStart = bounds.zMin
        local zEnd = bounds.zMin
        while zEnd <= bounds.zMax do
            local contains, open = true, true
            if not mapmgr:IsGridPlacable(x, zEnd) then
                open = false
            else
                contains, open = region:ContainsGrid(x, zEnd)
            end
            if not open then
                self:FillRectangle(x, zStart, zEnd)
                zStart = zEnd + 1
            end
            zEnd = zEnd + 1
        end
        self:FillRectangle(x, zStart, zEnd - 1)
    end
end

function GridRationalityIndicator:FillRectangle(x, zStart, zEnd)
    if zEnd < zStart then
        return
    end
    local r = GridRect.new(x, zStart, x, zEnd)
    for i = #self.grassIndicators, 1, -1 do
        if self.grassIndicators[i]:Merge(r) then
            return
        end
    end
    table.insert(self.grassIndicators, r)
end

function GridRationalityIndicator:OnRectLockStateChanged(id)
    if not self.grassIndicatorInited then
        return
    end
    local rect = RegionManager.Instance():FindRect(id)
    if rect:IsLinked() then
        local bounds = {
            xMin = rect.xMin,
            zMin = rect.zMin,
            xMax = rect.xMin + rect.xSize - 1,
            zMax = rect.zMin + rect.zSize - 1
        }
        local region = RegionManager.Instance():FindRegion(rect.regionId)
        self:FillRegion(region, bounds)

        for k, indicator in pairs(self.grassIndicators) do
            indicator:Initialize(GridBGPrefab, self.grassIndicatorRoot)
        end
    end
end
---------------------------------建筑可操作指示框---------------------------------
---@param buildingData AgentData
function GridRationalityIndicator:FillBuilding(buildingData)
    local centerPos = buildingData:GetBottomCenter()
    self:ShowMoveFrames(FramePrefab, centerPos, Vector2(buildingData.size_x - 0.05, buildingData.size_z - 0.05))
end
function GridRationalityIndicator:ShowMoveFrames(frameAssetPath, pos, size)
    local getFrame = function(callback)
        if self.frames then
            for k, frame in pairs(self.frames) do
                if not frame.used then
                    InvokeCbk(callback, frame)
                    return
                end
            end
        end

        local asset = BResource.InstantiateFromAssetName(frameAssetPath, self.frameIndicatorRoot, false)
        if Runtime.CSNull(asset) then
            InvokeCbk(callback)
            return
        end

        local frame = {}
        frame.renderObj = asset
        frame.used = false
        frame.renderObj:SetActive(false)
        frame.sprite = frame.renderObj:GetComponent(typeof(Image))

        frame.SetPosition = function(position)
            frame.renderObj:SetPosition(position)
        end

        frame.Use = function(state)
            if frame.used == state then
                return
            end
            frame.renderObj:SetActive(state)
            frame.used = state
        end
        frame.Destroy = function()
            Runtime.CSDestroy(frame.renderObj)
            frame.renderObj = nil
        end
        frame.SetSize = function(size)
            frame.sprite.transform.sizeDelta = size * 100
        end

        self.frames = self.frames or {}
        table.insert(self.frames, frame)

        InvokeCbk(callback, frame)
    end

    getFrame(
        function(frame)
            if frame then
                frame.Use(true)
                frame.SetPosition(pos)
                if size then
                    frame.SetSize(size)
                end
            end
        end
    )
end
--- 回收并隐藏所有可移动建筑下的高亮地块
function GridRationalityIndicator:RecycleMoveFrames()
    if self.frames then
        for k, frame in pairs(self.frames) do
            frame.Use(false)
        end
    end
end
---------------------------------------------------------------------------------
function GridRationalityIndicator:OnDestroy()
    self.alive = nil
    Runtime.CSDestroy(self.moveIndicatorRoot)
    self.moveIndicatorRoot = nil
    self.placingIndicators = nil

    Runtime.CSDestroy(self.grassIndicatorRoot)
    self.grassIndicatorRoot = nil

    self.grassIndicators = {}

    Runtime.CSDestroy(self.frameIndicatorRoot)
    self.frameIndicatorRoot = nil

    self.arrow_left = nil
    self.arrow_right = nil
    self.arrow_forward = nil
    self.arrow_back = nil

    GlobalEventDispatcher.Instance():removeObserver(self, GlobalEvents.RECT_CHANGED)
end

return GridRationalityIndicator
