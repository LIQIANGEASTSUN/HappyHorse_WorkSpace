---@type BaseEntity
local BaseEntity = require "Cleaner.Entity.BaseEntity"
---@type ShipStateInfo
local ShipStateInfo = require "Fsm.Ship.ShipStateInfo"
---@type IslandTemplateTool
local IslandTemplateTool = require "Fsm.Ship.IslandTemplateTool"

local UE = CS.UnityEngine
local BoxCollider = typeof(UE.BoxCollider)

local ShipEntity = class(BaseEntity, "ShipEntity")

function ShipEntity:ctor()
    self.entityType = EntityType.Ship
    self.campType = CampType.Blue
end

function ShipEntity:BindView(gameObject)
    BaseEntity.BindView(self, gameObject)

    local colliders = gameObject:GetComponent(BoxCollider)
    if Runtime.CSValid(colliders) then
        colliders.isTrigger = true
    end

    self:CreateState()
    self:RegiseterListeners()
end

function ShipEntity:CreateState()
    for _, path in pairs(ShipStateInfo.States) do
        BaseEntity.AddState(self, path)
    end

    local toStateType = ShipStateInfo.ShipStateType.Homeland
    local transitionData = nil
    local islandId = AppServices.User:GetPlayerIslandInfo()
    local type = IslandTemplateTool:GetType(islandId)
    if type == IslandTemplateType.Island then
        toStateType = ShipStateInfo.ShipStateType.Island
        transitionData = {islandId = islandId}
    end
    BaseEntity.ChangeState(self, toStateType, transitionData)
end

function ShipEntity:RegiseterListeners()
    local colliders = self.gameObject:GetComponent(BoxCollider)
    colliders.isTrigger = true
    local detector = self.gameObject:GetOrAddComponent(typeof(CS.ColliderDetector))
    detector:SetTriggerListener(
        function(collider)
            self:TriggerEnter(collider.gameObject)
        end
    )
end

function ShipEntity:GetCurrentState()
    local currentState = self.fsmStateMachine:GetCurrentState()
    return currentState
end

-- 处理点击
function ShipEntity:ProcessClick()
    local currentState = self:GetCurrentState()
    --currentState:ProcessClick()
    currentState:TriggerPlayer()
end

function ShipEntity:TriggerEnter(gameObject)
    if gameObject.name == "Player" then
        local currentState = self:GetCurrentState()
        currentState:TriggerPlayer()
    end
end

function ShipEntity:GetWorldPosition()
    return self:GetPosition()
end

function ShipEntity:EnableAttack()
    return false
end

function ShipEntity:LateUpdate()
    BaseEntity.LateUpdate(self)
end

function ShipEntity:NeedLateUpdate()
    return true
end

return ShipEntity