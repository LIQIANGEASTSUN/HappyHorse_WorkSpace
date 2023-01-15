---@type BehaviorTreeInfo
local BehaviorTreeInfo = require "Cleaner.BehaviorTree.BehaviorTreeInfo"

---@type BTConstant
local BTConstant = require "Cleaner.BehaviorTree.BTConstant"

---@type NodeAction
local NodeAction = require "Cleaner.BehaviorTree.Node.Leaf.NodeAction"

-- 探索岛宠物行为：死亡
---@class PetActionPursuit
local PetActionPursuit = class(NodeAction, "PetActionPursuit")

function PetActionPursuit:ctor()
    self.refresTime = 0
    self.REFRESH_INTERVAL = 1
end

function PetActionPursuit:OnEnter()
    NodeAction.OnEnter(self)
    console.error("PetActionPursuit:OnEnter:")
    ---@type BehaviorTreeEntity
    self.btEntity = self.owner:BehaviorTreeEntity()
    ---@type PetEntity
    self.entity = self.owner.entity
    ---@type PetActionTool
    self.petActionTool = self.entity.petActionTool
    self.entity:PlayAnimation(EntityAnimationName.Walk)
end

function PetActionPursuit:DoAction()
    self:Refresh()
    --console.error("PetActionPursuit:DoAction")
    local arrive, pos = self.entity.unitMove:OnTick()
    self.entity:SetPosition(pos)
    if arrive then
        self.btEntity:SetBoolParameter(BTConstant.HasTarget, true)
        self.btEntity:SetBoolParameter(BTConstant.TargetInAttackDistance, true)
        return BehaviorTreeInfo.ResultType.Success
    end

    return BehaviorTreeInfo.ResultType.Running
end

function PetActionPursuit:OnExit()
    NodeAction.OnExit(self)
    console.error("PetActionPursuit:OnExit")
end

function PetActionPursuit:Refresh()
    if Time.realtimeSinceStartup < self.refresTime then
        return
    end

    self.refresTime = Time.realtimeSinceStartup + self.REFRESH_INTERVAL
    self.petActionTool:CalculateFollowPos()

    ---@type TargetSearchResult
    local result = self.petActionTool:SearchAttackTarget()
    if not result:TargetInAttackDistance() then
        local destination =  result:NearestAttackPosition()
        self.entity.unitMove:ChangeDestination(destination)
    end
end

return PetActionPursuit