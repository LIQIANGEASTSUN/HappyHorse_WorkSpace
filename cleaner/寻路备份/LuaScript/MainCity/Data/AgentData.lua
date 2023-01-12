---
--- 绑定物体属性:
---     位置信息:位置, 大小
---     锁定状态
---
--- 绑定物体功能:
---     消除状态
---

---@class AgentData @绑定物体数据
local AgentData = class(nil, "AgentData")

--- MapData:
---     编号
---     模板id
---     地图坐标/世界坐标/旋转/缩放
function AgentData:ctor(mapData, meta)
    self.alive = true
    ---@type ObjectData 地图中配置的原始数据
    self.mapData =
        mapData or
        {
            tid = meta.sn
        }
    --绑定物体模板数据
    ---@type ObjectMeta
    self.meta = meta
    --服务器返回的动态数据: 进度....
    self.state = CleanState.uninited
    self.buildingMsg = {level = -1, progress = 0, hangupMsg = nil}
    local coord = self.mapData.coord
    if coord then
        self:InitLocation(coord[1], coord[2], false)
    end
    local p = self.mapData.pos
    if p then
        self.position = Vector3(p[1], p[2], p[3])
        self._position = self.position
    end
end

---ServerData:
---    状态/消除进度
function AgentData:InitServerData(id, serverData)
    self.mapData.id = id
    if serverData then
        self.mapData.level = serverData.level
        self:InitLocation(serverData.pos.x, serverData.pos.y, false)
        self.position = App.scene.mapManager:ToWorld(self:GetMin()) - self:GetCenterOffset()
        self._position = self.position
    else
        self.mapData.level = 1
    end
end
function AgentData:GetServerData()
    local data = {
        id = self:GetId(),
        level = self:GetLevel(),
        pos = {x = self.xMin, y = self.zMin},
        tid = self:GetTemplateId()
    }

    -- message DMapObj {
    --     required string id = 1;   //地图元素唯一id
    --     required int32 level = 2; //地图元素等级
    --     required DPos pos = 3;    //地图元素坐标
    --     required int32 tid = 4;   //地图元素模板id
    --   }
    return data
end
function AgentData:InitExtraData(extraData)
    self.extraData = extraData
end

function AgentData:GetId()
    if self.mapData then
        return self.mapData.id
    end
end
function AgentData:SetId(id)
    if self.mapData then
        self.mapData.id = id
    end
end

function AgentData:GetTemplateId()
    if self.meta then
        return self.meta.sn
    end
end

function AgentData:GetLevel()
    return self.mapData.level
end

function AgentData:SetLevel(level)
    self.mapData.level = level
end

--获取agent类型，是建筑，障碍物还是迷雾
function AgentData:GetType()
    return self.meta.type
end

function AgentData:GetSize()
    local x = self.meta.x
    local z = self.meta.z
    return x, z
end

--- 获取边界框的最小坐标 x z (单位:格)
---@return number,number
function AgentData:GetMin()
    return self.xMin, self.zMin
end

function AgentData:SetMin(x, z)
    self.xMin, self.zMin = x, z
end

function AgentData:GetPosition()
    return self.position
end

function AgentData:GetRawLocalScale()
    local s = self.mapData.scale
    return s
end

function AgentData:GetRawEulerAngle()
    local r = self.mapData.euler
    return r
end

---获取修复等级
function AgentData:GetRepaireLevel()
    return self.buildingMsg.level
end

function AgentData:Clean(value)
    self:SetState(CleanState.cleared)
    return true
end

function AgentData:SetState(state)
    if state <= self:GetState() then
        return
    end
    self.state = state
    return true
end

function AgentData:InitState(state)
    self.state = state
end

function AgentData:GetState()
    return self.state
end

function AgentData:SetServerData(serverData)
    if serverData then
        self.mapData.level = serverData.level
    end
end

function AgentData:GetIdleAnimaName()
    return
end

function AgentData:GetLvupAnimaName()
    local level = self.buildingMsg.level
    if not level or level <= 1 then
        return
    end
    local templateId = self:GetTemplateId()
    local cfg = AppServices.Meta:GetBuildingRepair(templateId)
    if not cfg then
        return
    end
    local anima = cfg.repairingspine[level - 1]
    return anima
end

---更新修复等级
---@param level int 新等级
function AgentData:UpdateRepaireLevel(level)
    self.buildingMsg.level = level
end

function AgentData:UpdateRepairProgress(progress)
    self.buildingMsg.progress = progress
end

function AgentData:GetRepairProgress()
    return self.buildingMsg.progress or 0
end
--------------------------------------------------------
function AgentData:GetMetaSize(flip)
    if flip == nil then
        flip = self.flipped
    end

    local x = self.meta.x
    local z = self.meta.z
    if flip then
        return z, x
    else
        return x, z
    end
end
function AgentData:InitLocation(xMin, zMin, flip)
    self.xMin = xMin
    self._xMin = xMin
    self.zMin = zMin
    self._zMin = zMin
    self.flipped = flip
    self.cache_flip = flip
    self.size_x, self.size_z = self:GetMetaSize(flip)
end
-- ---@return Vector3 @计算建筑模型位置, 返回
-- function AgentData:GetPosition()
--     local mapOrigin = App.scene.mapManager.mapOrigin
--     local pos = mapOrigin + Vector3(self.xMin + self.size_x * 0.5, 0, self.zMin + self.size_z * 0.5) -
--         self:GetCenterOffset()
--     return pos
-- end
function AgentData:SetPosition(position)
    local modify = false
    local map = App.scene.mapManager
    local offset = self:GetCenterOffset()
    local anchorPos = position + offset

    local local_x, local_z = map:ToLocal(anchorPos)
    modify = self.xMin ~= local_x or local_z ~= self.zMin

    self.xMin = local_x
    self.zMin = local_z

    if modify then
        local newPos = map:ToWorld(local_x, local_z) - offset
        self.position = newPos
    end

    return modify
end

function AgentData:GetTileMax()
    return self.xMin + self.size_x - 1, self.zMin + self.size_z - 1
end

---设置建筑的格位点(xMin, zMin)
---@param xMin number
---@param zMin number
function AgentData:SetTileMin(xMin, zMin)
    self.xMin = xMin
    self.zMin = zMin
end
--- 建筑翻转跟建筑位置点用的不是同一个点, 翻转用视图中建筑最下边的点(xMax, zMin)
function AgentData:GetBottomTile()
    local xMax = self.xMin + self.size_x - 1
    return xMax, self.zMin
end
function AgentData:SetBottomTile(xMax, zMin)
    local xMin = xMax - self.size_x + 1
    self.xMin = xMin
    self.zMin = zMin
end
---根据传入位置获取建筑移动到相应位置后对应的边界框最小坐标(单位:格)
---@param position Vector3
---@return number,number
function AgentData:GetMinByPosition(position)
    --对传入的世界坐标取整然后计算出相对地图原点的坐标
    local mapOrigin = App.scene.mapManager.mapOrigin
    position = Vector3(math.round(position.x), 0, math.round(position.z)) - mapOrigin
    local offset = self:GetCenterOffset()

    local min_x = math.ceil((position.x + offset.x) - self.size_x * 0.5)
    local min_z = math.ceil((position.z + offset.z) - self.size_z * 0.5)

    return min_x, min_z
end

---@return Vector3 @返回建筑模型位置到建筑Min锚点的偏移量
function AgentData:GetCenterOffset()
    if not self.meta.offset then
        local offset = AppServices.Meta:GetOffset(self:GetTemplateId())
        offset = offset or {x = 0, y = 0}
        self.meta.offset = offset
    end
    local off_x = self.meta.offset.x or 0
    local off_z = self.meta.offset.y or 0
    if self.flipped then
        return Vector3(-off_z, 0, -off_x)
    end
    return Vector3(off_x, 0, off_z)
end

function AgentData:GetFlip()
    return self.flipped
end
function AgentData:SetFlip(flip)
    self.flipped = flip
end

--- 位置调整完成
--- 将原缓存格位修改为当前格位
function AgentData:CommitTile()
    self._xMin = self.xMin
    self._zMin = self.zMin
    self.cache_flip = self.flipped
    self._position = self.position
end
--- 位置调整撤销, 翻转会改变当前位置, 按照以下顺序进行
--- 1.如果建筑有翻转, 再先翻转回来
--- 2.将当前格位撤回到原缓存格位
function AgentData:RevertTile()
    if self.flipped ~= self.cache_flip then
        self:SetFlip(self.cache_flip)
    end

    self.xMin = self._xMin
    self.zMin = self._zMin
    self.position = self._position
end

function AgentData:IsModified()
    return self.cache_flip ~= self.flipped or self.xMin ~= self._xMin or self.zMin ~= self._zMin
end

function AgentData:SetGridRationality(x, z, rationality)
    if not self.invalid_tiles then
        self.invalid_tiles = {}
    end
    if not self.invalid_tiles[x] then
        self.invalid_tiles[x] = {}
    end
    self.invalid_tiles[x][z] = rationality
end
function AgentData:GetGridRationality(x, z)
    if not self.invalid_tiles then
        return true
    end
    if not self.invalid_tiles[x] then
        return true
    end
    return self.invalid_tiles[x][z]
end
function AgentData:ClearGridRationality()
    self.invalid_tiles = nil
end

function AgentData:CheckBuildingPosValid()
    local agent = App.scene.objectManager:GetAgent(self:GetId())
    return App.scene.mapManager:CheckBuildingPosValid(agent)
end

function AgentData:CheckBuildingRationality()
    if not self.invalid_tiles then
        local result = self:CheckBuildingPosValid()
        if result == 0 then
            return true
        else
            return false
        end
    end

    for x, z_tiles in pairs(self.invalid_tiles) do
        for z, tile in pairs(z_tiles) do
            if not tile then
                return false
            end
        end
    end
    return true
end

--------------------------------------------------------
function AgentData:OnDestroy()
    if not self.alive then
        return
    end
    self.alive = nil
    self.meta = nil
    self.mapData = nil
end

return AgentData
