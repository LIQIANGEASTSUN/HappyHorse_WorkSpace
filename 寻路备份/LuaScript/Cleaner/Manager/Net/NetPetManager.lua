---@type PetTemplateTool
local PetTemplateTool = require "Cleaner.Entity.Pet.PetTemplateTool"

---@type PetReceiveEnum
local PetReceiveEnum = require "UI.Pet.PetReceivePanel.View.UI.PetReceiveEnum"

-- 宠物网络消息模块
---@class NetPetManager
local NetPetManager = {}

function NetPetManager:Init()
    self:RegisterEvent()
end

-- 发送宠物上阵
function NetPetManager:SendPetUp(petId)
    local msg = {
        petId = petId,
    }
    AppServices.NetWorkManager:Send(MsgMap.CSPetUp, msg)
    self:ReceivePetUp(msg)
end

-- 接收宠物上阵
function NetPetManager:ReceivePetUp(msg)
    local petId = msg.petId
    local pet = AppServices.User:GetPet(petId)
    pet.up = 1
end

-- 发送宠物下阵
function NetPetManager:SendPedDown(petId)
    local msg = {
        petId = petId,
    }
    AppServices.NetWorkManager:Send(MsgMap.CSPetDown, msg)
    self:ReceivePetDown(msg)
end

-- 接收宠物下阵
function NetPetManager:ReceivePetDown(msg)
    local petId = msg.petId
    local pet = AppServices.User:GetPet(petId)
    pet.up = 0
end

-- 发送宠物升级
function NetPetManager:SendPetLevelUp(petId, level)
    local msg = {
        petId = petId,
        level = level,
    }
    AppServices.NetWorkManager:Send(MsgMap.CSPetLevelUp, msg)
    --self:ReceivePetLevelUp(msg)
end

-- 发送宠物升级
function NetPetManager:ReceivePetLevelUp(msg)
    local petId = msg.petId
    local pet = AppServices.User:GetPet(petId)
    pet.level = msg.level

    self:CheckPetUpType(pet)
    MessageDispatcher:SendMessage(MessageType.PetUpLevel, pet.type, pet.level)
end

function NetPetManager:ReceiveAddPet(msg)
    local pet = {
        id = msg.petId,
        type = msg.type,
        level = msg.level,
        up = 0
    }
    AppServices.User:SetPet(pet)

    --console.error("ReceiveAddPet:"..msg.type)
    --local arguments = {petId = pet.id, receiveType = PetReceiveEnum.Reward}
    --PanelManager.showPanel(GlobalPanelEnum.PetReceivePanel, arguments)

    local count = 1
    MessageDispatcher:SendMessage(MessageType.AddPet, pet.type, pet.level, count)
end

function NetPetManager:CheckPetUpType(pet)
    local key = PetTemplateTool:Getkey(pet.type, pet.level)
    local data = AppServices.Meta:Category("PetTemplate")[tostring(key)]

    local lastKey = PetTemplateTool:Getkey(pet.type, pet.level - 1)
    local lastData = AppServices.Meta:Category("PetTemplate")[tostring(lastKey)]

    if data.stage ~= lastData.stage then
        PanelManager.closePanel(GlobalPanelEnum.PetInfoPanel)
        local arguments = {petId = pet.id, receiveType = PetReceiveEnum.UpStage, fromPetInfo = true}
        PanelManager.showPanel(GlobalPanelEnum.PetReceivePanel, arguments)
    end
end

function NetPetManager:RegisterEvent()
    AppServices.NetWorkManager:addObserver(MsgMap.SCPetUp, self.ReceivePetUp, self)
    AppServices.NetWorkManager:addObserver(MsgMap.SCPetDown, self.ReceivePetDown, self)
    AppServices.NetWorkManager:addObserver(MsgMap.SCPetLevelUp, self.ReceivePetLevelUp, self)
    AppServices.NetWorkManager:addObserver(MsgMap.SCAddPet, self.ReceiveAddPet, self)
end

function NetPetManager:UnRegisterEvent()
    AppServices.NetWorkManager:removeObserver(MsgMap.SCPetUp, self.ReceivePetUp, self)
    AppServices.NetWorkManager:removeObserver(MsgMap.SCPetDown, self.ReceivePetDown, self)
    AppServices.NetWorkManager:removeObserver(MsgMap.SCPetLevelUp, self.ReceivePetLevelUp, self)
    AppServices.NetWorkManager:removeObserver(MsgMap.SCAddPet, self.ReceiveAddPet, self)
end

function NetPetManager:Release()
    self:UnRegisterEvent()
end

return NetPetManager