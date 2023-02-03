---@type FactoryProductionCheck
local FactoryProductionCheck = require "Cleaner.Factory.FactoryProductionCheck"

local AgentCommonUnit = require "Cleaner.Unit.AgentCommonUnit"

---@type FoodFactoryUnit
local FoodFactoryUnit = class(AgentCommonUnit, "FoodFactoryUnit")

function FoodFactoryUnit:ctor(agent)
    self:SetUnitType(UnitType.FoodFactoryUnit)
    self.currentStatus = ProductionStatus.None
    self.productionCheck = FactoryProductionCheck.new(self.id, function(status)
        self:StatusHandle(status)
    end)

    self.productionData = nil
    self:RegisgerEvent()
end

function FoodFactoryUnit:FactoryClick(callback)
    local status = self:Click()
    if status == ProductionStatus.Doing or status ==  ProductionStatus.Finish then
        return
    end
    self:ClickMoveCameraFinish()
    -- local position = self.agent:GetWorldPosition()
    -- MoveCameraLogic.Instance():MoveCameraToLook2(position, 1, 0, function()
    --     if callback then
    --         callback()
    --     else
    --         self:ClickMoveCameraFinish()
    --     end
    -- end)
end

-- 点击了 Tips
function FoodFactoryUnit:UnitTipsClick(unitId, tipsType)
    if self.instanceId ~= unitId then
        return
    end

    self:Click()
end

function FoodFactoryUnit:Click()
    self.productionCheck:CheckFinish()
    local data = self:GetProductionData()
    local status = AppServices.User:ProductionStatue(data)
    if status == ProductionStatus.Doing then
        local arguments = {id = self.id, sn = self.data.meta.sn}
        PanelManager.showPanel(GlobalPanelEnum.FoodFactoryPanel, arguments)
    elseif status == ProductionStatus.Finish then
        self:TakeProduction()
    end
    return status
end

function FoodFactoryUnit:ClickMoveCameraFinish()
    local arguments = {id = self.id, sn = self.data.meta.sn}
    PanelManager.showPanel(GlobalPanelEnum.FoodFactoryPanel, arguments)
end

function FoodFactoryUnit:GetProductionData()
    local data = AppServices.User:GetProduction(self.id)
    return data
end

function FoodFactoryUnit:CreateProductionData()
    local level = self.data:GetLevel()
    local sn = self.data.meta.sn
    local data = AppServices.BuildingLevelTemplateTool:CreateProductionData(self.id, level, sn)
    AppServices.User:SetProduction(data)
    return data
end

function FoodFactoryUnit:ReceiveStartProduction(agentId)
    if self.id ~= agentId then
        return
    end

    self:StartProduction()
end

-- 开始生产
function FoodFactoryUnit:StartProduction()
    local data = self:GetProductionData()
    if not data then
        data = self:CreateProductionData()
    end
    data.status = ProductionStatus.Doing
end

-- 领取产物
function FoodFactoryUnit:TakeProduction()
    self.productionData = self:GetProductionData()
    if not self.productionData then
        return
    end

    AppServices.NetBuildingManager:SendTakeProduction(self.id)
    AppServices.User:RemoveProduction(self.id)
    self:StateChangeToNone()
end

function FoodFactoryUnit:ReceiveTakeProduction(agentId)
    if self.id ~= agentId or (not self.productionData) then
        return
    end

    local initPos = self:GetAnchorPosition(true)
    for _, item in pairs(self.productionData.outItem) do
        local itemInfo = {
            itemId = item.key,
            initPos = initPos,
            sizeDelta = Vector2(80, 80),
        }

        AppServices.FlyAnimation.CreateItemWithFly(itemInfo)
    end
end

function FoodFactoryUnit:LateUpdate()
    AgentCommonUnit.LateUpdate(self)
    self.productionCheck:LateUpdate()
end

function FoodFactoryUnit:StatusHandle(status)
    if self.currentStatus and (status == self.currentStatus) then
        return
    end

    if status == ProductionStatus.None then
        self:StateChangeToNone()
    elseif status == ProductionStatus.Doing then
        self:StateChangeToDoing()
    elseif status == ProductionStatus.Finish then
        self:StateChangeToFinish()
    end
    self.currentStatus = status
end

function FoodFactoryUnit:StateChangeToNone()
    AppServices.UnitTipsManager:RemoveTipsAll(self.instanceId)
end

function FoodFactoryUnit:StateChangeToDoing()
    AppServices.UnitTipsManager:ShowTips(self.instanceId, TipsType.UnitProductDoingTips)
end

function FoodFactoryUnit:StateChangeToFinish()
    local data = self:GetProductionData()
    if not data then
        self:CreateProductionData()
    end
    AppServices.UnitTipsManager:ShowTips(self.instanceId, TipsType.UnitProductFinishTips)
end

function FoodFactoryUnit:Remove()
    AgentCommonUnit.Remove(self)
    self:UnRegisterEvent()
end

function FoodFactoryUnit:RegisgerEvent()
    MessageDispatcher:AddMessageListener(MessageType.UnitTipsClick, self.UnitTipsClick, self)
    MessageDispatcher:AddMessageListener(MessageType.ReceiveStartProduction, self.ReceiveStartProduction, self)
    MessageDispatcher:AddMessageListener(MessageType.BuildingTakeProduction, self.ReceiveTakeProduction, self)
end

function FoodFactoryUnit:UnRegisterEvent()
    MessageDispatcher:RemoveMessageListener(MessageType.UnitTipsClick, self.UnitTipsClick, self)
    MessageDispatcher:RemoveMessageListener(MessageType.ReceiveStartProduction, self.ReceiveStartProduction, self)
    MessageDispatcher:RemoveMessageListener(MessageType.BuildingTakeProduction, self.ReceiveTakeProduction, self)
end

return FoodFactoryUnit