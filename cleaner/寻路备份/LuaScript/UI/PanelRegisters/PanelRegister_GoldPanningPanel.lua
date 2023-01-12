GlobalPanelEnum.GoldPanningPanel = {
    panelName = "GoldPanningPanel",
    classPath = "UI.Activities.GoldPanning.MainPanel.View.UI.GoldPanningPanel",
    panelPrefabName = "Prefab/Activities/GoldPanning/MainPanel/GoldPanningPanel.prefab",
    mediatorPath = "UI.Activities.GoldPanning.MainPanel.View.GoldPanningPanelMediator",
    prefabNames =
    {
        "Prefab/Activities/GoldPanning/MainPanel/GoldPanningPanel.prefab",
        "Prefab/Activities/GoldPanning/MainPanel/worldRankItem.prefab",
        CONST.ASSETS.G_UI_ACTIVITYTASKRANK_RANKITEM
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
