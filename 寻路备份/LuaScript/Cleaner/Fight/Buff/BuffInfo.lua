---@class BuffInfo
local BuffInfo = {}

-- Buff 类型
BuffInfo.BuffType = {
    -- 效果类
    -- 无效值
    None = -1,
    -- 恢复血量固定值
    RecoverHpValue = 1,
    -- 恢复血量百分比
    RecoverHpPercent = 2,
    -- 物理伤害增加值
    PhysicsDamageAddValue = 3,
    -- 物理伤害增加百分比
    PhysicsDamageAddPercent = 4,
    -- 属性克制物理伤害倍数
    RestraintPhysicsHarmMultiple = 5,

    -- 移动速度增加值
    MoveSpeedAddValue = 6,
    -- 净化(移除所有有害buff)
    Purify = 7,

    -- 状态类
    -- 眩晕
    Dizziness = 10000,
    -- 沉默
    Silence = 10001,
    -- 无敌
    Unbeatable = 10002,
    -- 霸体
    SuperArmor = 10003,
    -- 免疫
    Immune = 10004,
}

-- 触发类型
BuffInfo.TriggerType = {
    -- 无效值
    None = -1,
    -- 按时间间隔
    TimeInterval = 1,
    -- owner主动攻击时
    Hit = 2,
    -- owner被攻击时
    BeHit = 3,
    -- owner死亡前触发
    DeathBefore = 4,
    -- owner死亡后触发
    DeathAfter = 5,
    -- 添加buff时触发
    Apply = 6,
    -- 移除buff时触发
    Remove = 7,
}

-- 移除类型
BuffInfo.RemoveType = {
    -- 无效值
    None = -1,
    -- 时间结束
    TimeEnd = 1,
    -- 触发次数
    TriggerNumber = 2,
}

BuffInfo.AdvantageType = {
    -- 有利的
    Helpful = 1,
    -- 有害
    Harmful = 2,
}

-- 优先级类型
BuffInfo.PriorityType = {
    -- 覆盖
    Overlay = 1,
    -- 叠加
    Superposition = 2,
}

BuffInfo.GetBuffAlias = function(type)
    local path = BuffInfo.Buffs[type]
    local skill = include(path)
    return skill
end


-- Buff 配置
BuffInfo.Buffs = {
    [BuffInfo.BuffType.RecoverHpValue] = "Cleaner.Fight.Buff.BuffEntity.BuffEffectRecoverHpValue",
    [BuffInfo.BuffType.RecoverHpPercent] = "Cleaner.Fight.Buff.BuffEntity.BuffEffectRecoverHpPercent",
    [BuffInfo.BuffType.RestraintPhysicsHarmMultiple] = "Cleaner.Fight.Buff.BuffEntity.BuffEffectRestraintPhysicsHarmMultiple",
    [BuffInfo.BuffType.MoveSpeedAddValue] = "Cleaner.Fight.Buff.BuffEntity.BuffEffectMoveSpeedAddValue",
    [BuffInfo.BuffType.Purify] = "Cleaner.Fight.Buff.BuffEntity.BuffEffectPurify",

    [BuffInfo.BuffType.SuperArmor] = "Cleaner.Fight.Buff.BuffEntity.BuffStateSuperArmor",
    [BuffInfo.BuffType.Immune] = "Cleaner.Fight.Buff.BuffEntity.BuffStateImmune",
    [BuffInfo.BuffType.Unbeatable] = "Cleaner.Fight.Buff.BuffEntity.BuffStateUnbeatable",
}

BuffInfo.BuffTriggers = {
    [BuffInfo.TriggerType.TimeInterval] = "Cleaner.Fight.Buff.BuffTrigger.BuffTriggerTimeInterval",
    [BuffInfo.TriggerType.Hit] = "Cleaner.Fight.Buff.BuffTrigger.BuffTriggerHit",
    [BuffInfo.TriggerType.BeHit] = "Cleaner.Fight.Buff.BuffTrigger.BuffTriggerBeHit",
    [BuffInfo.TriggerType.DeathBefore] = "Cleaner.Fight.Buff.BuffTrigger.BuffTriggerDeathBefore",
    [BuffInfo.TriggerType.DeathAfter] = "Cleaner.Fight.Buff.BuffTrigger.BuffTriggerTimeInterval",
}

BuffInfo.BuffRemoves = {
    [BuffInfo.RemoveType.TimeEnd] = "Cleaner.Fight.Buff.BuffRemove.BuffRemoveTimeEnd",
    [BuffInfo.RemoveType.TriggerNumber] = "Cleaner.Fight.Buff.BuffRemove.BuffRemoveTriggerNumber"
}


BuffInfo.GetTriggerAlias = function(type)
    local path = BuffInfo.BuffTriggers[type]
    local trigger = include(path)
    return trigger
end

BuffInfo.GetRemoveAlias = function(type)
    local path = BuffInfo.BuffRemoves[type]
    local trigger = include(path)
    return trigger
end

return BuffInfo