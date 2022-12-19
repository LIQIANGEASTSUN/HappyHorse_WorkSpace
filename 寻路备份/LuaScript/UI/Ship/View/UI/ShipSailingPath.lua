---@type FindPathInfo
local FindPathInfo = require "Cleaner.PathFinding.FindPathInfo"

--@type PathFindingController
local PathFindingController = require "Cleaner.PathFinding.PathFindingController"

---@class ShipSailingPath
local ShipSailingPath = {
    pathParent = nil,
    pathArr = {},
    mapMin = Vector2(0, 0),
    mapSize = Vector2(1080, 1920) * 5,
    gridSize = 70,

    homelandDir = {
        Vector2(0, 1),
        Vector2(0, -1),
        Vector2(-1, 0),
        Vector2(1, 0),
    }
}

function ShipSailingPath:SetHomelandData(homelandAnchored, sizeDelta)
    ShipSailingPath:SetAreaNodeType(homelandAnchored, sizeDelta)

    local x = homelandAnchored.x
    local y = homelandAnchored.y - sizeDelta.y * 0.5 - self.gridSize
    self.startPos = Vector2(x, y)
end

function ShipSailingPath:SetPathParent(pathParent)
    self.pathParent = pathParent
    self.item = find_component(self.pathParent.gameObject,'Item',Transform)

    if not self.pathFindingController then
        self.pathFindingController = PathFindingController.new(FindPathInfo.AlgorithmType.Astar, FindPathInfo.MapType.Quad_Four)
        self.pathFindingController:CreateMap(self.mapMin, self.mapMin + self.mapSize, self.gridSize)
    end
end

function ShipSailingPath:SetAreaNodeType(anchoredPosition, sizeDelta)
    anchoredPosition = self:UIPositionToMapPos(anchoredPosition)
    self.pathFindingController:SetAreaNodeType(anchoredPosition, sizeDelta * 1, 10)
end

function ShipSailingPath:UIPositionToMapPos(anchoredPosition)
    anchoredPosition = anchoredPosition + self.mapSize * 0.5
    return anchoredPosition
end

function ShipSailingPath:MapPosToUiPosition(pos)
    pos = pos - self.mapSize * 0.5
    return pos
end

function ShipSailingPath:ResetPath(anchoredPosition, sizeDelta, show)
    self:Clear()
    if not show then
        return
    end

    local center = self:UIPositionToMapPos(self.startPos)
    local port = self:IslandPortPosition(anchoredPosition, sizeDelta)
    local list = self.pathFindingController:Search(center.x, center.y, port.x, port.y)

    -- for i = 0, list.Count - 1 do
    --     self:CreateItem(list, i)
    -- end
    for i = 1, #list do
        self:CreateItem(list, i)
    end
end

function ShipSailingPath:Clear()
    for _, go in pairs(self.pathArr) do
        GameObject.Destroy(go)
    end
    self.pathArr = {}
end

-- 到的正上、正下、正左、正右，四个位置，算出来一个距离家园中心点最近的位置
function ShipSailingPath:IslandPortPosition(anchoredPosition, sizeData)
    local islandPos = anchoredPosition

    local size = sizeData * 0.5
    -- 周边加上一个地图格子的空间
    size = size + Vector2(self.gridSize, self.gridSize)
    local distance = 1000000
    local result = islandPos
    for _, dir in pairs(self.homelandDir) do
        local offset = islandPos + Vector2(dir.x * size.x, dir.y * size.y)
        local value = offset.magnitude
        if value < distance then
            distance = value
            result = offset
        end
    end

    result = self:UIPositionToMapPos(result)
    return result
end

function ShipSailingPath:CreateItem(list, index)
    local pos = list[index]
    pos = self:MapPosToUiPosition(pos)
    local rect, text = self:CloneItem()
    text.text = tostring(index)
    rect.anchoredPosition = pos

    local direction = self:Direction(list, index)
    for i = 1, 4 do
        local name = string.format("%d", i)
        local dir = find_component(rect.gameObject,name,Transform)
        dir.gameObject:SetActive(direction[i])
    end
end

function ShipSailingPath:CloneItem()
    local clone_go = self.item.gameObject
    local go = GameObject.Instantiate(clone_go)
    table.insert(self.pathArr, go)
    local parent = self.pathParent
    go.transform:SetParent(parent, false)
    go:SetActive(true)
    local rect = go:GetComponent(typeof(RectTransform))
    local text = find_component(go,'Text',Text)
    return rect, text
end

function ShipSailingPath:Direction(list, index)
    -- 分别代表 上 1、下 2、左 3、右 4
    local direction = {false, false, false, false}
    if #list <= 1 then
        direction = {true, true, false, false}
        return direction
    end

    local result, value = self:ToPre(list, index)
    if result then
        direction[value] = true
    end

    result, value = self:ToNext(list, index)
    if result then
        direction[value] = true
    end
    return direction
end

function ShipSailingPath:ToPre(list, index)
    if index == 1 then
        local selfPos = list[index]
        local prePos = list[index + 1]
        return self:DirectionOffset(selfPos, prePos)
    else
        local selfPos = list[index]
        local prePos = list[index - 1]
        return self:DirectionOffset(selfPos, prePos)
    end
end

function ShipSailingPath:ToNext(list, index)
    if index == #list then
        local selfPos = list[index]
        local prePos = list[index - 1]
        return self:DirectionOffset(selfPos, prePos)
    else
        local selfPos = list[index]
        local prePos = list[index + 1]
        return self:DirectionOffset(selfPos, prePos)
    end
end

function ShipSailingPath:DirectionOffset(selfPos, ToPos)
    -- 上 1、 -- 下 2、  -- 左 3、  -- 右 4
    local offset = ToPos - selfPos
    if offset.x > 10 then      -- 右
        return true, 4
    elseif offset.x < -10 then -- 左
        return true, 3
    elseif offset.y > 10 then  -- 上
        return true, 1
    elseif offset.y < -10 then -- 下
        return true, 2
    end
    return false, 0
end

return ShipSailingPath