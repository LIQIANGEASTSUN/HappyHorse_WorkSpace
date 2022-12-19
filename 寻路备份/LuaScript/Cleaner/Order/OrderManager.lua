---@class OrderManager 通用订单管理器
local OrderManager = {}

function OrderManager:Init()

end

function OrderManager:GetOrderConfig(sn)
    local cfgs = self._configs
    if not cfgs then
        cfgs = {}
        local tmp = AppServices.Meta:Category("OrderTemplate")
        for _, cfg in pairs(tmp) do
            cfgs[cfg.sn] = cfg
        end
        self._configs = {}
    end
    return cfgs[sn]
end

function OrderManager:GetItemsByOrderLevel(orderLv)
    local cfgs = self._itemsByOrderLvs
    if not cfgs then
        cfgs = {}
        local tmp = AppServices.Meta:GetAllItemMeta()
        for _, itemCfg in pairs(tmp) do
            local ol = itemCfg.orderLevel or 0
            if ol > 0 then
                cfgs[ol] = cfgs[ol] or {}
                table.insert(cfgs[ol], itemCfg)
            end
        end
        self._itemsByOrderLvs = cfgs
    end
    return cfgs[orderLv]
end

---生成订单的道具数量
function OrderManager:GetTaskItemNum(threeItem)
    local genNumWeight = {}
    for i, v in ipairs(threeItem) do
        if v[1] > 0 then
            genNumWeight[i] = v[1]
        else
            break
        end
    end
    local taskItemNum = math.weight(genNumWeight)
    return taskItemNum
end

---生成订单消耗的道具
function OrderManager:GenCostItems(sn)
    console.lzl("Order_LOG 生成订单消耗道具", sn) --@DEL
    local cfg = self:GetOrderConfig(sn)
    if not cfg then
        return
    end
    local costs = {}
    ---待筛选道具
    local items = {}

    ---获取所有所需订单等级的道具配置
    for _, orderLv in ipairs(cfg.orderLevel) do
        local tmp = self:GetItemsByOrderLevel(orderLv)
        table.join(items, tmp)
    end
    table.shuffle(items) --打乱顺序
    local valueTime = cfg.totalValueTime
    local itemNum = self:GetTaskItemNum(cfg.threeItem)
    local firstItemWeight = cfg.threeItem[itemNum][2]
    ---每个道具的时间表
    local valueTimeTbs = self.GenValueTimes(valueTime, itemNum, firstItemWeight)

    for idx = 1, itemNum do
        local useTime = valueTimeTbs[idx]
        local retItem
        retItem, items = self:_getItemNormal(idx, useTime, items)
        if retItem then --最终结果
            table.insert(costs, retItem)
        end
    end
    return costs
end

---根据价值时间随机道具并计算数量
function OrderManager:_getItemNormal(itemIdx, valueTime, items)
    local idx = math.random(#items)
    local item = table.remove(items, idx)
    local count = math.max(1, math.floor(valueTime / item.valueTime))
    return { key = item.sn, value = count }, items
end

---给总价值时间分组
function OrderManager.GenValueTimes(valueTime, GenOrderNum, firstItemWeight)
    local tb = {
        [1] = math.ceil(valueTime * firstItemWeight)
    }
    if GenOrderNum == 1 then
        return tb
    end
    if GenOrderNum == 2 then
        tb[2] = valueTime - tb[1]
        return tb
    end
    local lastTime = valueTime - tb[1]
    local r = 10 - (firstItemWeight * 10)
    tb[2] = math.ceil(math.random(r - 1) / 10 * lastTime)
    tb[3] = math.max(1, lastTime - tb[2])
    table.sort(tb, table.DESC)
    return tb
end

function OrderManager:GetRandomProduction(sn, level)
    if not self._productsByLevel then
        self._productsByLevel = {}
    end
    local cfgs = self._productsByLevel[sn]
    if not cfgs then
        cfgs = {}
        local tmps = {}
        local allCfgs = AppServices.Meta:Category("BuildingLevelTemplate")
        for _, cfg in pairs(allCfgs) do
            if cfg.building == sn then
                table.insert(tmps, {level = cfg.level, productionRandom = cfg.productionRandom})
            end
        end
        table.sort(tmps, table.asc('level'))
        cfgs[1] = table.join({}, tmps[1].productionRandom)
        for i = 2, #tmps do
            local lv = tmps[i].level
            cfgs[lv] = table.join({}, cfgs[lv-1])
            cfgs[lv] = table.join(cfgs[lv], tmps[i].productionRandom)
        end
        self._productsByLevel[sn] = cfgs
    end
    return cfgs[level]
end

---根据building sn 和 level 生成订单奖励
function OrderManager:GenRewardsBySnLv(buildingSn, level)
    local cfg = AppServices.BuildingLevelTemplateTool:GetConfig(buildingSn, level)
    return self:GenRewards(cfg)
end

---根据BuildingLevelTemplate生成订单奖励
function OrderManager:GenRewardsByBuildingLvCfg(buildingLvCfg)
    local rewards
    if not table.isEmpty(buildingLvCfg.production) then
        rewards = {}
        for _, item in ipairs(buildingLvCfg.production) do
            table.insert(rewards, { key = item[1], value = item[2]})
        end
        return rewards
    end
    if not table.isEmpty(buildingLvCfg.productionRandom) then
        local productionRandom = self:GetRandomProduction(buildingLvCfg.building, buildingLvCfg.level)
        rewards = {}
        local ratetb = {}
        for _, item in ipairs(productionRandom) do
            table.insert(ratetb, item[3])
        end
        local idx = math.weight(ratetb)
        local item = productionRandom[idx]
        rewards = { { key = item[1], value = item[2]} }
        return rewards
    end

    return rewards
end
OrderManager:Init()
return OrderManager