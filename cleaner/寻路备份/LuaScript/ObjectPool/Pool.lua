local PoolEntity = require "ObjectPool.PoolEntity"
local Queue = require "Game.Common.Queue"
---@class Pool
local Pool = class(nil, "Pool")

function Pool:ctor()
    self.poolEntitys = {}
    self.path = ""
    self.queue = Queue.Create()
    self.rootGo = nil
    self.maxCount = 0
end

function Pool:Init(params, parent)
    self.rootGo = parent
    self.path = params.path
    self.maxCount = params.maxCount or 8
end

function Pool:GetEntity(autoShow)
    --先查找队列中是否有可用资源，否则创建新资源
    local function getNew()
        if self.queue.count > 0 then
            return self.queue:deQueue()
        end

        local entity = PoolEntity.new(self.path, self.rootGo.transform)
        table.insert(self.poolEntitys, entity)
        return entity
    end

    local newEntity = getNew()
    newEntity.dirty = true
    if autoShow then
        newEntity:Show()
    end

    return newEntity
end

--默认回收自动隐藏。如果隐藏前需要增加操作，则需要手动隐藏
---@param go PoolEntity 回收的资源池实例
---@param resetParam string[] @{"doTween","parent","postion"...}
function Pool:RecycleEntity(go, resetParam)
    if not go.dirty then
        console.lj(go.gameObject.name .. "已经被其他地方回收,检查逻辑是否正常") --@DEL
        return
    end
    if #self.poolEntitys > self.maxCount then
        table.removeIfExist(self.poolEntitys, go)
        go:Destroy()
        return
    end

    --检查是否需要重置，没有就直接跳过。
    if resetParam then
        go:Reset(resetParam)
    end
    self.queue:enQueue(go)
    go.dirty = false
    go:Hide()
end

--整体回收资源池
function Pool:RecyclePool()
    for _, entity in pairs(self.poolEntitys) do
        if entity.dirty then
            self:RecycleEntity(entity)
        end
    end
end

--资源池销毁
function Pool:DestroyPool()
    for _, entity in pairs(self.poolEntitys) do
        entity:Destroy()
    end
    self.poolEntitys = nil
    self.path = nil
    self.queue = nil
    self.rootGo = nil
    self.maxCount = nil
end

return Pool
