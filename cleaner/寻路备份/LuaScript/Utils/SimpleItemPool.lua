local createInstance = function()
    ---@class SimpleItemPool
    local SimpleItemPool = {}

    function SimpleItemPool:Init(createItemFunc, prewarmSize)
        self.createItemFunc = createItemFunc
        self.pool = {}
        self.index = 1

        if prewarmSize and prewarmSize > 0 then
            self:Prewarm(prewarmSize)
        end
    end

    function SimpleItemPool:Prewarm(prewarmSize)
        for index = 1, prewarmSize do
            local item = self:GetItem()
            item.gameObject:SetActive(false)
        end
        self.index = 1
    end

    function SimpleItemPool:GetItem()
        local item
        if self.index > #self.pool then
            item = self.createItemFunc()
            table.insert(self.pool, item)
        else
            item = self.pool[self.index]
        end
        self.index = self.index + 1

        return item
    end

    function SimpleItemPool:ClearAll()
        for index, value in ipairs(self.pool) do
            value.gameObject:SetActive(false)
        end
        self.index = 1
    end

    return SimpleItemPool
end

return createInstance
