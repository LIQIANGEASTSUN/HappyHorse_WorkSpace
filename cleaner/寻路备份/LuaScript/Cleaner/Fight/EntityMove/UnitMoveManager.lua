---@class UnitMoveManager
local UnitMoveManager = {

}

-- 行走路径获取类型
UnitMoveManager.MoveType = {
    -- 自由移动
    Freedom = 1,
    -- 寻路算法移动
    FindPathAlgorithm = 2,
}

-- 技能配置
UnitMoveManager.Moves = {
    [UnitMoveManager.MoveType.Freedom] = "Cleaner.Fight.EntityMove.UnitMoveFreedom",
    [UnitMoveManager.MoveType.FindPathAlgorithm] = "Cleaner.Fight.EntityMove.UnitMoveFindPath",
}

function UnitMoveManager:CreateMove(entity, moveType)
    local path = self.Moves[moveType]
    local unitMove = include(path)
    local unitMoveInstance = unitMove.new(entity)
    return unitMoveInstance
end

return UnitMoveManager