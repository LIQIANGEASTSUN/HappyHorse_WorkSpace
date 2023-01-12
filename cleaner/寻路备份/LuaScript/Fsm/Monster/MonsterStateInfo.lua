---@class MonsterStateInfo
local MonsterStateInfo = { }

MonsterStateInfo.StateType = {
    Idle = 1,
    -- 攻击
    Attack = 2,
    -- 怪物死亡
    Death = 3,
    -- 巡逻
    Patrol = 4,
    -- 追击去攻击
    Pursuit = 5,
}

MonsterStateInfo.States = {
    [MonsterStateInfo.StateType.Idle] = "Fsm.Monster.MonsterStateIdle",
    [MonsterStateInfo.StateType.Attack] = "Fsm.Monster.MonsterStateAttack",
    [MonsterStateInfo.StateType.Death] = "Fsm.Monster.MonsterStateDeath",
    [MonsterStateInfo.StateType.Patrol] = "Fsm.Monster.MonsterStatePatrol",
    [MonsterStateInfo.StateType.Pursuit] = "Fsm.Monster.MonsterStatePursuit",
}

return MonsterStateInfo