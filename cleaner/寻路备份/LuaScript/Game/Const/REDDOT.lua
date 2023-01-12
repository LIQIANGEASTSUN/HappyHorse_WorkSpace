return{
    redConfig = {
        ["DiamondItem"] = {
            ["MysticalShop"] = {
                ["MysticalShop_FirstOpen"] = {},
                ["MysticalShop_NewTag"] = {},
            },
            ["CommonShop"] = {
            },
        },
        ["BuildingCollect"] = {
            ["OverView"] = {},
            ["Skin"] = {},
            ["TopBuilding"] = {},
        },
        ["settingButton"] = {
            ["FacebookAccount"] = {},
            ["FAQ"] = {},
        },
        -- ["ExpItem"] = {},
        ["CollectionItem"] = {},
        ["Task"] = {
            ["Task_Main"] = {
                ["Task_Finish_Main"] = {},
                ["Task_New_Main"] = {},
            },
            ["Task_Activity"] = {
                ["Task_Finish_Activity"] = {},
                ["Task_New_Activity"] = {},
            },
        },
        ["GoldPass"] = {
            ["Mission"] = {},
            ["Rewards"] = {},
            ["Privilege"] = {},
        },
        --活动右侧红点 用场景名字 Start
        ["21Christmas"] = {},
        ["20220214"] = {},
        ["22AdvIsland"] = {},
        ["2204CallGodBall"] = {},
        ["2205DragonMuseum"] = {},
        ["2206SeaCarnival"] = {},
        ["2207SakuraManor"] = {},
        ["2208DesertPark"] = {},
        ["2209GhostMansion"] = {},
        ["GoldPanning"] = {},
        --活动右侧红点 用场景名字 End
        ["Scarecrow"] = {},
        ["UserInfo"] = {
            ["HeadInfo"] = {
                ["newHead"] = {},
                ["newFrame"] = {},
            },
            ["newRoleSkin"] = {},
            ["newPetSkin"] = {},
        },
        ["DragonTrade"] = {
            ["DragonTrade_Task"] = {},
            ["DragonTrade_Reward"] = {},
            ["DragonTrade_Match"] = {},
            ["DragonTrade_Rank"] = {},
        }
    },
    eventMap = {
        ["DiamondItem"] = "MainCityNotificationEnum_RefreshRedDot",
        ["MysticalShop"] = "BuyDiamondPanelNotificationEnum_RefreshNew",
        ["BuildingCollect"] = "MainCityNotificationEnum_RefreshRedDot",
        ["TopBuilding"] = "CollectionPanelNotificationEnum_RefreshRedDot",
        ["UserInfo"] = "MainCityNotificationEnum_RefreshRedDot",
        ["newRoleSkin"] = "UserInfoPanelNotificationEnum_RefreshSkinReddot",
        ["newPetSkin"] = "UserInfoPanelNotificationEnum_RefreshSkinReddot",
        ["settingButton"] = "MainCityNotificationEnum_RefreshRedDot",
        ["FAQ"] = "LoginScenePanelNotificationEnum_Refresh_FAQ_RED"
    }
}