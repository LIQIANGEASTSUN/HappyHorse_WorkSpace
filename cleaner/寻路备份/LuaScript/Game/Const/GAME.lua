---@class GAME
local GAME = {
    SCENE_NAMES = table.deserialize(AppServices.Meta:GetConfigMetaValue("SCENE_NAMES")),
    FACEBOOK_BIND_AWARD_ITEM_ID = "-99999",  -- facebook奖励条目id

    FRAME_RATE = 60,
    FRAME_INTERVAL       = 1 / 60,

    SceneTeleporterPosition = Vector3(-2.45, 0, 8.23),

    -- HEADIMAGE_FACEBOOK_AVATAR_NUM = 999,
    NpcAlias = {
        ["Femaleplayer"] = "Cynthia",
        ["Maleplayer"] = "Harrison",
        ["Petdragon"] = "Nino",
        ["Mayapriest"] = "Sarah",
        ["Trader"] = "Benjamin",
        ["Doctor"] = "Allen",
        ["Mayabro"] = "Samael",
        ["Chief"] = "Saul",
        ["Snowman"] = "Snowman",
        ["Grandma"] = "Ciel",
        ["scarecrow"] = "Scarecrow",
        ["dragon_blueberry_lv3"] = "BlueberryDargon",
        ["dragon_wheat_lv4@1"] = "DragonGuard",
        ["dragon_ruby_lv2"] = "RubyDragon",
        ["dragon_diamond_lv3"] = "DiamondDragon",
        ["dragon_copperwire_lv2"] = "CopperwireDragon",
        ["DragonGod"] = "DragonGod",
        ["dragon_sapphire_lv4"] = "SapphireDragon",
        ["dragon_milk_lv3"] = "MilkDragon",
        ["Misaki"] = "Misaki",
        ["dragon_emerald_lv3"] = "EmeraldDragon",
        ["dragon_sh_lv2"] = "WoolDragon",
        ["dragon_purple_lv3"] = "PurplePotatoDragon",
        ["Femaleplayer_WitchSilhouette"] = "WitchSilhouette",
        ["PumpkinKingStatue"] = "PumpkinKingStatue",
        ["PumpkinKingStatueruined"] = "StrangeStatue",
        ["dragon_mummy_lv1"] = "BandageDragon"
    }
}
return GAME
