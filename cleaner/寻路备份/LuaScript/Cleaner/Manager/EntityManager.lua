---@type PetFollowPlayer
local PetFollowPlayer = require "Cleaner.Entity.Pet.PetFollowPlayer"

---@class EntityManager 生物管理器
local EntityManager = {
    alive = true,
    ---@type Dictionary<number, BaseEntity>
    entityDic = {},
    ---@type List<number>
    entityCallLateUpate = {},

    instanceId = 100000000
}

local InvokeCbk = Runtime.InvokeCbk
local CSNull = Runtime.CSNull
-- local CSValid = Runtime.CSValid
local entityRoot = nil

local EntityTypes = {
    [EntityType.Monster] = {
        path = "Cleaner.Entity.MonsterEntity",
        config = "MonsterTemplate",
        dataPath = "Cleaner.Entity.Data.MonsterEntityData",
        assetpath = "Prefab/Art/Characters/Monster/%s.prefab",
    },

    [EntityType.Pet] ={
        path = "Cleaner.Entity.PetEntity",
        config = "PetTemplate",
        dataPath = "Cleaner.Entity.Data.PetEntityData",
        assetpath = "Prefab/Art/Characters/Monster/%s.prefab",
    },

    [EntityType.PetHL] ={
        path = "Cleaner.Entity.PetHLEntity",
        config = "PetTemplate",
        dataPath = "Cleaner.Entity.Data.PetHLEntityData",
        assetpath = "Prefab/Art/Characters/Monster/%s.prefab",
    },

    [EntityType.Ship] ={
        path = "Cleaner.Entity.ShipEntity",
        config = "ShipTemplate",
        dataPath = "Cleaner.Entity.Data.ShipEntityData",
        assetpath = "Prefab/BindingObject/%s.prefab",
    },
}

function EntityManager:RegisterEvents()
    --MessageDispatcher:AddMessageListener(MessageType.Global_After_Player_Levelup, self.TriggerDragonShopRedRot, self)
end

function EntityManager:UnregisterEvents()
    --MessageDispatcher:RemoveMessageListener(MessageType.Global_After_Player_Levelup, self.TriggerDragonShopRedRot, self)
end

--每次进入场景执行一次
function EntityManager:Initialize(callback)
    self:RegisterEvents()
end

function EntityManager:HandleClick()
    local ids = UserInput.getCastList()

    for _, id in pairs(ids) do
        local entity = self:GetEntity(id)
        if entity then
            entity:ProcessClick()
        end
    end
end

---------------------------------------- 生物相关 ----------------------------------------
function EntityManager:GetAllEntity()
    local entities = {}
    for _, v in pairs(self.entityDic) do
        table.insert(entities, v)
    end
    return entities
end

function EntityManager:NewInstanceId()
    self.instanceId = self.instanceId + 1
    return self.instanceId
end

---@type BaseEntity
function EntityManager:GetEntity(entityId)
    return self.entityDic[entityId]
end

---@type BaseEntity
function EntityManager:GetEntityWithName(name)
    local entityId = tonumber(name)
    if not entityId then
        return nil
    end
    return self:GetEntity(entityId)
end

function EntityManager:CreateWithType(id, entityType)

end

function EntityManager:CreateEntity(id, entityType, callback)
    local typeData = EntityTypes[entityType]
    local entityId = self:NewInstanceId()
    local config = AppServices.Meta:Category(typeData.config)
    local meta = config[id]
    local assetPath = string.format(typeData.assetpath, meta.model)
    local data = include(typeData.dataPath)
    local entityData = data.new(meta)
    local entityClass = include(typeData.path)
    local baseEntity = entityClass.new(entityId, meta)

    local finish = function(go)
        baseEntity:InitData(entityData)
        baseEntity:BindView(go)

        self.entityDic[baseEntity.entityId] = baseEntity
        if baseEntity.NeedLateUpdate and baseEntity:NeedLateUpdate() then
            table.insert(self.entityCallLateUpate, baseEntity.entityId)
        end
        InvokeCbk(callback, baseEntity)
    end

    self:CreateEntityGoAsync(assetPath, finish)
end

function EntityManager:CreateEntityGo(sn, entityType, callback)
    local typeData = EntityTypes[entityType]
    local config = AppServices.Meta:Category(typeData.config)
    local meta = config[sn]
    local assetPath = string.format(typeData.assetpath, meta.model)

    self:CreateEntityGoAsync(assetPath, callback)
end

function EntityManager:CreateEntityGoAsync(assetPath, callBack)
    App.buildingAssetsManager:LoadAssets(
        {assetPath},
        function()
            local go = BResource.InstantiateFromAssetName(assetPath)
            local parent = self:GetRoot()
            go:SetParent(parent, false)
            InvokeCbk(callBack, go)
        end
    )
end

function EntityManager:GetRoot()
    if CSNull(entityRoot) then
        entityRoot = GameObject("MagicalCreaturesRootCanvas")
        entityRoot:SetLocalScale(Vector3.one)
        entityRoot:SetPosition(Vector3.zero)
    end
    return entityRoot
end

function EntityManager:RemoveEntity(entityId)
    local entity = self.entityDic[entityId]
    if entity then
        self.entityDic[entityId] = nil
        entity:Destroy()

        PetFollowPlayer:RemoveEntity(entity.entityId)
        AppServices.EventDispatcher:dispatchEvent(EntityEvent.ENTITY_DESTROY, entityId)
    end
end

---------------------------------------- 刷新相关 ----------------------------------------
function EntityManager:LateUpdate()
    if self.isDirty then
        self:WriteToFile()
    end

    for i = #self.entityCallLateUpate, 1, -1 do
        local entityId = self.entityCallLateUpate[i]
        local entity = self.entityDic[entityId]
        if not entity then
            table.remove(self.entityCallLateUpate, i)
        else
            entity:LateUpdate()
        end
    end
end

function EntityManager:OnDayRefresh()
    self.day_count = self.day_count + 1
    self:MarkDirty()
    --重置玩家龙技能释放次数
    self:SetDailySkillCnt(0)
    MessageDispatcher:SendMessage(MessageType.ResetDragonSpellCnt)
end

---------------------------------------- 数据相关 ----------------------------------------
function EntityManager:MarkDirty()
    self.isDirty = true
end

function EntityManager:RegisterEvents()
    UserInput.registerListener(self, UserInputType.clickEntity, self.HandleClick)
end

function EntityManager:UnRegisterEvent()
    UserInput.removeListener(self, UserInputType.clickEntity)
end

function EntityManager:Release()
    self:UnregisterEvents()
end

return EntityManager
