---@class PetFollowPlayer
-- 宠物跟随 Player
local PetFollowPlayer = {
    targetTr = nil,
    entityArr = {},
    ---@type Dictionary[entityId, (row, index)]
    entityRowCol = {},
}

local GetPlayer = function()
    local playerCharacter = CharacterManager.Instance():Find("Player")
    if playerCharacter then
        return playerCharacter:GetGameObject().transform
    end
    return nil
end

-- 计算宠物跟随的位置
function PetFollowPlayer:GetFollowPos(entity)
    if not Runtime.CSValid(self.targetTr) then
        self.targetTr = GetPlayer()
    end

    if not Runtime.CSValid(self.targetTr) then
        return false, self.entity:GetPosition()
    end

    local entityId = entity.entityId
    local result = self:Calculate(entityId)
    if not result then
        return false, self.entity:GetPosition()
    end

    --local x = Random.Range(-0.5, 0.5)
    --local z = Random.Range(-0.5, 0.5)
    --local destination = self.targetTr.position - self.targetTr.forward + Vector3(x, 0, z)

    local offset1 = self.targetTr.forward * (result.row + 1) * -1
    local offset2 = self.targetTr.right * result.col
    local destination = self.targetTr.position + offset1 + offset2

    return true, destination
end

-- 第 n 行的个数 count = n + 1
function PetFollowPlayer:AddEntity(entityId)
    table.insert(self.entityArr, entityId)
    self:ReLayout()
end

--[[
function PetFollowPlayer:AddEntity(entityArr)
    self.entityArr = entityArr
    self:ReLayout()
end
--]]

function PetFollowPlayer:RemoveEntity(entityId)
    for i, v in ipairs(self.entityArr) do
        if v == entityId then
            table.remove(self.entityArr, i)
        end
    end

    self:ReLayout()
end

-- 是否奇数
function IsOdd(value)
    local floor = value % 2
    return floor == 1
end

function PetFollowPlayer:Calculate(entityId)
    local data = self.entityRowCol[entityId]
    if not data then
        return 0, 0
    end

    local col = 0
    --data.row, data.index, data.rowCount
    if IsOdd(data.rowCount) then
        -- 从中间往两边排列，下面这行是 index 对应的位置
        --  3， 1， 0， 2， 4
        -- 这一行是奇数个 (index + 1) / 2 取整
        -- index：0， 1， 2， 3， 4， 5， 6
        -- col  ：0，-1， 1，-2， 2，-3， 3
        col = (data.index + 1) / 2
        col = math.floor(col)
        -- 正负号：index 为奇数取 -1， 偶数取 1
        local sign = IsOdd(data.index) and -1 or 1
        col = col * sign
    else
        -- 从中间往两边排列，下面这行是 index 对应的位置
        -- 4, 2， 0， 1， 3, 5
        -- 这一行是偶数个 (index) / 2 取整
        -- index：  0，   1，    2，   3，    4，   5
        -- col  ：-0.5， 0.5， -1.5， 1.5， -2.5， 2.5
        col = (data.index) / 2
        col = math.floor(col) + 0.5
        -- 正负号：index 为奇数取 1， 偶数取 -1
        local sign = IsOdd(data.index) and 1 or -1
        col = col * sign
    end

    local result = {row = data.row, col = col}
    return result
end

-- 如果个数小于 5 个，则排一行就行了
-- 如果个数大于 5 个，则第一排 3 个，每增加一排，多 2 个, 阵型如下
--     * * *
--   * * * * *
-- * * * * * * *
-- 或者，如果个数大于 5 个，则第一排 4 个，每增加一排，多 1 个, 阵型如下
--   * * * *
--  * * * * *
-- * * * * * *
function PetFollowPlayer:ReLayout()
    local rowCount = #self.entityArr
    if rowCount >= 5 then
        rowCount = 4
    end

    self.entityRowCol = {}
    -- row 行从 0 开始
    local row = 0
    -- 每一行的index 从 0 开始
    local index = 0
    for i, v in ipairs(self.entityArr) do
        local data = {
            entityId = v,
            row = row,
            -- 每一行的第多少个，从 0 开始
            index = index,
            rowCount = rowCount
        }
        self.entityRowCol[v] = data

        index = index + 1
        if index >= rowCount then
            index = 0
            rowCount = rowCount + 1
            -- 如果剩余个数不足 rowCount，则rowCount 等于剩余个数
            if rowCount > #self.entityArr - i then
                rowCount = #self.entityArr - i
            end
            row = row + 1
        end
    end
end

return PetFollowPlayer