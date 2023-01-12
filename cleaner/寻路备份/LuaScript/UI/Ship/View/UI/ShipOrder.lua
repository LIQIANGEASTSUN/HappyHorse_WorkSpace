
---@type ShipOrder
local ShipOrder = {}

function ShipOrder:GetId()
    local id = AppServices.IslandManager:GetShipDockInfo()
    return id
end

function ShipOrder:RequestOrder()
    local id = self:GetId()
    local production = AppServices.User:GetProduction(id)
    if production then
        return production
    end

    local order = self:GenerateOrder()
    local msg = {
        id = self:GetId(),
        costs = order.costs,
        rewards = order.rewards,
    }
    AppServices.NetOrderManager:SendOrder(msg)
    return self:AddProduction(order)
end

function ShipOrder:AddProduction(order)
    ---@type DProduction
    local production = {
        id = order.id,
        level = order.level,
        recipe = order.costs,
        outItem = order.rewards,
        startTime = 0,
        endTime = 0,
    }
    AppServices.User:SetProduction(production)
    return production
end

---生成一个订单
function ShipOrder:GenerateOrder()
    local orderMgr = AppServices.OrderManager
    local _, sn, level = AppServices.IslandManager:GetShipDockInfo()
    local buildingLvCfg = AppServices.BuildingLevelTemplateTool:GetConfig(sn, level)
    local costs = orderMgr:GenCostItems(buildingLvCfg.sn)
    local rewards = orderMgr:GenRewardsByBuildingLvCfg(buildingLvCfg)
    local order = {
        id = self:GetId(),
        level = level,
        costs = costs,
        rewards = rewards
    }
    return order
end

return ShipOrder