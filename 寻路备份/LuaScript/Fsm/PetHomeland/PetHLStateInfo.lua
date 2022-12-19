local PetHLStateInfo = { }

-- 己方怪物
PetHLStateInfo.StateType = {
    -- 休闲
    Idle = 1,
    -- 巡逻
    Patrol = 2,
}

PetHLStateInfo.States = {
    [PetHLStateInfo.StateType.Idle] = "Fsm.PetHomeland.PetHLStateIdle",
    [PetHLStateInfo.StateType.Patrol] = "Fsm.PetHomeland.PetHLStatePatrol",
}

return PetHLStateInfo