---@class ForAdSdk
local ForAdSdk = {
    delegate = CS.BetaGame.MainApplication.forAdsDelegate,
    rewardSet = false,
    isPlayingAds = false,
    playCallback = nil,
}

local ad_play_start_ts = 0

function ForAdSdk:Init()
    if not self.delegate then
        return
    end
    --默认为激励视频id，分android和ios，如果是插屏广告，需要重新设置id，在onAdLoad中完成初始化
    self.ScreenId = self.delegate.ScreenId

    --self.delegate:Regiset_onAdLoaded(function (adInfo) self:onAdLoad(adInfo) end)
    --self.delegate:Regiset_onAdFailedToLoad(function (adInfo) self:onAdFailedToLoad(adInfo) end)
    --目前不需要这个监听
    --self.delegate:Regiset_onAdClicked(function (adInfo) self:onAdClicked(adInfo) end)
    self.delegate:Regiset_onAdClosed(function(adInfo) self:onAdClosed(adInfo) end)
    --self.delegate:Regiset_onAdDisplayed(function (adInfo) self:onAdDisplayed(adInfo) end)
    self.delegate:Regiset_onAdFailedToDisplay(function (adInfo) self:onAdFailedToDisplay(adInfo) end)
    self.delegate:Regiset_onUserEarnedReward(function (rewardInfo) self:onUserEarnedReward(rewardInfo) end)

    if RuntimeContext.VERSION_DEVELOPMENT then
        self.delegate:setLogPrintEnable(true)
    end
end

---预加载后开始解析广告类型，（插屏，激励以及高价值激励）
function ForAdSdk:onAdLoad(adInfo)
    console.lj("！！Lua：预加载回调成功")--@DEL
    --DcDelegates.Ads:LogAdsLoaded(adInfo)
end

--[[
function ForAdSdk:onAdClicked(adInfo)
end
]]

function ForAdSdk:onAdClosed(adInfo)
    self.isPlayingAds = false
    -- 延迟2秒检查，如果有激励回调就是看完了
    -- sdk在onClose之后调用激励回调
    WaitExtension.SetTimeout(function()
        if not RuntimeContext.UNITY_EDITOR then
            local type = self.rewardSet and 1 or 2
            DcDelegates.Ads:LogAdsResult(adInfo, type, os.time() - ad_play_start_ts, self:GetEcpm(), self.currentAdsId, self.currentReward)
        end

        Runtime.InvokeCbk(self.playCallback, self.rewardSet)
        Util.BlockAll(0.5, "playAds")
        App:SetPauseAlive(true)
        self.rewardSet = false
        self.playCallback = nil
    end, 0.5)
    Util.BlockAll(-1, "playAds")
    console.lj("！！Lua：关闭了广告","广告类型："..self.currentAdsId) --@DEL
    App.audioManager:SetMusicEnable(self.musicOn)
end

--- 播放成功
function ForAdSdk:onAdDisplayed(adInfo)
    console.lj("！！Lua：播放广告成功","广告类型："..self.currentAdsId) --@DEL
    --[[
    --初始化奖励参数和时间记录，
    --self.rewardSet = false
    ad_play_start_ts = os.time()
    --记录当前音乐状态，屏蔽音乐
    self.musicOn = App.audioManager:IsMusicEnable()
    App.audioManager:SetMusicEnable(false)

    DcDelegates.Ads:LogAdsShow(self.currentAdsId,adInfo, self:GetEcpm())
    ]]
end

--- 播放失败
function ForAdSdk:onAdFailedToDisplay(adInfo)
    console.lj("！！Lua：播放广告失败","广告类型："..self.currentAdsId) --@DEL

    self.isPlayingAds = false
    self.rewardSet = false
    DcDelegates.Ads:LogAdsResult(adInfo, 3, 0, self:GetEcpm(), self.currentAdsId, self.currentReward)
    Runtime.InvokeCbk(self.playCallback, self.rewardSet)
    self.playCallback = nil
    App:SetPauseAlive(true)
    App.audioManager:SetMusicEnable(self.musicOn)
end

--- 已触发激励奖励
function ForAdSdk:onUserEarnedReward(rewardInfo)
    console.lj("！！Lua：获得了广告奖励","广告类型："..self.currentAdsId) --@DEL
    --标记奖励，并缓存奖励
    self.rewardSet = true
    --AppServices.AdsManager:SetReward(self.currentAdsId, self.currentReward)
end

function ForAdSdk:onAdFailedToLoad(adInfo)
    console.lj("！！Lua：预加载回调失败") --@DEL
end

function ForAdSdk:PreLoadAd()
end

--- 展示广告
function ForAdSdk:DisplayScreenAd(adsId, reward, callback)
    if not self.delegate then
        return
    end

    self.isPlayingAds = true
    self.currentAdsId = adsId
    self.currentReward = reward
    self.playCallback = callback
    self.rewardSet = false
    --Util.BlockAll(-1, "playAds")
    self.delegate:DisplayAd(self.ScreenId)

    ad_play_start_ts = os.time()
    self.musicOn = App.audioManager:IsMusicEnable()
    App.audioManager:SetMusicEnable(false)
end

--[[目前没这功能
--@ Position:"TOP","BOTTOM"
--@ Size:"BANNER_50/90/250"
function ForAdSdk:DisplayBannerAd()
    if self.delegate then
        self.delegate:DisplayBanner(self.delegate.BannerId,"BOTTOM","BANNER_50")
    end
end
]]

function ForAdSdk:IsScreenAdCached()
    if RuntimeContext.UNITY_EDITOR then
        return true
    end
    if not self.delegate then
        return false
    end

    local isCache = self.delegate:IsCached(self.ScreenId) or false
    console.lj("广告是否有缓存：", isCache,self.ScreenId) --@DEL
    return isCache
end

function ForAdSdk:SendUserTag(tags)
    console.lj("上传sdk广告位：",tags) --@DEL
    if self.delegate then
        self.delegate:setUserTags(tags)
    end
end

function ForAdSdk:ShowTestView()
    if self.delegate then
        self.delegate:showTestAdView()
    end
end

function ForAdSdk:GetEcpm()
    return self.delegate:GetEcpm(self.ScreenId)
end

ForAdSdk:Init()
return ForAdSdk
