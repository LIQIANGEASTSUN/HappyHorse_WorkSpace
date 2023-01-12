---@class MessageType 消息定义
MessageType = {
    Global_After_Show_Panel = "Global_After_Show_Panel",
    Global_After_Destroy_Panel = "Global_After_Destroy_Panel",
    -- 好友界面
    FlyItemControlSceneIcons = "FlyItemControlSceneIcons", -- 控制场景中主UI图标
    RefreshMainUICurrency = "RefreshMainUICurrency", -- 刷新主UI货币
    ------------任务
    ---任务完成
    Task_OnTaskFinish = "Task_OnTaskFinish",
    ---主任务提交
    Task_OnTaskSubmit = "Task_OnTaskSubmit",
    ---主任务提交完成
    Task_After_TaskSubmit = "Task_After_TaskSubmit",
    ---子任务完成
    Task_OnSubTaskFinish = "Task_OnSubTaskFinish",
    ---子任务进度增加
    Task_OnSubTaskAddProgress = "Task_OnSubTaskAddProgress",
    ---任务进度增加
    Task_OnTaskAddProgress = "Task_OnTaskAddProgress",
    ---开始一个任务
    Task_OnTaskStart = "Task_OnTaskStart",
    ---点击移动角色之后
    After_Move_Character = "After_Move_Character",
    GM_Task_OnSubTaskFinish = "GM_Task_OnSubTaskFinish",
    ---场景Awake 再跳转场景之前
    Global_After_Scene_Awake = "Global_After_Scene_Awake",
    ---跳转场景
    Global_After_ChangeScene = "Global_After_ChangeScene",
    ---清理障碍物(完全清除时)
    Global_After_Plant_Cleared = "Global_After_Plant_Cleared",
    ---清理障碍物（清除障碍物表现结束）
    Global_After_Show_Clean_End = "Global_After_Show_Clean_End",
    ---订单完成
    Global_Afater_Order_Finish = "Global_Afater_Order_Finish",
    ---订单完成动画飞结束
    Global_Afater_Order_Finish_AnimaDone = "Global_Afater_Order_Finish_AnimaDone",
    ---获得新道具
    Global_After_AddItem = "Global_After_AddItem",
    ---使用了道具
    Global_After_UseItem = "Global_After_UseItem",
    ---建筑修复完成
    Global_After_RepaireBuilding = "Global_After_RepaireBuilding",
    ---开始生产道具
    Global_After_ProduceItem = "Global_After_ProduceItem",
    ---清理击杀NPC结束
    Global_After_Monster_Defeated = "Global_After_Monster_Defeated",
    ---障碍物显示出来事件, 任务用
    Global_After_Agent_Clearing = "Global_After_Agent_Clearing",
    ---玩家升级事件
    Global_After_Player_Levelup = "Global_After_Player_Levelup",
    --升级面板关闭
    Gloabl_LevelupPanel_Close = "Gloabl_LevelupPanel_Close",
    ---解锁某个系统事件
    Global_OnUnlock = "Global_OnUnlock",
    ---场景释放前
    Global_Before_Scene_Unload = "Global_Before_Scene_Unload",
    ---场景所有资源初始化完后
    Global_After_Scene_Loaded = "Global_After_Scene_Loaded",
    ---种植
    Global_After_Planting = "Global_after_Planting",
    ---收集套装完成
    Global_After_CollectionItem = "Global_After_CollectionItem",
    ---从工厂收获道具
    Global_After_CollectFactoryItem = "Global_After_CollectFactoryItem",
    ---从土地中收获道具
    Global_After_CollectFarmItem = "Global_After_CollectFarmItem",
    ---得到某个ID的龙
    Global_After_GetDragonById = "Global_After_GetDragonById",
    ---购买某个ID的龙
    Global_After_BuyDragonById = "Global_After_BuyDragonById",
    ---喂养龙
    Global_After_FeedDragon = "Global_After_FeedDragon",
    ---从龙身上生产道具
    Global_After_ProduceDragonItem = "Global_After_ProduceDragonItem",
    ---从龙身上收获道具
    Global_After_CollectDragonItem = "Global_After_CollectDragonItem",
    ---食物出现
    Global_Food_Appear = "Global_Food_Appear",
    ---食物被吃
    Global_Food_Eaten = "Global_Food_Eaten",
    ---食物回收
    Global_Food_Recycle = "Global_Food_Recycle",
    ---开始播放drama
    Global_Drama_Start = "Global_Drama_Start",
    ---结束播放drama
    Global_Drama_Over = "Global_Drama_Over",
    ---龙初始化完成
    Global_After_InitDragons = "Global_After_InitDragons",
    ---龙合成成功
    Global_After_Dragon_Merged = "Global_After_Dragon_Merged",
    ---龙合成成功
    Global_After_Dragon_Hungry = "Global_After_Dragon_Hungry",
    ---繁育龙
    Global_After_BreedDragon = "Global_After_BreedDragon",
    ---繁育一次
    Global_After_Breed = "Global_After_Breed",
    ---恢复龙之力之后(目前只包括钻石和棒棒糖恢复的情况)
    Global_After_Accelerate_Dragon_Energy = "Global_After_Accelerate_Dragon_Energy",
    ---龙飞出进入cd状态
    Dragon_FlyoutToCoolDown = "Dragon_FlyoutToCoolDown",
    ---引导开始
    Global_Guide_Start = "Global_Guide_Start",
    ---引导结束
    Global_Guide_Finish = "Global_Guide_Finish",
    ---引导中断
    Global_Guide_Break = "Global_Guide_Break",
    ---地图气泡初始化完成消息
    Global_Bubble_Inited = "Global_Bubble_Inited",
    ---摄像机Zoom消息
    Global_Camera_Size_Changed = "Global_Camera_Size_Changed",
    ---建筑修复状态改变的消息
    Building_RepairState_Changed = "Building_RepairState_Changed",
    ---建筑修复完成设置了StateClean
    Building_Repair_Done = "Building_Repair_Done",
    ---任务弱引导
    TASK_WAKE_GUIDE = "TASK_WAKE_GUIDE",
    ---队列结束
    PopupQueue_FINISHED = "PopupQueue_FINISHED",
    ---龙技能次数用完
    DragonDailySkillCntRunOut = "DragonDailySkillCntRunOut",
    ---龙开始使用技能
    Dragon_Begin_UseSkill = "Dragon_Begin_UseSkill",
    ---龙使用技能结束
    Dragon_Finish_UseSkill = "Dragon_Finish_UseSkill",
    ---每日龙技能数重置
    ResetDragonSpellCnt = "ResetDragonSpellCnt",
    ---装满船发货
    Global_Afater_TimeOrder_Full_Deliver = "Global_Afater_TimeOrder_Full_Deliver",
    ---圣水车成功兑换体力
    After_Energy_Exchange = "After_Energy_Exchange",
    ---活动解锁
    Activity_On_Activity_Unlock = "Activity_On_Activity_Unlock",
    ---活动获得数据后
    Activity_On_Activity_Response = "Activity_On_Activity_Response",
    ---活动结束
    Activity_On_Activity_End = "Activity_On_Activity_End",
    ---黄金通行证任务完成
    Activity_GoldPass_TaskFinish = "Activity_GoldPass_TaskFinish",
    ---付费购买黄金通行证
    Activity_GoldPass_BuyPass = "Activity_GoldPass_BuyPass",
    ---黄金通行证领取奖励类型
    Activity_GoldPass_ReceiveReward = "Activity_GoldPass_ReceiveReward",
    ---黄金通行证跳转奖励滑动后
    Activity_GoldPass_AfterJumpReward = "Activity_GoldPass_AfterJumpReward",
    ---礼包初始化完成
    Gift_Init = "Gift_Init",
    ---礼包打开
    Gift_Open = "Gift_Open",
    ---礼包关闭
    Gift_Close = "Gift_Close",
    ---炼金炉开启
    Gold_Order_Open = "Gold_Order_Open",
    ---炼金炉冷却
    Gold_Order_Close = "Gold_Order_Close",
    ---炼金炉炼金
    Gold_Order_Draw = "Gold_Order_Draw",
    ---炼金炉条件满足
    Gold_Order_Can_Draw = "Gold_Order_Can_Draw",
    ---家园龙委托探索消息:派遣出去
    Commission_Dispatch_Success = "Commission_Dispatch_Success",
    ---家园龙委托探索消息:派遣结束,回巢休息
    Commission_Dispatch_end = "Commission_Dispatch_end",
    ---家园探索领取奖励消息
    Commission_After_Get_Reward = "Commission_After_Get_Reward",
    ---切换玩家头像框
    Switch_Avatar_Frame = "Switch_Avatar_Frame",
    ---切换玩家头像
    Switch_Avatar = "Switch_Avatar",
    ---显示作物信息框
    CropInfo_Show = "CropInfo_Show",
    ---关闭作物信息框
    CropInfo_Hide = "CropInfo_Hide",
    ---龙出售
    Global_After_Dragon_Sell = "Global_After_Dragon_Sell",
    GoldPassBatchPopBegin = "GoldPassBatchPopBegin",
    GoldPassBatchPopOver = "GoldPassBatchPopOver",
    GetWay_Open_Closed = "GetWay_Open_Closed",
    ---跨天
    DAY_SPAN = "DAY_SPAN",
    ---彩蛋倒计时刷新
    Active_Egg_CD_Refrash = "Active_Egg_CD_Refrash",
    ---龙工作消息:工作状态变更(WARN: 非即时消息)
    DRAGON_WORK_DRAGON_STATE_CHANGED = "DRAGON_WORK_DRAGON_STATE_CHANGED",
    ---实验室成功合成龙之后
    Global_After_Dragon_Compose = "Global_After_Dragon_Compose",
    AFTER_DRAGON_ENTITY_ADDED = "AFTER_DRAGON_ENTITY_ADDED",
    Global_OnShake = "Global_OnShake",
    ---龙从临时龙巢移动出来
    Global_Dragon_MoveToNest = "Global_Dragon_MoveToNest",
    ---扭蛋机消息
    Global_After_Gacha = "Global_After_Gacha",
    ---商人普通兑换完成消息
    Global_After_Trader_Normal_Complete = "Global_After_Trader_Normal_Complete",
    ---完成地图三星任务的某个星星的所有任务 param : sceneId, starId
    MapStar_StarTask_AllDone = "MapStar_StarTaskAllDone",
    ---某个地图的三星达成了的消息 param : sceneId, isInLimit:是否限时内完成
    MapStar_3Star_Done = "MapStar_3Star_Done",
    ---发光障碍物被采集完消息
    PickDragonCollect_Done = "PickDragonCollect_Done",
    ---月卡开启以及结束事件
    MonCard_RefreshState = "MonCard_RefreshState",
    WeeklyPack_RefreshState = "WeeklyPack_RefreshState",
    SkinPack_RefreshState = "SkinPack_RefreshState",
    ---
    GrowthFund_RefreshState = "GrowthFund_RefreshState",
    ---龙迷宫开启时间结束
    DragonMazeTimeOver = "DragonMazeTimeOver",
    ---
    DragonMazeDayRefresh = "DragonMazeDayRefresh",
    DragonMazeSuccess = "DragonMazeSuccess",
    --开通神龙迷宫场景
    OpenDragonMaze = "OpenDragonMaze",
    ---龙跑酷场景事件
    Parkour_Collect_Item = "Parkour_Collect_Item", --碰撞到道具
    Parkour_GameState_Changed = "Parkour_GameState_Changed", --游戏状态改变
    ChristmasDrowCount = "ChristmasDrowCount", --游戏状态改变
    --- 公会地图活动NPC道具足够状态变化
    Team_Activity_TaskItemTrigger = "Team_Activity_TaskItemTrigger",
    --- 公会地图活动NPC任务更新
    Team_Activity_NpcTaskUpdate = "Team_Activity_NpcTaskUpdate",
    --- 公会活动地图 在里面的玩家信息更新
    Team_Activity_OnAdvPlayerUpdate = "Team_Activity_OnAdvPlayerUpdate",
    Team_Activity_OnProgressDone = "Team_Activity_OnProgressDone",
    --- 公会活动地图 完成了任务
    Team_Activity_OnTaskFinish = "Team_Activity_OnTaskFinish",
    Team_Activity_OnActivityFinish = "Team_Activity_OnActivityFinish",
    ---小猪存钱罐
    PiggyBankRefresh = "PiggyBankRefresh",
    ---龙抽卡
    DragonDrawUpChange = "DragonDrawUpChange", --抽卡up变化,
    --体力折扣时间buff结束
    EnergyDiscountBuffEnd = "EnergyDiscountBuffEnd",
    --龙采集体力折扣时间buff结束
    DragonEnergyDiscountBuffEnd = "DragonEnergyDiscountBuffEnd",
    --神龙贸易季签到
    DragonSeasonCheckIn = "DragonSeasonCheckIn",
    --神龙贸易季交付龙物资
    DeliverDragonProduct = "DeliverDragonProduct",
    --获得新装扮消息
    ObtainNewDragonSkin = "ObtainNewDragonSkin",
    --删除装扮消息
    DeleteDragonSkin = "DeleteDragonSkin",
    --由于合成儿消耗掉的装扮
    ConsumedDragonSkin = "ConsumedDragonSkin",
    --拉取到引导数据以后
    Global_After_GuideDataReady = "Global_After_GuideDataReady",
    ---开启农田 zoneId agentId
    Global_After_OpenFarmland = "Global_After_OpenFarmland",
    ---任务地图初始化完成
    Task_ActivityTaskConfig_Loaded = "Task_ActivityTaskConfig_Loaded",
    ---淘金活动获得宝藏
    Task_GoldPanningTreasure = "Task_GoldPanningTreasure",
    ---NPC换皮肤
    ChangeNpcSkin = "ChangeNpcSkin",
    ---水管完成
    PipeFinished = "PipeFinished",
    ---左上角小图标滑入(隐藏)
    MainUI_TopLeft_OnHide = "MainUI_TopLeft_OnHide",
    ---右上角小图标滑入(隐藏)
    MainUI_TopRight_OnHide = "MainUI_TopRight_OnHide",
    ---割草场景事件
    Mow_Collect_Item = "Mow_Collect_Item", --碰撞到道具
    Mow_GameState_Changed = "Mow_GameState_Changed", --游戏状态改变
    --商品数据拉取结果，result：bool
    Product_Fetch_Result = "Product_Fetch_Result",
    DragonDrawTenTimes = "DragonDrawTenTimes", -- 贝壳十连抽
    --钓鱼场景事件
    Fishing_GetFish = "Fishing_GetFish",
    Fishing_StartFish = "Fishing_StartFish",
    ---龙使用体力
    Global_After_Dragon_PhysicalStrength_Use = "Global_After_Dragon_PhysicalStrength_Use",
    ---角色和龙更换皮肤
    Global_After_Character_ChangeSkin = "Global_After_Character_ChangeSkin",
    ---领取挂机奖励成功
    TakeHangUpRewardSuccess = "TakeHangUpRewardSuccess",
    ---升级挂机奖励
    HangUpRewardLevelUp = "HangUpRewardLevelUp",
    ---挂机奖励进度
    HangUpRewardProgress = "HangUpRewardProgress",

    -- Cleaner -------------------------------
    -- 建筑升级
    BuildingUpLevel = "BuildingUpLevel",
    -- 建筑产物领取
    BuildingTakeProduction = "BuildingTakeProduction",
    -- 删除建筑
    BuildingRemove = "BuildingRemove",
    -- 船坞等级
    ShipDockLevel = "ShipDockLevel",
    -- 岛屿连接接到家园
    IslandLinkHomeland = "IslandLinkHomeland",
    -- 去探索到
    GoToIsland = "GoToIsland",
    -- 去家园
    GoToHomeland = "GoToHomeland",
    -- entity 死亡
    EntityDeath = "EntityDeath",
    -- 获得宠物
    AddPet = "AddPet",
    -- 宠物升级
    PetUpLevel = "PetUpLevel",
    -- 岛屿进度变化
    IslandProgressChange = "IslandProgressChange",
    -- Agent 状态到 Cleaned
    AgentCleaned = "AgentCleaned",
    VaccumChanged = "VaccumChanged",
    ---开始生产
    StartProduction = "StartProduction",
    ---开始生产饰品
    StartProductDecoration = "StartProductDecoration",
    ---回收道具
    Global_After_Recycle = "Global_After_Recycle",
    --- 摄像机跟随Player
    Camera_Follow_Player = "Camera_Follow_Player",
    -- 宠物上阵
    Pet_Up_Team = "Pet_Up_Team",
    ------------------------------------------
}

MessageDispatcher = {
    messageListeners = {},
    subMessageListeners = {}
}

local dassert = console.assert

---添加一个注册事件的监听
---@param key MessageType
function MessageDispatcher:AddMessageListener(key, callback, observer)
    dassert(callback ~= nil, "Can't register a nil message listener, message type = ", key)

    local listeners = self.messageListeners[key]
    local listener = {observer = observer, callback = callback}

    if table.isEmpty(listeners) then
        self.messageListeners[key] = {[1] = listener}
    else
        local exist = false
        for _, v in ipairs(listeners) do
            if v.callback == callback and v.observer == observer then
                exist = true
                break
            end
        end

        if exist then
            console.warn(nil, "Can't register the same handler by same observer twice, message type = ", key) --@DEL
            return false
        else
            table.insert(listeners, listener)
        end
    end
    return true
end

---删除一个注册事件的监听
---@param key MessageType
function MessageDispatcher:RemoveMessageListener(key, callback, observer)
    -- dassert(callback ~= nil, "Can't remove a message listener with a nil handler, message type = ", key)

    local listeners = self.messageListeners[key]
    if table.isEmpty(listeners) then
        console.warn(nil, "Try to remove an unregistered message listener, message type, message type = ", key) --@DEL
        return
    end

    for i, v in ipairs(listeners) do
        if (not callback or v.callback == callback) and v.observer == observer then
            table.remove(listeners, i)
            break
        end
    end
end

---@param key MessageType
function MessageDispatcher:HasMessageListener(key)
    return not table.isEmpty(self.messageListeners[key])
end

---同步发送一个事件
---@param key MessageType
function MessageDispatcher:SendMessage(key, ...)
    local listeners = self.messageListeners[key] or {}
    local cachedHandlers = {table.unpack(listeners)}
    for _, v in ipairs(cachedHandlers) do
        if v.observer ~= nil then
            Runtime.InvokeCbk(v.callback, v.observer, ...)
        else
            Runtime.InvokeCbk(v.callback, ...)
        end
    end

    self:sendSubMessage(key, ...)
end

function MessageDispatcher:sendSubMessage(key, ...)
    local subKey = select(1, ...)
    if not subKey then
        return
    end
    local subListeners = self.subMessageListeners[key] and self.subMessageListeners[key][subKey]
    if table.isEmpty(subListeners) then
        return
    end
    local cachedHandlers = {table.unpack(subListeners)}
    for _, v in ipairs(cachedHandlers) do
        if v.observer ~= nil then
            Runtime.InvokeCbk(v.callback, v.observer, ...)
        else
            Runtime.InvokeCbk(v.callback, ...)
        end
    end
end

function MessageDispatcher:AddSubMessageListener(key, callback, observer, subKey)
    dassert(callback ~= nil, "Can't register a nil message listener, message type = ", key)
    if not self.subMessageListeners[key] then
        self.subMessageListeners[key] = {}
    end
    local listeners = self.subMessageListeners[key][subKey]
    local listener = {observer = observer, callback = callback}

    if table.isEmpty(listeners) then
        self.subMessageListeners[key][subKey] = {[1] = listener}
    else
        local exist = false
        for _, v in ipairs(listeners) do
            if v.callback == callback and v.observer == observer then
                exist = true
                break
            end
        end

        if exist then
            console.warn(nil, "Can't register the same handler by same observer twice, message type = ", key) --@DEL
            return false
        else
            table.insert(listeners, listener)
        end
    end
    return true
end

---删除一个注册事件的监听
---@param key MessageType
function MessageDispatcher:RemoveSubMessageListener(key, callback, observer, subKey)
    -- dassert(callback ~= nil, "Can't remove a message listener with a nil handler, message type = ", key)

    local listeners = self.subMessageListeners[key] and self.subMessageListeners[key][subKey]
    if table.isEmpty(listeners) then
        console.warn(nil, "Try to remove an unregistered message listener, message type, message type = ", key) --@DEL
        return
    end

    for i, v in ipairs(listeners) do
        if (not callback or v.callback == callback) and v.observer == observer then
            table.remove(listeners, i)
            break
        end
    end
end

---异步发送一个事件（未测试）
---@param key MessageType
function MessageDispatcher:PostMessage(key, ...)
    local listeners = self.messageListeners[key]
    if table.isEmpty(listeners) then
        return
    end

    local cachedHandlers = {table.unpack(listeners)}
    local args = {...}
    local idx = 1
    local function OnFrameAction()
        local v = cachedHandlers[idx]
        if not v then
            return
        end
        if v.observer ~= nil then
            Runtime.InvokeCbk(v.callback, v.observer, table.unpack(args))
        else
            Runtime.InvokeCbk(v.callback, table.unpack(args))
        end
        idx = idx + 1
        if #cachedHandlers <= idx then
            App.nextFrameActions:Add(OnFrameAction)
        end
    end
    App.nextFrameActions:Add(OnFrameAction)
end

return MessageDispatcher
