
---@type FindPathInfo
local FindPathInfo = {}

FindPathInfo.AlgorithmType = {
    -- AStar 寻路算法
    Astar = 1,
    -- Jump Point Search 算法
    Jps = 2,
}

-- 地图类型
FindPathInfo.MapType = {
    -- 正方形格子地图, 4 个方向
    Quad_Four = 4,
    -- 正六边形格子地图, 6 个方向
    Hex_Six = 6,
    -- 正方形格子地图， 8 个方向
    Quad_Eight = 8,
    -- 正方形格子地图， 8 个方向
    Quad_Eight_Cleaner = 10,
}

FindPathInfo.NodeType ={
    -- 空地
    Null = -1,

    -- 平坦的路
    Smooth = 0,

    -- 泥路
    Mud = 1,

    -- 草地
    Grass = 2,

    -- 沙地
    Desert = 3,

    -- 障碍物
    Obstacle = 10,
}

FindPathInfo.NodeState = {
    Null = 0,
    InOpenTable = 1,
    InColsedTable = 2,
    Known = 3,
}

-- 邻居类型
FindPathInfo.NeighborType = {
    -- 4 个邻居:地图方形格子,长宽一样
    Four = 4,
    -- 6 个邻居:地图正六边形格子
    Hex = 6,
    -- 8 个邻居:地图方形格子,长宽一样
    Eight = 8,
}

-- 地图对应的格子邻居类型
FindPathInfo.MapNodeNeighborType = {
    [FindPathInfo.MapType.Quad_Four] = FindPathInfo.NeighborType.Four,
    [FindPathInfo.MapType.Hex_Six] = FindPathInfo.NeighborType.Hex,
    [FindPathInfo.MapType.Quad_Eight] = FindPathInfo.NeighborType.Eight,
    [FindPathInfo.MapType.Quad_Eight_Cleaner] = FindPathInfo.NeighborType.Eight,
}

FindPathInfo.NeighborQuad = {
    [FindPathInfo.NeighborType.Four] = {
        { -1,  0},  -- 左
        {  0,  1},  -- 上
        {  1,  0},  -- 右
        {  0, -1}   -- 下
    },

    [FindPathInfo.NeighborType.Eight] = {
        { -1,  1},  -- 左上
        { -1,  0},  -- 左
        {  1,  1},  -- 右上
        {  0,  1},  -- 上
        {  1, -1},  -- 右下
        {  1,  0},  -- 右
        { -1, -1},  -- 左下
        {  0, -1}   -- 下
    },
}

-- 六边形地图格子列类型：奇数列、偶数列
FindPathInfo.HexColType = {
    -- 偶数列
    Even = 0,
    -- 奇数列
    Odd = 1,
}

FindPathInfo.NeighborHex = {
    -- 偶数列节点 6 个邻居的相对二维坐标
    [FindPathInfo.HexColType.Even] = {
        {  1,  0},   -- 上
        {  0,  1},   -- 右上
        { -1,  1},   -- 右下
        { -1,  0},   -- 下
        { -1, -1},   -- 左下
        {  0, -1},   -- 左上
    },

    -- 奇数列节点 6 个邻居的相对二维坐标
    [FindPathInfo.HexColType.Odd] = {
        {  1,  0},   -- 上
        {  1,  1},   -- 右上
        {  0,  1},   -- 右下
        { -1,  0},   -- 下
        {  0, -1},   -- 左下
        {  1, -1},   -- 左上
    }
}

FindPathInfo.Algorithms = {
    [FindPathInfo.AlgorithmType.Astar] = "Cleaner.PathFinding.Algorithm.AStar.AStar",
    [FindPathInfo.AlgorithmType.Jps] = "Cleaner.PathFinding.Algorithm.JumpPointSearch.JPS",
}

FindPathInfo.Maps = {
    [FindPathInfo.MapType.Quad_Four] = "Cleaner.PathFinding.Map.MapQuad",
    [FindPathInfo.MapType.Hex_Six] = "Cleaner.PathFinding.Map.MapHex",
    [FindPathInfo.MapType.Quad_Eight] = "Cleaner.PathFinding.Map.MapQuad",
    [FindPathInfo.MapType.Quad_Eight_Cleaner] = "Cleaner.PathFinding.Map.MapCleaner",
}

return FindPathInfo