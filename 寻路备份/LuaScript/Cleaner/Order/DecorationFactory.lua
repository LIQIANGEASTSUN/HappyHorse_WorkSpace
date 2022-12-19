---@class DecorationFactory 装饰品工厂
local DecorationFactory = class(nil, "DecorationFactory")
function DecorationFactory:ctor()
    self._productsByLevel = {}
    ---@type DProduction
    self.production = nil
    self:RegisterEvent()
end

function DecorationFactory:SetId(id)
    self.id = id
end

function DecorationFactory:GetId()
    return self.id
end

function DecorationFactory:GetLevel()
    local agent = App.scene.objectManager:GetAgent(self:GetId())
    return agent and agent:GetLevel() or 1
end

function DecorationFactory:GetMaxLevel()
    if not self._maxLevel then
        local sn = self:GetSn()
        local cfgs = AppServices.Meta:Category("BuildingLevelTemplate")
        for _, cfg in pairs(cfgs) do
            if cfg.building == sn then
                self._maxLevel = math.max(self._maxLevel or 0, cfg.level)
            end
        end
    end
    return self._maxLevel
end

function DecorationFactory:GetSn()
    local agent = App.scene.objectManager:GetAgent(self:GetId())
    return agent and agent:GetTemplateId()
end

function DecorationFactory:GetConfig(sn)
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

function DecorationFactory:GetAllProducts()
    if not self._allProducts then
        local all = {}
        local tmp = {}
        local cfgs = AppServices.Meta:Category("BuildingLevelTemplate")
        local sn = self:GetSn()
        for _, cfg in pairs(cfgs) do
            if cfg.building == sn then
                for _, item in ipairs(cfg.productionRandom) do
                    local id = item[1]
                    if not tmp[id] then
                        tmp[id] = true
                        table.insert(all, id)
                    end
                end
            end
        end
        self._allProducts = all
    end
    return self._allProducts
end

function DecorationFactory:GetCanProducts()
    local sn = self:GetSn()
    local level = self:GetLevel()
    return AppServices.OrderManager:GetRandomProduction(sn, level)
end

function DecorationFactory:GetLvupUnlocks(lv)
    local lvupUnlocks = self._lvupUnlocks
    if not lvupUnlocks then
        lvupUnlocks = {}
        local cfgs = AppServices.Meta:Category("BuildingLevelTemplate")
        local sn = self:GetSn()
        local tmps = {}
        for _, cfg in pairs(cfgs) do
            if cfg.building == sn then
                tmps[cfg.level] = {}
                for _, item in ipairs(cfg.productionRandom) do
                    tmps[cfg.level][item[1]] = true
                end
            end
        end
        for i = #tmps, 2, -1 do
            lvupUnlocks[i] = {}
            for itemId in pairs(tmps[i]) do
                if not tmps[i-1][itemId] then
                    table.insert(lvupUnlocks[i], itemId)
                end
            end
        end
        self._lvupUnlocks = lvupUnlocks
    end
    return lvupUnlocks[lv]
end

function DecorationFactory:InitWithResponse(id, production)
    self:SetId(id)
    if not table.isEmpty(production) then
        self:SetProduction(production)
    end
end

---@return DProduction
function DecorationFactory:GetProduction()
    return self.production
end

function DecorationFactory:AddProduction()
    local order = self:GetOrder()
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
    self:SetProduction(production)
end

function DecorationFactory:SetProduction(production)
    self.production = production
end

function DecorationFactory:ShowPanel()
    local production = self:GetProduction()
    if production then
        self:showPanelEx()
        return
    end
    self:RequestOrder(true)
end

---@private
function DecorationFactory:showPanelEx()
    PanelManager.showPanel(GlobalPanelEnum.DecorationFactoryPanel, {agentId = self:GetId()})
end

---生成一个订单
function DecorationFactory:GenerateOrder()
    local orderMgr = AppServices.OrderManager
    local level = self:GetLevel()
    local sn = self:GetSn()
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

function DecorationFactory:SetOrder(order)
    self.order = order
end

function DecorationFactory:GetOrder()
    return self.order
end

function DecorationFactory:RequestOrder(isShowPanel)
    local order = self:GenerateOrder()
    local msg = {
        id = self:GetId(),
        costs = order.costs,
        rewards = order.rewards,
    }
    if isShowPanel then
        self:setNeedShowPanel(true)
    end
    self:SetOrder(order)
    AppServices.NetDecorationFactoryManager:RequestOrder(msg)
end

function DecorationFactory:Product()
    local production = self:GetProduction()
    for _, v in ipairs(production.recipe) do
        local itemId = v.key
        local need = v.value
        local have = AppServices.User:GetItemAmount(itemId)
        if have < need then
            return
        end
    end
    for _, v in ipairs(production.recipe) do
        local itemId = v.key
        local need = v.value
        AppServices.User:UseItem(itemId, need)
    end
    local msg = {
        id = self:GetId()
    }
    local production = self:GetProduction()
    local st = TimeUtil.ServerTime()
    production.startTime = st
    local buildingLvCfg = AppServices.BuildingLevelTemplateTool:GetConfig(self:GetSn(), self:GetLevel())
    local cd = buildingLvCfg.time
    production.endTime = st + cd
    AppServices.User:SetProduction(production)
    AppServices.NetDecorationFactoryManager:Product(msg)
end

---生成订单网络回调
function DecorationFactory:OnDecorateOrderResponse(msg)
    local order = self:GetOrder()
    if not order then
        return
    end
    if msg.id == order.id then
        self:AddProduction()
    end
    if self:needShowPanel() then
        self:showPanelEx()
    end
end

---开始生产网络回调
function DecorationFactory:OnStartProductionOrder(msg)
    if msg.id == self:GetId() then
        local agent = App.scene.objectManager:GetAgent(self:GetId())
        if agent then
            local factoryUnit = agent:GetFactoryUnit()
            if factoryUnit then
                factoryUnit:StartProduction()
            end
        end
        if PanelManager.isPanelShowing(GlobalPanelEnum.DecorationFactoryPanel) then
            PanelManager.closePanel(GlobalPanelEnum.DecorationFactoryPanel)
        end
    end
end

function DecorationFactory:OnBuildingUpLevel(id, level)
    if self:GetId() ~= id then
        return
    end
    self.level = level
end

function DecorationFactory:OnBuildingTakeProduction(id)
    if id == self:GetId() then
        self:SetProduction(nil)
        self:SetOrder(nil)
    end
end

---@private
function DecorationFactory:setNeedShowPanel(isShow)
    self._needShowPanel = isShow
end
---@private
function DecorationFactory:needShowPanel()
    local needShow = self._needShowPanel
    self._needShowPanel = nil
    return needShow
end
-- 注册消息
function DecorationFactory:RegisterEvent()
    -- 注册消息
    AppServices.NetWorkManager:addObserver(MsgMap.SCDecorateOrder, self.OnDecorateOrderResponse, self)
    AppServices.NetWorkManager:addObserver(MsgMap.SCStartProductionOrder, self.OnStartProductionOrder, self)
    MessageDispatcher:AddMessageListener(MessageType.BuildingUpLevel, self.OnBuildingUpLevel, self)
    MessageDispatcher:AddMessageListener(MessageType.BuildingTakeProduction, self.OnBuildingTakeProduction, self)
end

-- 移除消息
function DecorationFactory:UnRegisterEvent()
    -- 移除消息
    AppServices.NetWorkManager:removeObserver(MsgMap.SCDecorateOrder, self.OnDecorateOrderResponse, self)
    AppServices.NetWorkManager:removeObserver(MsgMap.SCStartProductionOrder, self.OnStartProductionOrder, self)
    MessageDispatcher:RemoveMessageListener(MessageType.BuildingUpLevel, self.OnBuildingUpLevel, self)
    MessageDispatcher:RemoveMessageListener(MessageType.BuildingTakeProduction, self.OnBuildingTakeProduction, self)
end

function DecorationFactory:OnDestroy()
    self:UnRegisterEvent()
end
return DecorationFactory.new()