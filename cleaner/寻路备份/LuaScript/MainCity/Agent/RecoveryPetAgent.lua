local FightUnitAgent = require "Cleaner.Unit.FightUnitAgent"

---@type NormalAgent
local NormalAgent = require("MainCity.Agent.NormalAgent")

---@class RecoveryPetAgent:NormalAgent 探索船
local RecoveryPetAgent = class(NormalAgent, "RecoveryPetAgent")

local StateChangedHandles = {
    ---@param agent BaseAgent
    [CleanState.prepare] = function(agent)
        --因为没有处理逻辑,这个函数理论上可以不要
    end,
    ---@param agent NormalAgent
    [CleanState.clearing] = function(agent)
        if not agent:BlockGrid() then
            return agent:SetState(CleanState.cleared)
        end
    end,
    ---@param agent NormalAgent
    [CleanState.cleared] = function(agent)
        local x, z = agent:GetMin()
        local sx, sz = agent:GetSize()

        if AppServices.User:IsBuildingRemove(agent.id) then
            agent:Destroy()
        else
            agent:InitRender(
                function(result)
                    agent:SetClickable(true)
                end
            )
        end

        --后触发格子状态
        ---@type MapManager
        local map = App.scene.mapManager
        return map:SetBlockState(x, sx, z, sz, CleanState.cleared)
    end
}

-- 探索船 Agent
function RecoveryPetAgent:ctor(id, data)
    self.data = data

    ---@type FightUnitBase
    self.fightUnit = nil
    self.campType = CampType.Blue
    self.init = false
end

---@private
---触发显示更新/格子状态更新
function RecoveryPetAgent:OnStateChanged()
    local state = self:GetState()
    local handler = StateChangedHandles[state]
    if handler then
        return handler(self)
    end
end

function RecoveryPetAgent:InitRender(callback)
    NormalAgent.InitRender(self, callback)
    self.render:AddInstantiateListener(
        function(result)
            self:RenderInstantiateCallBack(result)
    end)
end

function RecoveryPetAgent:RenderInstantiateCallBack(result)
    if not result then
        return
    end

    if not self.init then
        self.init = true
        self:AddBuff()
    end
end

function RecoveryPetAgent:AddBuff()
    if not self.fightUnit then
        self.fightUnit = FightUnitAgent.new()
        self.fightUnit:SetAgent(self)
        self.fightUnit:SetCamp(self.campType)
        AppServices.UnitManager:AddUnit(self.fightUnit)
    end

    local buffId = self.data.meta.buff
    local casterData= {
        caster = self.fightUnit,
        casterSkillId = -1,
        casterBuffId = buffId
    }

    local buffManager = self.fightUnit:GetBuffManager()
    buffManager:AddBuff(buffId, casterData)
end

-- 连接到家园，删除怪物出生点，删除怪物
function RecoveryPetAgent:OnRegionLinked()
    --console.error("RecoveryPetAgent:OnRegionLinked")
    AppServices.NetBuildingManager:SendRemoveBuilding(self.id)
end

function RecoveryPetAgent:Destroy()
    NormalAgent.Destroy(self)

    if self.fightUnit then
        AppServices.UnitManager:RemoveUnit(self.fightUnit)
        self.fightUnit = nil
    end
end

return RecoveryPetAgent