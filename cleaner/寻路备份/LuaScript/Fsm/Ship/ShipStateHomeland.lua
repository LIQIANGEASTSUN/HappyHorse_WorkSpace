---@type ShipStateBase
local ShipStateBase = require "Fsm.Ship.ShipStateBase"

---@type ShipStateInfo
local ShipStateInfo = require "Fsm.Ship.ShipStateInfo"

---@type PetFollowPlayer
local PetFollowPlayer = require "Cleaner.Entity.Pet.PetFollowPlayer"

---@type IslandTemplateTool
local IslandTemplateTool = require "Fsm.Ship.IslandTemplateTool"

---@type PetTemplateTool
local PetTemplateTool = require "Cleaner.Entity.Pet.PetTemplateTool"

---@class ShipStateHomeland
local ShipStateHomeland = class(ShipStateBase, "ShipStateHomeland")
-- 船状态：在家园港口

function ShipStateHomeland:ctor()
    self.stateType = ShipStateInfo.ShipStateType.Homeland
    self.isCreatePet = false
    self:Init()
end

function ShipStateHomeland:Init()
    ShipStateBase.Init(self)
end

function ShipStateHomeland:OnEnter()
    --console.error("ShipStateHomeland:OnEnter")
    self.activity = true

    self:SetData()
    self:FromIslandToHomeland()

    AppServices.PlayerJoystickManager:SetActiveRock(false)

    self:RegisterEvent()
end

function ShipStateHomeland:OnExit()
    self.activity = false
    CharacterManager.Instance():RemoveByName("PlayerHome")
    self:UnRegisterEvent()
end

function ShipStateHomeland:SetData()
    local islandId = AppServices.User:GetPlayerIslandInfo()
    local shipPos, playerPos, shipDir = IslandTemplateTool:GetHomelandPos(islandId)
    self.entity:SetPosition(shipPos)
    self.entity:SetForward(shipDir)

    MoveCameraLogic.Instance():MoveCameraToLook2(shipPos, false, 0)

    self:SpawnPlayer(playerPos)
    self:SpawnPet()
end

function ShipStateHomeland:SpawnPlayer(playerPos)
    local playerParams = {position = playerPos}
    CharacterManager.Instance():CreateByName("PlayerHome", playerParams)
end

function ShipStateHomeland:SpawnPet()
    if self.isCreatePet then
        return
    end
    self.isCreatePet = true

    local pets = AppServices.User:GetPets()
    for _, pet in pairs(pets) do
        local key = PetTemplateTool:Getkey(pet.type, pet.level)
        AppServices.EntityManager:CreateEntity(tostring(key), EntityType.PetHL, function(entity)
            self:CreatePetCallBack(entity)
        end)
    end
end

function ShipStateHomeland:CreatePetCallBack(entity)
    local playerCharacter = CharacterManager.Instance():Find("PlayerHome")
    local transform = playerCharacter:GetGameObject().transform
    local birthPos = transform.transform.position - transform.forward
    entity:Init(birthPos)
end

function ShipStateHomeland:FromIslandToHomeland()
    if nil == self.transitionData then
        return
    end
    local reason = self.transitionData.changeStateReason
    if not reason or reason ~= ShipStateInfo.ChangeStateReason.From_Island_To_Homeland then
        return
    end
    ShipStateBase.EndSailing(self)
end

-- Player 碰撞到船
function ShipStateHomeland:TriggerPlayer()
    PanelManager.showPanel(GlobalPanelEnum.ShipSailingPanel)
end

function ShipStateHomeland:GoIslandEvent(islandId)
    if not self.activity then
        return
    end

    if not IslandTemplateTool:IsValid(islandId) then
        return
    end

    AppServices.NetIslandManager:SendChangeIsland(islandId)
    AppServices.User:SetPlayerIslandInfo(islandId)

    local finish = function()
        self:GoIsland(islandId)
    end
    ShipStateBase.StartSailing(self, finish)
end

function ShipStateHomeland:GoIsland(islandId)
    if not self.activity then
        return
    end

    local toStateType = ShipStateInfo.ShipStateType.Island
    local transitionData = {
        islandId = islandId,
        changeStateReason = ShipStateInfo.ChangeStateReason.Click_Go_To_Island
    }
    self:ChangeState(toStateType, transitionData)
end

function ShipStateHomeland:AddPet(type, level, count)
    local key = PetTemplateTool:Getkey(type, level)
    AppServices.EntityManager:CreateEntity(tostring(key), EntityType.PetHL, function(entity)
        self:CreatePetCallBack(entity)
    end)
end

function ShipStateHomeland:RegisterEvent()
    MessageDispatcher:AddMessageListener(MessageType.GoToIsland, self.GoIslandEvent, self)
    MessageDispatcher:AddMessageListener(MessageType.AddPet, self.AddPet, self)
end

function ShipStateHomeland:UnRegisterEvent()
    MessageDispatcher:RemoveMessageListener(MessageType.GoToIsland, self.GoIslandEvent, self)
    MessageDispatcher:RemoveMessageListener(MessageType.AddPet, self.AddPet, self)
end

return ShipStateHomeland