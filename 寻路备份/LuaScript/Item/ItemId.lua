local TYPE_GIFT_PACK = 3
local TYPE_ENERGY_BUFF = 19999 --- 精力buff(限时无限精力)

ItemId = {
    ---@class ItemType
    EType = {
        MONEY = 1,
        AGENT = 2,
        FACTORY = 3,
        TASK = 4,
        DRAGON = 5,
        DRAGON_ENTITY = 14,
        FARM_ITEM = 18,
        BUFF = 20,
        BuildingRepairReward = 21,
        Skin = 27,
    },
    EXP = "1000",
    COIN = "1002",
    DIAMOND = "1001",
    ENERGY = "1003",
    CHIP = "1004", -- 万能碎片
    BOMB = "11001",
    TOPLEVEL = "100067",
    DRAGONBREED = "2100", -- 龙源石  繁育用的
    TimeOrderTicket = "25000", ---航海订单的票
    PhysicalStrengthRecovery = "30000",    ---龙之力加速恢复道具
    MapReopen = "33000",             --支线地图重启券
    ExploitScore = "37001",
    ParkourScore = "39001",
    Buff2Drop = "20004",
    Buff2Collect = "20003",
    BuffDoubleParkourScore = "20005",
    FactorySpeedUp = "42000",   --工厂加速道具
    DawnGem = "44001", --曙光宝石，买帽子
    GoldPanningShovel = "6000", --淘金活动挖掘道具-铲子
    MowScore = "39003",
    BuffDoubleMowScore = "20009",   --割草双倍buff
    MowTime = "39006", --割草加时道具。
}

local itemFlags = {}

function ItemId.GetWidgetType(itemId)
    local item = AppServices.Meta:GetItemMeta(itemId)
    if item then
        return item.widgetType
    end
end

function ItemId.GetWidget(itemId, eVal)
    return App.scene:GetWidget(ItemId.GetWidgetType(itemId), eVal)
end

function ItemId.IsExp(value)
    return tostring(value) == ItemId.EXP
end

function ItemId.IsCoin(value)
    return tostring(value) == ItemId.COIN
end

function ItemId.IsDiamond(value)
    return tostring(value) == ItemId.DIAMOND
end

function ItemId.IsChip(value)
    return tostring(value) == ItemId.CHIP
end

function ItemId.IsEnergy(value)
    return tostring(value) == ItemId.ENERGY
end

function ItemId.IsEnergyBuff(itemId)
    return AppServices.Meta:GetItemType(itemId) == TYPE_ENERGY_BUFF
end

function ItemId.IsBuff(itemId)
    return AppServices.Meta:GetItemType(itemId) == ItemId.EType.BUFF
end

function ItemId.IsGift(itemId)
    return AppServices.Meta:GetItemType(itemId) == TYPE_GIFT_PACK
end

function ItemId.IsTimeLimit(itemId)
    local itemMeta = AppServices.Meta:GetItemMeta(itemId)
    if itemMeta then
        return itemMeta.limittime > 0
    end
    return false
end

function ItemId.IsTimeLimit2(itemId)
    local itemMeta = AppServices.Meta:GetItemMeta(itemId)
    if itemMeta then
        return itemMeta.limittime > 0 and not ItemId.IsEnergy(itemId) and not ItemId.IsEnergyBuff(itemId)
    end
    return false
end

function ItemId.IsDragonSkinDesign(itemId)
    if not itemId then
        return false
    end
    local funcType = AppServices.Meta:GetItemFuncType(itemId)
    if funcType == 23 then
        return true
    end
    return false
end

function ItemId.IsDragonSkin(itemId)
    if not itemId then
        return false
    end
    local itmType = AppServices.Meta:GetItemType(itemId)
    if itmType == PropsType.dragonSkin then
        return true
    end
    return false
end

function ItemId.IsDragonKey(itemId)
    if not itemId then return false end
    local itmType = AppServices.Meta:GetItemType(itemId)
    if itmType == PropsType.dragonKey then
        return true
    end
    return false
end

--大于1消失
function ItemId.IsTimeLimitOver60(itemId)
    local itemMeta = AppServices.Meta:GetItemMeta(itemId)
    if itemMeta then
        return itemMeta.limittime > 3600 and ItemId.IsEnergyBuff(itemId)
    end
    return false
end

function ItemId.SetNewFlag(itemId, value)
    if value == true then
        itemFlags[itemId] = value
    else
        itemFlags[itemId] = nil
    end
    AppServices.User.Default:SetKeyValue("item.new_items", itemFlags, true)
end

function ItemId.InitNewFlag(flag, flush)
    itemFlags = flag
    if flush then
        AppServices.User.Default:SetKeyValue("item.new_items", itemFlags, true)
    end
end

function ItemId.IsNewItem(itemId)
    return itemFlags[itemId] == true
end

function ItemId.GetEnergyBuffTimeText(itemId)
    local itemConfig = AppServices.Meta:GetItemMeta(itemId)
    local hour = TimeUtil.SecondsToHour(itemConfig.limittime)
    local text = tostring(hour) .. "h"
    return text
end

function ItemId.IsDragon(itemId)
    return AppServices.Meta:GetItemType(itemId) == ItemId.EType.DRAGON_ENTITY
end

function ItemId.IsDragonProduct(itemId)
    local cfg = AppServices.Meta:GetItemMeta(itemId)
    return not string.isEmpty(cfg.dragonId) and cfg.dragonId ~= '0'
end

function ItemId.IsSkin(itemId)
    return AppServices.Meta:GetItemType(itemId) == ItemId.EType.Skin
end

---是否是折扣道具
function ItemId.IsDiscountProp(itemId)
    if itemId then
        local tp = AppServices.Meta:GetItemType(itemId)
        if tp == PropsType.energyBuff then
            return true
        end
    end
    return false
end

function ItemId.GetEffectiveCount(itemId, count)
    local funcType = AppServices.Meta:GetItemFuncType(itemId)
    -- 直接加体力
    if funcType == 1 then
        local funcParam = AppServices.Meta:GetItemFuncParam(itemId)
        return funcParam * count
    end
    return count
end

function ItemId.GetBuffType(itemId)
    local buffTemplateId = AppServices.Meta:GetItemFuncParam(itemId)
    if not buffTemplateId then
        return
    end
    local buffCfg = AppServices.Meta:GetBuffMeta(tostring(buffTemplateId))
    return buffCfg and buffCfg.type
end