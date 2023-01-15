---@type BehaviorTreeInfo
local BehaviorTreeInfo = require "Cleaner.BehaviorTree.BehaviorTreeInfo"

---@type BTConstant
local BTConstant = require "Cleaner.BehaviorTree.BTConstant"

---@type NodeAction
local NodeAction = require "Cleaner.BehaviorTree.Node.Leaf.NodeAction"

-- 探索岛宠物行为：死亡
---@class PetActionAttack
local PetActionAttack = class(NodeAction, "PetActionAttack")

function PetActionAttack:ctor()
    self.refresTime = 0
    self.REFRESH_INTERVAL = 1
end

function PetActionAttack:OnEnter()
    NodeAction.OnEnter(self)
    console.error("PetActionAttack:OnEnter:")
    ---@type BehaviorTreeEntity
    self.btEntity = self.owner:BehaviorTreeEntity()
    ---@type PetEntity
    self.entity = self.owner.entity
    ---@type PetActionTool
    self.petActionTool = self.entity.petActionTool
end

function PetActionAttack:DoAction()
    --console.error("PetActionAttack:DoAction:")
    self:Refresh()
    return BehaviorTreeInfo.ResultType.Success
end

function PetActionAttack:OnExit()
    NodeAction.OnExit(self)
    console.error("PetActionAttack:OnExit:")
end

function PetActionAttack:Refresh()
    if Time.realtimeSinceStartup < self.refresTime then
        return
    end

    self.refresTime = Time.realtimeSinceStartup + self.REFRESH_INTERVAL
    self.petActionTool:CalculateFollowPos()

    ---@type TargetSearchResult
    local result = self.petActionTool:SearchAttackTarget()
    if not result:IsTargetAndSkillValid() then
        return
    end

    if not result:TargetInAttackDistance() then
        return
    end

    -- 有攻击目标，且在攻击范围内，攻击
    local _, normalized = result:OffsetPosition()
    self.entity:SetForward(normalized)

    -- 释放技能 skill
    ---@type SkillController
    local skillController = self.owner:SkillController()
    if skillController:EnableUse(result.skillId) then
        local targets = {result.other}
        skillController:Fire(result.skillId, targets)
    end
end

return PetActionAttack