
---@type EffectEntity
local EffectEntity = require "Cleaner.Effect.EffectEntity"

---@type EffectInfo
local EffectInfo = require "Cleaner.Effect.EffectInfo"

---@type EffectManager
local EffectManager = {
    effectMap = {},
    instanceId = 0
}

-- 在世界坐标位置播放特效
function EffectManager:Play(effectName, position)
    local id = self:NewInstanceId()
    local data = {
        type = EffectInfo.WorldPosition,
        effectName = effectName,
        position = position
    }

    local entity = EffectEntity.new(id, data)
    self:AddEntity(entity)
    return entity:GetInstanceId()
end

-- 按照 Transform 局部坐标播放特效
function EffectManager:PlayTargetLocal(effectName, targetTr, localPosition, follow)
    local id = self:NewInstanceId()

    local data = {
        type = EffectInfo.TargetLocal,
        effectName = effectName,
        targetTr = targetTr,
        localPosition = localPosition,
        follow = follow
    }

    local entity = EffectEntity.new(id, data)
    self:AddEntity(entity)
    return entity
end

-- 根据 Transfor 骨骼位置播放特效
function EffectManager:PlayTargetBone(effectName, targetTr, bone, follow)
    local id = self:NewInstanceId()

    local data = {
        type = EffectInfo.TargetBone,
        effectName = effectName,
        targetTr = targetTr,
        bone = bone,
        follow = follow
    }

    local entity = EffectEntity.new(id, data)
    self:AddEntity(entity)
    return entity
end

function EffectManager:AddEntity(entity)
    local instanceId = entity:GetInstanceId()
    self.effectMap[instanceId] = entity
end

function EffectManager:RemoveEntity(instanceId)
    local entity = self.effectMap[instanceId]
    if entity then
        entity:Destroy()
        self.effectMap[instanceId] = nil
    end
end

function EffectManager:LateUpdate()
    self.remove = {}
    for _, entity in pairs(self.effectMap) do
        entity:LateUpdate()
        local timeEnd = entity:IsTimeEnd()
        if timeEnd then
            table.insert(self.remove, entity:GetInstanceId())
        end
    end

    for _, id in pairs(self.remove) do
        self:RemoveEntity(id)
    end
end

function EffectManager:NewInstanceId()
    self.instanceId = self.instanceId + 1
    return self.instanceId
end

return EffectManager