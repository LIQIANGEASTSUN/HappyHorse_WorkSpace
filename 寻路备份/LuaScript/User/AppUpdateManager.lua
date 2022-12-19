AppUpdateManager = {}

local fileName = "app_update.dat"

local CHECEK_UPDATE_API_URL = NetworkConfig.rpcUrl .. "/BI/open/getRewardsVersion.do"

local TIP_INTERVAL = 3600 * 24 * 5
local AUTO_CHECK_INTERVAL = 10 * 60

function AppUpdateManager:RecordDNDTime()
   -- if not self.data then
    --    self.data = {}
    --end
    self.data.lastTipTime = os.time()
    self:Storge()
end

function AppUpdateManager:GetLastTipTime()
    --if not self.isInit then
    --    self:Init()
    --end
    return self.data.lastTipTime or 0
end

function AppUpdateManager:AppHasNewVersion()
    return self.needUpdate
end

function AppUpdateManager:NeedForceUpdate()
    return self.foreceUpdate
end

function AppUpdateManager:NeedTipUpdate()
    local lastTipTime = self:GetLastTipTime()
    return os.time() - lastTipTime >= TIP_INTERVAL
end

function AppUpdateManager:GetUpdateRewardItems()
    return self.updateRewards
end

function AppUpdateManager:Storge()
    if self.data then
        local content = table.serialize(self.data)
        FileUtil.SaveWriteFile(content, string.format("%s/%s", FileUtil.GetPersistentPath(), fileName), true)
    end
end

function AppUpdateManager:LogVersionToBI()
    --if self.verionToBILog then
    --    return
    --end

    --self.verionToBILog = true

    if not self.data.lastVersion then
        self.data.lastVersion = RuntimeContext.BUNDLE_VERSION
        self:Storge()
        return
    end

    local function split_version(versionStr)
        local res = {}
        for w in string.gmatch(versionStr, "%w+") do
            table.insert(res, w)
        end
        return res
    end
    local lastVersion = split_version(self.data.lastVersion, ".")
    local newVersion = split_version(RuntimeContext.BUNDLE_VERSION, ".")
    if #lastVersion > 0 and #newVersion > 0 and #lastVersion == #newVersion and #lastVersion == 3 then
        local lastMajorVersion = tonumber(lastVersion[1])
        local newMajorVersion = tonumber(newVersion[1])
        local lastMinorVersion = tonumber(lastVersion[2])
        local newMinorVersion = tonumber(newVersion[2])
        if
            newMajorVersion > lastMajorVersion or
                (lastMajorVersion == newMajorVersion and newMinorVersion > lastMinorVersion)
         then
            DcDelegates:Log("forceUpdate_success", {version = RuntimeContext.BUNDLE_VERSION})
            self.data.lastVersion = RuntimeContext.BUNDLE_VERSION
            self:Storge()
        end
    end
end

function AppUpdateManager:CheckAppUpdate(needTip, finishCallback)
    --self:LogVersionToBI()
    self.checkFinishCallback = finishCallback
    self.needUpdate = false
    self.foreceUpdate = false
    local url = CHECEK_UPDATE_API_URL
    --local _, uid = App.loginLogic:GetLastLoginAccount()
    local _, uid = AppServices.AccountData:GetLastLoginAccount()
    if not uid then
        uid = ""
    end
    local headers = {
        uid = uid,
        platform = RuntimeContext.PLATFORM_NAME,
        appversion = RuntimeContext.BUNDLE_VERSION
    }

    local body = table.serialize(headers)
    self.lastAutoCheckTime = os.time()

    Runtime.InvokeCbk(finishCallback)

    --[[
    App.httpClient:HttpPost(
        url,
        body,
        headers,
        function(ret)
            local response = table.deserialize(ret, true)
            self.needUpdate = response.update
            self.foreceUpdate = response.BigUp
            if self.foreceUpdate then
                self:DisableAutoCheck()
            end
            self.updateRewards = self:ParseUpdateRewards(response.Rewards)
            Runtime.InvokeCbk(finishCallback)
            -- if self.needUpdate then
            --     if needTip then
            --         if self.foreceUpdate then
            --             self:OpenAppUpdatePanel()
            --         else
            --             if self:NeedTipUpdate() then
            --                 self:OpenAppUpdatePanel(finishCallback)
            --             else
            --                 Runtime.InvokeCbk(finishCallback)
            --             end
            --         end
            --     else
            --         Runtime.InvokeCbk(finishCallback)
            --     end
            -- else
            --     Runtime.InvokeCbk(finishCallback)
            -- end
        end,
        function(msg)
            self.needUpdate = false
            self.foreceUpdate = false
            Runtime.InvokeCbk(finishCallback)
        end
    )
    --]]
end

function AppUpdateManager:CheckShowUpdatePanel()
    if self.foreceUpdate then
        -- 强更
        self:OpenAppUpdatePanel()
    else
        -- 不强理，仅提示
        if self.needUpdate and self:NeedTipUpdate() then
            self:OpenAppUpdatePanel()
        end
    end
end

function AppUpdateManager:EnableAutoCheck()
    if not self.autoCheckEnabled then
        self.autoCheckTimer =
            WaitExtension.InvokeRepeating(
            function()
                self:CheckAppUpdate(false)
            end,
            0,
            AUTO_CHECK_INTERVAL
        )
        self.autoCheckEnabled = true
    end
end

function AppUpdateManager:DisableAutoCheck()
    if self.autoCheckEnabled then
        if self.autoCheckTimer then
            WaitExtension.CancelTimeout(self.autoCheckTimer)
            self.autoCheckTimer = nil
        end
        self.autoCheckEnabled = false
    end
end

function AppUpdateManager:OpenAppUpdatePanel(finishCallback)
    PanelManager.showPanel(GlobalPanelEnum.AppUpdatePanel, {
            forceUpdate = self.foreceUpdate,
            finishCallback = finishCallback,
            rewards = self.updateRewards
        }
    )
end

function AppUpdateManager:ParseUpdateRewards(origin)
    local result = {}
    if origin then
        local itemStrList = string.split(origin, ";")
        for _, v in ipairs(itemStrList) do
            local itemStr = string.split(v, ",")
            if #itemStr == 2 then
                table.insert(result, {itemId = itemStr[1], count = tonumber(itemStr[2])})
            end
        end
    end
    return result
end

function AppUpdateManager:CheckAppUpdateReward(finishCallback)
    if self.availableRewards ~= nil and #self.availableRewards > 0 then
        PanelManager.showPanel(GlobalPanelEnum.AppUpdateRewardPanel,
            {rewards = self.availableRewards, finishCallback = finishCallback}
        )
    else
        Runtime.InvokeCbk(finishCallback)
    end
    self.availableRewards = nil
end

function AppUpdateManager:RequsetAppUpdateRewardInfo(finishCallback)
    local function onSuccess(rewardInfo)
        local rewards = self:ParseUpdateRewards(rewardInfo.versionInfo)
        self.availableRewards = rewards
        Runtime.InvokeCbk(finishCallback)
    end

    local function onFail(errorCode)
        self.availableRewards = nil
        Runtime.InvokeCbk(finishCallback)
    end
    if App.loginLogic:IsLoggedIn() then
        Net.Coremodulemsg_1011_VersionRewardsInfo_Request({}, onFail, onSuccess)
    else
        Runtime.InvokeCbk(finishCallback)
    end
end

function AppUpdateManager:GetAvailableRewards()
    return self.availableRewards
end

function AppUpdateManager:GetAppUdpateReward(onSuccessCallback, onFailCallback)
    local function onSuccess(rewardInfo)
        local rewards = self:ParseUpdateRewards(rewardInfo.versionInfo)
        for _, v in ipairs(rewards) do
            AppServices.User:AddItem(v.itemId, v.count, ItemGetMethod.system)
        end
        onSuccessCallback(rewards)
    end

    local function onFail(errorCode)
        ErrorHandler.ShowErrorPanel(errorCode)
        Runtime.InvokeCbk(onFailCallback)
    end
    Net.Coremodulemsg_1012_GetVersionRewards_Request(nil, onFail, onSuccess)
end

function AppUpdateManager:Init()
    local content = FileUtil.ReadFromFile(string.format("%s/%s", FileUtil.GetPersistentPath(), fileName), true) or {}
    self.data = table.deserialize(content) or {}
    self:LogVersionToBI()
end


function AppUpdateManager:PopupCheck()
    return self.availableRewards ~= nil and #self.availableRewards > 0
 end

 function AppUpdateManager:PopupDo(finishCallback)
     PanelManager.showPanel(GlobalPanelEnum.AppUpdateRewardPanel,
         {rewards = self.availableRewards, finishCallback = finishCallback}
     )
 end

 function AppUpdateManager:PopupExit()
     self.availableRewards = nil
 end

AppUpdateManager:Init()
