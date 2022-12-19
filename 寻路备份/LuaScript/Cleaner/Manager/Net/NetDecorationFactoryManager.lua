---@class NetDecorationFactoryManager 装饰工厂网络消息
local NetDecorationFactoryManager = {}

function NetDecorationFactoryManager:Init()
    self:RegisterEvent()
end

function NetDecorationFactoryManager:RequestOrder(msg)
    AppServices.NetWorkManager:Send(MsgMap.CSDecorateOrder, msg)
end
function NetDecorationFactoryManager:Product(msg)
    AppServices.NetWorkManager:Send(MsgMap.CSStartProductionOrder, msg)
end

function NetDecorationFactoryManager:OnDecorateOrderResponse(msg)
    SceneServices.DecorationFactory:OnDecorateOrderResponse(msg)
end

function NetDecorationFactoryManager:OnStartProductionOrder(msg)
    SceneServices.DecorationFactory:OnStartProductionOrder(msg)
    MessageDispatcher:SendMessage(MessageType.StartProductDecoration)
end

function NetDecorationFactoryManager:RegisterEvent()
    -- 注册消息
    AppServices.NetWorkManager:addObserver(MsgMap.SCDecorateOrder, self.OnDecorateOrderResponse, self)
    AppServices.NetWorkManager:addObserver(MsgMap.SCStartProductionOrder, self.OnStartProductionOrder, self)
end

function NetDecorationFactoryManager:UnRegisterEvent()
    AppServices.NetWorkManager:removeObserver(MsgMap.SCDecorateOrder, self.OnDecorateOrderResponse, self)
    AppServices.NetWorkManager:removeObserver(MsgMap.SCStartProductionOrder, self.OnStartProductionOrder, self)
end

function NetDecorationFactoryManager:Release()
    self:UnRegisterEvent()
end

return NetDecorationFactoryManager
