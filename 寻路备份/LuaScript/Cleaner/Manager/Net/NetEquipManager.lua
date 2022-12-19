-- 宠物网络消息模块
---@class NetEquipManager
local NetEquipManager = {
    recycles = {}
}

function NetEquipManager:Init()
    self:RegisterEvent()
end

function NetEquipManager:SendEquip(info)
    local msg = {
        id = info.id
    }
    AppServices.Net:Send(MsgMap.CSEquipChange, msg)
end

function NetEquipManager:SendEquipLvUp(info)
    local msg = {
        id = info.id
    }
    AppServices.Net:Send(MsgMap.CSEquipLvUp, msg)
end

function NetEquipManager:OnEquipLvUp(msg)
    local equip = AppServices.User:GetEquip(msg.id)
    if equip then
        equip.level = msg.level
    end
    AppServices.User:SetEquipInfo(equip)
    if equip.up == 1 then
        MessageDispatcher:SendMessage(MessageType.VaccumChanged, equip)
    end
end
function NetEquipManager:OnEquipChange(msg)
end
function NetEquipManager:OnAddEquip(msg)
end

function NetEquipManager:RegisterEvent()
    AppServices.NetWorkManager:addObserver(MsgMap.SCEquipLvUp, self.OnEquipLvUp, self)
    AppServices.NetWorkManager:addObserver(MsgMap.SCEquipChange, self.OnEquipChange, self)
    AppServices.NetWorkManager:addObserver(MsgMap.SCAddEquip, self.OnAddEquip, self)
end

function NetEquipManager:UnRegisterEvent()
    AppServices.NetWorkManager:removeObserver(MsgMap.SCEquipLvUp, self.OnEquipLvUp, self)
    AppServices.NetWorkManager:removeObserver(MsgMap.SCEquipChange, self.OnEquipChange, self)
end

function NetEquipManager:Release()
    self:UnRegisterEvent()
end

return NetEquipManager