local filename = "noti.dat"

local E_NOTI_TYPE = {
    Normal = 1, --通用
    Energy = 2, --体力相关
    Factory = 3, --生产基地
    Dragon = 4, --挂机奖励
    TimeOrder = 5, --航海订单
    DragonStrength = 6, --龙之力
    Activity = 7 -- 活动
}

-- local E_MOMENTS_IDX = {
--     Weekday1 = 1,
--     Weekday2 = 2,
--     Weekend1 = 3,
--     Weekend2 = 4,
--     Weekend3 = 5
-- }

-- 推送的特定的时间点
-- local E_MOMENTS = {
--     -- 工作日时间推送时间点
--     [E_MOMENTS_IDX.Weekday1] = {12, 0},
--     [E_MOMENTS_IDX.Weekday2] = {19, 0},
--     -- 假期时间推送时间点
--     [E_MOMENTS_IDX.Weekend1] = {10, 30},
--     [E_MOMENTS_IDX.Weekend2] = {13, 00},
--     [E_MOMENTS_IDX.Weekend3] = {20, 00}
-- }

---@class Notification
local Notification = {
    pushedNotifications = {},
    lastPushedNotifications = {},
    minInterval = 4 * 60 * 60,
    minHour = 9,
    maxHour = 22,
    E_NOTI_TYPE = E_NOTI_TYPE,
    -- 打点用的(没有其他任何作用) 统计提示面板弹出次数 玩家跳转去开启权限后清0
    openUITimes = 0
}

function Notification:Init()
    if self.inited then
        return
    end
    self.inited = true

    MessageDispatcher:AddMessageListener(MessageType.Global_After_UseItem, self.OnUseItemEvent, self)
    App:AddAppOnPauseCallback(
        function(isPause)
            if isPause then
                self:OnPause()
            else
                self:OnResume()
            end
        end
    )
end

function Notification:OnSceneLoaded()
    self:_InitGenFuncs()
    self:TryInitFromFile()
end

-- 目前不需要调用
function Notification:Dispose()
    MessageDispatcher:RemoveMessageListener(MessageType.Global_After_UseItem, self.OnUseItemEvent, self)
end

function Notification:OnUseItemEvent(itemId)
    if itemId ~= ItemId.ENERGY then
        return
    end

    self:CheckOpenNotificationByEnergy()
end

function Notification:TryInitFromFile()
    local rawData = FileUtil.ReadFromUserFile(filename)
    local data
    self.openNotifications = {
        [E_NOTI_TYPE.Energy] = true,
        [E_NOTI_TYPE.Factory] = true,
        [E_NOTI_TYPE.Dragon] = true,
        [E_NOTI_TYPE.TimeOrder] = true,
        [E_NOTI_TYPE.DragonStrength] = true,
        [E_NOTI_TYPE.Activity] = true
    }
    if rawData then
        data = table.clone(table.deserialize(rawData) or {}, true)
        -- self.topPriorityNotifications = data.topPriority or {}
        self.pushedNotifications = data.pushedList or {}
        if data.openNotifications then
            for key, value in pairs(self.openNotifications) do
                self.openNotifications[key] = false
            end
            for index, value in ipairs(data.openNotifications) do
                self.openNotifications[value] = true
            end
        end
        if data.showTime then
            self.showTime = data.showTime
        end
        if data.lastPushedNotifications then
            self.lastPushedNotifications = data.lastPushedNotifications
        end
        if data.openUITimes then
            self.openUITimes = data.openUITimes
        end
    end

    local configs = AppServices.Meta:Category("PushNoticeTemplate")
    for key, value in pairs(self.lastPushedNotifications) do
        if value <= TimeUtil.ServerTime() then
            DcDelegates:Log(SDK_EVENT.push, {push = 1, id = key, languageKey = configs[key].content})
        end
    end

    self:CheckLaunchByLocalNotice()

    return true
end

function Notification:CheckLaunchByLocalNotice()
    local delegate = self:GetDelegate()
    if delegate then
        --判断是否是点击推送启动的APP
        console.datui("CheckLaunchByLocalNotice enter") --@DEL
        if delegate:IsLaunchByLocalNotice() then
            local id = delegate:GetLaunchNoticeKey()
            console.datui("CheckLaunchByLocalNotice", id) --@DEL
            self.pushedNotifications[id] = nil
            local configs = AppServices.Meta:Category("PushNoticeTemplate")
            DcDelegates:Log(SDK_EVENT.push, {push = 2, id = id, languageKey = configs[id].content})
        end
    end
end

function Notification:GetOpenUITimes()
    return self.openUITimes
end

function Notification:IncreaceOpenUITimes()
    self.openUITimes = self.openUITimes + 1
    self:WriteToFile()
end

function Notification:ResetOpenUITimes()
    self.openUITimes = 0
    self:WriteToFile()
end

function Notification:WriteToFile()
    local openNotifications = {}
    for key, value in pairs(self.openNotifications) do
        if value then
            table.insert(openNotifications, key)
        end
    end
    local jsonStr =
        table.serialize(
        {
            -- topPriority = self.topPriorityNotifications,
            pushedList = self.pushedNotifications,
            openNotifications = openNotifications,
            showTime = self.showTime,
            lastPushedNotifications = self.lastPushedNotifications or {},
            openUITimes = self.openUITimes
        }
    )
    FileUtil.SaveWriteUserFile(jsonStr, filename)
end

function Notification:GetDelegate()
    if not self.delegate then
        self.delegate = CS.BetaGame.MainApplication.notificationDelegate
    end
    if not self.delegate then
        self.delegate = include("Game.System.Notification.NullDelegate")
    end
    return self.delegate
end

function Notification:IsLevelOpen()
    local openLevel = AppServices.Meta:GetConfigMetaValue("noticeOpenLevel")
    if openLevel then
        local topLevel = AppServices.User:GetCurrentLevelId()
        openLevel = tonumber(openLevel) or topLevel
        return topLevel >= openLevel, topLevel == openLevel
    end
    return false, false
end

function Notification:IsNotificationOpen()
    return self.delegate:IsOpen()
end

-- 请求推送权限(不好用)
function Notification:RequestOpen()
    if self.delegate.RequestOpen then
        self.delegate:RequestOpen()
    end
end

-- 跳转到设置
function Notification:OpenSettings()
    self.delegate:OpenSettings()
end

function Notification:OpenSettingsURL()
    self.delegate:OpenSettingsURL()
end

function Notification:SetShowTime(showTime)
    self.showTime = showTime
    self:WriteToFile()
end

function Notification:CheckOpenNotificationByEnergy()
    local energy = AppServices.User:GetItemAmount(ItemId.ENERGY)
    if energy == 0 then
        self:CheckOpenNotification(GlobalPanelEnum.OpenNotificationPanel.tipsType.Energy)
    end
end

function Notification:CheckOpenNotification(type)
    local function idleDo()
        local canOpen = self:IsLevelOpen()
        if not canOpen then
            return
        end
        if self:IsNotificationOpen() then
            return
        end
        if self.showTime and self.showTime + TimeUtil._24H_To_Sec * 3 > TimeUtil.ServerTime() then
            return
        end
        self:SetShowTime(TimeUtil.ServerTime())
        PanelManager.showPanel(
            GlobalPanelEnum.OpenNotificationPanel,
            {type = type or GlobalPanelEnum.OpenNotificationPanel.tipsType.Energy}
        )
    end
    PopupManager:CallWhenIdle(idleDo)
end

function Notification:OpenNotification()
    DcDelegates:LogInitMessaging()
end

function Notification:ScheduleAll()
    if not self:IsLevelOpen() then
        return
    end
    if not self:IsNotificationOpen() then
        return
    end
    console.trace("[Notification] ScheduleAll ") --@DEL

    local notifications = self:_GenNotifications()
    local delegate = self:GetDelegate()
    -- self.pushedNotifications = {}
    self.lastPushedNotifications = {}
    for _, v in ipairs(notifications) do
        self.pushedNotifications[v.key] = v.ts --标记为已推送
        self.lastPushedNotifications[v.key] = v.ts --最近一次注册的推送
        delegate:Schedule(v.title, v.body, v.ts, v.key)
        local logStr = --@DEL
            "<color=#00ff00>添加通知：id: " .. --@DEL
            v.key .. "\t通知时间" .. os.date("%Y-%m-%d %H:%M:%S", v.ts) .. v.body .. "</color>" --@DEL
        console.trace(logStr) --@DEL
        DcDelegates:Log(SDK_EVENT.push, {push = 0, id = v.key, languageKey = v.config.content})
    end
    self:WriteToFile()
end

function Notification:OnPause()
    -- Pause重新设置所有推送
    self:ScheduleAll()
end

function Notification:OnResume()
    -- Resume取消所有，防止App在前台弹出推送
    local delegate = self:GetDelegate()
    if delegate and delegate.ProcessLastNotification then
        delegate:ProcessLastNotification()
    end
    self:CheckLaunchByLocalNotice()
    self:UnScheduleAll()
end

-- 生成推送配置
function Notification:_GenNotifications()
    local nowTS = TimeUtil.LocalTime()
    local nowDate = os.date("*t")
    local todayTS =
        os.time(
        {
            year = nowDate.year,
            month = nowDate.month,
            day = nowDate.day,
            hour = 0,
            min = 0,
            sec = 0
        }
    )

    local result = {}
    -- self:_GenDayNotifications(result, nowTS, true) --当天

    -- --第1-3天
    local DAY_TOTAL_SEC = 24 * 3600
    -- for i = 1, 3 do
    --     self:_GenDayNotifications(result, todayTS + i * DAY_TOTAL_SEC, false)
    -- end

    local function insertNotice(config, noticeTime)
        local title = ""
        if config.title ~= "empty" then
            title = Runtime.Translate(config.title)
        end
        console.warn( --@DEL
            self, --@DEL
            "insertNotice " .. Runtime.Translate(config.content) .. os.date(" %Y-%m-%d %H:%M:%S", noticeTime) --@DEL
        ) --@DEL
        table.insert(
            result,
            {
                key = config.id,
                title = title,
                body = Runtime.Translate(config.content),
                ts = noticeTime,
                config = config
            }
        )
    end

    local configs = AppServices.Meta:Category("PushNoticeTemplate")
    for key, value in pairs(configs) do
        local genFunc = self.genFuncs[value.type]
        if genFunc and self:GetIsOpenByType(value.type) then
            local noticeTime = genFunc(value.value)
            if noticeTime > nowTS then
                insertNotice(value, noticeTime)
            end
        end

        if value.type == E_NOTI_TYPE.Normal then
            local timing_types = value.timing_types
            local days = timing_types[1]
            local hour = timing_types[2]
            local min = timing_types[3]
            for index = 1, days do
                local noticeTime = todayTS + (index - 1) * DAY_TOTAL_SEC + hour * 3600 + min * 60
                if noticeTime > nowTS then
                    insertNotice(value, noticeTime)
                end
            end
        end
    end

    -- 按优先级排序,优先级相同时按时间排序
    table.sort(
        result,
        function(a, b)
            if a.config.priority == b.config.priority then
                return a.ts < b.ts
            end
            return a.config.priority < b.config.priority
        end
    )

    -- 最小间隔处理
    local count = #result
    local index = 2
    while index <= count do
        local pre = result[index - 1]
        local current = result[index]
        --活动不受间隔影响
        if pre.config.type ~= E_NOTI_TYPE.Activity and current.config.type ~= E_NOTI_TYPE.Activity then
            current.ts = math.max(current.ts, pre.ts + self.minInterval)
        end
        index = index + 1
    end

    -- 玩家未点击的推送1天最多推送1次
    local filterFrequencyResult = {}
    for index, value in ipairs(result) do
        local pushedTs = self.pushedNotifications[value.key]
        if pushedTs and value.config.type ~= E_NOTI_TYPE.Normal then
            if pushedTs > TimeUtil.ServerTime() then -- 注册了还没推
                table.insert(filterFrequencyResult, value)
            else
                if TimeUtil.ServerTime() > pushedTs + DAY_TOTAL_SEC then -- 虽然没点,但距离上次推送已经超过24小时
                    table.insert(filterFrequencyResult, value)
                else
                    console.warn( --@DEL
                        self, --@DEL
                        "推了没点过滤 " .. Runtime.Translate(value.config.content) .. os.date(" %Y-%m-%d %H:%M:%S", value.ts) --@DEL
                    ) --@DEL
                end
            end
        else
            table.insert(filterFrequencyResult, value)
        end
    end
    result = filterFrequencyResult

    -- 时间段过滤
    local filterTimeResult = {}
    for index, value in ipairs(result) do
        local date = os.date("*t", value.ts)
        if date.hour >= self.minHour and date.hour < self.maxHour then
            table.insert(filterTimeResult, value)
        else
            console.warn( --@DEL
                self, --@DEL
                "时间段过滤 " .. Runtime.Translate(value.config.content) .. os.date(" %Y-%m-%d %H:%M:%S", value.ts) --@DEL
            ) --@DEL
        end
    end
    result = filterTimeResult

    return result
end

function Notification:UnScheduleAll()
    console.trace("[Notification] UnScheduleAll ") --@DEL
    local delegate = self:GetDelegate()
    delegate:UnscheduleAll()
end

function Notification:_InitGenFuncs()
    self.genFuncs = {}

    self.genFuncs[E_NOTI_TYPE.Energy] = function()
        -- local level = AppServices.User:GetCurrentLevelId()
        local maxCount = HeartManager:GetMaxCount()
        local currentCount = AppServices.User:GetItemAmount(ItemId.ENERGY)

        if currentCount >= maxCount then
            return 0
        end

        local deltaCount = maxCount - currentCount
        local time = deltaCount * AppServices.Meta:GetEnergyCdTime()

        return TimeUtil.ServerTime() + time
    end
    self.genFuncs[E_NOTI_TYPE.Factory] = function()
        return AppServices.FactoryManager:GetAllMainFinishTime() // 1000
    end
    self.genFuncs[E_NOTI_TYPE.Dragon] = function()
        return AppServices.MagicalCreatures:GetAllFinishTime() // 1000
    end
    self.genFuncs[E_NOTI_TYPE.TimeOrder] = function()
        local mgr = AppServices.TimeOrder
        if mgr:IsInCD() then
            return math.floor(mgr:GetNextStateTime())
        else
            return 0
        end
    end
    self.genFuncs[E_NOTI_TYPE.DragonStrength] = function(attribute)
        local dragonsByAttr = AppServices.MagicalCreatures:GetCreaturesByAttribute(attribute)
        local maxResumeTime = 0
        for index, value in ipairs(dragonsByAttr) do
            ---@param value MagicalCreatureMsg
            local cfg = AppServices.Meta:GetMagicalCreateuresConfigById(value.templateId)
            if cfg.physicalStrength > 0 and value.physicalStrength == 0 then
                local resumeTime = value.getPhysicalStrengthTime + cfg.physicalStrengthResumeTime
                maxResumeTime = math.max(maxResumeTime, resumeTime)
            end
        end
        return maxResumeTime
    end

    self.genFuncs[E_NOTI_TYPE.Activity] = function(activityId)
        activityId = tostring(activityId)
        local config = ActivityServices.ActivityManager:GetConfigById(activityId)
        if not config then
            return 0
        end
        return tonumber(config.startTime)
    end
end

function Notification:SetIsOpenByType(type, isOpen)
    self.openNotifications[type] = isOpen
    self:WriteToFile()
end

function Notification:GetIsOpenByType(type)
    return self.openNotifications[type]
end

Notification:Init()

return Notification
