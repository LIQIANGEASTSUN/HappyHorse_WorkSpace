---@type BehaviorTreeInfo
local BehaviorTreeInfo = require "Cleaner.BehaviorTree.BehaviorTreeInfo"

---@type BTConstant
local BTConstant = require "Cleaner.BehaviorTree.BTConstant"

---@type NodeAction
local NodeAction = require "Cleaner.BehaviorTree.Node.Leaf.NodeAction"

-- 探索岛宠物行为：死亡
---@class PetActionFollowPlayer
local PetActionFollowPlayer = class(NodeAction, "PetActionFollowPlayer")

function PetActionFollowPlayer:ctor()
    self.refresTime = 0
    self.REFRESH_INTERVAL = 1
end

function PetActionFollowPlayer:OnEnter()
    NodeAction.OnEnter(self)
    console.error("PetActionFollowPlayer:OnEnter:")
    ---@type BehaviorTreeEntity
    self.btEntity = self.owner:BehaviorTreeEntity()
    ---@type PetEntity
    self.entity = self.owner.entity
    ---@type PetActionTool
    self.petActionTool = self.entity.petActionTool
    self.entity:PlayAnimation(EntityAnimationName.Walk)
end

function PetActionFollowPlayer:DoAction()
    --console.error("PetActionFollowPlayer:DoAction:")
    self:Refresh()

    local arrive, pos = self.entity.unitMove:OnTick()
    self.entity:SetPosition(pos)
    if arrive then
        console.error("arrive")
        self.btEntity:SetFloatParameter(BTConstant.DistancePlayer, 0)
        self.btEntity:SetBoolParameter(BTConstant.ArriveFollowPos, true)
        return BehaviorTreeInfo.ResultType.Success
    end

    return BehaviorTreeInfo.ResultType.Running
end

function PetActionFollowPlayer:OnExit()
    NodeAction.OnExit(self)
    console.error("PetActionFollowPlayer:OnExit:")
end

function PetActionFollowPlayer:Refresh()
    if Time.realtimeSinceStartup < self.refresTime then
        return
    end

    self.refresTime = Time.realtimeSinceStartup + self.REFRESH_INTERVAL
    self.petActionTool:ResetFollowPos()
    self.petActionTool:SearchAttackTarget()
end

return PetActionFollowPlayer