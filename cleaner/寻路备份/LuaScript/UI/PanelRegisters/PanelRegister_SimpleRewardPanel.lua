GlobalPanelEnum.SimpleRewardPanel = {
    panelName = "SimpleRewardPanel",
    classPath = "UI.Common.SimpleRewardPanel.View.UI.SimpleRewardPanel",
    panelPrefabName = "Prefab/UI/Common/SimpleRewardPanel.prefab",
    mediatorPath = "UI.Common.SimpleRewardPanel.View.SimpleRewardPanelMediator",
    prefabNames = {
        "Prefab/UI/Common/SimpleRewardPanel.prefab"
    },
    autoUnload = true,
    loadingFlag = {
        loadingProcessType = "tip"
    },
    showFlag = {
        showType = "stack",
        header = {}, -- currency = {},home = true,back = false,notice = true,chat = true
        background = "",
        music = "",
        opacity = 0,
        -- showMask = false
    },
    navigation_key_disable = true  -- 禁止通过导航键关闭窗口
}
