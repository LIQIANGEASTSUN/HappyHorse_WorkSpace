---@class MAINUI 用于控制飞道具时需要显示的icon
local MAINUI = {
    LAYERS = {
        SCENE_UI = "SCENE_UI",
        SCENE_BG = "SCENE_BG",
        BASIC_UI = "BASIC_UI"
    },
    ICONS = {
        UserInfoWidget = 1, --左上角玩家经验值，设置按钮等
        PropsWidget = 2, --右上角玩家金币和材料预览
        ShopButton = 3,
        CleanerButton = 4,
        AnimalsButton = 5,
        PetInfoButton = 6,
        GMButton = 7,
        ---背包
        BagButton = 8,
        ---任务按钮
        TaskButton = 9,
        -- EnergyIcon = 1, -- 精力
        -- DiamondIcon = 2, -- 钻石
        -- CoinIcon = 3, -- 金币
        -- BuildingIcon = 6, -- 建筑
        -- BackHomeIcon = 7, -- 回家
        -- Experience = 9, -- 经验
        -- MailButton = 10, -- 邮件
        -- WorldMapBtn = 11, -- 地图
        -- DragonAssistBtn = 12, --主界面的神龙协助按钮
        -- FactoryBtn = 14, -- 工厂
        -- BreedBtn = 15, -- 培育
        -- DragonShopBtn = 16, -- 龙商店
        -- TaskBtn = 17, -- 任务
        -- AchievementButton = 18, -- 采集成就
        -- Bomb = 19, -- 炸弹包裹
        -- Head = 20, -- 头像
        -- SettingButton = 21, -- 设置按钮
        -- DayRewardButton = 22, -- 签到按钮
        -- DragonInfo = 23, -- 龙信息
        -- DragonBag = 24, -- 龙背包(已废弃)
        -- DragonBagBtn = 25, -- 龙背包按钮
        -- BuldingRepairBtns = 26, -- 建筑修复按钮
        -- GoldPassButton = 27, --黄金通行证按钮
        -- RemainsBackBtn = 28, -- 从遗迹返回按钮
        -- RemainsDragonBtn = 29, --遗迹场景龙选择按钮
        -- BreedActivityButton = 30, --繁育季活动按钮
        -- ActiveEggsButton = 31, --彩蛋活动按钮
        -- MergeButton = 32, --可合成龙提示按钮
        -- BreedButton = 33, --可繁育提示按钮
        -- HeadInfoView = 34, --顶部全部UI
        -- HRWidgetsMenu = 35, --右侧伸缩菜单
        -- EnergyDiscount = 36, -- 清除障碍打折,按时间使用，显示剩余时间
        -- Prune = 37, -- 场景裁剪
        -- Christmas = 38, --圣诞活动入口
        -- LabButton = 39, --实验室可合成提示按钮
        -- DragonFlyTarget = 40, --野外获得龙飞入的目标
        -- ActivityTaskBtn = 41, ---活动任务按钮
        -- Valentine = 42, ---情人节活动按钮
        -- UpdatingButton = 43,
        -- SceneStarButton = 44, --地图三星按钮
        -- EnergyDiscountItemIcon = 45, -- 清除折扣道具icon,按次数使用的,显示剩余个数
        -- ScarecrowButton = 46, -- 稻草人按钮
        -- SaveAnimalButton = 47, -- 拯救小动物按钮
        -- DragonExploitButton = 48, --神龙探索活动按钮
        -- MazeShopButton = 49, -- 迷宫商店
        -- MazeTimeButton = 50, -- 迷宫倒计时
        -- MazeBackBtn = 51, -- 从迷宫返回按钮
        -- TeamBtn = 52, -- 队伍按钮
        -- TeamMapInfo = 54, -- 队伍按钮
        -- ActivityCalendarButton = 53, --活动预热按钮
        -- ActivityCalendarTipButton = 55, --活动预热提示按钮(界面底部小铃铛)
        -- DressingHut = 56, --装扮小屋提示小按钮
        -- ShakeButton = 57, --摇一摇按钮
        -- 活动类的分下段，从100开始吧
        -- ParkourButton = 100, --跑酷场景小游戏
        -- AdventureIsland = 102, ---冒险岛
        -- TeamMapActivity = 103, ---公会秘境寻宝
        -- CallGodBall = 104, ---唤神舞会
        -- DragonTradeButton = 105,    --神龙贸易季
        -- LevelMapActivityButton = 106, ---等级地图任务按钮(等级活动)
        -- DragonMuseum = 107, ---神龙博物馆按钮
        -- SeaCarnival = 108, ---海底祭典
        -- GoldPanning = 109, --淘金大赛
        -- TeamDragonEntrance = 110, ---公会龙入口按钮
        -- TeamDragonButton = 111, ---公会龙活动场景中选择龙界面按钮
        -- DragonEnergyDiscount = 112, -- 龙清除障碍打折,按时间使用，显示剩余时间
        -- TeamDragonInfo = 113, --公会龙活动左侧面板
        -- MowButton = 114, --割草小游戏
        -- SakuraManor = 115, -- 樱花庄园
        -- InviteButton = 116, ---邀请按钮
        -- DesertPark = 117, ---甜蜜丰饶节
        -- GhostMansion = 118, ---幽灵宅邸
        -- Anonymous = 1001, -- 匿名区(动态)会占用1001和1002
        -- --龙pve活动相关：2000
        -- ExploitQuitButton = 2001,
        -- ExploitScoreItem = 2002,
        -- ExploitProgress = 2003,
        -- ExploitDragons = 2004,
        -- ExploitBuffs_2Drop = 2010,
        -- ExploitBuffs_2Collect = 2011,
        -- --龙跑酷活动相关：3000
        -- ParkourScoreItem = 3001,
        -- BuffDoubleParkourScore = 3002,
        -- ParkourJump = 3003,
        -- --龙钓鱼活动
        -- DragonFishingButton = 3004,

        -- --割草活动相关：4000
        -- MowScoreItem = 4001,
        -- BuffDoubleMowScore = 4002,
        -- MowHandleButton = 4003,
        -- MowTimeProcess = 4004,
    }
}
return MAINUI
