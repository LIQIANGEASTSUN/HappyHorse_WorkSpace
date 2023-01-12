local PetStateInfo = { }

-- 己方怪物
PetStateInfo.StateType = {
    -- 休闲
    Idle = 1,
    -- 跟随 Player
    FollowPlayer = 2,
    -- 攻击
    Attack = 3,
    -- 怪物死亡
    Death = 4,
    -- 追击去攻击
    Pursuit = 5,
}

PetStateInfo.States = {
    [PetStateInfo.StateType.Idle] = "Fsm.Pet.PetStateIdle",
    [PetStateInfo.StateType.FollowPlayer] = "Fsm.Pet.PetStateFollowPlayer",
    [PetStateInfo.StateType.Attack] = "Fsm.Pet.PetStateAttack",
    [PetStateInfo.StateType.Death] = "Fsm.Pet.PetStateDeath",
    [PetStateInfo.StateType.Pursuit] = "Fsm.Pet.PetStatePursuit",
}

return PetStateInfo