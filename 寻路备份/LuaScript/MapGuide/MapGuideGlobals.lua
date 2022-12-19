HoleType = {
    -- Building = 1,
    WorldUI = 2,
    UI = 3,
    Obstacle = 4, --障碍物
    WorldCoordinate = 5,
    Region = 6 --区域
}

HoleShape = {
    Circle = 1,
    Rect = 2
}

HandType = {
    DownPress = 1,
    Click = 2,
    LongPress = 3,
    Moving = 4,
    Arrow = 5
}

GuideEvent = {
    DragonsInit = 5,
    TargetButtonClicked = 6,
    PanelPoppedOut = 7,
    OnPanelClose = 8,
    CityEntered = 11,
    ---进入场景事件
    AfterPanelClosed = 12,
    EnterMainCity = 13,
    EnterGameBoard = 14,
    ClickAnywhere = 15,
    DramaEvent = 19,
    AgentClick = 21,
    ObstacleValid = 22,
    ObstacleCleared = 23,
    PanelCloseFadeFinish = 24,
    DragonClick = 25,
    HarvestCrops = 26,
    DragUI = 27,
    DragUIEnd = 28,
    SeedCrops = 29,
    AnimationFinish = 30,
    PageSwitch = 31,
    CustomEvent = 32,
    OnShake = 33,
    CameraMove = 34,
    RegionClick = 35, --区域被点击
    Interrupt = 36, --引导被打断
    DoubleClickAgent = 37, --双击障碍物
    CameraMoveWithSize = 38,
    TargetDown = 39 --目标按钮按下
}

CameraFocusType = {
    Agent = 1,
    WorldCoordinate = 2
}

TipType = {
    Default = 1,
    TopRight = 2,
    BottomLeft = 3,
    BottomRight = 4,
    None = 5
}

ClickType = {
    ClickButton = 1,
    TapScreen = 2,
    ClickAgent = 3
}

SkipType = {
    Default = 0,
    Next = 1,
    Other = 2
}

GuideIDs = {
    ---清除障碍引导
    GuideCleanObstacleFirst = "GuideCleanObstacleFirst",
    ---清除障碍引导
    GuideCleanObstacleSecond = "GuideCleanObstacleSecond",
    --发现主角龙后引导
    GuideCleanObstacleAfterFindDragon = "GuideCleanObstacleAfterFindDragon",
    ---建造龙乐园引导
    GuideBuidingDragonPark = "GuideBuidingDragonPark",
    ---发现3只神龙后,收获产出引导
    GuideHarvestDragonProduct = "GuideHarvestDragonProduct",
    ---工厂界面引导
    GuideFactory = "GuideFactory",
    ---寻找农场
    GuideFindFarm = "GuideFindFarm",
    ---种植喂养
    GuideHarvest = "GuideHarvest",
    GuideSeed = "GuideSeed",
    GuideFeed = "GuideFeed",
    ---任务引导
    GuideTask = "GuideTask",
    ---订单引导
    GuideOrder = "GuideOrder",
    ---龙穴引导
    GuideDragonMerge = "GuideDragonMerge",
    ---第二次龙穴引导
    GuideBuyLeafDragon = "GuideBuyLeafDragon",
    ---第二次龙穴后续
    GuideLeafDragonSupport1 = "GuideLeafDragonSupport1",
    ---龙协助探索引导
    GuideDragonHelpSearch = "GuideDragonHelpSearch",
    ---场景入口解锁
    GuideUnlockSceneIcon = "GuideUnlockSceneIcon",
    ---龙商店入口解锁
    GuideUnlockDragonShop = "GuideUnlockDragonShop",
    ---炸弹界面解锁
    GuideUnlockBombIcon = "GuideUnlockBombIcon",
    ---圣水车引导
    GuideHolyWaterVehicle = "GuideHolyWaterVehicle",
    ---航海订单引导
    GuideSailingOrder = "GuideSailingOrder",
    ---繁育引导
    GuideBreed = "GuideBreed",
    ---临时龙巢引导
    GuideTemporaryNest = "GuideTemporaryNest",
    ---炸弹引导
    GuideBomb = "GuideBomb",
    ---体力引导
    GuideEnergy = "GuideEnergy",
    ---地图引导
    GuideMap = "GuideMap",
    ---龙协助探索
    GuideDragonAssist = "GuideDragonAssist",
    --材料跳转
    GuideMaterialJump = "GuideMaterialJump",
    --家园委托引导
    GuideExplore = "GuideExplore",
    ---炼金炉
    GuideGoldOrder = "GuideGoldOrder",
    ---遗迹探索
    GuideRuins = "GuideRuins",
    ---通行证引导 GuideGoldPass_15_9 版本号15 9活动id
    -- GuideGoldPass_21_11 = "GuideGoldPass_21_11",
    GuideGoldPass = "GuideGoldPass",
    ---繁育活动引导
    GuideBreedActivity = "GuideBreedActivity",
    ---活跃彩蛋引导
    GuideActiveEgg = "GuideActiveEgg",
    ---发光树引导
    GuideGlowingPine = "GuideGlowingPine",
    ---引导发光宝箱的开启
    GuideOpenChestAgain = "GuideOpenChestAgain",
    GuideOpenChestAgainUI = "GuideOpenChestAgainUI",
    ---面粉订单介绍引导
    GuideFlourOrder = "GuideFlourOrder",
    ---繁育面粉龙
    GuideBreedFlourDragon = "GuideBreedFlourDragon",
    ---皇冠龙引导
    GuideCrownDragon = "GuideCrownDragon",
    ---基因合成引导
    GuideGene = "GuideGene",
    ---临时龙巢引导第二版
    GuideTemporaryNest2 = "GuideTemporaryNest2",
    ---龙装扮的引导
    GuideDragonSkin = "GuideDragonSkin",
    ---情人节活动扭蛋机引导
    GuideValentineGacha = "GuideValentineGacha",
    ---情人节活动
    GuideValentine = "GuideValentine",
    ---龙之力不足引导玩家繁育龙
    GuideBreedDragon = "GuideBreedDragon",
    ---稻草人
    GuideScarecrow = "GuideScarecrow",
    ---拯救小动物, 动物指引
    SaveAnimalObstacleGuide = "SaveAnimalObstacleGuide",
    ---拯救小动物图标引导
    GuideSaveAnimalHand = "GuideSaveAnimalHand",
    ---通用手指引导
    GuideCustomHand = "GuideCustomHand",
    ---场景三星
    GuideSceneStar = "GuideSceneStar",
    ---场景章节星星奖励
    GuideChapterStar = "GuideChapterStar",
    ---10级航海手指引导
    Guide10LvSailOrder = "Guide10LvSailOrder",
    ---10级龙委托手指引导
    Guide10LvDragonCommission = "Guide10LvDragonCommission",
    --12级炼金炉手指引导
    Guide12LvAlchemy = "Guide12LvAlchemy",
    --点击采集发光松树引导
    GuideGlowingSpineAgain = "GuideGlowingSpineAgain",
    --装扮打造引导
    GuideDressingBuy = "GuideDressingBuy",
    GuideDressingProduce = "GuideDressingProduce",
    --迷宫商店引导
    GuideMazeShop = "GuideMazeShop",
    ---迷宫入口界面引导
    GuideMazeEnterUI = "GuideMazeEnterUI",
    ---圣诞引导
    GuideChristmas = "GuideChristmas",
    ---冒险岛引导
    GuideAdventureIsland = "GuideAdventureIsland",
    ---神龙博物馆
    GuideDragonMuseum = "GuideDragonMuseum",
    ---龙PVE
    GuideDragonExploit = "GuideDragonExploit",
    ---部落引导
    GuideTeam = "GuideTeam",
    --跑酷引导
    GuideParkour = "GuideParkour",
    GuideParkourJump1 = "GuideParkourJump1",
    GuideParkourJump2 = "GuideParkourJump2",
    GuideDragonDraw = "GuideDragonDraw",
    GuideDragonDrawPanel = "GuideDragonDrawPanel",
    --部落活动
    GuideSaveDragon = "GuideSaveDragon", --营救神龙引导
    GuideSaveDragonSelect = "GuideSaveDragonSelect", --营救神龙选龙引导
    GuideTeamMapActivity = "GuideTeamMapActivity",
    GuidePlayerHatSkin = "GuidePlayerHatSkin", --戴帽子的默认皮肤引导
    --幻神舞会引导
    GuideCallGodBall = "GuideCallGodBall",
    --神龙贸易引导
    GuideDragonSeazon = "GuideDragonSeazon",
    GuideNestReplace = "GuideNestReplace", -- 巢穴置换引导
    GuidePurchaseNest = "GuidePurchaseNest", -- 付费龙岛(海盗岛引导)
    --回收龙引导
    GuideRecycleDragon = "GuideRecycleDragon",
    GuideGoldPanning = "GuideGoldPanningNew", --淘金活动(满级活动)引导
    ---通用活动引导
    GuideCommonActivity = "GuideCommonActivity",
    --割草引导
    GuideMow = "GuideMow",
    GuideMowJoystick1 = "GuideMowJoystick1",
    GuideMowJoystick2 = "GuideMowJoystick2",
    --摇一摇
    Shake = "Shake",
    ---迷宫引导23.1新玩家
    GuideMaze23New = "GuideMaze23New",
    ---迷宫引导23.1老玩家
    GuideMaze23Old = "GuideMaze23Old",
    ---迷宫内的任务完成入口
    GuideMazeTask = "GuideMazeTask",
    ---龙钓鱼引导
    GuideDragonFishing = "GuideDragonFishing",
    ---挂机奖励
    GuideHangUpReward = "GuideHangUpReward"
}
---引导配置文件
GuideConfigName = {
    GuideCleanObstacle = "GuideCleanObstacle",
    GuideBuildDragonPark = "GuideBuildDragonPark",
    GuideHarvestDragonProduct = "GuideHarvestDragonProduct",
    GuideFactory = "GuideFactory",
    GuideFindFarm = "GuideFindFarm",
    GuidePlantAndFeed = "GuidePlantAndFeed",
    GuideTask = "GuideTask",
    GuideOrder = "GuideOrder",
    GuideDragonMerge = "GuideDragonMerge",
    GuideDragonHelpSearch = "GuideDragonHelpSearch",
    GuideUnlockSceneIcon = "GuideUnlockSceneIcon",
    GuideUnlockDragonShop = "GuideUnlockDragonShop",
    GuideUnlockBombIcon = "GuideUnlockBombIcon",
    GuideHolyWaterVehicle = "GuideHolyWaterVehicle",
    GuideSailingOrder = "GuideSailingOrder",
    GuideBreed = "GuideBreed",
    GuideTemporaryNest = "GuideTemporaryNest",
    GuideBomb = "GuideBomb",
    GuideEnergy = "GuideEnergy",
    GuideMap = "GuideMap",
    GuideDragonAssist = "GuideDragonAssist",
    GuideMaterialJump = "GuideMaterialJump",
    GuideExplore = "GuideExplore",
    GuideGoldOrder = "GuideGoldOrder",
    GuideRuins = "GuideRuins",
    -- GuideGoldPass_21_11 = "GuideGoldPass_21_11",
    GuideGoldPass = "GuideGoldPass",
    GuideActiveEgg = "GuideActiveEgg",
    GuideGlowingPine = "GuideGlowingPine",
    GuideBuyLeafDragon = "GuideBuyLeafDragon",
    GuideLeafDragonSupport1 = "GuideLeafDragonSupport1",
    GuideOpenChestAgain = "GuideOpenChestAgain",
    GuideFlourOrder = "GuideFlourOrder",
    GuideBreedFlourDragon = "GuideBreedFlourDragon",
    GuideTemporaryNest2 = "GuideTemporaryNest2",
    GuideDragonSkin = "GuideDragonSkin",
    GuideValentineGacha = "GuideValentineGacha",
    GuideValentine = "GuideValentine",
    GuideCustomHand = "GuideCustomHand",
    GuideChapterStar = "GuideChapterStar",
    Guide10LvSailOrder = "Guide10LvSailOrder",
    Guide10LvDragonCommission = "Guide10LvDragonCommission",
    Guide12LvAlchemy = "Guide12LvAlchemy",
    GuideGlowingSpineAgain = "GuideGlowingSpineAgain",
    GuideDressingHut = "GuideDressingHut",
    GuideMazeEnterUI = "GuideMazeEnterUI",
    GuideChristmas = "GuideChristmas",
    GuideAdventureIsland = "GuideAdventureIsland",
    GuideDragonExploit = "GuideDragonExploit",
    GuideParkour = "GuideParkour",
    GuideParkourJump1 = "GuideParkourJump1",
    GuideParkourJump2 = "GuideParkourJump2",
    GuideDragonDraw = "GuideDragonDraw",
    GuideDragonDrawPanel = "GuideDragonDrawPanel",
    GuideTeamMapActivity = "GuideTeamMapActivity",
    GuidePlayerHatSkin = "GuidePlayerHatSkin", --戴帽子的默认皮肤引导
    GuideCallGodBall = "GuideCallGodBall",
    GuideDragonSeazon = "GuideDragonSeazon",
    GuideRecycleDragon = "GuideRecycleDragon",
    GuideDragonMuseum = "GuideDragonMuseum",
    GuideCommonActivity = "GuideCommonActivity",
    GuideSaveDragon = "GuideSaveDragon",
    GuideSaveDragonSelect = "GuideSaveDragonSelect",
    GuideMow = "GuideMow",
    GuideMowJoystick1 = "GuideMowJoystick1",
    GuideMowJoystick2 = "GuideMowJoystick2",
    GuideMaze23New = "GuideMaze23New",
    GuideMaze23Old = "GuideMaze23Old",
    GuideMazeTask = "GuideMazeTask",
    GuideDragonFishing = "GuideDragonFishing",
}

---Drama到引导配置的映射
DramaGuideConfigDic = {
    City_Opening001Lostplace = GuideConfigName.GuideCleanObstacle,
    City_Opening002MeetDragon = GuideConfigName.GuideCleanObstacle,
    City_Opening003Mysteriousfootprints = GuideConfigName.GuideBuildDragonPark,
    City_Opening004Buildgoldenparadise = GuideConfigName.GuideHarvestDragonProduct,
    City_Opening004Dragongift = GuideConfigName.GuideFindFarm,
    City_Opening004Findfarm = GuideConfigName.GuidePlantAndFeed,
    City_001FindOrderboard = GuideConfigName.GuideOrder,
    City_Opening005FeedDragon = GuideConfigName.GuideTask,
    zone2_energyguidance = GuideConfigName.GuideHolyWaterVehicle,
    zone3_dragonsceneunlock = GuideConfigName.GuideRuins,
    level10_nuaticaltrade = GuideConfigName.Guide10LvSailOrder,
    level10_dragoncommission = GuideConfigName.Guide10LvDragonCommission,
    level12_alchemy = GuideConfigName.Guide12LvAlchemy,
    city_guide_Dragondressup = GuideConfigName.GuideDressingHut,
    -- zone1_002Closeathand = GuideConfigName.GuideBomb,
    city_guide_sellingdragons = GuideConfigName.GuideRecycleDragon
}

---任务完成ID触发的引导
TaskGuideConfigDic = {
    Mission1_sub013PlaceShenlong = GuideConfigName.GuideDragonMerge,
    Mission3_subunlockfanyu = GuideConfigName.GuideBreed,
    Mission2_guideglowingplant = GuideConfigName.GuideGlowingPine,
    Mission2_guideglowingchest = GuideConfigName.GuideOpenChestAgain,
    Submission_dragonwork_5 = GuideConfigName.GuideTemporaryNest2
}

---重复使用的引导文件，比如活动 , id = reusedId
ReusedGuideId = {
    [GuideIDs.GuideGoldPass] = "0",
    [GuideIDs.GuideParkour] = "0",
    [GuideIDs.GuideDragonExploit] = "0",
    [GuideIDs.GuideDragonSeazon] = "0",
    [GuideIDs.GuideCommonActivity] = "0",
    [GuideIDs.GuideAdventureIsland] = "0",
    [GuideIDs.GuideMow] = "0",
    [GuideIDs.GuideGoldPanning] = "0",
    [GuideIDs.GuideDragonFishing] = "0",
    [GuideIDs.GuideCallGodBall] = "0"
}

---解锁触发的引导映射
UnlockEventGuideConfig = {}

LevelUpGuideConfig = {}

---进某个场景触发
EnterSceneGuideConfigMap = {
    ["city"] = {
        GuideConfigName.GuideCleanObstacle,
        GuideConfigName.GuideBuildDragonPark,
        GuideConfigName.GuideHarvestDragonProduct,
        GuideConfigName.GuideFindFarm,
        GuideConfigName.GuidePlantAndFeed,
        GuideConfigName.GuideTask,
        GuideConfigName.GuideOrder,
        GuideConfigName.GuideDragonMerge,
        --GuideConfigName.GuideHolyWaterVehicle,
        --GuideConfigName.GuideSailingOrder,
        GuideConfigName.GuideMap,
        GuideConfigName.GuideDragonSkin
        -- GuideConfigName.GuideDressingHut
        --GuideConfigName.GuideTemporaryNest,
        -- GuideConfigName.GuideBreed,
        --GuideConfigName.GuideDragonDraw,
    },
    ["2"] = {
        GuideConfigName.GuideDragonHelpSearch,
        GuideConfigName.GuideBomb
    },
    ["3"] = {
        GuideConfigName.GuideHolyWaterVehicle,
        GuideConfigName.GuideGlowingPine,
        GuideConfigName.GuideOpenChestAgain,
        GuideConfigName.GuideGlowingSpineAgain
    },
    ["explore"] = {
        ---进入探索场景就会触发
        GuideConfigName.GuideDragonSkin
    }
}
---获得某个类型道具或者道具区间触发的引导,键对应ItemTemplate type字段
ItemGuideConfigDic = {
    [27] = GuideConfigName.GuideDragonSkin
}
---弱引导id，值越小优先级越高
WeakGuideIdConfig = {
    GuideActiveEgg = 100,
    GuideValentine = 101,
    GuideCustomHand = 102
    --GuidePlayerHatSkin = 103,
}
