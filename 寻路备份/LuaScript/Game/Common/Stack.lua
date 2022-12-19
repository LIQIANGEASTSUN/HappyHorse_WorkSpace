---@class Stack
local Stack = class(nil, "stack")

function Stack:Create()
    local instance = Stack.new()
    return instance
end

function Stack:ctor()
    self.list = {}
    self.count = 0
end

function Stack:push(obj)
    table.insert(self.list, obj)
    self.count = self.count + 1
end

function Stack:pop()
    if self.count > 0 then
        local obj = self.list[self.count]
        table.remove(self.list)
        self.count = self.count - 1
        return obj
    end
end

function Stack:size()
    return self.count
end

function Stack:Top()
    return self.list[self.count]
end

function Stack:Clear()
    self.list = {}
    self.count = 0
end

return Stack