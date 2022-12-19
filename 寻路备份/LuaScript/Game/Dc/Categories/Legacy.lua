
---@class DcUtils
local DcUtils = setmetatable({}, {
    __index = function()
        return function() end
    end
    })

function DcUtils:LogEvent(event, params)
    DcDelegates:Log(event, params or {})
end

function DcUtils:GetDcItemType(itemId)
    local type
    if ItemId.IsDiamond(itemId) then
        type = DcItemType.Diamond
    elseif ItemId.IsCoin(itemId) then
        type = DcItemType.Coin
    elseif ItemId.IsEnergy(itemId) or ItemId.IsEnergyBuff(itemId) then
        type = DcItemType.Energy
    elseif itemId == "cash" then
        type = DcItemType.cash
    end
    return type
end

function DcUtils:LogAcquisition(item, source)
    console.assert(type(item) == "table") --@DEL

    DcDelegates:Log(SDK_EVENT.ItemAcquisition, {
            itemId = item.itemId,
            count = item.num,
            source = source,
            total = DcUtils:GetTotalItemCount(item.itemId) or 0,
            type = DcUtils:GetDcItemType(item.itemId),
        }
    )
end

function DcUtils:GetTotalItemCount(itemId)
    if ItemId.IsCoin(itemId) then
        return AppServices.User:GetItemAmount(ItemId.COIN)
    elseif ItemId.IsDiamond(itemId) then
        return AppServices.User:GetItemAmount(ItemId.DIAMOND)
    else
        if AppServices.User:IsInItemList(itemId) then
            return AppServices.User:GetItemAmount(itemId)
        end
    end
end

function DcUtils:LogConsumption(item, source)
    console.assert(type(item) == "table")
    DcDelegates:Log(SDK_EVENT.ItemConsumption, {
            itemId = item.itemId,
            count = item.num,
            source = source,
            type = DcUtils:GetDcItemType(item.itemId),
            total = DcUtils:GetTotalItemCount(item.itemId),
            os = self:GetPlatform(),
            playerId = LogicContext.UID,
            deviceId = RuntimeContext.DEVICE_ID
        }
    )
end

---obsolete will be removed later
function DcUtils:LogFirstDayLevel(levelId)
    if self:IsFirstDay() then
        DcDelegates:Log("first_day_level", {levelId = levelId})
    end
end

function DcUtils:LogIngameDiamondUse(levelId, num, source, leftCount)
    DcDelegates:Log(SDK_EVENT.UseDiamondInLevel,{count = num, levelId = levelId, source = source, leftCount = leftCount})
end

function DcUtils:IsFirstDay()
    local createTime = AppServices.User:GetCreateTime()
    local currentTime = TimeUtil.ServerTime()
    return currentTime - createTime < 24 * 3600
end

function DcUtils:GetErrorCodePrettyName(errorCode)
    local ErrorCodeNames = require "System.Error.ErrorCodeNames"
    return ErrorCodeNames[errorCode] or "未配置错误名称"
end

function DcUtils:GetPropStats(extraParams)
    local ret = {}
    local includings = {
        PropType.CROSS_PROP,
        PropType.TIME_LIMIT_CROSS_PROP,
    }
    for _, v in pairs(includings) do
        ret[v] = AppServices.User:GetItemAmount(v)
    end
    ret.diamond = AppServices.User:GetItemAmount(ItemId.DIAMOND)
    for k, v in pairs(extraParams) do
        ret[k] = v
    end
    return ret
end

function DcUtils:OnPurchase(count)
    if not self.purchaseCount then
        self.purchaseCount = 0
    end
    self.purchaseCount = self.purchaseCount + count
end

function DcUtils:GetDeviceInfo()
    local infoString = DcDelegates.Bi:GetDeviceInfo()
    if string.isEmpty(infoString) then
        return {}
    end
    return table.deserialize(infoString, true)
end

function DcUtils:LogShopBuyItem(productId, paneltype)
    DcDelegates:Log(SDK_EVENT.ShopClickBuy, {
        levelId = AppServices.User:GetCurrentLevelId(),
        source = "shop",
        paneltype = paneltype,
        productId = productId
    })
end

---@param packType string @"first_time"(破冰礼包), "holiday"(活动礼包)
---@param source int @ 1 自动弹出, 2 手动点击
---@param packId string @ ProductId
function DcUtils:LogPackageShow(packType, source, remainTime, package_show_place)
    DcDelegates:Log(SDK_EVENT.LTE_PackageShow, {
        levelId = AppServices.User:GetCurrentLevelId(),
        package_type = packType,
        show_type = source,
        time_last = remainTime,
        diamondCount = AppServices.User:GetItemAmount(ItemId.DIAMOND),
        preprop1 = AppServices.User:GetItemAmount(PropType.PREGAME_AREA_PROP),
        preprop2 = AppServices.User:GetItemAmount(PropType.PREGAME_SPECIAL_TILE_DOUBLER),
        midprepro = AppServices.User:GetItemAmount(PropType.CROSS_PROP),
        energy = AppServices.User:GetItemAmount(ItemId.ENERGY),
        package_show_place = package_show_place
    })
end

---@param packType string @"first_time"(破冰礼包), "holiday"(活动礼包)
---@param source int @ 1 自动弹出, 2 手动点击
---@param packId string @ ProductId
function DcUtils:LogDiamondPackageShow(packType, source, remainTime)
    DcDelegates:Log(SDK_EVENT.LTE_DiamondPackageShow, {
        levelId = AppServices.User:GetCurrentLevelId(),
        package_type = packType,
        show_type = source,
        time_last = remainTime,
        diamondCount = AppServices.User:GetItemAmount(ItemId.DIAMOND),
        preprop1 = AppServices.User:GetItemAmount(PropType.PREGAME_AREA_PROP),
        preprop2 = AppServices.User:GetItemAmount(PropType.PREGAME_SPECIAL_TILE_DOUBLER),
        midprepro = AppServices.User:GetItemAmount(PropType.CROSS_PROP),
        energy = AppServices.User:GetItemAmount(ItemId.ENERGY)
    })
end

---@param packType string @"first_time"(破冰礼包), "holiday"(活动礼包)
---@param source int @ 1 自动弹出, 2 手动点击
---@param packId string @ ProductId
function DcUtils:LogPackageClick(packType, source, packId, remainTime, packName, package_show_place)
    DcDelegates:Log(SDK_EVENT.LTE_PackageClick, {
        package_type = packType,
        show_type = source,
        package_id = packId,
        time_last = remainTime,
        diamondCount = AppServices.User:GetItemAmount(ItemId.DIAMOND),
        energy = AppServices.User:GetItemAmount(ItemId.ENERGY),
        packageName = packName,
        package_show_place = package_show_place
    })
end

function DcUtils:FinishChangeScene(info)
    if info.before and info.after and info.startTime then
        DcDelegates:Log("SceneSwitch", {
            BeforeScene = info.before,
            AfterScene = info.after,
            TimeConsume = TimeUtil.ServerTime() - info.startTime,
            levelId = AppServices.User:GetCurrentLevelId(),
        })
    end
end

function DcUtils:LogDiamondBallon(info)
    DcDelegates:Log(SDK_EVENT.DiamondBalloonEjectOrClick, {
        show_type = info.show_type,
        itemId = ItemId.DIAMOND,
        type =  DcItemType.Diamond,
        count = info.num,
        levelId = AppServices.User:GetCurrentLevelId(),
    })
end

function DcUtils:LevelTypeToDc(levelType)
    return levelType
end

local cache_Log_Icon_Show = {}
function DcUtils:Log_Icon_Show(icon_name)
    if cache_Log_Icon_Show[icon_name] then
        return
    end
    cache_Log_Icon_Show[icon_name] = true
    DcDelegates:Log("icon_show", {
            icon_name = icon_name,
            levelId = AppServices.User:GetCurrentLevelId()
        }
    )
end

function DcUtils:icon_click(icon_name)
    DcDelegates:Log("icon_click",{
            icon_name = icon_name,
            levelId = AppServices.User:GetCurrentLevelId()
        }
    )
end

--无好评弹窗；1好评；2差评；3关闭
function DcUtils:Log_web_user_eva_game(type, retryCount, scene_name)
    --[[DcDelegates:Log("web_user_eva_game", {
            type = type,
            retryCount = retryCount,
            levelId = AppServices.User:GetCurrentLevelId(),
            scene_name = scene_name
        }
    )--]]
    DcDelegates:Log(SDK_EVENT.praise_guide, {buttonName = type, num = retryCount})
end

function DcUtils:GetPlatform()
    local platform = "unity_editor"
    if RuntimeContext.UNITY_IOS then
        platform = "ios"
    elseif RuntimeContext.UNITY_ANDROID then
        platform = "android"
    end
    return platform
end

-- type 1 道具小图标展示 2 道具使用页面展示 3 点击确定按钮
function DcUtils:LogUsePropTips(type,itemId)
    local levelContext = App.scene.levelContext
    local userManager = AppServices.User
    local prop_num = 0

    local info = {
        type = type,
        playerId = userManager:GetUid(),
        levelId = levelContext.levelId,
        itemId = itemId,
        pros_id = 1,
        prop_remain_num = prop_num,
        os = self:GetPlatform(),
        deviceId = RuntimeContext.DEVICE_ID,
        version = RuntimeContext.BUNDLE_VERSION
    }
    DcDelegates:Log(SDK_EVENT.web_ingame_prop_show_click, info)
end

--page_name: 点击按钮时所处的页面名称，mono_activity 大富翁界面 home_page 游戏主界面
function DcUtils:web_mono_activity_box_click(page_name)
    DcDelegates:Log("web_mono_activity_box_click", {
        page_name = page_name,
        levelId = AppServices.User:GetCurrentLevelId(),
        zone_id = MissionManager.Instance():GetCurrentZone(),
        diamond_count = AppServices.User:GetItemAmount(ItemId.DIAMOND),
    })
end

return DcUtils