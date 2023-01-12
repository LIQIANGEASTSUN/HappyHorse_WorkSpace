---@type BuffInfo
local BuffInfo = require "Cleaner.Fight.Buff.BuffInfo"

---@class BuffManager
local BuffManager = class(nil, "BuffManager")

function BuffManager:ctor(fightUnit)
    ---@type FightUnitBase
    self.owner = fightUnit

    self.buffMap = {}
    self.lastTime = 1
    self.TIME_INTERVAL = 0.1
    self.instanceId = 0
end

function BuffManager:GetOwner()
    return self.owner
end

function BuffManager:AddBuff(buffId, casterData)
    local buffKey = tostring(buffId)
    local enableAdd = self:EnableAddBuff(buffKey)
    if not enableAdd then
        return
    end

    local buffConfig = AppServices.Meta:Category("BuffTemplate")[buffKey]
    local priority = buffConfig.priority

    local newBuff = self:CreateBuff(buffConfig, casterData)
    local oldBuff = self:GetBuffWithBuffId(buffKey)

    local useNew = (not oldBuff) or (priority == BuffInfo.PriorityType.Overlay)
    if useNew then
        self:RemoveBuff(buffKey)
        local instanceId = newBuff:GetInstanceId()
        self.buffMap[instanceId] = newBuff
        newBuff:Applay()
    else
        oldBuff:AddLayer(1)
        oldBuff:Superposition()
    end
end

function BuffManager:RemoveBuff(instanceId)
    local buff = self:GetBuffWithInstanceId(instanceId)
    if buff then
        buff:Remove()
        self.buffMap[instanceId] = nil
    end
end

-- 移除所有有害 buff
function BuffManager:RemoveAllHarmfulBuff()
    local removes = {}
    for _, buff in pairs(self.buffMap) do
        local advantage = buff:GetBuffAdvantage()
        if advantage == BuffInfo.AdvantageType.Harmful then
            local instanceId = buff:GetInstanceId()
            table.insert(removes, instanceId)
        end
    end

    for _, instanceId in pairs(removes) do
        self:RemoveBuff(instanceId)
    end
end

function BuffManager:ClearBuff()
    for _, buff in pairs(self.buffMap) do
        buff:Remove()
    end
    self.buffMap = {}
end

-- 检查当前添加的所有buff，是否可以添加 新的buffId，如存在免疫buff，则无法添加有害的buff
function BuffManager:EnableAddBuff(buffKey)
    local result = true
    for _, buff in pairs(self.buffMap) do
        result = buff:EnableAddBuff(buffKey)
        if not result then
            break
        end
    end

    return result
end

function BuffManager:CreateBuff(buffConfig, casterData)
    local instanceId = self:NewInstanceId()
    local buffType = buffConfig.buffType
    local buffAlias = BuffInfo.GetBuffAlias(buffType)
    local buffInstance = buffAlias.new(instanceId, self, tostring(buffConfig.sn), casterData)
    return buffInstance
end

function BuffManager:GetBuffWithInstanceId(instanceId)
    return self.buffMap[instanceId]
end

function BuffManager:GetBuffWithBuffId(buffId)
    local result = nil
    for _, buff in pairs(self.buffMap) do
        if buff:GetBuffId() == buffId then
            result = buff
        end
    end

    return result
end

function BuffManager:Trigger(type, data)
    for _, buff in pairs(self.buffMap) do
        buff:Trigger(type, data)
    end
end

function BuffManager:LateUpdate()
    if Time.realtimeSinceStartup - self.lastTime <= self.TIME_INTERVAL then
        return
    end

    for _, buff in pairs(self.buffMap) do
        buff:LateUpdate()
    end
end

function BuffManager:NewInstanceId()
    self.instanceId = self.instanceId + 1
    return self.instanceId
end

return BuffManager