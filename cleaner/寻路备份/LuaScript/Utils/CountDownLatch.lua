CountDownLatch = class()

function CountDownLatch.Create(count, cb)
    local inst = CountDownLatch.new(count, cb)
    return inst
end

function CountDownLatch:ctor(count, cb)
    self.count = count or 1
    self.cb = cb
end

function CountDownLatch:Done()
    self.count = self.count - 1
    if self.count == 0 then
        return self.cb()
    end
end