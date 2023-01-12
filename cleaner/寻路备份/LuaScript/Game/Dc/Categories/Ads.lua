---@class Ads
local AdsDc = {}
local group = AppServices.User:GetUserGroup()

local function AdsLog(typeName,param)
    param.group = group
    param.energy = AppServices.User:GetItemAmount(ItemId.ENERGY)
    param.diamondCount = AppServices.User:GetItemAmount(ItemId.DIAMOND)
    param.goldCount = AppServices.User:GetItemAmount(ItemId.COIN)
    DcDelegates:Log(typeName,param)
end

--需要开发打的打点
function AdsDc:LogWinShow(adsType)
    AdsLog(SDK_EVENT.video_ads_show_win,{enterid = adsType})
end

function AdsDc:LogEntryShow(adsType)
    AdsLog(SDK_EVENT.video_ads_entershow,{enterid = adsType})
end

function AdsDc:LogEntryClick(adsType)
    AdsLog(SDK_EVENT.video_ads_enterclick,{enterid = adsType})
end

--内置默认点
function AdsDc:LogAdsShow(adsType,forAdInfo,ecpm)
    AdsLog(SDK_EVENT.video_ads_show,
    {
        enterid = adsType,
        adid = forAdInfo.platformId,
        adplatform = forAdInfo.platformDesc,
        positionId = forAdInfo.positionId,
        ecpm = ecpm,
    })
end

function AdsDc:LogAdsResult(forAdInfo, result, playtimes, ecpm, adsType)
    AdsLog(SDK_EVENT.video_ads_result,
    {
        enterid = adsType,
        adid = forAdInfo.platformId,
        adplatform = forAdInfo.platformDesc,
        positionId = forAdInfo.positionId,
        ecpm = ecpm,
        result = result,
        playtimes = playtimes,
    })
end

--[[
function AdsDc:GetDcRewardInfo(reward)
    local info = {itemId = "0", type = "0", count = 0}
    if reward and #reward > 0 then
        info.itemId = reward[1].itemId
        info.type = DcDelegates.Legacy:GetDcItemType(reward[1].itemId)
        info.count = reward[1].num
    end
    return info
end

function AdsDc:LogEntryShow(adsType, reward, if_ads_ok)
    -- local rewardInfo = self:GetDcRewardInfo(reward)
    DcDelegates:Log(
        SDK_EVENT.video_ads_entershow,
        {
            energy = AppServices.User:GetItemAmount(ItemId.ENERGY),
            diamondCount = AppServices.User:GetItemAmount(ItemId.DIAMOND),
            goldCount = AppServices.User:GetItemAmount(ItemId.COIN),
            -- itemId = rewardInfo.itemId,
            -- type = rewardInfo.type,
            -- count = rewardInfo.count,
            enterid = adsType,
            if_ads_ok = if_ads_ok
        }
    )
end

function AdsDc:LogWinShow(adsType, reward)
    -- local rewardInfo = self:GetDcRewardInfo(reward)
    DcDelegates:Log(
        SDK_EVENT.video_ads_show_win,
        {
            energy = AppServices.User:GetItemAmount(ItemId.ENERGY),
            diamondCount = AppServices.User:GetItemAmount(ItemId.DIAMOND),
            goldCount = AppServices.User:GetItemAmount(ItemId.COIN),
            -- itemId = rewardInfo.itemId,
            -- type = rewardInfo.type,
            -- count = rewardInfo.count,
            enterid = adsType
        }
    )
end

function AdsDc:LogWinClose(adsType, reward)
    -- local rewardInfo = self:GetDcRewardInfo(reward)
    DcDelegates:Log(
        SDK_EVENT.video_ads_close_win,
        {
            energy = AppServices.User:GetItemAmount(ItemId.ENERGY),
            diamondCount = AppServices.User:GetItemAmount(ItemId.DIAMOND),
            goldCount = AppServices.User:GetItemAmount(ItemId.COIN),
            -- itemId = rewardInfo.itemId,
            -- type = rewardInfo.type,
            -- count = rewardInfo.count,
            enterid = adsType
        }
    )
end

function AdsDc:LogEntryClick(adsType, reward)
    -- local rewardInfo = self:GetDcRewardInfo(reward)
    DcDelegates:Log(
        SDK_EVENT.video_ads_enterclick,
        {
            energy = AppServices.User:GetItemAmount(ItemId.ENERGY),
            diamondCount = AppServices.User:GetItemAmount(ItemId.DIAMOND),
            goldCount = AppServices.User:GetItemAmount(ItemId.COIN),
            -- itemId = rewardInfo.itemId,
            -- type = rewardInfo.type,
            -- count = rewardInfo.count,
            enterid = adsType
        }
    )
end

function AdsDc:LogAdsShow(forAdInfo, ecpm, adsType, reward)
    --local rewardInfo = self:GetDcRewardInfo(reward)
    DcDelegates:Log(
        SDK_EVENT.video_ads_show,
        {
            adid = forAdInfo.platformId,
            adplatform = forAdInfo.platformDesc,
            positionId = forAdInfo.positionId,
            energy = AppServices.User:GetItemAmount(ItemId.ENERGY),
            diamondCount = AppServices.User:GetItemAmount(ItemId.DIAMOND),
            goldCount = AppServices.User:GetItemAmount(ItemId.COIN),
            --itemId = rewardInfo.itemId,
            --type = rewardInfo.type,
            --count = rewardInfo.count,
            ecpm = ecpm,
            enterid = adsType
        }
    )
end

function AdsDc:LogAdsConfirm(operation, adsType, reward)
    -- local rewardInfo = self:GetDcRewardInfo(reward)
    DcDelegates:Log(
        SDK_EVENT.video_ads_confirm,
        {
            operation = operation,
            energy = AppServices.User:GetItemAmount(ItemId.ENERGY),
            diamondCount = AppServices.User:GetItemAmount(ItemId.DIAMOND),
            goldCount = AppServices.User:GetItemAmount(ItemId.COIN),
            -- itemId = rewardInfo.itemId,
            -- type = rewardInfo.type,
            -- count = rewardInfo.count,
            enterid = adsType
        }
    )
end

function AdsDc:LogAdsResult(forAdInfo, result, playtimes, ecpm, adsType, reward)
    --local rewardInfo = self:GetDcRewardInfo(reward)
    DcDelegates:Log(
        SDK_EVENT.video_ads_result,
        {
            result = result,
            playtimes = playtimes,
            adid = forAdInfo.platformId,
            adplatform = forAdInfo.platformDesc,
            positionId = forAdInfo.positionId,
            energy = AppServices.User:GetItemAmount(ItemId.ENERGY),
            diamondCount = AppServices.User:GetItemAmount(ItemId.DIAMOND),
            goldCount = AppServices.User:GetItemAmount(ItemId.COIN),
            --itemId = rewardInfo.itemId,
            --type = rewardInfo.type,
            --count = rewardInfo.count,
            ecpm = ecpm,
            enterid = adsType
        }
    )
end

function AdsDc:LogAdsLoaded(forAdInfo)
    DcDelegates:Log(
        SDK_EVENT.video_ads_loading,
        {
            adid = forAdInfo.platformId,
            adplatform = forAdInfo.platformDesc,
            positionId = forAdInfo.positionId,
            energy = AppServices.User:GetItemAmount(ItemId.ENERGY),
            diamondCount = AppServices.User:GetItemAmount(ItemId.DIAMOND),
            goldCount = AppServices.User:GetItemAmount(ItemId.COIN)
        }
    )
end

function AdsDc:LogWebScreenAds(forAdInfo, enterid, step, ecpm, playtimes)
    DcDelegates:Log(
        "web_screen_ads",
        {
            ads_id = forAdInfo.platformId,
            adplatform = forAdInfo.platformDesc,
            scene_name = "maincity",
            positioinId = forAdInfo.positionId,
            enterid = enterid,
            step = step,
            ecpm = ecpm,
            playtimes = playtimes
        }
    )
end
]]
return AdsDc
