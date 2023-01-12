---广告数据的逻辑(必须登录后初始化)
---@class ForAdSdk
local ForAdSdk = require "Game.Sdk.Ads.ForAdSdk"
---@class AdsManager
local AdsManager = {}

--由RestructureAdsConfig解析出来
--AdsOrder = 1,
--AdsRegister = 2,
--AdsTreasureChest = 3,
--AdsEnergyRecovery = 4,
--AdsGoldcoinTurntable = 5,
--AdsBalloonBombs = 6
--AdsFactorySpeedUp = 7
--AdsClock = 8
---@class AdsTypes
---@field AdsEnergyRecovery string
---@field AdsRegister string
---@field AdsFactorySpeedUp string
---@field AdsClock string
---@field AdsFillOneSailOrder string
---@field AdsOrderDoubleReward string
---@field AdsGoldOrderSpeedUp string
AdsTypes = {}
AdsIgnore = {
    activeLevel = 1,
    coldtime = 2,
    dailyLimit = 3,
    ifActive = 4,
    cached = 5
}

function AdsManager:Init()
    --初始化数据结构
    self.group = ""
    --- key:[id]
    --self.adsConfigs = AppServices.Meta:Category("AdsConfigTemplate")
    --- key:[分组][广告类型]
    self.adsConfigMap = {}

    ---用户分组信息
    self.group = AppServices.User:GetUserGroup()
    self.adsConfigs = AppServices.Meta:Category("AdsConfigTemplate.AdsConfigTemplate"..self.group)
    self:RestructureAdsConfig()

    self.adsIncentives = {}
    self:InitServerdata()
    --重新组装配置表
   --self:RestructureAdsConfig()

    ---监听每日刷新
    App:AddToDayRefreshList(
        {
            refreshFunc = function()
                self:OnDayChange()
            end
        }
    )
end

function AdsManager:RestructureAdsConfig()
    for _, config in pairs(self.adsConfigs) do
        if not self.adsConfigMap[config.userID] then
            self.adsConfigMap[config.userID] = {}
        end
        self.adsConfigMap[config.userID][config.type] = config
        AdsTypes[config.name] = config.type
    end
end

function AdsManager:InitServerdata()
    -- 初始化本地广告数据
    local response = App.response
    if table.isEmpty(response) or not response.adsIncentive then
        return
    end

    --标记是否被初始化
    self.inited = true

    for i = 1, table.maxn(response.adsIncentive.viewInfos) do
        local id = response.adsIncentive.viewInfos[i].id
        local data = {
            lastViewTime = math.floor(response.adsIncentive.viewInfos[i].lastViewTime / 1000),
            todayViewCount = response.adsIncentive.viewInfos[i].todayViewCount
        }
        local configItem = self.adsConfigs[id]
        if configItem and configItem.userID == self.group then
            self.adsIncentives[configItem.type] = data
        end
    end
end

function AdsManager:OnDayChange()
    if table.isEmpty(self.adsIncentives) then
        return
    end

    ---重置数据
    for k, v in pairs(self.adsIncentives) do
        self.adsIncentives[k].todayViewCount = 0
    end
end

--- 获取当前分组下的广告ID
function AdsManager:GetConfigId(adsType)
    local config = self.adsConfigMap[self.group][adsType]
    return config.id
end

--- 获取当前分组下的广告配置
function AdsManager:GetConfigByType(adsType)
    return self.adsConfigMap[self.group][adsType]
end

function AdsManager:GetAdsIncentives(adsType)
    if not self.adsIncentives[adsType] then
        self.adsIncentives[adsType] = {
            lastViewTime = 0,
            todayViewCount = 0
        }
    end
    return self.adsIncentives[adsType]
end

---触发激励奖励，同步给服务器，有效的一次广告观看
function AdsManager:RequsetReward(param)
    local function onSucess(msg)
        self:ClientWatchAdsById(param.adsType)
        Runtime.InvokeCbk(param.onSuc,msg)
    end

    local function onFail(errorcode)
        ErrorHandler.ShowErrorPanel(errorcode)
        Runtime.InvokeCbk(param.onFail)
    end

    if param.adsType and not param.adsId then
        param.adsId = self:GetConfigId(param.adsType)
    end

    Net.Adsmodulemsg_13002_AdsIncentiveReward_Request(param, onFail, onSucess)
end

---记录广告播放时间
function AdsManager:RecordLastPlayTime(adsType)
    local incentiveInfo = self:GetAdsIncentives(adsType)
    incentiveInfo.lastViewTime = TimeUtil.ServerTime()
end

---记录每日观看次数
function AdsManager:RecordTodayPlayTimes(adsType)
    local incentiveInfo = self:GetAdsIncentives(adsType)
    incentiveInfo.todayViewCount = incentiveInfo.todayViewCount + 1
end

---观看广告，记录每日观看次数，记录观看时间
function AdsManager:ClientWatchAdsById(adsType)
    self:RecordLastPlayTime(adsType)
    self:RecordTodayPlayTimes(adsType)
end

--触发显示前检查：广告是否有效，包括配置，激励信息，缓存检查
function AdsManager:CheckActiveById(adsType,ignore)
    if not self:CheckConfigById(adsType,ignore) then
        return false
    end

    if not self:CheckAdsIncentivesById(adsType,ignore) then
        return false
    end

    if not self:CheckCached(ignore) then
        return false
    end

    return true
end

--检查配置内容
function AdsManager:CheckConfigById(adsType,ignore)
    --先屏蔽下总开关
    if not BCore.IsOpen("Ad") then
        return false
    end

    if not self.inited then
        console.lj("AdsManager 未初始化") --@DEL
        return false
    end

    --检查配置
    if not self.adsConfigMap[self.group] then
        console.lj("广告配置：找不到", "广告分组：" .. self.group) --@DEL
        return false
    end

    local config = self.adsConfigMap[self.group][adsType]
    ignore = ignore or {}
    if not config then
        console.lj("广告配置：找不到", "广告分组：" .. self.group, " 广告类型" .. adsType) --@DEL
        return false
    end

    if not ignore or not table.indexOf(ignore, AdsIgnore.ifActive) then
        if not config.ifActive or config.ifActive == 0 then
            console.lj("广告配置：不开启广告", "广告id：" .. config.id) --@DEL
            return false
        end
    end

    if not ignore or not table.indexOf(ignore, AdsIgnore.activeLevel) then
        local curLevel = AppServices.User:GetCurrentLevelId()
        if curLevel < config.activeLevel then
            console.lj("广告配置：等级不足", "curLevel:" .. curLevel, "广告id：" .. config.id) --@DEL
            return false
        end
    end

    return true
end

--检查激励广告记录（每日上限与cd）
function AdsManager:CheckAdsIncentivesById(adsType,ignore)
    --激励信息检查
    local incentiveInfo = self:GetAdsIncentives(adsType)
    local config = self.adsConfigMap[self.group][adsType]
    if not ignore or not table.indexOf(ignore, AdsIgnore.dailyLimit) then
        if config.dailyLimit ~= -1 and incentiveInfo.todayViewCount >= config.dailyLimit then
            console.lj("广告配置：超过最大领取次数", "todayViewCount:" .. incentiveInfo.todayViewCount, "广告id：" .. config.id) --@DEL
            return false
        end
    end

    if not ignore or not table.indexOf(ignore, AdsIgnore.coldtime) then
        local timeNext = TimeUtil.ServerTime() - incentiveInfo.lastViewTime
        if  timeNext < config.coldtime then
            console.lj("广告配置：冷却中", "冷却时间（s）:" .. timeNext, "广告id：" .. config.id) --@DEL
            return false
        end
    end
    return true
end

--返回cd结束的时间戳(非cd阶段不返回)
function AdsManager:GetRemaidColdTime(adsType)
    local incentiveInfo = self:GetAdsIncentives(adsType)
    local config = self.adsConfigMap[self.group][adsType]
    local timeNext =  incentiveInfo.lastViewTime + config.coldtime
    return timeNext > TimeUtil.ServerTime() and timeNext or 0
end

--检查缓存
function AdsManager:CheckCached(ignore)
    if ignore and table.indexOf(ignore, AdsIgnore.cached) then
        return true
    end
    return ForAdSdk:IsScreenAdCached()
end

--广告播放，先检查是否有缓存
function AdsManager:PlayAds(adsType, reward, callback)
    if self:CheckCached() and Runtime.GetNetworkState() then
        --Runtime.CSCollectGarbage(true)
        App:SetPauseAlive(false)
        ForAdSdk:DisplayScreenAd(adsType, reward, callback)
    else
        ErrorHandler.ShowErrorMessage(Runtime.Translate("ads_Tips_text"))
        Runtime.InvokeCbk(callback, false)
    end
end

function AdsManager:ShowTestView()
    ForAdSdk:ShowTestView()
end

function AdsManager:IsWatiCD(adsType)
    if not self:CheckConfigById(adsType) then
        return false
    end

    if not self:CheckCached() then
        return false
    end

    --激励信息检查
    local incentiveInfo = self:GetAdsIncentives(adsType)
    local config = self.adsConfigMap[self.group][adsType]
    if incentiveInfo.todayViewCount >= config.dailyLimit then
        console.lj("广告配置：超过最大领取次数", "todayViewCount:" .. incentiveInfo.todayViewCount, "广告id：" .. config.id) --@DEL
        return false
    end

    local timeNext = config.coldtime + incentiveInfo.lastViewTime
    if timeNext > TimeUtil.ServerTime() then
        return true, timeNext
    else
        console.lj("广告配置", "冷却时间（s）:" .. timeNext, "广告id：" .. config.id) --@DEL
        return false
    end
end

AdsManager:Init()
return AdsManager
