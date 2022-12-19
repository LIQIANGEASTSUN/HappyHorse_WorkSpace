---@class Queue
local Queue = class(nil, "Queue")

function Queue:Create()
    local instance = Queue.new()
    return instance
end

function Queue:ctor()
    self.list = {}
    self.count = 0
end

function Queue:enQueue(obj)
    table.insert(self.list, obj)
    self.count = self.count + 1
end

function Queue:deQueue()
    if self.count > 0 then
        local obj = self.list[1]
        table.remove(self.list, 1)
        self.count = self.count - 1
        return obj
    end
end

function Queue:size()
    return self.count
end

function Queue:isEmpty()
    return self.count == 0
end

return Queue
