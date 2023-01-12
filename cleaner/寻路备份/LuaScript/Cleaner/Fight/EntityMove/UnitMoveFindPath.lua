---@type UnitMoveBase
local UnitMoveBase = require "Cleaner.Fight.EntityMove.UnitMoveBase"

---@class UnitMoveFindPath
local UnitMoveFindPath = class(UnitMoveBase, "UnitMoveFindPath")
-- 设置目标点，令角色移动到目标点

function UnitMoveFindPath:ctor(entity)
    self.pathList = {}
    self.pathFind = false
end

function UnitMoveFindPath:ChangeDestination(destination)
    UnitMoveBase.ChangeDestination(self, destination)

    self.pathFind = false

    self.pathList = {}
    local map = App.scene.mapManager
    local region = map:FindRegionByPos(destination)
    if not region then
        return
    end

    local islandId = region:GetId()
    local islandMapPath = AppServices.IslandPathManager:GetMapPath(islandId)
    if not islandMapPath then
        return
    end

    local startPos = self.entity:GetPosition()
    local endPos = destination
    local list = islandMapPath:Search(Vector2(startPos.x, startPos.z), Vector2(endPos.x, endPos.z))
    for _, pos in pairs(list) do
        local position = Vector3(pos.x, 0, pos.y)
        table.insert(self.pathList, position)
    end

    self.pathFind = #self.pathList > 0
    self:ResetForward()
end

function UnitMoveFindPath:ResetForward()
    if #self.pathList <= 0 then
        return false
    end

    local position = self.pathList[1]

    local entityPos = self.entity:GetPosition()
    self.moveDir = (position - entityPos).normalized
    self:CurrentForward(self.moveDir)
end

function UnitMoveFindPath:Move()
    if not self.isSetDestination then
        return false, self.entity:GetPosition()
    end

    -- 是否到达目的地，x、y 方向上的偏移都小于 self.minDis
    local arrive = self:DisIsMinDestination()
    if arrive then
        return arrive, self.destination
    end

    local entityPos = self.entity:GetPosition()
    if not self.pathFind then
        return false, entityPos
    end

    if #self.pathList <= 0 then
        return arrive, self.destination
    end

    local position = self.pathList[1]

    local speed = 1 -- self.speed
    local pos = entityPos + self.moveDir * Time.deltaTime * speed

    if self:DisIsMinEntity(position) then
        table.remove(self.pathList, 1)
        self:ResetForward()
    end

    arrive = self:DisIsMinDestination(position)
    return arrive, pos
end

function UnitMoveFindPath:RandomPosition(pos)
    local map = App.scene.mapManager
    local region = map:FindRegionByPos(pos)
    if not region then
        return false, pos
    end

    local islandId = region:GetId()
    self.islandMapPath = AppServices.IslandPathManager:GetMapPath(islandId)
    if not self.islandMapPath then
        return false, pos
    end

    local result, position = self.islandMapPath:RandomPath(pos.x, pos.z)
    return result, position
end

return UnitMoveFindPath