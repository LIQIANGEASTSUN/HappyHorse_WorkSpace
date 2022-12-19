GlobalPanelEnum.OrderTaskPanel = {
    panelName = "OrderTaskPanel",
    classPath = "UI.OrderTask.View.UI.OrderTaskPanel",
    panelPrefabName = "Prefab/UI/OrderTask/OrderTaskPanel.prefab",
    mediatorPath = "UI.OrderTask.View.OrderTaskPanelMediator",
    prefabNames =
    {
        "Prefab/UI/OrderTask/OrderTaskPanel.prefab",
        "Prefab/UI/OrderTask/OrderTaskItem.prefab",
        "Prefab/UI/Bag/ItemDetailTip.prefab",
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
     background = "",
     music = ""
    }
}
