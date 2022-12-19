---@class TileType 地图格子类型
TileType = {
    none = 0x00,
    pass = 0x01,
    place = 0x02,
    place_pass = 0x03
}

---@class SceneMode
SceneMode = {
    unknown = "unknown",
    loading = {name = "PlayInterface", report = "PlayInterface"},
    home = {name = "city", report = "MainInterface"},
    visit = {name = "FriendCity", report = "FriendTown"},
    exploit = {name = "DragonExploit", report = "DragonExploit"},
    parkour = {name = "DragonParkour", report = "DragonParkour"},
    fishing = {name = "DragonFishing", report = "DragonFishing"},
    [2] = {name = "2", report = "MainInterface"},
    [3] = {name = "3", report = "MainInterface"},
    [4] = {name = "4", report = "MainInterface"}
}

SceneId2Mode = {
    city = SceneMode.home,
    ["2"] = SceneMode[2],
    ["3"] = SceneMode[3],
    ["4"] = SceneMode[4]
}
--------------------------------------------
-- 清除消耗类型
CleanConsumeType = {
    none = 0, --不消耗
    item = 1, --道具
    task = 2, --任务
    buildingRepair = 3, --建筑修复
    ads = 4 --观看广告
}

---@class CleanState
CleanState = {
    uninited = -1, --未初始化
    locked = 0, --未开始
    prepare = 1, --准备
    clearing = 2, --进行中
    cleared = 3 --已完成
}

CleanAgentState = {
    PopAgent = 1,
    CleanDirectly = 2,
    Prepare = 3,
    ShowClean = 4,
    showEnd = 5,
    Exit = 6
}

ObstacleType = {
    other = 0, -----其它功能障碍
    grass = 1,
    tree = 2,
    stone = 3,
    box = 15
}
--道具类型，对应itemTemplate表的type字段
PropsType = {
    dragonKey = 17, --龙钥匙
    energyBuff = 20, --体力buff（关联buff配置表）
    dragonSkin = 27,
    energyDiscountItem = 34 --体力折扣道具（纯道具，用一次少一个）
}
--钥匙宝箱ID，1普通，2银宝箱，3金宝箱
-- KeyBoxIds = {
--     ["15001"] = 1,--普通钥匙宝箱
-- }

---@class CommissionMsg
---@field commissionId int64 当前探索中洞穴id
---@field unlockMaxId int64 最近解锁洞穴
---@field finished boolean 最近解锁洞穴是否已探索
---@field startTime int64 当前探索中洞穴开始探索时间
---@field creatures string[] 参与探索的龙
---@field hasReward boolean 前端增加变量, 代表是否有奖励未领取

---@class CommissionMeta
---@field id any
---@field attribute any
---@field floor any
---@field nextID any
---@field dragonEnergy any
---@field consume any
---@field time any 分钟
---@field reward any
---@field weightReward1 any
---@field weightReward2 any
---@field unlockfloor any

---@class CarryParams
---@field gameObject GameObject 奖励物体
---@field fromPosition Vector3 起始点
---@field targetPosition Vector3 中间停止点
---@field finalPosition Vector3 终点
---@field lookDir Vector3 停下后朝向
---@field carry boolean 是否挂载奖励

---@class CommissionReward
---@field carryParams CarryParams[] 奖励物体

---@class ObjectData
---@field id string
---@field tid string
---@field coord any
---@field pos any
---@field scale any
---@field euler any

---@class ObjectMeta
---@field id string
---@field name string
---@field model string
---@field icon string
---@field x number
---@field z number
---@field attribute number
---@field dragonSkillAttribute number
---@field cleanTool string
---@field type number
---@field obstacleType number
---@field achievementType number
---@field taskunlock string
---@field consumeType number
---@field consume any
---@field whetherHide number
---@field rewardItem any
---@field rewardItem1 any
---@field probabilityRewardItem1 any
---@field probabilityRewardItem2 any
---@field probabilityRewardItem3 any
---@field dragonReward any
---@field roleLevel number

---@class CustomInput
---@field up bool
---@field down bool
---@field press bool
---@field drag bool
---@field progress float 长按进度条, 取值范围[0, 1]
---@field scale float
---@field worldDelta Vector3
---@field screenDelta Vector2
---@field hit RaycastHit
---@field mousePosition Vector2
---@field GetHitCount function
---@field GetHitInfo function

---@class SkinMeta 皮肤配置表
---@field id string 编号
---@field remarks string 备注
---@field name string 名字
---@field desc string 描述
---@field type int 类型(1:nino 2:female 3:building)
---@field user string 使用对象
---@field icon string 图标
---@field model string 模型
---@field getWay string 获得途径
---@field time string 有效期

---@class PlayerInfoResponse 个人信息响应
---@field pid string 编号pid
---@field nickname string 昵称
---@field avatar string 头像
---@field unlockAvatars string[] 已解锁头像
---@field frame string 头像框
---@field unlockFrames string[] 已解锁头像框
---@field inuseSkins string[] 正在使用的皮肤
---@field unlockSkins string[] 已解锁的皮肤
--------------------------------------------

---模型类型
RenderType = {
    sprite = 1,
    spine = 2,
    skinnedMesh = 3,
    animator = 4
}

MissionType = {
    ---修复建筑
    Building = 0,
    ---采集指定类型pickable
    Pickable = 1,
    ---收集指定类型goods
    Goods = 2,
    ---完成指定数量订单
    Order = 3,
    ---采集指定某1/多个障碍物
    Collection = 4,
    ---去某一个场景
    Scenes = 5,
    ---击杀某一个npc
    Kill = 6,
    ---生产道具
    Produce = 7,
    ---寻找一个障碍物
    FindObject = 8,
    ---种植
    Planting = 9,
    ---套装收藏
    CollectionItem = 10,
    ---从工厂收获道具
    CollectFactoryItem = 11,
    ---从土地中收获道具
    CollectFarmItem = 12,
    ---得到某个ID的龙
    GetDragon = 13,
    ---喂养龙
    FeedDragon = 14,
    ---从龙身上收获道具
    CollectDragonItem = 15,
    ---购买龙
    BuyDragon = 16,
    ---种植次数
    PlantingCount = 17,
    ---从土地中收获任意道具
    CollectFarmItemCount = 18,
    ---繁育固定次数
    BreedCount = 19,
    ---繁育固定Id的龙
    Breed = 20,
    -- 拥有某个龙
    OwnedDragon = 21,
    ---消耗指定数量体力
    UseEnergy = 22,
    ---兑换指定次数能量
    ExchangeEnergy = 23,
    ---满载货船次数
    TimeOrder = 24,
    ---合成指定等级的龙
    MergeDragon = 25,
    ---完成炼金的次数
    GoldOrderCount = 26,
    ---洞穴探索次数
    CommissionCount = 27,
    ---去副本场景
    GoDungeon = 28,
    ---登录
    Login = 29,
    ---领取洞穴探索奖励次数
    CommissionRewardCount = 30,
    --修复建筑类计数子任务
    BuildingRepairCount = 31,
    -- 参与圣诞转盘次数
    ChristmasDrawCount = 32,
    ---把龙从临时背包移动到龙巢
    DragonMoveToNest = 33,
    ---清除指定类型的障碍达到Y个（历史清除也算，按照场景统计，三星系统用）
    PickableCount = 34,
    ---完成商人交易
    Trade = 35,
    ---完成场景任务（最后一个任务ID）
    FinishTask = 36,
    ---扭蛋次数到达X次
    GachaCount = 37,
    ---采集发光障碍(地图三星用)
    PickDragonCollect = 38,
    ---完成云端之旅次数
    DragonMazeCount = 39,
    ---交付龙物资个数
    DeliverDragonProduct = 40,
    ---签到(神龙贸易季)
    DragonSeasonCheckIn = 41,
    ---开农田地块
    OpenFarmland = 42,
    ---拥有X个XX物品
    OwnedItem = 43,
    ---完成洞穴探索次数
    CommissionFinishedCount = 44,
    ---交付限时生产物资个数（马拉松）
    DeliverLimitProduct = 45,
    ---挖掘出指定分组的宝藏
    GoldPanningTreasure = 46,
    ---穿戴某个时装
    DressUp = 47,
    ---修复指定的水管
    Pipe = 48,
    ---限时地图内消耗体力（阻碍物和转盘）
    LimitedMapUseEnergy = 49,
    ---限时地图内扭蛋次数
    LimitedMapGashapon = 50,
    ---公会地图内消耗体力（阻碍物和转盘）
    TeamMapUseEnergy = 51,
    ---公会地图完成npc任务次数
    TeamMapNPCTask = 52,
    ---公会地图内消耗龙力（阻碍物）
    TeamDragonMapUseStamina = 53,
    ---公会地图完成npc任务次数
    TeamDragonMapNPCTask = 54,
    ---挂机系统领取奖励次数
    HangUpReceive = 55,
}

---@class TaskKind 任务种类
TaskKind = {
    ---全部 查询用
    All = -1,
    ---主线支线
    Task = 0,
    ---黄金通行证
    GoldPass = 1,
    ---繁育活动
    BreedActivity = 2,
    ---活跃彩蛋
    ActiveEgg = 99,
    ---圣诞节 场景任务
    Christmas = 3,
    ---圣诞节 积分任务
    ChristmasScore = 4,
    ---情人节任务
    Valentine = 5,
    ---情人节积分任务
    ValentineScore = 6,
    ---地图三星任务
    MapStar = 7,
    ---拯救小动物任务
    SaveAnimal = 8,
    ---冒险岛任务
    AdventureIsland = 9,
    ---冒险岛积分任务
    AdventureIslandScore = 10,
    ---唤神舞会任务
    CallGodBall = 11,
    ---唤神舞会积分任务
    CallGodBallScore = 12,
    ---神龙贸易季任务
    DragonTrade = 13,
    ---神龙博物馆
    DragonMuseum = 14,
    ---神龙博物馆积分
    DragonMuseumScore = 15,
    ---海底祭典
    SeaCarnival = 16,
    ---海底祭典积分
    SeaCarnivalScore = 17,
    ---淘金大赛活动
    GoldPanning = 18,
    ---樱花庄园
    SakuraManor = 19,
    ---樱花庄园积分
    SakuraManorScore = 20,
    ---樱花庄园
    DesertPark = 21,
    ---樱花庄园积分
    DesertParkScore = 22,
    ---幽灵宅邸
    GhostMansion = 23,
    ---幽灵宅邸积分
    GhostMansionScore = 24,
}

---@class ActivityKind2TaskKind 活动id映射任务类型
ActivityKind2TaskKind = {
    ["100"] = TaskKind.Christmas,
    ["101"] = TaskKind.Valentine,
    ["102"] = TaskKind.AdventureIsland,
    ["103"] = TaskKind.CallGodBall,
    ["104"] = TaskKind.DragonMuseum,
    ["105"] = TaskKind.SeaCarnival,
    ["106"] = TaskKind.SakuraManor,
    ["107"] = TaskKind.DesertPark,
    ["108"] = TaskKind.GhostMansion,
    ["100001"] = TaskKind.GoldPanning,
    ["100002"] = TaskKind.GoldPanning,
    ["100003"] = TaskKind.GoldPanning,
    ["100004"] = TaskKind.GoldPanning,
}

TaskKind2ActivityId = table.reverse(ActivityKind2TaskKind)
---@class ActivityKind2ScoreTaskKind 活动id映射任务类型
ActivityKind2ScoreTaskKind = {
    ["100"] = TaskKind.ChristmasScore,
    ["101"] = TaskKind.ValentineScore,
    ["102"] = TaskKind.AdventureIslandScore,
    ["103"] = TaskKind.CallGodBallScore,
    ["104"] = TaskKind.DragonMuseumScore,
    ["105"] = TaskKind.SeaCarnivalScore,
    ["106"] = TaskKind.SakuraManorScore,
    ["107"] = TaskKind.DesertParkScore,
    ["108"] = TaskKind.GhostMansionScore,
}

---@class LevelMapActivityId2TaskKind
LevelMapActivityId2TaskKind = {
    ["100"] = TaskKind.Christmas,
    ["102"] = TaskKind.AdventureIsland,
    ["103"] = TaskKind.CallGodBall,
    ["104"] = TaskKind.DragonMuseum,
    ["105"] = TaskKind.SeaCarnival,
    ["106"] = TaskKind.SakuraManor,
    ["107"] = TaskKind.DesertPark,
    ["108"] = TaskKind.GhostMansion,
}

TaskKind2LevelMapActivityId = table.reverse(LevelMapActivityId2TaskKind)

---@class LevelMapActivity2ScoreTaskKind 活动id映射任务类型
LevelMapActivity2ScoreTaskKind = {
    ["100"] = TaskKind.ChristmasScore,
    ["102"] = TaskKind.AdventureIslandScore,
    ["103"] = TaskKind.CallGodBallScore,
    ["104"] = TaskKind.DragonMuseumScore,
    ["105"] = TaskKind.SeaCarnivalScore,
    ["106"] = TaskKind.SakuraManorScore,
    ["107"] = TaskKind.DesertParkScore,
    ["108"] = TaskKind.GhostMansionScore,
}

---@class AutoJumpType 自动跳转类型
AutoJumpType = {
    ---完全自动跳转
    Full = 0,
    ---打开界面跳转不帮忙自动点
    ShowWorldMapOnly = 1
}

---@class UICustomColor
UICustomColor = {
    green = "69ed4f",
    red = "ff563f",
    white = "ffffff",
    gold = "ffd700",
    tog_Select = "FFFFFF",
    tog_Default = "6f3104",
    dragonLevelColors = {
        Runtime.HexToRGB("bf8009"),
        Runtime.HexToRGB("1b7fda"),
        Runtime.HexToRGB("841edb"),
        Runtime.HexToRGB("eb7500")
    },
    dragonLevelColors2 = {
        Runtime.HexToRGB("895400"),
        Runtime.HexToRGB("00518d"),
        Runtime.HexToRGB("4d009d"),
        Runtime.HexToRGB("b13e00")
    },
    dragonLevelColors3 = {
        Runtime.HexToRGB("8a6222"),
        Runtime.HexToRGB("296392"),
        Runtime.HexToRGB("682ea2"),
        Runtime.HexToRGB("aa5623")
    },
    dragonLevelColors4 = {
        Runtime.HexToRGB("f7d59e"),
        Runtime.HexToRGB("9bedff"),
        Runtime.HexToRGB("f196ff"),
        Runtime.HexToRGB("ffdf35")
    }
}

DragonAttributeKey = {
    "ui_attributes_grass",
    "ui_attributes_tree",
    "ui_attributes_stone",
    "ui_attributes_gold"
}

--[[
    public ACTION_GAMEOBJECT onClick;
    public ACTION_GAMEOBJECT onDown;
    public ACTION_GAMEOBJECT onUp;
    public ACTION_GAMEOBJECT onEnter;
    public ACTION_GAMEOBJECT onExit;
    public ACTION_POINTER_EVENTDATA onBeginDrag;
    public ACTION_POINTER_EVENTDATA onDrag;
    public ACTION_POINTER_EVENTDATA onEndDrag;
]]
---@class UIEventName
UIEventName = {
    onClick = "onClick",
    onDown = "onDown",
    onUp = "onUp",
    onEnter = "onEnter",
    onExit = "onExit",
    onBeginDrag = "onBeginDrag",
    onDrag = "onDrag",
    onEndDrag = "onEndDrag"
}

CameraBaseSize = 3

---@class RepairState 修复状态
RepairState = {
    ---锁定中, 未开启修复
    Lock = 0,
    ---修复中, 道具不足
    Repairing = 1,
    ---可修复
    CanRepair = 2,
    ---修复完成
    Closed = 3
}

DragonEvent = {
    NestUpgrade = "DragonEvent_NestUpgrade",
    SelectDragon = "DragonEvent_SelectDragon",
    ShowFeed = "DragonEvent_ShowFeed",
    HungryDragonCount = "DragonEvent_HungryDragonCount",
    FinishProduct = "DragonEvent_FinishProduct",
    BeforeAddDragon = "DragonEvent_BeforeAddDragon",
    AddDragon = "DragonEvent_AddDragon",
    RemoveDragon = "DragonEvent_RemoveDragon",
    NestLevelUp = "DragonEvent_NestLevelUp"
}

DragonAbility = {
    ---生产能力
    Product = 1,
    ---协助能力
    Support = 2,
    ---繁育能力
    Breed = 3,
    ---施法技能
    -- Spell = 4,
    ---皇冠龙碎片
    Crown = 5
}

SystemEvent = {
    UPDATING_PROGRESS = "UPDATING_PROGRESS",
    UPDATING_FINISHED = "UPDATING_FINISHED",
}

--地图气泡类型
---@class BubbleType
BubbleType = {
    ---龙采集障碍物气泡
    Collection = 1,
    ---商人气泡
    Trader = 2,
    ---建筑可修复气泡
    Building_Repair = 3,
    ---建筑收藏气泡
    Building_Collection = 4,
    ---龙饿了
    Dragon_Hungry = 5,
    ---地图障碍物详情
    Agent_Detail = 7,
    ---船坞有奖励可以领取
    TimeOrder = 8,
    ---龙详情气泡
    DragonDetail = 9,
    ---引导用的箭头
    GuideArrow = 10,
    ---船坞有货物可以装填
    TimeOrderLoadItem = 12,
    ---龙穴新龙提示
    Had_New_Dragon = 13,
    --圣水车气泡
    WaterWheel_Energy = 14,
    ---建筑修复中气泡1 任务书
    Building_Repairing1 = 15,
    ---建筑修复中气泡2 扳手
    Building_Repairing2 = 16,
    ---广告宝箱
    Ads_Chest = 17,
    ---消耗龙之力气泡
    DragonEnergyConsume = 18,
    ---龙采去集障碍物气泡
    DragonTargetBubble = 20,
    ---龙技能气泡
    -- DragonSkill = 21,
    ---炼金炉
    GoldOrder = 22,
    ---繁育
    Breed = 23,
    ---开启预告
    PreUnlock = 24,
    ---工作空间
    WorkSpace = 25,
    ---挂机
    HangUp = 26,
    ---实验室
    Lab = 27,
    ---获得的新(New)
    NewGet = 28,
    ---挂机产物
    HangUpProduct = 29,
    ---龙探索
    Commission = 30,
    ---情人节扭蛋机
    Valentine = 31,
    ---工厂中心收集
    Factory = 32,
    ---稻草人CD
    ScarecrowCD = 33,
    ---龙工作台
    DragonWorkCenter = 34,
    ---拯救小动物
    SaveAnimal = 35,
    ---转盘障碍
    Monster = 36,
    ---拼图
    Puzzle = 37,
    ---订单板
    OrderTask = 38,
    ---龙遗迹入口
    RuinsEnterBubble = 39,
    ---装扮打造气泡
    DressingHut = 40,
    ---迷宫入口
    MazeEntry = 41,
    ---公会活动NPC泡泡
    TeamTaskNpc = 42,
    ---限时钻石宝箱的泡泡
    TimeLimitGift = 43,
    ---神龙贸易气泡
    DragonTrade = 44,
    ---抽卡
    DragonDraw = 45,
    ---回收龙
    RecycleDragon = 46,
    ---买海盗岛
    NestPurchase = 47,
    ---龙巢(调整睡觉位置的地方)
    NestSetting = 48,
    ---有新的繁育解锁
    BreedNew = 49,
    ---有新的工厂解锁
    FactoryNew = 50,
    ---挂机
    HangUpReward = 51
}

--广告类型
--广告行为类型
ADSDC_TYPE = {
    EntryShow = 1,
    WinShow = 2,
    WinClose = 3,
    EntryClick = 4,
    AdsShow = 5,
    AdsConfirm = 6,
    AdsResult = 7
}

---@class ORDER_TYPE 订单类型
ORDER_TYPE = {
    ---普通订单
    NORMAL = 0,
    ---困难订单
    DIFFICULTY = 1,
    ---新手配置订单
    GUIDE = 2,
    ---广告订单
    ADS = 3,
    ---龙订单
    DRAGON = 4,
    ---龙困难订单
    DRAGON_DIFFICULTY = 5
}

---@class ActivityType 活动类型
ActivityType = {
    GoldPass = 1, --通行证
    BreedActivity = 2, --繁育季
    Map = 3, -- 地图类的活动
    -- Christmas = 3, --圣诞节
    -- Valentine = 4, --情人节
    DragonExploit = 4, --龙PVE
    Parkour = 5, --跑酷
    DragonDraw = 6, --龙抽卡
    TeamMapActivity = 7, --公会活动任务
    DragonTrade = 8, --神龙贸易季
    ---公会龙活动营救神龙
    TeamDragonActivity = 9,
    GoldPanning = 10, ---淘金大赛活动
    Mow = 11, --割草小游戏,
    DragonFishing = 12, --钓鱼活动
}

---@class GoldPassKind 黄金通行证种类
GoldPassKind = {
    ---普通通行证
    Normal = 1,
    ---付费通行证
    Vip = 2
}
---@class GoldPassTaskType 黄金通行证任务类型
GoldPassTaskType = {
    ---每日任务
    Daily = 1,
    ---每周任务
    Weekly = 2
}

---@class GoldPassTaskStatus
GoldPassTaskStatus = {
    ---未完成
    Undone = 0,
    ---已完成
    Done = 1,
    ---已领奖
    Awarded = 2
}

---@class CommissionState
CommissionState = {
    locked = -1,
    ready = 0,
    exploring = 1,
    reward = 2,
    finish = 3
}

---@class CommonTaskStatus
CommonTaskStatus = {
    ---未完成
    Undone = 0,
    ---已完成
    Done = 1,
    ---已领奖
    Awarded = 2
}

---@class GoldPassRewardKind 通行证奖励类型
GoldPassRewardKind = {
    ---道具
    Item = 0,
    ---圣水车槽
    EnergySlot = 1,
    ---体力上线
    MaxEnergy = 2,
    ---生产基地位置
    FactorySlot = 3,
    ---皮肤(女主跟宠物龙)
    Skin = 4,
    ---每日免费体力
    FreeEnergy = 5,
    ---头像框
    AvatarFrame = 6,
    ---龙装扮,龙皮肤类型，可有多个
    DragonDress = 7,
    ---龙抽卡
    DragonDraw = 10,
}

---@class GoldPassItemRewards 可作为item的通行证奖励类型
GoldPassItemRewards = {
    GoldPassRewardKind.Item,
    GoldPassRewardKind.Skin,
    GoldPassRewardKind.AvatarFrame,
    GoldPassRewardKind.DragonDress
}

---@class ItemUseMethod 物品消耗途径 新途径请补充
ItemUseMethod = {
    ---清除障碍
    clearObstacle = "clearObstacle",
    ---拯救龙
    saveDragon = "saveDragon",
    ---龙穴内购买龙
    nestBuyDragon = "nestBuyDragon",
    ---升级龙
    upgradeDragon = "upgradeDragon",
    ---繁育龙
    breedingDragon = "breedingDragon",
    ---购买场景中炸弹
    sceneBomb = "sceneBomb",
    ---完成订单
    order = "order",
    ---完成航海订单
    timeOrder = "timeOrder",
    ---体力快捷补充（补充当前所选障碍）
    quickSupplementEnergy = "quickSupplementEnergy",
    ---补满体力
    fillUpEnergy = "fillUpEnergy",
    ---购买100体力
    supplement100Energy = "supplement100Energy",
    ---钻石商城(购买体力、炸弹)
    diamondShop = "diamondShop",
    ---解锁农田
    unlockfarmland = "unlockfarmland",
    ---解锁龙乐园(是清除障碍)
    unlockDragonRest = "unlockDragonRest",
    ---加速生产基地生产
    speedUpFactoryProduct = "speedUpFactoryProduct",
    ---加速龙生产
    speedUpDragonProduct = "speedUpDragonProduct",
    ---商人兑换（普通、限时、完成）
    businessmanExchange = "businessmanExchange",
    ---清除航海订单CD
    clearCDTimeOrder = "clearCDTimeOrder",
    ---清除订单CD
    clearCDOrder = "clearCDOrder",
    ---修复任务建筑
    repairTaskBuilding = "repairTaskBuilding",
    ---收藏品兑换
    collectionExchange = "collectionExchange",
    ---水车
    waterWheel = "waterWheel",
    ---开启龙宝箱(是清除障碍)
    openDragonBox = "openDragonBox",
    ---种植农作物
    plantingCrops = "plantingCrops",
    ---快捷补充订单物品
    supplementOrder = "supplementOrder",
    ---快捷补充航海订单物品
    supplementTimeOrder = "supplementTimeOrder",
    ---快捷补充生产材料物品
    supplementProduct = "supplementProduct",
    ---龙喂食
    feedingDragon = "feedingDragon",
    ---工厂生产
    factoryProduct = "factoryProduct",
    ---工厂开槽
    factoryOpenSlot = "factoryOpenSlot",
    ---场景中炸弹清除障碍
    fireBombs = "fireBombs",
    ---背包中炸弹清除障碍
    throwBombs = "throwBombs",
    ---加速作物生产
    speedUpCrop = "speedUpCrop",
    ---登录自动转换龙道具
    login = "login",
    ---使用补齐钻石补齐道具
    diamondBuy = "diamondBuy",
    ---交换物品
    exchangeItem = "exchangeItem",
    ---BI修改玩家道具
    alterItem = "alterItem",
    ---龙补充体力
    creature_buyphysicalstrength = "creature_buyphysicalstrength",
    ---已删除
    factory = "factory",
    ---快捷补充任务物品
    supplementTask = "supplementTask",
    ---家园委托加速
    AccelerateCommission = "AccelerateCommission",
    ---家园委托
    StartCommission = "StartCommission",
    ---清除炼金炉CD
    clearCDGoldOrder = "clearCDGoldOrder",
    ---goldOrderCost
    goldOrderCost = "goldOrderCost",
    ---背包宝箱
    bagChest = "bagChest",
    ---礼包
    gift = "gift",
    ---彩蛋清cd
    ActiveEgg = "ActiveEgg",
    ---钻石炸弹气球
    diamondBomb = "diamondBomb",
    ---重启支线地图
    ReopenScene = "ReopenScene",
    ---抽卡
    DragonDraw = "DragonDraw",
    ---兑换图示消耗
    exchangeDesignItem = "exchangeDesignItem",
    ---转水管
    turn_pipe = "turn_pipe",
    ---重启支线三星地图
    ReopenAllStarScene = "ReopenAllStarScene",
    ---钻石加速扫荡cd
    dragon_maze_quick_pass_cd = "dragon_maze_quick_pass_cd",
}

setmetatable(
    ItemUseMethod,
    {
        __index = function(t, k)
            return k
        end
    }
)

---@class ItemGetMethod 物品获得途径  新途径请补充
ItemGetMethod = {
    ---清除障碍 subSource 场景ID，障碍模板ID
    clearObstacle = "clearObstacle",
    ---地图宝箱(是清除障碍) subSource 宝箱模板ID
    sceneBox = "sceneBox",
    ---任务奖励 subSource 任务ID
    missionReward = "missionReward",
    ---收藏品奖励 subSource 收藏品ID
    collectionReward = "collectionReward",
    ---订单奖励
    orderReward = "orderReward",
    ---累计完成订单奖励
    orderTotalReward = "orderTotalReward",
    ---航海订单奖励
    timeOrderReward = "timeOrderReward",
    ---签到奖励, 广告签到：subMethod:=enterid_2
    daily_reward = "daily_reward",
    ---升级奖励
    levelReward = "levelReward",
    ---合成(龙合成不计道具)
    mergeDragon = "mergeDragon",
    ---繁育
    breedingDragon = "breedingDragon",
    ---龙商城购买
    dragonShop = "dragonShop",
    ---抚摸龙奖励, 每次随机一种奖励，可用于判定抚摸次数
    caressDragon = "caressDragon",
    ---点击漂浮物
    floaterReward = "floaterReward",
    ---宠物龙奖励
    petDragonReward = "petDragonReward",
    ---商人兑换（确认普通、限时、完成）
    businessmanExchange = "businessmanExchange",
    ---龙挂机奖励
    dragonProduct = "dragonProduct",
    ---拯救龙奖励
    saveDragonReward = "saveDragonReward",
    ---水车
    waterWheel = "waterWheel",
    ---快捷补充订单物品
    supplementOrder = "supplementOrder",
    ---快捷补充航海订单物品
    supplementTimeOrder = "supplementTimeOrder",
    ---快捷补充生产材料物品
    supplementProduct = "supplementProduct",
    ---种植收获
    harvestCrops = "harvestCrops",
    ---工厂生产收取
    factoryProduct = "factoryProduct",
    ---场景中炸弹清除障碍
    fireBombs = "fireBombs",
    ---背包中炸弹清除障碍
    throwBombs = "throwBombs",
    ---回主城自动领取龙采集奖励
    dragonAutoReceiveCollectReward = "dragonAutoReceiveCollectReward",
    ---点击气泡领取龙采集奖励
    dragonReceivePlantCollectReward = "dragonReceivePlantCollectReward",
    ---地图清除障碍成就奖励, 地图成就
    obstacleAchievement = "obstacleAchievement",
    ---地图清除障碍成就全部完成奖励, 地图成就
    sceneAchievement = "sceneAchievement",
    ---修复场景建筑奖励
    repairTaskBuilding = "repairTaskBuilding",
    ---建筑掉落奖励
    buildingDropReward = "buildingDropReward",
    ---初始赠送
    addPlayer = "addPlayer",
    ---邮件
    rewardMail = "rewardMail",
    ---BI修改玩家道具
    alterItem = "alterItem",
    ---钻石商店
    diamondShop = "diamondShop",
    ---获取龙道具并立刻转换成龙, 同时生成正负1两条记录
    useItem = "useItem",
    ---使用补齐钻石补齐道具
    diamondBuy = "diamondBuy",
    ---恢复体力
    AddEnergyByTime = "AddEnergyByTime",
    ---体力快捷补充（补充当前所选障碍）
    quickSupplementEnergy = "quickSupplementEnergy",
    ---补满体力
    fillUpEnergy = "fillUpEnergy",
    ---购买100体力
    supplement100Energy = "supplement100Energy",
    ---满级后经验转化金币
    expExchangeGold = "expExchangeGold",
    ---摇一摇
    shake = "shake",
    ---版本更新
    system = "system",
    ---看广告, subMethod是enterid_1-4（类型：订单、签到、宝箱、体力）
    video_ads = "video_ads",
    ---免费看广告, subMethod是enterid_1-4（类型：订单、签到、宝箱、体力）
    video_ads_free = "video_ads_free",
    ---航海订单装货消耗道具
    timeOrder = "timeOrder",
    ---龙技能清障
    DragonSkill = "DragonSkill",
    ---快捷补充任务物品
    supplementTask = "supplementTask",
    ---付费商城
    purchase = "purchase",
    ---家园委托奖励
    commissionReward = "commissionReward",
    ---炼金炉累计奖励
    goldOrderTotalReward = "goldOrderTotalReward",
    ---炼金炉奖励
    goldOrderReward = "goldOrderReward",
    --转盘
    luckyTurntable = "luckyTurntable",
    --场景关闭道具兑换
    SceneCloseExchangeItem = "SceneCloseExchangeItem",
    --礼包
    Gift = "Gift",
    --通行证
    goldPass = "goldPass",
    ---活跃彩蛋
    OpenActiveEgg = "OpenActiveEgg",
    ---系统彩蛋
    OpenSystemEgg = "OpenSystemEgg",
    ---气球炸弹累计奖励
    diamondBombTotalReward = "diamondBombTotalReward",
    ---气球炸弹
    diamondBomb = "diamondBomb",
    ---圣诞转盘
    valentinesTurnableDraw = "valentinesTurnableDraw",
    --领取月卡每日奖励
    monthGift = "monthGift",
    --重启地图
    ReopenMap = "ReopenMap",
    --累计星星
    TotalStar = "TotalStar",
    --龙气泡
    DragonBubble = "DragonBubble",
    --龙PVE冒险
    DragonPveStartAdv = "DragonPveStartAdv",
    --龙PVE累计积分奖励
    DragonPVEScroreReward = "DragonPVEScroreReward",
    --龙PVE排行奖励
    DragonPveRankReward = "DragonPveRankReward",
    ---龙装扮出售
    DragonSkinSell = "DragonSkinSell",
    ---装扮打造消耗
    ProductDragonSkin = "ProductDragonSkin",
    --打造装扮失败获得的道具
    ProductDragonSkinFail = "ProductDragonSkinFail",
    --龙技能采集获得的道具
    CollectExtraSkinReward = "CollectExtraSkinReward",
    --成长基金
    GrowthFund = "GrowthFund",
    --跑酷补充生命
    ParkourBuyLife = "ParkourBuyLife",
    --跑酷累计积分奖励
    ParkourScroreReward = "ParkourScroreReward",
    --跑酷排行奖励
    ParkourRankReward = "ParkourRankReward",
    --跑酷关卡结算奖励
    ParkourFinishLevel = "ParkourFinishLevel",
    --通行证兑换金币奖励
    GoldPassMaxLevelBox = "GoldPassMaxLevelBox",
    ---抽卡
    DragonDraw = "DragonDraw",
    --钻石购买神龙贸易任务
    DragonSeasonBuyTask = "DragonSeasonBuyTask",
    --钻石减任务CD
    DragonSeasonSkipTaskCd = "DragonSeasonSkipTaskCd",
    --神龙贸易任务获得积分
    DragonSeasonFinishTask = "DragonSeasonFinishTask",
    --神龙贸易交付龙物资
    DragonFinishTask = "DragonFinishTask",
    --神龙贸易个人积分奖励
    DragonSeasonScroreReward = "DragonSeasonScroreReward",
    --神龙贸易公会积分奖励
    DragonSeasonTeamScroreReward = "DragonSeasonTeamScroreReward",
    --神龙贸易世界排名奖励
    DragonSeasonRankReward = "DragonSeasonRankReward",
    --跑酷累计积分奖励
    MowScroreReward = "MowScroreReward",
    --割草关卡结算奖励
    MowFinishLevel = "MowFinishLevel",
    --割草补充生命
    MowBuyLife = "MowBuyLife",
    --装扮订单加速请求
    dragonSkinOrderAccelerate = "dragonSkinOrderAccelerate",
    --打造装扮累计奖励
    DragonSkinOrderCumulativeReward = "DragonSkinOrderCumulativeReward",
    --打造装扮额外奖励
    DragonSkinOrderExtraReward = "DragonSkinOrderExtraReward",
    ---钻石加速龙钓鱼CD
    FishingStart = "FishingStart",
    ---解锁鱼图鉴奖励
    FishUnlock = "FishUnlock",
    ---随机宝箱奖励
    FishingRandBox = "FishingRandBox",
    ---钓鱼活动内产出
    FishingFishItemReward = "FishingFishItemReward",
    ---钓鱼积分奖励
    FishingScoreReward = "FishingScroreReward",
    ---钓鱼分组排名奖励
    FishingMatchRankReward = "FishingMatchRankReward",
    ---钓鱼世界排名奖励
    FishingWorldRankReward = "FishingWorldRankReward",
    ---装扮订单快捷补充
    supplementSkinProduce = "supplementSkinProduce",
    ---龙迷宫快速探索
    dragon_maze_quick_pass = "dragon_maze_quick_pass",
    SceneCompleteReward = "SceneCompleteReward",
    ---绑定FB奖励
    fb_bind_reward = "fb_bind_reward",
    ---兑换码
    GiftCode = "GiftCode",
}

setmetatable(
    ItemGetMethod,
    {
        __index = function(t, k)
            return k
        end
    }
)

---@class GetWayType 道具获取途径枚举
GetWayType = {
    none = -1,
    ---文本描述
    Text = 0,
    ---钻石商店
    diamondShop = 1,
    ---加工厂
    factory = 2,
    ---龙探索产出
    dragon = 3,
    ---探索
    clean = 4,
    ---金币商成
    coinShop = 5,
    ---打开礼包
    open = 6,
    ---实验室
    lab = 7,
    ---家园委托
    commission = 8,
    ---种植
    farmland = 9,
    ---使用(龙基因)
    useGene = 10,
    ---跳转地图
    map = 11,
    ---跳转迷宫入口
    maze = 12,
    ---去试穿(心机呀和尼诺)
    dress = 13,
    ---去试穿(龙)
    dragonDress = 14,
    ---装扮小屋
    dressHouse = 15,
    --马拉松临时掉落道具
    marathon = 17
}

---@class CleanMethods 障碍物清除途径
CleanMethods = {
    player = 1, --人物
    bomb = 2, --炸弹
    dragonSkill = 3, --龙技能
    click = 4, --直接点击
    diamond = 5, --消费钻石
    dragonKey = 6, --龙钥匙
    ads = 7, --看广告
    coin = 8 --金币
}

---皮肤挂点名字
PointName = {
    [4] = "Hat", --帽子
    [5] = "Tall" --尾巴
}

---@class ItemMsg
---@field itemTemplateId string 道具模板id
---@field count number 道具数量
---@field cdTimes number[] 道具生效剩余时间

---@class OrderTaskProgress 订单累计奖励
---@field playerLevel int 进度生成时玩家等级
---@field finishCnt int 订单任务完成次数
---@field rewardIndex int 订单奖励领取索引
---@field finishCntBeforeDifficulty int 生成困难订单前完成订单个数
---@field orderTaskCreateCnt int 生成订单数
---@field todayDragonOrderTaskCnt int 今日龙订单数
---@field refreshTime int 刷新时间
---@field rewardCdTime int 订单进度奖励cd开始时间
---@field todayNormalOrderCnt int 今日普通订单完成数量(非龙, 非广告)

---@class OrderTask 订单
---@field position int 位置
---@field orderType int 订单难度
---@field orderLevel int 订单等级
---@field cdStartTime int cd开始时间
---@field valueTime int 订单价值时间
---@field taskItems OrderTaskItem 任务需求物品列表
---@field orderId int 订单Id
---@field orderIcon int 订单ICON
---@field rewardItems ItemMsg 奖励

---@class OrderTaskItem 订单道具
---@field itemTemplateId string
---@field count int

---@class CommonTask
---@field int32 state 未完成0 已完成1 已经提交领奖2
---@field ProtoTypes  params 任务所需参数
---@field string  taskId 任务配置

---@class 跳转道具障碍物查找的方式
LookUpWay = {
    NearPlayer = 0,
    OrderById = 1
}

---@class 修复建筑类型
BuildingRepairKind = {
    ---普通消耗道具修复
    Normal = 0,
    ---使用体力修复
    Energy = 1,
    ---监听其他障碍物的清理完成
    AgentClean = 2
}

--商城
ShopType = {
    DiamondShop = 1,
    --Holiday = 3,
    DiamondShop_GiftPack = 4,
    DiamondShop_MonCard = 7,
    DiamondShop_MonCardExtension = 9
    --PiggyBank = 5,
    --Sakura = 6,
    --LuckyRune = 10,
    --DiamondShop_GiftPack_Subscribe = 14,
    --SubscribeAddStep = 15,
}

DiamondShopGoodsType = {
    Gold = 1,
    Power = 2,
    Gift = 3,
    Bomb = 4
}

BuyItemPanelSourceType = {
    default = 0,
    --工厂
    factory = 1,
    --订单
    order = 2,
    --航海订单
    sailOrder = 3,
    --任务
    task = 4,
    --炼金炉
    goldOrder = 5
}

CurrencyType = {
    Money = 0,
    Diamond = 1
}
BuildingRepairKindName = table.reverse(BuildingRepairKind)

BuildingTemplateIdEnum = {
    Factory = "300001",
    Breed = "300028",
    -- MagicalCreaturesInfo = "300066",
    MagicalCreaturesNest = "300014"
}

---@class SceneStarMsg 场景三星信息
---@field star int32		当前星星
---@field limittime int64	限时奖励到期时间unix
---@field limitreward int32 	限时奖励领取状态 0:未领取 1:可领取 2:已领取
---@field completeReward int32 达成奖励领取状态 0:未领取 1:可领取 2:已领取
---@field stars StarMsg		星星任务信息

---@class StarMsg 星星任务
---@field starId int32 星星ID 1、2、3
---@field reward int32 励领取状态 0:未领取 1:可领取 2:已领取
---@field tasks CommonTask 任务信息

SceneStarRewardRequestType = {
    ---1.星星奖励
    Star = 1,
    ---2.达成奖励
    Reward = 2,
    ---3.限时奖励
    LimitReward = 3
}

SCENE_STAR_NUM = 3

---@class ScarecrowMsg 稻草人活动
---@field actId string 对应的活动id
---@field cfgUids string[] 已经解救的稻草人集合 配置表中唯一ID (不是障碍id 需要注意)
---@field endMillTime int64 活动结束时间
---@field awardIndex int32 已经领取奖励的index(index 从0开始 -1 表示没有领取过奖励)

GIFT_OPEN_TIME = {
    OnLevelUp = 1,
    OnChangeNewScene = 2,
    OnSelfCDEnd = 3,
    OnLogin = 4,
    OnGroupCDEnd = 5,
    OnUseItem = 6,
    OnGiftClose = 7
}

MonCardState = {
    --未解锁
    Lock = 1,
    --未购买
    NotPurchased = 2,
    --已购买但未领取
    NotRecieved = 3,
    --已领取
    Recieved = 4,
    --过期
    Expire = 5
}

---功能为解锁
---未购买礼包
---有可以领取的道具
---当前无领取道具，等待解锁新道具
---全部领取完，结束功能
GrowthState = {
    lock = 1,
    noBuy = 2,
    hasBuy = 3,
    finish = 4
}

---@class AnimalTask
---@field id string AnimalTaskTemplate中配置的id
---@field endTime int64 任务结束时间(0：结束时间无效 其他值:结束时间戳)
---@field needItems ItemMsg[] 任务需求物资
---@field awardItems ItemMsg[] 任务奖励物资
---@field state int32  任务状态  0:未提交 1:已提交
---@field difficulty int32 任务难度 1：easy 2：medium  3：hard

---@class Animal
---@field id string AnimalObstacleTemplate表中配置的id
---@field task AnimalTask 动物任务信息

---@class AnimalActivity
---@field id string 对应的活动id（AnimalRewardTemplate表中配置的id）
---@field animalId string[] 开启活动的动物id（ AnimalObstacleTemplate表中配置的id）
---@field animals Animal[] 活动中已经出现的动物数据集合
---@field endTime int64 活动结束时间
---@field awardIndexes int32[] 已经领取奖励的index集合(index 从0开始)
---@field endHandle int32 结束处理  （0 未处理 1 已处理）

---@class TaskListRefreshKind 任务列表刷新消息
TaskListRefreshKind = {
    ---任务开始
    Start = 0,
    ---子任务完成
    SubFinish = 1,
    ---任务完成
    Finish = 2,
    ----任务提交删除, 更新列表
    Submit = 3
}
---@class TaskListRefreshKindName 任务列表刷新消息名字
TaskListRefreshKindName = table.reverse(TaskListRefreshKind)

---@class TaskListKind 任务列表分类
TaskListKind = {
    ---主线
    Main = 1,
    ---支线
    Branch = 2,
    ---活动
    Activity = 3
}

---@class RankType
RankType = {
    ---龙PVE活动比赛榜
    DragonExploit_Match = 1,
    --- 龙PVE活动总榜
    DragonExploit_Global = 2,
    ---活动地图分组排行
    RankActivity = 3,
    ---龙跑酷比赛排行榜
    Parkour_Match = 4,
    ---龙跑酷世界排行榜
    Parkour_Global = 5,
    ---公会活动地图活动世界排行
    TeamMapAcitivty_Global = 6,
    ---公会活动地图活动内部排行
    TeamMapActivity_InTeam = 7,
    ---活动地图全球榜
    RankActivity_Global = 8,
    ---马拉松周排行
    DragonTrade_Week = 9,
    ---马拉松世界排行
    DragonTrade_Global = 10,
    ---公会龙活动世界排行
    TeamDragonActivity_Global = 11,
    ---公会龙活动个人排行
    TeamDragonActivity_InTeam = 12,
    ---满级活动世界排行
    GoldPanning = 13,
    ---割草比赛排行榜
    Mow_Match = 14,
    ---割草世界排行榜
    Mow_Global = 15,
    ---钓鱼比赛排行
    Fishing_Match = 16,
    ---钓鱼比赛世界排行
    Fishing_Global = 17,
    ---满级活动分组排行
    GoldPanning_Group = 18,
}

WorldRankType = {
    [RankType.DragonTrade_Global] = true,
    [RankType.DragonExploit_Global] = true,
    [RankType.TeamMapAcitivty_Global] = true,
    [RankType.RankActivity_Global] = true,
    [RankType.GoldPanning] = true,
    [RankType.Fishing_Global] = true
}
RankId2Type = table.reverse(RankType)
---@class RankTypeName
RankTypeName = {
    ---龙PVE活动比赛榜
    [RankType.DragonExploit_Match] = "ui_dragonPve_main_match",
    --- 龙PVE活动总榜
    [RankType.DragonExploit_Global] = "ui_dragonPve_main_rank"
}

---@class RankMsg 排行信息
---@field playerId string 玩家ID
---@field name string 名字
---@field avatar string 头像
---@field frame string 头像框
---@field level int32 等级
---@field score int32分数
---@field index int32 排名
---@field lastIndex int32 奖励状态 0:不可领取 1:已领取 2:可领取
---@field rewardstate int32 上次排名

---@class RankListMsg 排行榜信息
---@field type int32   类型 1:龙PVE活动比赛榜 2:龙PVE活动总
---@field ranklist RankMsg   排行信息
---@field myrank RankMsg   我的排名

---@class RankChangeType 排名变化状态
RankChangeType = {
    ---在内部变化排行
    IndexChange = 1,
    ---离开排行榜
    IndexOut = 2,
    ---进入排行榜
    IndexIn = 3
}

RankChangeTypeName = table.reverse(RankChangeType)
--场景类型枚举
---@class SceneType
SceneType = {
    Main = 0, --主场景
    Minor = 1, --支线场景
    Activity = 2, --活动地图
    Remains = 4, -- 遗迹
    MinorTaskScene = 5, --支线副本任务场景
    Maze = 6, --迷宫
    Exploit = 7, --冒险场景
    Parkour = 8, --跑酷场景
    TeamMap = 9, --公会场景
    LevelMapActivity = 10, ---等级地图活动场景
    GoldPanning = 11, ---淘金大赛活动
    TeamDragon = 12, ---公会龙活动
    Mow = 13,    --割草场景
    Fishing = 14,--钓鱼场景
    Cleaner = 15, --cleaner 场景
}

DragonStatusEnum = {
    commision = 1,
    explore = 2,
    inbag = 3,
    maze = 4
}

MoneyShopPage = {
    Extra = 1,
    Diamond = 2,
    Coin = 3
}

ParkourGameState = {
    None = 0,
    Ready = 1,
    Playing = 2,
    Pause = 3,
    Resume = 4,
    GameFailed = 5,
    GameSuccess = 6
}

SkinType = {
    Pet = 1,
    FemalePlayer = 2,
    Building = 3,
    DragonHead = 4,
    DragonTail = 5
}

---@class AdvPlayerMsg 冒险玩家信息
---@field pid string
---@field avatar string
---@field frame string
---@field nickname string
---@field skinNino string
---@field skinHeroine string
---@field endTime int64 玩家结束探索时间戳

---@class ActivityTeamMapInfo 公会地图活动信息
---@field sceneId string 场景ID
---@field advcount int 已冒险次数
---@field AdvPlayerMsg AdvPlayerMsg 冒险玩家信息
---@field finishProcess int 已完成探索进度信息(0表示还没有完成过任务节点)
---@field task NpcTask 当前正在进行的任务(可能没有,客户端会是lua协议代码的默认值)
---@field lastScoreReward string 上次领取的阶段奖励
---@field layer string 层
---@field score int 积分

---@class NpcTask 公会地图活动NPC任务
---@field id string 任务id 参见ActivityTribeTaskTemplate中的id

AvatarType = {
    Image = "Image",
    Spine = "Spine",
    Animator = "Animator",
    Other = "Other"
}

---@class LimitTimeMsg
---@field plantId string 地图障碍物生成的唯一id
---@field endTime int 限时障碍的结束时间(服务器是毫秒, 客户端转换成了秒)
---
---
GiftFrameType = {
    Skin = 1,
    Gift21 = "Gift21",
    Gift22 = "Gift22",
    Gift23 = "Gift23",
    Gift31 = "Gift31",
    Gift33 = "Gift33",
    Gift180 = "Gift180",
    Gift410 = "Gift410",
    Gift420 = "Gift420",
    Gift430 = "Gift430",
    Gift440 = "Gift440",
    Gift450 = "Gift450",
    Gift451 = "Gift451",
    Gift452 = "Gift452",
    Gift460 = "Gift460",
    Gift1000 = "Gift1000",
    Gift1001 = "Gift1001"
}

---@class LevelMapActivity 等级地图活动
---@field id string 参见SceneLevelTemplate中配置的id
---@field startTime int; 开启时间
---@field tasks CommonTask[] 所有存储信息的任务信息
---@field score int 已获取积分
---@field awardIndex int 已经奖励的index(有效值从0开始 如果为-1 说明没有奖励过)

---@class ActivityKind
ActivityKind = {
    Activity = 1,
    LevelMapActivity = 2,
    GoldPanning = 3
}

---@class RankRewardMsg
---@field rankType RankType
---@field index int 排名
---@field rewards ItemMsg[] 奖励

---@class RecycleCount 回收龙计数
---@field dragonType int 龙类型
---@field count int 回收次数 (按一级龙计算）

---@class CumulativeReward 回收龙累积奖励
---@field rewardId int 奖励id 从0开始
---@field rewards ItemMsg[] 奖励

---@class RecycleDragonInfo 回收龙信息
---@field startTime int 回收开始时间
---@field dragonTypes int[] 回收龙类型
---@field cumulativeRewardId int 累计贡献奖励索引
---@field cumulativeScore int 累计贡献积分
---@field recycleCounts RecycleCount 回收龙计数
---@field cumulativeRewards CumulativeReward 累计奖励
---@field unclaimedTransferRewards ItemMsg[]
---@field unclaimedScore int

---@class RecycleDragonBubbleState 回收龙气泡状态
RecycleDragonBubbleState = {
    ---不显示
    None = 0,
    ---有奖励可以领取
    HaveReward = 1,
    ---有龙可以回收
    HaveDragon = 2
}

---@class BuffType buff类型
BuffType = {
    Obstacle = 1,
    DragonExploit = 2,
    DragonExploitCri = 3,
    Parkour = 4,
    DragonCollect = 5,
}

---@class BuffMsg buff信息
---@field buffId int buff实例id
---@field buffTemplateId string buff模板id
---@field duration int buff剩余时间(毫秒)

---@class BuffData buff信息客户端用
---@field buffId int buff实例id
---@field buffTemplateId string buff模板id
---@field duration int buff剩余时间(毫秒)
---@field buffOffPercent float 效果参数/折扣(默认1)

---@class TeamMapScorePassRewardType
TeamMapScorePassRewardType = {
    ---通行证奖励
    Pass = 0,
    ---普通奖励+通行证奖励
    All = 1
}

---通行证悬赏任务对应活动type
GoldPassTaskType2ActivityType = {
    [2] = ActivityType.Map,
    [3] = ActivityType.TeamMapActivity,
    [4] = ActivityType.TeamDragonActivity,
}