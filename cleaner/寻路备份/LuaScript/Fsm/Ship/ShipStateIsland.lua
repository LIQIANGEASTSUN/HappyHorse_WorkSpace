---@type ShipStateBase
local ShipStateBase = require "Fsm.Ship.ShipStateBase"

---@type PetFollowPlayer
local PetFollowPlayer = require "Cleaner.Entity.Pet.PetFollowPlayer"

---@type ShipStateInfo
local ShipStateInfo = require "Fsm.Ship.ShipStateInfo"

---@type IslandTemplateTool
local IslandTemplateTool = require "Fsm.Ship.IslandTemplateTool"

---@type PetTemplateTool
local PetTemplateTool = require "Cleaner.Entity.Pet.PetTemplateTool"

---@class ShipStateIsland
local ShipStateIsland = class(ShipStateBase, "ShipStateIsland")
-- 船状态：在岛屿港口

function ShipStateIsland:ctor()
    self.stateType = ShipStateInfo.ShipStateType.Island
    self:Init()
end

function ShipStateIsland:Init()
    ShipStateBase.Init(self)
end

function ShipStateIsland:OnEnter()
    self.activity = true
    --console.error("ShipStateIsland:OnEnter")
    self:SetData()
    self:FromClickGoToIsland()

    self:RegisterEvent()
end

function ShipStateIsland:OnExit()
    self:RemoveAllPet()
    self.activity = false
    CharacterManager.Instance():RemoveByName("Player")
    self:UnRegisterEvent()
end

function ShipStateIsland:SetData()
    local islandId = AppServices.User:GetPlayerIslandInfo()
    local shipPos, playerPos, shipDir = IslandTemplateTool:GetIslandPos(islandId)
    self.entity:SetPosition(shipPos)
    self.entity:SetForward(shipDir)
    self:SpawnPlayer(playerPos)
    self:SpawnPet()

    self.entity:SetVisible(self:EnableUseShip())
end

function ShipStateIsland:EnableUseShip()
    local sn = AppServices.Meta:GetConfigMetaValue("defaultIsland", 0)
    local defaultId = tonumber(sn)
    local islandId = AppServices.User:GetPlayerIslandInfo()
    return islandId ~= defaultId
end

function ShipStateIsland:SpawnPlayer(playerPos)
    local playerParams = {position = playerPos}
    CharacterManager.Instance():CreateByName("Player", playerParams)
end

function ShipStateIsland:SpawnPet()
    local pets = AppServices.User:GetPets()
    for _, pet in pairs(pets) do
        if pet.up == 1 then
            local key = PetTemplateTool:Getkey(pet.type, pet.level)
            AppServices.EntityManager:CreateEntity(tostring(key), EntityType.Pet, function(entity)
                self:CreatePetCallBack(entity)
            end)
        end
    end
end

function ShipStateIsland:PetUpTeam(pet)
    local key = PetTemplateTool:Getkey(pet.type, pet.level)
    AppServices.EntityManager:CreateEntity(tostring(key), EntityType.Pet, function(entity)
        self:CreatePetCallBack(entity)
    end)
end

function ShipStateIsland:CreatePetCallBack(entity)
    PetFollowPlayer:AddEntity(entity.entityId)

    local playerCharacter = CharacterManager.Instance():Find("Player")
    local transform = playerCharacter:GetGameObject().transform
    local birthPos = transform.transform.position - transform.forward
    entity:Init(birthPos)
end

function ShipStateIsland:FromClickGoToIsland()
    if not self.transitionData or not self.transitionData.islandId then
        return
    end
    local reason = self.transitionData.changeStateReason
    if not reason or reason ~= ShipStateInfo.ChangeStateReason.Click_Go_To_Island then
        return
    end

    ShipStateBase.EndSailing(self)
end

-- Player 碰撞到船
function ShipStateIsland:TriggerPlayer()
    if not self:EnableUseShip() then
        return
    end
    PanelManager.showPanel(GlobalPanelEnum.ShipIslandLeavePanel)
end

function ShipStateIsland:GoHomelandStart()
    local islandId = IslandTemplateTool:GetHomelandId()
    AppServices.NetIslandManager:SendChangeIsland(tonumber(islandId))
    AppServices.User:SetPlayerIslandInfo(tonumber(islandId))

    local finish = function()
        self:GoHomelandState()
    end
    ShipStateBase.StartSailing(self, finish)
end

function ShipStateIsland:GoHomelandState()
    if not self.activity then
        return
    end

    local toStateType = ShipStateInfo.ShipStateType.Homeland
    local transitionData = {
        changeStateReason = ShipStateInfo.ChangeStateReason.From_Island_To_Homeland
    }
    self:ChangeState(toStateType, transitionData)
end

-- 退出岛屿时，移除所有宠物
function ShipStateIsland:RemoveAllPet()
    local entities = AppServices.EntityManager:GetAllEntity()
    for _, entity in ipairs(entities) do
        local entityType = entity:GetEntityType()
        if entityType == EntityType.Pet then
            AppServices.EntityManager:RemoveEntity(entity.entityId)
        end
    end
end

function ShipStateIsland:LinkedHomeland(islandId)
    local currentIslandId = AppServices.User:GetPlayerIslandInfo()
    if currentIslandId ~= islandId then
        console.error("当前在岛屿%d,但是接收到岛屿%d连接到家园的消息了", currentIslandId, islandId)
        return
    end
    PanelManager.showPanel(GlobalPanelEnum.ShipIslandLinkHomelandPanel)
end

function ShipStateIsland:RegisterEvent()
    MessageDispatcher:AddMessageListener(MessageType.IslandLinkHomeland, self.LinkedHomeland, self)
    MessageDispatcher:AddMessageListener(MessageType.GoToHomeland, self.GoHomelandStart, self)
    MessageDispatcher:AddMessageListener(MessageType.Pet_Up_Team, self.PetUpTeam, self)
end

function ShipStateIsland:UnRegisterEvent()
    MessageDispatcher:RemoveMessageListener(MessageType.IslandLinkHomeland, self.LinkedHomeland, self)
    MessageDispatcher:RemoveMessageListener(MessageType.GoToHomeland, self.GoHomelandStart, self)
    MessageDispatcher:RemoveMessageListener(MessageType.Pet_Up_Team, self.PetUpTeam, self)
end

return ShipStateIsland