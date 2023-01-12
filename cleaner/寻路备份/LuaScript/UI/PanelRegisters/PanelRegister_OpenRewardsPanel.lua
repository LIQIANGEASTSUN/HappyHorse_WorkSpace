GlobalPanelEnum.OpenRewardsPanel = {
    panelName = "OpenRewardsPanel",
    classPath = "MainCity.UI.OpenRewardsPanel.View.UI.OpenRewardsPanel",
    panelPrefabName = G_UI_REWARD_PANEL,
    mediatorPath = "MainCity.UI.OpenRewardsPanel.View.OpenRewardsPanelMediator",
    prefabNames = {
        --"Prefab/SpriteAtlas/RewardPanel.spriteatlas",
        G_UI_REWARD_PANEL
    },
    loadingFlag = {
        loadingProcessType = "tip"
    },
    showFlag = {
        showType = "stack",
        header = {}, -- currency = {},home = true,back = false,notice = true,chat = true
        background = "",
        music = "",
        withoutAudio = true
    }
}
