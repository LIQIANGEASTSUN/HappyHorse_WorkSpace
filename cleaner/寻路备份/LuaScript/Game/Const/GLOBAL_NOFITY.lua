----通告消息
----约定  模块名字_消息名字 (消息名字 = 面板名字_元素上一级容器_元素名字 )
----参考 STAR_NOTICE_NOTICE_MAIN_PANEL_MEMBER_INFO_COMP_CLICK_BTN_EXPAND
--     *模块名字:STAR_NOTICE
--     *面板名字:NOTICE_MAIN_PANEL
--     *comp名字:MEMBER_INFO_COMP
--     *元素名字:CLICK_BTN_EXPAND
--     TODO 未来都会自动生成 (考虑可以去掉模块名字)
----放在一起的好处：可以检查是否消息重复

return {
    --<全局事件>
    --UPDATE = "Lua_Update",
    LATEUPDATE = "Lua_LateUpdate",
    FIXEDUPDATE = "Lua_FixedUpdate",

    Open_Panel = "Open_Panel",

    SCREEN_PLAY_EVENTS = "SCREEN_PLAY_EVENTS",

    SYS_SHORTCUT = "SYS_SHORTCUT",
    USER_UID_CHANGED = "USER_UID_CHANGED",
    CLICKED_BUILDING = "CLICKED_BUILDING",

    --BUILDING_CREATE_BUILDING = '',

    BUILDING_PRESS_PROGRESS = 'BUILDING_PRESS_PROGRESS',
    BUILDING_PRESS_PROGRESS_END = 'BUILDING_PRESS_PROGRESS_END',

    BUILDING_ADD_BUILDING = 'BUILDING_ADD_BUILDING',
    BUILDING_ADDED = 'BUILDING_ADDED',

    BUILDING_UNLOCK = 'BUILDING_UNLOCK',

    BUILDING_DELETED = 'BUILDING_DELETED',

    BUILDING_BUILDING_INFO_SHOW = 'BUILDING_BUILDING_INFO_SHOW',
    BUILDING_BUILDING_INFO_HIDE = 'BUILDING_BUILDING_INFO_HIDE',
    BUILDING_MANUAL_COLLECT_BUILDING_IDLE = "BUILDING_MANUAL_COLLECT_BUILDING_IDLE",

    BUILDING_COMPOSED = 'building_composed',
    BUILDING_COMPOSE_SHOW = 'BUILDING_COMPOSE_SHOW',
    BUILDING_COMPOSE_HIDE = 'BUILDING_COMPOSE_HIDE',

    MODEL_LOADED = 'MODEL_LOADED',

    SHOW_INDICATORS = {
        NONE = "NONE",
        IDLE = "BUILDING_IDLE",
        MERGE_REWARD = "BUILDING_MERGE_REWARD",
        COMPOSABLE = "BUILDING_COMPOSE_INDICATOR"
    },

    --Buff
    --BUFF_OPEN = "GlobalNotificationEnum_BUFF_OPEN",
    --BUFF_CLOSE = "GlobalNotificationEnum_BUFF_CLOSE",
    --BUFF_BUILDING_BUTTON_DESTROY = "GlobalNotificationEnum_BUFF_BUILDING_BUTTON_DESTROY",

    Lock_Screen = "GlobalNotificationEnum_LOCK_SCREEN",
    Lock_Camera = "GlobalNotificationEnum_LOCK_CAMERA",
    CAMERA_ZOOM = "GlobalNotificationEnum_CAMERA_ZOOM",

    ShowRankFriend = "GlobalNotificationEnum_ShowRankFriend",
    AccessRankFriend = "GlobalNotificationEnum_AccessRankFriend",
    ApplyRankFriend = "GlobalNotificationEnum_ApplyRankFriend",

    PreLoadAds = "GlobalNotificationEnum_PreLoadAds",

    EnableAutoCompose = "GlobalNotificationEnum_EnableAutoCompose",
    DisableAutoCompose = "GlobalNotificationEnum_DisableAutoCompose",
    ---订单被刷新消息
    Order_On_Order_Refresh = "Order_On_Order_Refresh",
    Order_On_Order_Submit = "Order_On_Order_Submit",
    TimeOrder_On_Order_Refresh = "TimeOrder_On_Order_Refresh",
    Order_On_Order_SubmitFinish = "Order_On_Order_SubmitFinish",
    Order_On_Order_RefreshProgressRewardCd = "Order_On_Order_RefreshProgressRewardCd",
    ---飞修复奖励
    BuildRepair_LevelUp_Done = "BuildRepair_LevelUp_Done",
    IngameLogin_Result = "IngameLogin_Result",

    --登陆模块，全局使用
    Login_Start = "Login_Start",
    Login_Fail  = "Login_Fail",
    Login_Suc = "Login_Suc",

    Product_Refresh = "Product_Refresh",
    Reopen_Map = "Reopen_Map",
    Refresh_Factory_Free_Count = "Refresh_Factory_Free_Count",
    Dragon_Exploit_Dragon_Changed = "Dragon_Exploit_Dragon_Changed",
    Team_Activity_OnAdvPlayerUpdate = "Team_Activity_OnAdvPlayerUpdate",

    ---回收龙自动刷新了订单
    Recycle_Dragon_AutoRefresh = "Recycle_Dragon_AutoRefresh",

    Click_PanelMask = "Click_PanelMask"
}