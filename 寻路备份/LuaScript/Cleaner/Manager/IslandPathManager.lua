---@type IslandTemplateTool
local IslandTemplateTool = require "Fsm.Ship.IslandTemplateTool"

---@type IslandMapPath
local IslandMapPath = require "Cleaner.PathFinding.MapPath.IslandMapPath"

---@type IslandPathManager
local IslandPathManager = {
    islandMapPaths = {},
    cleanedAgents = {}
}

function IslandPathManager:Init()
    self.islandMapPaths = {}

    local ids = IslandTemplateTool:GetAllIsland()
    for _, id in pairs(ids) do
        local islinkHomeland = AppServices.User:IsLinkHomeland(id)
        local enableSailing = AppServices.IslandManager:EnableSailling(id)
        if id == 101 and (islinkHomeland or enableSailing) then
            self:CreateMapPath(id)
        end
    end

    local homelandId = IslandTemplateTool:GetHomelandId()
    self:CreateMapPath(homelandId)

    self:CheckIslandMapArea()

    self:RegisterEvent()
end

function IslandPathManager:PositionToIslandId(position)
    local map = App.scene.mapManager
    local region = map:FindRegionByPos(position)
    if not region then
        return -1
    end
    return region:GetId()
end

function IslandPathManager:CleanedAgent(id)
    local data = {id = id, time = Time.realtimeSinceStartup }
    table.insert(self.cleanedAgents, data)
end

function IslandPathManager:GetMapPath(islandId)
    return self.islandMapPaths[islandId]
end

function IslandPathManager:CreateMapPath(islandId)
    local islandMapPath = IslandMapPath.new(islandId)
    self.islandMapPaths[islandId] = islandMapPath
    return islandMapPath
end

function IslandPathManager:CheckCleanedAgent()
    if #self.cleanedAgents <= 0 then
        return
    end

    local map = App.scene.mapManager
    while(#self.cleanedAgents > 0) do
        local data = self.cleanedAgents[1]
        if Time.realtimeSinceStartup - data.time <= 1 then
            break
        end
        table.remove(self.cleanedAgents, 1)

        local id = data.id
        local agent = App.scene.objectManager:GetAgent(id)
        if not agent then
            return
        end

        local position = agent:GetWorldPosition()
        local islandId = self:PositionToIslandId(position)
        if islandId <= 0 then
            return
        end
        local islandMapPath = self:GetMapPath(islandId)
        if not islandMapPath then
            islandMapPath = self:CreateMapPath(islandId)
        end
        islandMapPath:CleanedAgent(agent)
    end
end

function IslandPathManager:CheckIslandMapArea()
    for _, islandMap in pairs(self.islandMapPaths) do
        for _, islandMap2 in pairs(self.islandMapPaths) do
            self:IslandMapToMap(islandMap, islandMap2)
        end
    end
end

function IslandPathManager:LinkedHomeland(islandId)
    local islandMap = self:CreateMapPath(islandId)
    for _, islandMap2 in pairs(self.islandMapPaths) do
        self:IslandMapToMap(islandMap, islandMap2)
    end
end

function IslandPathManager:IslandMapToMap(islandMap, islandMap2)
    if islandMap.islandId >= islandMap2.islandId then  -- 防止 1 跟 101 做计算，后边 101 再跟 1 做计算，重复
        return
    end

    local islinkHomeland1 = AppServices.User:IsLinkHomeland(islandMap.islandId)
    local islinkHomeland2 = AppServices.User:IsLinkHomeland(islandMap2.islandId)
    if not islinkHomeland1 or not islinkHomeland2 then
        return
    end

    local isIntersect = islandMap.aabb:IsIntersect(islandMap2.aabb)
    if not isIntersect then
        return
    end

    local min1, max1 = islandMap.aabb:SelfNearestToOther(islandMap2.aabb)
    local resultList1 = islandMap:GetAreaNode(min1, max1)
    -- self:CreateGo("min1", min1)
    -- self:CreateGo("max1", max1)
    -- for _, pos in pairs(resultList1) do
    --     self:CreateGo("1", pos)
    -- end

    local min2, max2 = islandMap2.aabb:SelfNearestToOther(islandMap.aabb)
    local resultList2 = islandMap:GetAreaNode(min2, max2)
    -- self:CreateGo("min2", min2)
    -- self:CreateGo("max2", max2)
    -- for _, pos in pairs(resultList2) do
    --     self:CreateGo("2", pos)
    -- end
    local result = {distance = 10000, pos1 = Vector3.zero, pos2 = Vector3.zero}
    for _, pos1 in pairs(resultList1) do
        for _, pos2 in pairs(resultList2) do
            local distance = Vector3.Distance(pos1, pos2)
            if distance < result.distance then
                result.distance = distance
                result.pos1 = pos1
                result.pos2 = pos2
            end
        end
    end

    islandMap:SetNeighbourIsland(islandMap2.islandId, result.pos1)
    islandMap2:SetNeighbourIsland(islandMap.islandId, result.pos1)
    console.error("IsIntersect:"..islandMap.islandId.."   "..islandMap2.islandId)
end

function IslandPathManager:CreateGo(name, pos)
    local cube = GameObject.CreatePrimitive(CS.UnityEngine.PrimitiveType.Cube)
    cube.transform.localScale = Vector3(0.2, 0.2, 0.2)
    cube.transform.position = pos
    cube.name = name
end

function IslandPathManager:Search(formWorld, toWorld)
    local islandId1 = self:PositionToIslandId(formWorld)
    local islandId2 = self:PositionToIslandId(toWorld)
    if islandId1 <= 0 or islandId2 <= 0 then
        return
    end

    local islandMapPath1 = self:GetMapPath(islandId1)
    if islandId1 == islandId2 then
        return islandMapPath1:Search(Vector2(formWorld.x, formWorld.z), Vector2(toWorld.x, toWorld.z))
    end

    local pathList = {}
    local list = self:IslandToIsland(islandId1, islandId2)
    for i = 1, #list do
        local islandMapPath = list[i]
        if i == 1 then         -- 第一个
            local next = list[i + 1]
            local position = islandMapPath:GetNeighbourPosition(next.islandId)
            local arr = islandMapPath:Search(Vector2(formWorld.x, formWorld.z), Vector2(position.x, position.z))
            if #arr <= 0 then
                break
            end
            self:PathAddToList(pathList, arr)
        elseif i < #list then  -- 中间的
            local pre = list[i - 1]
            local prePos = islandMapPath:GetNeighbourPosition(pre.islandId)
            local next = list[i + 1]
            local nextPos = islandMapPath:GetNeighbourPosition(next.islandId)
            local arr = islandMapPath:Search(Vector2(prePos.x, prePos.z), Vector2(nextPos.x, nextPos.z))
            if #arr <= 0 then
                break
            end
            self:PathAddToList(pathList, arr)
        else                   -- 最后一个
            local pre = list[i - 1]
            local prePos = islandMapPath:GetNeighbourPosition(pre.islandId)
            local arr = islandMapPath:Search(Vector2(prePos.x, prePos.z), Vector2(toWorld.x, toWorld.z))
            if #arr <= 0 then
                break
            end
            self:PathAddToList(pathList, arr)
        end
    end

    return pathList
end

function IslandPathManager:PathAddToList(pathList, arr)
    for _, pos in pairs(arr) do
        table.insert(pathList, pos)
    end
end

function IslandPathManager:IslandToIsland(islandId1, islandId2)
    local islandMapPath1 = self:GetMapPath(islandId1)
    if islandId1 <= 0 or islandId2 <= 0 then
        return {}
    end

    local all = {}
    local result = nil
    local list = {}
    table.insert(list, islandMapPath1)
    table.insert(all, islandMapPath1)
    while #list > 0 do
        local islandMapPath = list[1]
        table.remove(list, 1)
        if islandMapPath.islandid == islandId2 then
            result = islandMapPath
            break
        end
        local neighbour = islandMapPath:GetNeightbour()
        for islandId, pos in pairs(neighbour) do
            local islandMapPath2 = self:GetMapPath(islandId)
            islandMapPath2:SetParent(islandMapPath.islandId)
            table.insert(list, islandMapPath2)
            table.insert(all, islandMapPath2)
        end
    end

    if not result then
        return {}
    end
    list = {}
    table.insert(list, result)
    while result:GetParent() > 0 do
        local parentId = result:GetParent()
        local parent = self:GetMapPath(parentId)
        result = parent
        table.insert(list, 0, result)
    end

    return list
end

function IslandPathManager:LateUpdate()
    --console.error("IslandPathManager:LateUpdate")
    self:CheckCleanedAgent()
end

function IslandPathManager:RegisterEvent()
    MessageDispatcher:AddMessageListener(MessageType.AgentCleaned, self.CleanedAgent, self)
    MessageDispatcher:AddMessageListener(MessageType.IslandLinkHomeland, self.LinkedHomeland, self)

end

function IslandPathManager:UnRegisterEvent()
    MessageDispatcher:RemoveMessageListener(MessageType.AgentCleaned, self.CleanedAgent, self)
    MessageDispatcher:RemoveMessageListener(MessageType.IslandLinkHomeland, self.LinkedHomeland, self)
end

function IslandPathManager:Release()
    self:UnRegisterEvent()
end

return IslandPathManager