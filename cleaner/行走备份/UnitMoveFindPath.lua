---@type SudokuScrewCross
local SudokuScrewCross = require "Cleaner.PathFinding.Search.SudokuScrewCross"

---@type PosIsOnWater
local PosIsOnWater = require "Cleaner.Fight.EntityMove.PosIsOnWater"

---@type UnitMoveBase
local UnitMoveBase = require "Cleaner.Fight.EntityMove.UnitMoveBase"

---@class UnitMoveFindPath:UnitMoveBase
local UnitMoveFindPath = class(UnitMoveBase, "UnitMoveFindPath")
-- 寻路移动
function UnitMoveFindPath:ctor(entity)
    -- self.moveType = 3
    -- self.nodes = {}
    -- self.destinationCount = 0
end

function UnitMoveFindPath:ChangeDestination(destination)
    UnitMoveBase.ChangeDestination(self, destination)

    self.pathList = {}
    local startPos = self.entity:GetPosition()
    if Vector3.Distance(startPos, destination) <= 1 then
        table.insert(self.pathList, destination)
    else
        local list = AppServices.IslandPathManager:Search(Vector2(startPos.x, startPos.z), Vector2(destination.x, destination.z))
        local start = #list > 1 and 2 or 1
        for i = start, #list do
            local pos = list[i]
            local position = Vector3(pos.x, 0, pos.y)
            table.insert(self.pathList, position)
        end
    end

    if #self.pathList <= 0 then
        self:NotFindPath()
    end

    self.hasPath = #self.pathList > 0
    self:ResetForward()
end

function UnitMoveFindPath:NotFindPath()
    local entityPos = self.entity:GetPosition()
    if not PosIsOnWater:IsOnWater(entityPos) then
        return
    end
    local find, pos = self:GetValidPosition()
    if find then
        self.entity:SetPosition(pos)
    end
end

-- function UnitMoveFindPath:ResetForward()
--     if #self.pathList <= 0 then
--         return false
--     end

--     local position = self.pathList[1]
--     local entityPos = self.entity:GetPosition()
--     self.moveDir = (position - entityPos).normalized
--     self:CurrentForward((position - entityPos))

--     local velocity = Vector2(self.moveDir.x * self.speed, self.moveDir.z * self.speed)
--     RVO2Controller.Instance:setAgentPrefVelocity(self.rvo2AgentId, velocity)
-- end

-- function UnitMoveFindPath:OnTick()
--     if not self.hasPath then
--         self:Stop()
--         return false, self.entity:GetPosition()
--     end
--     if not self.isSetDestination then
--         self:Stop()
--         return false, self.entity:GetPosition()
--     end

--     if #self.pathList <= 0 then
--         self:Stop()
--         return true, self.entity:GetPosition()
--     end

--     local entityPos = self.entity:GetPosition()
--     local position = self.pathList[1]

--     local arriveNode = self:EnableArriveThisFrame(entityPos, position, self.speed, self.entity.dt)
--     -- 是否到达目的地
--     if arriveNode then
--         table.remove(self.pathList, 1)
--         self:ResetForward()
--         self.entity:SetPosition(position)
--         if #self.pathList <= 0 then
--             local pos = Vector2(position.x, position.z)
--             RVO2Controller.Instance:setAgentPosition(self.rvo2AgentId, pos)
--             self:Stop()
--         end
--         return #self.pathList <= 0, position
--     end

--     if self.moveType == 1 then
--         local pos = entityPos + self.moveDir * self.entity.dt * self.speed
--         return false, pos
--     elseif self.moveType == 3 then

--         local position = self.pathList[1]
--         local entityPos = self.entity:GetPosition()
--         self.moveDir = (position - entityPos).normalized
--         self:CurrentForward((position - entityPos))

--         local velocity = Vector2(self.moveDir.x * self.speed, self.moveDir.z * self.speed)
--         RVO2Controller.Instance:setAgentPrefVelocity(self.rvo2AgentId, velocity)

--         local p = RVO2Controller.Instance:getAgentPosition(self.rvo2AgentId)
--         return false, Vector3(p.x, 0, p.y)
--     end
-- end

function UnitMoveFindPath:RandomPosition(pos)
    local result, position = AppServices.IslandPathManager:RandomPath(pos.x, pos.z)
    return result, position
end

function UnitMoveFindPath:FindPath()
    return self.hasPath
end

-- 查找一个可行走的位置，生成怪物用
function UnitMoveFindPath:GetValidPosition()
    local originPos = self.entity:GetPosition()
    local find = false
    local petSpawnPos = Vector2(originPos.x, originPos.z)
    SudokuScrewCross:Search( petSpawnPos, 0, 5, function(position)
        local enablePass = AppServices.IslandPathManager:EnablePass(position.x, position.y)
        if enablePass then
            petSpawnPos = Vector3(position.x, 0, position.y)
            find = true
            return false
        end
        return true
    end)

    return find, petSpawnPos
end

return UnitMoveFindPath




-- for _, v in ipairs(self.pathList) do
--     local go = GameObject.CreatePrimitive(CS.UnityEngine.PrimitiveType.Sphere)
--     go.name = tostring(self.destinationCount.."_"..#self.nodes)
--     go.transform.position = v
--     go.transform.localScale = Vector3(0.2, 0.2, 0.2)
--     table.insert(self.nodes, go)
-- end

-- do
--     local go = GameObject.CreatePrimitive(CS.UnityEngine.PrimitiveType.Cube)
--     go.name = tostring("Destination"..self.destinationCount)
--     go.transform.position = destination
--     go.transform.localScale = Vector3(0.3, 0.3, 0.3)
-- end
-- self.destinationCount = self.destinationCount + 1