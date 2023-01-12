-- 道具网络消息模块
---@class NetOrderManager
local NetOrderManager = {}

function NetOrderManager:Init()
    self:RegisterEvent()
end

function NetOrderManager:SendOrder(msg)
    --console.error("NetOrderManager:SendOrder:"..msg.id)
    AppServices.NetWorkManager:Send(MsgMap.CSDecorateOrder, msg)
end

function NetOrderManager:ReceiveOrder(msg)
    local id = msg.id
    --console.error("NetOrderManager:ReceiveOrder:"..id)
end

function NetOrderManager:SendStartOrder(id)
    local msg = { id = id }
    --console.error("NetOrderManager:SendStartOrder:"..msg.id)
    AppServices.NetWorkManager:Send(MsgMap.CSStartProductionOrder, msg)
end

function NetOrderManager:ReceiveStartOrder(msg)
    local id = msg.id
    --console.error("NetOrderManager:ReceiveStartOrder:"..id)
end

function NetOrderManager:RegisterEvent()
    AppServices.NetWorkManager:addObserver(MsgMap.SCDecorateOrder, self.ReceiveOrder, self)
    AppServices.NetWorkManager:addObserver(MsgMap.SCStartProductionOrder, self.ReceiveStartOrder, self)
end

function NetOrderManager:UnRegisterEvent()
    AppServices.NetWorkManager:removeObserver(MsgMap.SCDecorateOrder, self.ReceiveOrder, self)
    AppServices.NetWorkManager:removeObserver(MsgMap.SCStartProductionOrder, self.ReceiveStartOrder, self)
end

function NetOrderManager:Release()
    self:UnRegisterEvent()
end

return NetOrderManager