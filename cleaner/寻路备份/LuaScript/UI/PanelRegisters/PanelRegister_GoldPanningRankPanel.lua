GlobalPanelEnum.GoldPanningRankPanel = {
    panelName = "GoldPanningRankPanel",
    classPath = "UI.Activities.GoldPanning.GoldPanningRankPanel.View.UI.GoldPanningRankPanel",
    panelPrefabName = "Prefab/Activities/GoldPanning/MainPanel/GoldPanningRankPanel.prefab",
    mediatorPath = "UI.Activities.GoldPanning.GoldPanningRankPanel.View.GoldPanningRankPanelMediator",
    prefabNames =
    {
        "Prefab/Activities/GoldPanning/MainPanel/GoldPanningRankPanel.prefab",
        "Prefab/Activities/GoldPanning/MainPanel/worldRankItem.prefab",
        CONST.ASSETS.G_UI_RANK_RankRewardDetailTip
    },
    autoUnload = true,
    loadingFlag =
    {
     loadingProcessType = "tip",
    },
    showFlag =
    {
     showType = "stack",
     header = {},   -- currency = {},home = true,back = false,notice = true,chat = true
     music = "",
    }
}
