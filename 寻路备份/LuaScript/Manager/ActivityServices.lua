local _register = {
    ActivityManager = "Game.Activities.ActivityManager",
    RankManager = "Game.Activities.RankManager",
    GoldPass = "Game.Activities.GoldPass.GoldPassManager",
    Christmas = "Game.Activities.Christmas.ChristmasManager",
    Valentine = "Game.Activities.Valentine.ValentineManager",
    DragonExploit = "Game.Activities.DragonExploit.DragonExploitManager",
    AdventureIsland = "Game.Activities.AdventureIsland.AdventureIsland",
    Parkour = "Game.Activities.Parkour.ParkourManager",
    TeamMapActivity = "Game.Activities.Team.TeamMapActivity",
    TeamDragonActivity = "Game.Activities.Team.TeamDragonActivity",
    DragonTradeWeek = "Game.Activities.DragonTrade.DragonTradeWeekManager",
    DragonTradeMonth = "Game.Activities.DragonTrade.DragonTradeMonthManager",
    CallGodBall = "Game.Activities.CallGodBall.CallGodBall",
    GoldPanning = "Game.Activities.GoldPanning.GoldPanning",
    DragonMuseum = "Game.Activities.DragonMuseum.DragonMuseum",
    SeaCarnival = "Game.Activities.SeaCarnival.SeaCarnival",
    SakuraManor = "Game.Activities.SakuraManor.SakuraManor",
    DesertPark = "Game.Activities.DesertPark.DesertPark",
    GhostMansion = "Game.Activities.GhostMansion.GhostMansion",
    LevelMapActivity = "Game.Activities.LevelMapActivityManager",
    LevelMapActivityBase = "Game.Activities.LevelMapActivityBase",
    Mow = "Game.Activities.Mow.MowManager",
    DragonFishing = "Game.Activities.DragonFishing.DragonFishingManager"
}

local mt = {
    __index = function(t, k)
        if not k then
            -- console.lzl('fffukkk')
        end
        local path = _register[k] or "Manager." .. k .. "Manager"
        local inst = include(path)
        rawset(t, k, inst)
        return inst
    end
}
---@class ActivityServices
ActivityServices = {
    ---@type ActivityManager
    ActivityManager = nil,
    ---@type GoldPass 通行证管理器
    GoldPass = nil,
    ---@type BreedActivityManager
    BreedActivity = nil,
    ---@type ChristmasManager
    Christmas = nil,
    ---@type ValentineManager
    Valentine = nil,
    ---@type DragonExploit
    DragonExploit = nil,
    ---@type RankManager
    RankManager = nil,
    ---@type ParkourManager
    Parkour = nil,
    ---@type AdventureIsland
    AdventureIsland = nil,
    ---@type TeamMapActivity
    TeamMapActivity = nil,
    ---@type TeamDragonActivity
    TeamDragonActivity = nil,
    ---@type DragonTradeWeekManager
    DragonTradeWeek = nil,
    ---@type DragonTradeMonthManager
    DragonTradeMonth = nil,
    ---@type CallGodBall
    CallGodBall = nil,
    ---@type GoldPanning
    GoldPanning = nil,
    ---@type SeaCarnival
    SeaCarnival = nil,
    ---@type SakuraManor
    SakuraManor = nil,
    ---@type DesertPark
    DesertPark = nil,
    ---@type GhostMansion
    GhostMansion = nil,
    ---@type LevelMapActivityManager
    LevelMapActivity = nil,
    ---@type LevelMapActivityBase
    LevelMapActivityBase = nil,
    ---@type MowManager
    Mow = nil,
    ---@type DragonFishingManager
    DragonFishing = nil,
}
setmetatable(ActivityServices, mt)

return ActivityServices
