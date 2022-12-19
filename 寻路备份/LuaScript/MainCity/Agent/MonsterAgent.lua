local NormalAgent = require("MainCity.Agent.NormalAgent")
---@class MonsterAgent:BaseAgent 怪物生成器
local MonsterAgent = class(NormalAgent, "MonsterAgent")

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
function MonsterAgent:ctor(id, data)
    ---@type MonsterAgentData
    self.data = data
    self.isRenderCallBack = false

    self:RegisetEvent()
end

---@private
---触发显示更新/格子状态更新
function MonsterAgent:OnStateChanged()
    local state = self:GetState()
    local handler = StateChangedHandles[state]
    if handler then
        return handler(self)
    end
end

function MonsterAgent:InitRender(callback)
    if not self.render then
        local MonsterRender = require "MainCity.Render.MonsterRender"
        self.render = MonsterRender.new(self:GetAssetName())
    end
    self.render:SetPrune(self.prune)
    self.render:Init(self.data, callback)

    self.render:AddInstantiateListener(
        function(result)
            self:RenderInstantiateCallBack(result)
        end
    )
end

function MonsterAgent:RenderInstantiateCallBack(result)
    if not result then
        return
    end

    if self.isRenderCallBack then
        return
    end
    self.isRenderCallBack = true

    self:SpawnMonster()
    self:RegisetEvent()
end

-- 处理点击
function MonsterAgent:ProcessClick()
end

function MonsterAgent:SpawnMonster()
    local waitExtensionId = self.data:GetWaitExtensionId()
    if waitExtensionId then
        WaitExtension.CancelTimeout(waitExtensionId)
        self.data:SetWaitExtensionId(nil)
    end

    if self.data:IsCreating() then
        return
    end

    self.data:SetCreateEntityId(-1)

    local configId = tostring(self.data.meta.sn)
    local monsterConfig = AppServices.Meta:Category("MonsterTemplate")[tostring(configId)]
    local isBossAgent = (monsterConfig.isBoss == 1)
    self.data:SetIsBossAgent(isBossAgent)
    --console.error("SpawnMonster:"..Time.realtimeSinceStartup.."    configId:"..configId.."   time:"..tostring(self.data.meta.refreshCd))

    -- 重新创建怪物，此时不能被吸尘器吸了
    self.data:SetSuckable(false)
    self.data:SetCreating(true)
    AppServices.EntityManager:CreateEntity(configId, EntityType.Monster, function(entity)
        self:CreateEntitySuccess(entity)
    end)
end

function MonsterAgent:CreateEntitySuccess(entity)
    self.data:SetCreating(false)
    self.data:SetCreateEntityId(entity.entityId)

    local position = self:GetWorldPosition()
    entity:Init(position)

    local entityGameObject =  entity:GetGameObject()
    self.render:ResetGameObject(entityGameObject)
    --self.render.gameObject = entity:GetGameObject()
end

---是否与吸尘器交互(被吸)
function MonsterAgent:Suckable()
    return self.data:GetSuckable()
end

--- 被吸尘器吸后的处理
function MonsterAgent:AfterCleaned()
    local createEntityId = self.data:GetCreateEntityId()
    if createEntityId then
        AppServices.EntityManager:RemoveEntity(createEntityId)
    end

    local isBossAgent = self.data:GetIsBossAgent()
    if isBossAgent then
        self:Destroy()
    end
end

function MonsterAgent:MonsterDeath(entityId, sn)
    local createEntityId = self.data:GetCreateEntityId()
    if not createEntityId or createEntityId ~= entityId then
        return
    end

    -- 怪物死了能被吸
    self.data:SetSuckable(true)

    -- 间隔一定时间，再创建一个怪物
    local refreshCd = self.data.meta.refreshCd
    if refreshCd > 1 then
        local waitExtensionId = WaitExtension.InvokeRepeating(function() self:SpawnMonster() end, 0, refreshCd)
        self.data:SetWaitExtensionId(waitExtensionId)
    end

    local isBossAgent = self.data:GetIsBossAgent()
    if isBossAgent then
        AppServices.NetBuildingManager:SendRemoveBuilding(self.id)
    end
end

function MonsterAgent:GetCreateEntityId()
    return self.data:GetCreateEntityId()
end

-- 连接到家园，删除怪物出生点，删除怪物
function MonsterAgent:OnRegionLinked()
    --console.error("MonsterAgent:OnRegionLinked")
    AppServices.NetBuildingManager:SendRemoveBuilding(self.id)
    local createEntityId = self.data:GetCreateEntityId()
    if createEntityId and createEntityId > 0 then
        AppServices.EntityManager:RemoveEntity(createEntityId)
    end

    self:Destroy()
end

function MonsterAgent:RegisetEvent()
    MessageDispatcher:AddMessageListener(MessageType.EntityDeath, self.MonsterDeath, self)
end

function MonsterAgent:UnRegisetEvent()
    MessageDispatcher:RemoveMessageListener(MessageType.EntityDeath, self.MonsterDeath, self)
end

function MonsterAgent:Destroy()
    NormalAgent.Destroy(self)
    self:UnRegisetEvent()
end

return MonsterAgent