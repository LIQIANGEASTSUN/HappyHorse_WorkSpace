---@type BehaviorTreeInfo
local BehaviorTreeInfo = require "Cleaner.BehaviorTree.BehaviorTreeInfo"

---@type NodeAction
local NodeAction = require "Cleaner.BehaviorTree.Node.Leaf.NodeAction"

-- 探索岛宠物行为：死亡
---@class PetActionIdle
local PetActionIdle = class(NodeAction, "PetActionIdle")

function PetActionIdle:ctor()
    self.refresTime = 0
    self.REFRESH_INTERVAL = 1
end

function PetActionIdle:OnEnter()
    NodeAction.OnEnter(self)
    console.error("PetActionIdle:OnEnter:")
    self.btEntity = self.owner:BehaviorTreeEntity()
    self.entity = self.owner.entity
    ---@type PetActionTool
    self.petActionTool = self.entity.petActionTool

    self.entity:PlayAnimation(EntityAnimationName.Idle_A)
end

function PetActionIdle:DoAction()
    --console.error("PetActionIdle:DoAction:")
    self:Refresh()
    return BehaviorTreeInfo.ResultType.Running
end

function PetActionIdle:OnExit()
    NodeAction.OnExit(self)
    console.error("PetActionIdle:OnExit:")
end

function PetActionIdle:Refresh()
    if Time.realtimeSinceStartup < self.refresTime then
        return
    end

    self.refresTime = Time.realtimeSinceStartup + self.REFRESH_INTERVAL
    self.petActionTool:CalculateFollowPos()
    self.petActionTool:SearchAttackTarget()
end

return PetActionIdle