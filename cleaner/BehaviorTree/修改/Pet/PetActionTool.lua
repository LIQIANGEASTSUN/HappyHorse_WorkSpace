---@type PetFollowPlayer
local PetFollowPlayer = require "Cleaner.Entity.Pet.PetFollowPlayer"

---@type BTConstant
local BTConstant = require "Cleaner.BehaviorTree.BTConstant"

---@class PetActionTool
local PetActionTool = class(nil, "PetActionTool")

function PetActionTool:ctor(owner)
    ---@type FightUnitBase
    self.owner = owner
    ---@type BehaviorTreeEntity
    self.btEntity = self.owner:BehaviorTreeEntity()
    ---@type PetEntity
    self.entity = self.owner.entity
    ---@type FightSearchOpposed
    self.searchOpposed = self.owner:SearchOpposed()
end

function PetActionTool:CalculateFollowPos()
    local result, destination = PetFollowPlayer:GetFollowPos(self.entity)
    if not result then
        return result, destination
    end

    local position = self.entity:GetPosition()
    local distance = Vector3.Distance(position, destination)
    console.error("DistancePlayer:"..distance)

    self.btEntity:SetFloatParameter(BTConstant.DistancePlayer, distance)
    self.btEntity:SetBoolParameter(BTConstant.ArriveFollowPos, distance <= 0.3)
    return result, destination
end

function PetActionTool:ResetFollowPos()
    local result, destination = self:CalculateFollowPos()
    if result then
        self.entity.unitMove:ChangeDestination(destination)
    end
end

function PetActionTool:SearchAttackTarget()
    -- 搜索到能攻击的对象
    ---@type TargetSearchResult
    local result = self.searchOpposed:SearchWithPlayer()

    local hasTarget = result:IsTargetValid()
    self.btEntity:SetBoolParameter(BTConstant.HasTarget, hasTarget)

    console.error("hasTarget:"..tostring(hasTarget))

    local targetInAttackDistance = result:TargetInAttackDistance()
    self.btEntity:SetBoolParameter(BTConstant.TargetInAttackDistance, targetInAttackDistance)

    return result
end

return PetActionTool