---@type NetWorkManager
local NetWorkManager = {}


function NetWorkManager:Init()
    self.isRegister = false
    self:RegisterEvent()

    AppServices.NetIslandManager:Init()
    AppServices.NetPetManager:Init()
    AppServices.NetItemManager:Init()
    AppServices.NetBuildingManager:Init()
    AppServices.BuildingModifyManager:Init()
    AppServices.NetPingManager:Init()
    AppServices.NetDecorationFactoryManager:Init()
    AppServices.NetRecycleManager:Init()
    AppServices.NetEquipManager:Init()
end

function NetWorkManager:Send(msgId, msg)
    AppServices.Net:Send(msgId, msg)
end

function NetWorkManager:addObserver(msgId, handler, observer)
    local eventName = self:MsgIdToEvetName(msgId)
    MessageDispatcher:AddMessageListener(eventName, handler, observer)
end

function NetWorkManager:removeObserver(msgId, handler, observer)
    local eventName = self:MsgIdToEvetName(msgId)
    MessageDispatcher:RemoveMessageListener(eventName, handler, observer)
end

function NetWorkManager:MsgIdToEvetName(msgId)
    local eventName = string.format("NetEvent%d", msgId)
    return eventName
end

function NetWorkManager:GetAllMsg()
    local map = {}
    for key, value in pairs(MsgMap) do
        local msgId = 0
        if type(key) == "number" then
            msgId = key
        elseif type(value) == 'number' then
            msgId = value
        end

        if msgId > 0 and not map[msgId] then
            map[msgId] = true
        end
    end
    return map
end

local function ReceivedNet(msg, msgId)
    local eventName = AppServices.NetWorkManager:MsgIdToEvetName(msgId)
    MessageDispatcher:SendMessage(eventName, msg)
end

function NetWorkManager:RegisterEvent()
    if self.isRegister then
        return
    end
    self.isRegister = true

    local map = self:GetAllMsg()
    for msgId, _ in pairs(map) do
        AppServices.Net:Recieved(msgId, ReceivedNet)
    end
end

function NetWorkManager:UnRegisterEvent()
    if not self.isRegister then
        return
    end

    local map = self:GetAllMsg()
    for msgId, _ in pairs(map) do
        AppServices.Net:Remove(msgId, ReceivedNet)
    end
end

function NetWorkManager:Release()
    self:UnRegisterEvent()
    AppServices.NetIslandManager:Release()
    AppServices.NetPetManager:Release()
    AppServices.NetItemManager:Release()
    AppServices.NetBuildingManager:Release()
    AppServices.BuildingModifyManager:Release()
    AppServices.NetPingManager:Release()
    AppServices.NetDecorationFactoryManager:Release()
    AppServices.NetRecycleManager:Release()
    AppServices.NetEquipManager:Release()
end

return NetWorkManager