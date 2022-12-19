local Deque = {}

function Deque.new()
    return {first = 0, last = -1}
end

function Deque.isEmpty(deque)
    return deque.first > deque.last
end

function Deque.pushFront(deque, value)
    local first = deque.first - 1
    deque.first = first
    deque[first] = value
end

function Deque.pushBack(deque, value)
    local last = deque.last + 1
    deque.last = last
    deque[last] = value
end

function Deque.popFront(deque)
    local first = deque.first
    if first > deque.last then
        error("Deque is empty")
    end
    local value = deque[first]
    deque[first] = nil
    deque.first = first + 1
    return value
end

function Deque.popBack(deque)
    local last = deque.last
    if deque.first > last then
        error("Deque is empty")
    end
    local value = deque[last]
    deque[last] = nil
    deque.last = last - 1
    return value
end

return Deque