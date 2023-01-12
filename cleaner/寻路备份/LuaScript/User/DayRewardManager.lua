---@class DayRewardManager
local DayRewardManager = {
    inited = false,
    --- key:[id]
    dayRewardTemplate = AppServices.Meta:Category("DayRewardTemplate"),
    --- key:[周数][天数]
    dayRewardMap = {},
    ---服务器数据
    data = {}
}

function DayRewardManager:Init()
    --重新组装配置表
    self:RestructureConfig()
    local response = App.response.dayRewardInfo
    self:InitServerdata(response)

    -- App:AddToDayRefreshList({
    App:AddToLocalDayRefreshList(
        {
            refreshFunc = function()
                self:DayRefresh()
            end
        }
    )
end

function DayRewardManager:RestructureConfig()
    for k, v in pairs(self.dayRewardTemplate) do
        if not self.dayRewardMap[v.batchNum] then
            self.dayRewardMap[v.batchNum] = {}
        end

        local newItemIds = {}
        if table.count(v.itemIds) > 0 then
            for index, item in ipairs(v.itemIds) do
                newItemIds[index] = {itemId = tostring(item[1]), num = item[2]}
            end
        end

        v.originalItemIds = v.itemIds
        v.itemIds = newItemIds
        self.dayRewardMap[v.batchNum][v.dayNum] = v
    end
end

function DayRewardManager:InitServerdata(response)
    -- console.lzl("--DayRewardManager:InitServerdata--") --@DEL
    if table.isEmpty(response) or response.batchNum == 0 then
        return
    end

    self.isShowed = AppServices.User.LocalDailyData:GetKeyValue("DayRewardShownToday", false)

    --标记是否被初始化
    self.inited = true
    --后端同步数据
    self.data = {
        continueEnterGameNum = response.continueEnterGameNum,
        batchNum = response.batchNum,
        ---已领取了普通奖励
        isRewarded = response.isRewarded,
        ---已领取了广告奖励
        isAdsRewarded = response.isAdsRewarded
    }

    for index, value in ipairs(response.rewards) do
        local selected = self.dayRewardMap[self.data.batchNum][value.day].originalItemIds[value.rewardIndex + 1]
        self.dayRewardMap[self.data.batchNum][value.day].itemIds = {{itemId = tostring(selected[1]), num = selected[2]}}
    end

    console.lj("签到数据：" .. table.tostring(self.data)) --@DEL
    --已签到标记
    self:SetCheckIn(self.data.isRewarded and self:HasAdsRewarded())
end

--没有广告时也算领取了
function DayRewardManager:HasAdsRewarded()
    return self.data.isAdsRewarded or not AppServices.AdsManager:CheckActiveById(AdsTypes.AdsRegister)
end

function DayRewardManager:DayRefresh()
    self.inited = false
    if not AppServices.Unlock:IsUnlock("dayRewardOpenLevel") then
        return
    end

    local function onFailed(errorCode)
        if errorCode then
            ErrorHandler.ShowErrorPanel(errorCode)
        end
    end

    local function onSuccess(response)
        self:InitServerdata(response)
        if PanelManager.isPanelShowing(GlobalPanelEnum.DayReward14Panel) then
            AppServices.User.LocalDailyData:SetKeyValue("DayRewardShownToday", true)
            sendNotification(DayReward14PanelNotificationEnum.Msg_Refresh_UI)
        else
            PopupManager:CallWhenIdle(
                function()
                    -- -- console.lzl("------DayRewardManager:DayRefresh------", self.isCheckIn) --@DEL
                    if not self.isCheckIn then
                        PanelManager.showPanel(GlobalPanelEnum.DayReward14Panel, {isFirstShow = true})
                    else
                        self:SetCheckIn(true)
                    end
                end
            )
        end
    end
    AppServices.User.LocalDailyData:SetKeyValue("DayRewardShownToday", false)
    Net.Dayrewardmodulemsg_9001_DayRewardInfo_Request(nil, onFailed, onSuccess)
end

--队列专用，检查是否有签到
function DayRewardManager:CheckQueue()
    if not AppServices.Unlock:IsUnlock("dayRewardOpenLevel") then
        return false
    end

    if PanelManager.isPanelShowing(GlobalPanelEnum.DayReward14Panel) then
        return false
    end

    --已签到
    if self.isCheckIn then
        return false
    end

    if self.isShowed then
        self:SetCheckIn()
        return false
    end

    return true
end

function DayRewardManager:DoQueue(finishCallback)
    self.isShowed = true

    --已获得数据
    if self.inited then
        PanelManager.showPanel(GlobalPanelEnum.DayReward14Panel, {finishCallback = finishCallback, isFirstShow = true})
        return
    end

    --未登陆？？
    if not App.loginLogic:IsLoggedIn() then
        Runtime.InvokeCbk(finishCallback)
        return
    end

    --应该检查当前与上一次签到是否跨天，防止没有发送跨天信息
    --请求数据
    local function onFail(errorCode)
        Runtime.InvokeCbk(finishCallback, errorCode)
    end

    local function onSuccess(response)
        self:InitServerdata(response)
        PanelManager.showPanel(GlobalPanelEnum.DayReward14Panel, {finishCallback = finishCallback, isFirstShow = true})
    end

    Net.Dayrewardmodulemsg_9001_DayRewardInfo_Request(nil, onFail, onSuccess)
end

--获取当前奖励
function DayRewardManager:GetDayReward()
    return self.dayRewardMap[self.data.batchNum][self.data.continueEnterGameNum].itemIds or {}
end

--获取当前一轮的奖励
function DayRewardManager:GetBatchRewards()
    return self.dayRewardMap[self.data.batchNum] or {}
end

function DayRewardManager:GetDayRewardByDay(day)
    return self.dayRewardMap[self.data.batchNum][day].itemIds or {}
end

local hideButtonSceneTypes = {}
hideButtonSceneTypes[SceneType.Parkour] = true
hideButtonSceneTypes[SceneType.Exploit] = true

function DayRewardManager:SetCheckIn(value)
    local function FreshExBtn(val)
        ---@type DayRewardButton
        local dayRewardButton = App.scene:GetWidget(CONST.MAINUI.ICONS.DayRewardButton)
        -- local widgetsMenu = App.scene:GetWidget(CONST.MAINUI.ICONS.HRWidgetsMenu)
        if val and dayRewardButton then
            -- widgetsMenu:DelRHButton(CONST.MAINUI.ICONS.DayRewardButton)
            dayRewardButton.gameObject:SetActive(false)
        elseif not val and not dayRewardButton and self.isShowed then
            dayRewardButton = require("UI.Components.DayRewardButton"):Create()
            -- widgetsMenu:AddRHButton(CONST.MAINUI.ICONS.DayRewardButton, dayRewardButton)
            local topLeft = App.scene.view.layout:TopLeft()
            dayRewardButton.transform:SetParent(topLeft, false)
            dayRewardButton.transform:SetAsFirstSibling()
            App.scene:AddWidget(CONST.MAINUI.ICONS.DayRewardButton, dayRewardButton)
            if hideButtonSceneTypes[App.scene:GetSceneType()] then
                dayRewardButton.gameObject:SetActive(false)
            end
        end
    end

    --设置签到标记
    self.isCheckIn = value
    --刷新签到附带按钮操作
    FreshExBtn(value)
end

DayRewardManager:Init()

return DayRewardManager
