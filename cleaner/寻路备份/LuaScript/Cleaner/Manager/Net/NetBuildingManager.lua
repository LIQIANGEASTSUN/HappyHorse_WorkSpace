-- 宠物网络消息模块
---@class NetBuildingManager
local NetBuildingManager = {}

function NetBuildingManager:Init()
    self:RegisterEvent()
end

-- 发送建筑升级
function NetBuildingManager:SendBuildLevel(id)
    local msg = { id = tostring(id) }
    AppServices.NetWorkManager:Send(MsgMap.CSLevelBuildings, msg)
end

-- 接收建筑升级
function NetBuildingManager:ReceiveBuildLevel(msg)
    local id = msg.id
    local level = msg.level

    local agent = App.scene.objectManager:GetAgent(id)
    agent:SetLevel(level)

    local arguments = {id = id, sn = agent:GetTemplateId(), level = level}
    PanelManager.showPanel(GlobalPanelEnum.BuildUpLevelPanel, arguments)
    MessageDispatcher:SendMessage(MessageType.BuildingUpLevel, id, level)
end

-- 发送生产消息
function NetBuildingManager:SendStartProduction(id)
    local msg = { id = tostring(id) }
    AppServices.NetWorkManager:Send(MsgMap.CSStartProduction, msg)
end

-- 接收生产消息
function NetBuildingManager:ReceiveStartProduction(msg)
    local id = msg.id
    local factoryUnit = self:GetFactoryUnit(id)
    if factoryUnit then
        factoryUnit:StartProduction()
    end

    AppServices.EventDispatcher:dispatchEvent(BUILDING_EVENT.START_PRODUCTION, id)
    MessageDispatcher:SendMessage(MessageType.StartProduction, id, 1)
end

function NetBuildingManager:SendTakeProduction(id)
    local msg = { id = tostring(id) }
    AppServices.NetWorkManager:Send(MsgMap.CSTakeProduction, msg)
end

function NetBuildingManager:ReceiveTakeProduction(msg)
    local id = msg.id
    local factoryUnit = self:GetFactoryUnit(id)
    if factoryUnit then
        factoryUnit:TakeProduction()
    end

    MessageDispatcher:SendMessage(MessageType.BuildingTakeProduction, id)
end

function NetBuildingManager:SendRemoveBuilding(id)
    local msg = {id = tostring(id)}
    AppServices.NetWorkManager:Send(MsgMap.CSRemoveBuildings, msg)
end

function NetBuildingManager:ReceiveRemoveBuilding(msg)
    local id = msg.id
    AppServices.User:AddRemoveBuilding(id)
    MessageDispatcher:SendMessage(MessageType.BuildingRemove, id)
end

function NetBuildingManager:GetFactoryUnit(id)
    local agent = App.scene.objectManager:GetAgent(id)
    if agent and agent.GetFactoryUnit then
        return agent:GetFactoryUnit()
    end
    return nil
end

function NetBuildingManager:RegisterEvent()
    AppServices.NetWorkManager:addObserver(MsgMap.SCLevelBuildings, self.ReceiveBuildLevel, self)
    AppServices.NetWorkManager:addObserver(MsgMap.SCStartProduction,  self.ReceiveStartProduction, self)
    AppServices.NetWorkManager:addObserver(MsgMap.SCTakeProduction, self.ReceiveTakeProduction, self)
    AppServices.NetWorkManager:addObserver(MsgMap.SCRemoveBuildings, self.ReceiveRemoveBuilding, self)
end

function NetBuildingManager:UnRegisterEvent()
    AppServices.NetWorkManager:removeObserver(MsgMap.SCLevelBuildings, self.ReceiveBuildLevel, self)
    AppServices.NetWorkManager:removeObserver(MsgMap.SCStartProduction,  self.ReceiveStartProduction, self)
    AppServices.NetWorkManager:removeObserver(MsgMap.SCTakeProduction, self.ReceiveTakeProduction, self)
    AppServices.NetWorkManager:removeObserver(MsgMap.SCRemoveBuildings, self.ReceiveRemoveBuilding, self)
end

function NetBuildingManager:Release()
    self:UnRegisterEvent()
end

return NetBuildingManager