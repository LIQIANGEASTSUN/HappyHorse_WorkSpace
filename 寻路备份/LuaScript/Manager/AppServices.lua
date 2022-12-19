local _register = {
    --PaymentManager = "System.Buy.LuaPaymentManager",
    EventDispatcher = "System.Core.EventDispatcher",
    User = "User.UserManager",
    Connecting = "System.Core.Network.ConnectingPanelLogic",
    Connecting_Pay = "System.Buy.ConnectPayPanelLogic",
    PackageDefault = "User.PackageDefault",
    Notification = "Game.System.Notification.Notification",
    FarmManager = "MainCity.Manager.FarmManager",
    GuideArrowManager = "MainCity.Manager.GuideArrowManager",
    ItemIcons = "Item.ItemIcons",
    DynamicUpdateManager = "MainCity.Manager.DynamicUpdateManager",
    -- Task = "Task.TaskManager",
    TaskIconButtonLogic = "User.TaskIconButtonLogic",
    FoodContainer = "MagicalCreatures.Manager.DragonFoodContainer",
    Clean = "MainCity.Manager.CleanManager",
    UITextTip = "MainCity.UI.UITextTip",
    SceneTextTip = "MainCity.UI.SceneTextTip",
    ClickEffectTool = "MainCity.UI.ClickEffectTool",
    CollectAllPrompt = "MagicalCreatures.Manager.CollectAllPrompt",
    FiveStarManager = "MainCity.Manager.FiveStarManager",
    BuildingRepair = "User.BuildingRepairManager",
    FactoryManager = "MainCity.Manager.FactoryManager",
    MagicalCreatures = "MagicalCreatures.Manager.MagicalCreaturesManager",
    DiamondLogic = "User.DiamondLogic",
    UserCoinLogic = "User.UserCoinLogic",
    ExpLogic = "MainCity.Logic.ExpLogic",
    -- Animation
    FlyAnimation = "Game.Common.FlyAnimation",
    RewardAnimation = "Game.Common.RewardAnimation",
    -- OrderTask = "Order.OrderTaskManager",
    -- TimeOrder = "Order.TimeOrderManager",
    AgentAppear = "MainCity.Component.AgentAppear",
    --TaskData = "Data.TaskData",
    --data
    AccountData = "Data.AccountData",
    --Energy discount activity
    EnergyDisCountBuff = "MainCity.Manager.EnergyDiscountBuffManager",
    DragonBuff = "MainCity.Manager.DragonBuffManager",
    --ads
    AdsManager = "Game.Sdk.Ads.AdsManager",
    -- RedDotManage = "User.RedDotManage",
    DayRewardManager = "User.DayRewardManager",
    MailManager = "Game.System.Mail.MailManager",
    AdsEnergyManager = "MainCity.Manager.AdsEnergyManager",
    MapGiftManager = "MainCity.Manager.MapGiftManager",
    WeeklyGiftManager = "MainCity.Manager.WeeklyGiftManager",
    FashionLimitedGiftManager = "MainCity.Manager.FashionLimitedGiftManager",
    GiftFrameManager = "MainCity.Manager.GiftFrameManager",
    PoolManage = "objectPool.PoolManage",
    ProductManager = "System.Buy.ProductManager_" .. RuntimeContext.PAY_PLATE,
    ShopGroupManager = "System.Buy.ShopGroupManager",
    GiftManager = "Game.System.Gift.GiftManager",
    CommissionManager = "MainCity.Manager.CommissionManager",
    CollectionItem = "User.CollectionItem",
    GoldOrder = "Game.System.goldOrder.GoldOrderManager",
    SkinLogic = "Manager.SkinLogic",
    GetWay = "Manager.GetWay",
    DiamondConfirmUIManager = "UI.Components.DiamondConfirmUIManager",
    LuckyTurntable = "MainCity.Logic.LuckyTurntableLogic",
    AvatarFrame = "Manager.AvatarFrameLogic",
    Avatar = "Manager.AvatarLogic",
    ActiveEggManager = "Game.System.ActiveEgg.ActiveEggManager",
    MapStarManager = "MapStar.MapStarManager",
    MonCard = "MainCity.Manager.MonCardManager",
    GrowthFundManager = "MainCity.Manager.GrowthFundManager",
    MapCursor = "Game.System.MapCursor.MapCursor",
    SceneCloseInfo = "MainCity.Manager.SceneCloseInfoManager",
    SaveAnimal = "SaveAnimal.SaveAnimalManager",
    ChapterStar = "MapStar.SceneChapterStarManager",
    AdsRepeatBrushBox = "MainCity.Manager.AdsRepeatBrushBoxManager",
    DragonDropManager = "MainCity.Manager.DragonDropManager",
    SkinEquipManager = "MainCity.Manager.SkinEquipManager",
    DragonRecoverPower = "UI.Maze.DragonRecoverPower",
    --测试
    --TimerManager = "Utils.Timer.TimerManager",
    DragonMaze = "Game.System.DragonMaze.DragonMazeManager",
    TeamManager = "Team.TeamManager",
    PiggyBank = "Game.System.PiggyBank.PiggyBankManager",
    ActivityCalendar = "MainCity.Manager.ActivityCalendarLogic",
    DragonDraw = "Game.System.DragonDraw.DragonDrawManager",
    -- BagDot = "MainCity.Manager.BagDotManager",
    DragonNestManager = "MagicalCreatures.Manager.DragonNestManager",
    RecycleDragon = "Order.RecycleDragon",
    PersonCardManager = "MainCity.Manager.PersonCardManager",
    PipeManager = "MainCity.Manager.PipeManager",
    HangUpRewardManager = "MainCity.Manager.HangUpRewardManager",
    ShutDownServerLogic = "Game.System.ShutDownServer.ShutDownServerLogic",

    ---新项目管理器
    Net = "System.Core.Network.NetManager",
    EntityManager = "Cleaner.Manager.EntityManager",
    Meta = "Manager.MetaManager",
    BuildingModifyManager = "Cleaner.Manager.BuildingModifyManager",
    DamageController = "Cleaner.Fight.DamageController",
    NetPetManager = "Cleaner.Manager.Net.NetPetManager",
    PlayerJoystickManager = "Cleaner.Manager.PlayerJoystickManager",
    NetItemManager = "Cleaner.Manager.Net.NetItemManager",
    NetPingManager = "Cleaner.Manager.Net.NetPingManager",
    ItemCostManager = "Cleaner.Manager.ItemCostManager",
    NetBuildingManager = "Cleaner.Manager.Net.NetBuildingManager",
    NetWorkManager = "Cleaner.Manager.Net.NetWorkManager",
    NetIslandManager = "Cleaner.Manager.Net.NetIslandManager",
    BuildingLevelTemplateTool = "Cleaner.Factory.BuildingLevelTemplateTool",
    BagManager = "Cleaner.Manager.BagManager",
    OrderManager = "Cleaner.Order.OrderManager",
    IslandManager = "Cleaner.Manager.IslandManager",
    NetOrderManager = "Cleaner.Manager.Net.NetOrderManager",
    IslandPathManager = "Cleaner.Manager.IslandPathManager",
    Task = "Cleaner.Task.TaskManager",
    UnitMoveManager = "Cleaner.Fight.EntityMove.UnitMoveManager",
    Jump = "Cleaner.Jump.AutoJump",
    JumpTask = "Cleaner.Jump.JumpTask",
    UnitManager = "Cleaner.Unit.Base.UnitManager",
    UnitTipsManager = "Cleaner.UnitTips.Base.UnitTipsManager",
    NetDecorationFactoryManager = "Cleaner.Manager.Net.NetDecorationFactoryManager",
    NetRecycleManager = "Cleaner.Manager.Net.NetRecycleManager",
    NetEquipManager = "Cleaner.Manager.Net.NetEquipManager",
}

local mt = {
    __index = function(t, k)
        local path = _register[k] or "Manager." .. k .. "Manager"
        local inst = include(path)
        rawset(t, k, inst)
        return inst
    end
}
---@class AppServices
AppServices = {
    ---@type LuaPaymentManager
    --PaymentManager = nil,
    ---@type EventDispatcher
    EventDispatcher = nil,
    ---@type UserManager
    User = nil,
    ---@type ConnectingPanelLogic
    Connecting = nil,
    ---@type MetaManager
    Meta = nil,
    ---@type UnlockManager
    Unlock = nil,
    ---@type FarmManager
    FarmManager = nil,
    ---@type TaskManager
    Task = nil,
    ---@type TaskIconButtonLogic
    TaskIconButtonLogic = nil,
    ---@type DragonFoodContainer
    FoodContainer = nil,
    ---@type ItemIcons
    ItemIcons = nil,
    ---@type CleanManager
    Clean = nil,
    ---@type AutoJump
    Jump = nil,
    ---@type JumpTask
    JumpTask = nil,
    ---@type UITextTip
    UITextTip = nil,
    ---@type SceneTextTip
    SceneTextTip = nil,
    ---@type ClickEffectTool
    ClickEffectTool = nil,
    ---@type CollectAllPrompt
    CollectAllPrompt = nil,
    ---@type Notification
    Notification = nil,
    ---@type PackageDefault
    PackageDefault = nil,
    ---@type FiveStarManager
    FiveStarManager = nil,
    ---@type BuildingRepairManager
    BuildingRepair = nil,
    ---@type FactoryManager
    FactoryManager = nil,
    ---@type DiamondLogic
    DiamondLogic = nil,
    ---@type UserCoinLogic
    UserCoinLogic = nil,
    ---@type ExpLogic
    ExpLogic = nil,
    ---@type FlyAnimation
    FlyAnimation = nil,
    ---@type RewardAnimation
    RewardAnimation = nil,
    -- -@type OrderTaskManager
    -- OrderTask = nil,
    -- -@type TimeOrderManager
    -- TimeOrder = nil,
    ---@type AccountData
    AccountData = nil,
    ---@type AgentAppear
    AgentAppear = nil,
    ---@type EnergyDiscountBuffManager
    EnergyDisCountBuff = nil,
    ---@type AdsManager
    AdsManager = nil,
    -- ---@type RedDotManage
    -- RedDotManage = nil,
    ---@type DayRewardManager
    DayRewardManager = nil,
    ---@type MailManager
    MailManager = nil,
    ---@type AdsEnergyManager
    AdsEnergyManager = nil,
    ---@type MapGiftManager
    MapGiftManager = nil,
    ---@type WeeklyGiftManager
    WeeklyGiftManager = nil,
    ---@type PoolManage
    PoolManage = nil,
    ---@type ProductManager
    ProductManager = nil,
    ---@type ShopGroupManager
    ShopGroupManager = nil,
    ---@type GiftManager
    GiftManager = nil,
    ---@type CommissionManager
    CommissionManager = nil,
    ---@type CollectionItem
    CollectionItem = nil,
    ---@type GoldOrderManager
    GoldOrder = nil,
    ---@type SkinLogic
    SkinLogic = nil,
    ---@type GetWay
    GetWay = nil,
    ---@type DiamondConfirmUIManager
    DiamondConfirmUIManager = nil,
    ---@type LuckyTurntableLogic
    LuckyTurntable = nil,
    ---@type AvatarFrameLogic
    AvatarFrame = nil,
    ---@type AvatarLogic
    Avatar = nil,
    ---@type ActiveEggManager
    ActiveEggManager = nil,
    ---@type MapStarManager
    MapStarManager = nil,
    ---@type MonCardManager
    MonCard = nil,
    ---@type GrowthFundManager
    GrowthFundManager = nil,
    ---@type GuideArrowManager
    GuideArrowManager = nil,
    ---@type ScarecrowManager
    Scarecrow = nil,
    ---@type MapCursor
    MapCursor = nil,
    ---@type SceneCloseInfoManager
    SceneCloseInfo = nil,
    ---@type TimerManager
    --TimerManager = nil,
    ---@type SaveAnimalManager
    SaveAnimal = nil,
    ---@type SceneChapterStarManager
    ChapterStar = nil,
    ---@type AdsRepeatBrushBoxManager
    AdsRepeatBrushBox = nil,
    ---@type DragonDropManager
    DragonDropManager = nil,
    ---@type SkinEquipManager
    SkinEquipManager = nil,
    ---@type DragonRecoverPower
    DragonRecoverPower = nil,
    ---@type DragonMazeManager
    DragonMaze = nil,
    ---@type TeamManager
    TeamManager = nil,
    ---@type PiggyBankManager
    PiggyBank = nil,
    ---@type ActivityCalendarLogic
    ActivityCalendar = nil,
    ---@type DragonDrawManager
    DragonDraw = nil,
    ---@type BagDotManager
    BagDot = nil,
    ---@type GiftFrameManager
    GiftFrameManager = nil,
    ---@type DragonNestManager
    DragonNestManager = nil,
    ---@type RecycleDragon
    RecycleDragon = nil,
    ---@type PersonCardManager
    PersonCardManager = nil,
    ---@type PipeManager
    PipeManager = nil,
    ---@type DragonBuffManager
    DragonBuff = nil,
    ---@type InviteFriendsManager
    InviteFriends = nil,
    ---@type HangUpRewardManager
    HangUpRewardManager = nil,
    ---@type BuildingModifyManager
    BuildingModifyManager = nil,
    ---@type NetIslandManager
    NetIslandManager = nil,
    ---@type NetPetManager
    NetPetManager = nil,
    ---@type PlayerJoystickManager
    PlayerJoystickManager = nil,
    ---@type EntityManager
    EntityManager = nil,
    ---@type DamageController
    DamageController = nil,
    ---@type NetItemManager
    NetItemManager = nil,
    ---@type NetPingManager
    NetPingManager = nil,
    ---@type ItemCostManager
    ItemCostManager = nil,
    ---@type NetBuildingManager
    NetBuildingManager = nil,
    ---@type NetWorkManager
    NetWorkManager = nil,
    ---@type BuildingLevelTemplateTool
    BuildingLevelTemplateTool = nil,
    ---@type BagManager
    BagManager = nil,
    ---@type OrderManager
    OrderManager = nil,
    ---@type IslandManager
    IslandManager = nil,
    ---@type NetOrderManager
    NetOrderManager = nil,
    --@type IslandPathManager
    IslandPathManager = nil,
    ---@type UnitMoveManager
    UnitMoveManager = nil,
    ---@type UnitManager
    UnitManager = nil,
    ---@type UnitTipsManager
    UnitTipsManager = nil,
    ---@type NetDecorationFactoryManager
    NetDecorationFactoryManager = nil,
    ---@type NetRecycleManager
    NetRecycleManager = nil,
    ---@type NetEquipManager
    NetEquipManager = nil,
}
setmetatable(AppServices, mt)

return AppServices
