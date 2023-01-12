
---@class AgentType 建筑类型
AgentType = {
    food_factory = 1, --食品工厂
    dock = 2, --船坞
    recycle = 3, --回收站
    resource = 4, --资源
    animal = 5, --动物
    decoration = 6, --装饰
    ground = 7, --地块
    air_wall = 8, --空气墙
    recovery_pet = 9, -- 宠物回血点
    decoration_factory = 10, --装饰工厂
    decoration_building = 11,  -- 装饰建筑
    linkHomeland_groud = 12, -- 连接家园地块
}

---@class EntityType 生物类型
EntityType = {
    Pet = 1,            --- 宠物
    Monster = 2,        --- 敌方怪物
    Ship = 3,           --- 船
    PetHL = 4,          --- 家园内宠物
}

---@class EntityEvent
EntityEvent = {
    -- 创建
    ENTITY_CREATE = "ENTITY_CREATE",
    -- 销毁清除
    ENTITY_DESTROY = "ENTITY_DESTROY",
}

HpType = {
    Pet1 = 1,
    Pet2 = 2,
    Monster = 3,
}

HP_INFO_EVENT = {
    HP_INFO = "HP_INFO",
    HP_DESTROY = "HP_DESTROY",
    HP_ENABLE = "HP_ENABLE"
}

---@class ProructionStatus 产品状态
ProductionStatus = {
    -- 无效的
    None = -1,
    -- 生产中
    Doing = 1,
    -- 已完成
    Finish = 2,
}

BUILDING_EVENT = {
    START_PRODUCTION = "START_PRODUCTION",
    FINISH_PRODUCTION = "FINISH_PRODUCTION",
    TAKE_PRODUCTION = "TAKE_PRODUCTION",
}

---@class CampType
CampType = {
    -- 阵营：红方  (Player 对立方)
    Red = 1,
    -- 阵营：蓝方  (Player 一方)
    Blue = 2,

    -- 阵营关系
    CampRelation = {
        -- 自己
        Self = 1,
        -- 友方单位
        Friend = 2,
        -- 敌方单位
        Other = 3,
    },

    IsValidCampRelation = function(relation, camp, otherCamp, isSelf)
        if relation == CampType.CampRelation.Self then
            return isSelf
        elseif relation == CampType.CampRelation.Friend then
            return camp == otherCamp
        else
            return camp ~= otherCamp
        end
    end
}

---@class IslandUnlockCondition 岛屿解锁类型
IslandUnlockCondition = {
    -- 船坞等级
    ShipDock_Level = 1,
    -- 前置岛屿
    Pre_island = 2,
}

---@class IslandTemplateType
-- 岛屿表类型
IslandTemplateType = {
    -- 家园
    Homeland = 1,
    -- 探索岛
    Island = 2,
}

---@class EntityAnimationName
EntityAnimationName = {
    Walk = "Walk",
    Idle_A = "Idle_A",
    Idle_B = "Idle_B",
    Idle_C = "Idle_C",
    Death = "Death",
    Attack = "Attack",
}

-- UpgradeEnableType 升级类型
UpgradeEnableType = {
    -- 可以升级
    Enable = 1,
    -- 资源不够
    ItemNotEnougth = 2,
    -- Player 等级低
    PlayerLevelSmall = 3,
    -- 最大等级
    MaxLevel = 4,
}

---@class TaskEnum 任务类型枚举
TaskEnum = {
    ---玩家等级
    LevelUp = 101,
    ---获得宠物(某种类型)
    GetPet = 102,
    ---宠物等级(n个宠物达到)
    PetLevel = 103,
    ---拥有宠物(某种类型)
    HavePet = 104,
    ---生产{itemName}{num}个
    ProductItem = 105,
    ---使用装饰工厂{num}次
    ProductDecoration = 106,
    ---扩建{num}次
    LinkIsland = 107,
    ---使用回收站获得{num}金币
    RecycleItem = 108,
    ---获得{itemName}{num}个
    GetItem = 109,
    ---发现{factoryName}
    FindAgent = 110,

}

---@class TaskType
TaskType = {
    ---主线
    Main = 1,
    ---支线
    Branch = 2,
}

---@class TaskState 任务状态
TaskState = {
    ---未开始
    locked = -1,
    ---已接取
    started = 1,
    ---已完成
    finish = 2,
    ---已提交
    submit = 3
}

---@class TaskCountType 任务进度计算类型
TaskCountType = {
    ---累计型任务
    Count = 0,
    ---计算型任务，接到后才开始累计
    Add = 1,
}

---@class TaskCountMethod 任务进度计算方式
TaskCountMethod = {
    ---大于等于
    GreaterEqual = 0,
    ---小于等于
    LessEqual = 1,
    ---等于
    Equal = 2
}

TipsType = {
    -- 无效值
    None = -1,
    -- 工厂产品生产完成 Tips
    UnitProductFinishTips = 1,
    -- 工厂生产中 Tips
    UnitProductDoingTips = 2,
    -- 怪物血条
    UnitMonsterHpTips = 3,
    -- 宠物血条类型1
    UnitPetHpType1Tips = 4,
    -- 宠物血条种类2
    UnitPetHpType2Tips = 5,
    -- Boss 标记
    UnitBoss = 6,
}

UnitType = {
    None = -1,
    -- 战斗单位
    FightUnit = 1,
    -- 食品工厂单位
    FoodFactoryUnit = 2,
    -- 装饰工厂单位
    DecorationFactoryUnit = 3,
}

------------------------- 类型定义 插件用
---@class DIntInt
---@field key int
---@field value int

---@class DProduction 产出
---@field id string id
---@field level int 开始生产的等级
---@field recipe DIntInt[] 生产配方
---@field startTime int64 生产开始时间
---@field endTime int64 生产结束时间
---@field outItem DIntInt[] 产出
---@field use int32  0:生产完 1:正在生产

---@class DEquip 装备
---@field id int id
---@field type int 类型
---@field level int 等级
---@field up int 是否穿戴 0:未穿戴 1:穿戴