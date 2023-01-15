---@type BehaviorTreeInfo
local BehaviorTreeInfo = require "Cleaner.BehaviorTree.BehaviorTreeInfo"

---@type BTConstant
local BTConstant = require "Cleaner.BehaviorTree.BTConstant"

---@type NodeAction
local NodeAction = require "Cleaner.BehaviorTree.Node.Leaf.NodeAction"

-- 探索岛宠物行为：死亡
---@class PetActionDeath
local PetActionDeath = class(NodeAction, "PetActionDeath")

function PetActionDeath:ctor()

end

function PetActionDeath:OnEnter()
    NodeAction.OnEnter(self)
    console.error("PetActionDeath:OnEnter:")
    self.btEntity = self.owner:BehaviorTreeEntity()
    self.petEntity = self.owner.entity

    --self.owner:PlayAnimation(EntityAnimationName.Idle_A)
end

function PetActionDeath:DoAction()
    console.error("PetActionDeath:DoAction:")
    return BehaviorTreeInfo.ResultType.Running
end

function PetActionDeath:OnExit()
    NodeAction.OnExit(self)
    console.error("PetActionDeath:OnExit:")
end

return PetActionDeath