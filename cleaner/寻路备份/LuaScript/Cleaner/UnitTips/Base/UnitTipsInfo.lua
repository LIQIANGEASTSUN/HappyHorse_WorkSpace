---@type UnitTipsInfo
local UnitTipsInfo = {}

UnitTipsInfo.TipsConfigs = {
    [TipsType.UnitProductFinishTips] = "Cleaner.UnitTips.UnitProductFinishTips",
    [TipsType.UnitProductDoingTips] = "Cleaner.UnitTips.UnitProductDoingTips",
    [TipsType.UnitMonsterHpTips] = "Cleaner.UnitTips.TipsHpMonster",
    [TipsType.UnitPetHpType1Tips] = "Cleaner.UnitTips.TipsHpPetType1",
    [TipsType.UnitPetHpType2Tips] = "Cleaner.UnitTips.TipsHpPetType2",
    [TipsType.UnitBoss] = "Cleaner.UnitTips.TipsBoss",
}

-- Tips 跟随位置计算类型
UnitTipsInfo.TipsFollowType = {
    -- 只计算 UnitTipsInfo
    Unit = 1,
    -- 计算 Unit 并且向 Camera 偏移
    Unit_And_Camera = 2,
}

return UnitTipsInfo