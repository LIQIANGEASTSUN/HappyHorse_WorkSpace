---@class ShipStateInfo
local ShipStateInfo = { }

ShipStateInfo.ShipStateType = {
    -- 船在家园港口停靠
    Homeland = 1,
    -- 船移动去岛屿探索
    Move_To_Island = 2,
    -- 船移动回家园
    Move_To_Homeland = 3,
    -- 船在岛屿港口停靠
    Island = 4,
}

ShipStateInfo.States = {
    [ShipStateInfo.ShipStateType.Homeland] = "Fsm.Ship.ShipStateHomeland",
    [ShipStateInfo.ShipStateType.Island] = "Fsm.Ship.ShipStateIsland",
}

ShipStateInfo.ChangeStateReason = {
    -- 点击前往按钮去岛屿
    Click_Go_To_Island = 1,
    -- 从岛屿回家园
    From_Island_To_Homeland = 2,
}

return ShipStateInfo