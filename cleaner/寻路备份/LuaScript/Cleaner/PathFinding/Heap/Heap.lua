---@class Heap 优先队列/大根堆/小根堆
local Heap = class(nil, "Heap")

function Heap:ctor()
    -- 此处使用 List 是为了偷懒，因为涉及到 插入 insert 和删除 delet
    -- 如果使用数组首先开辟多大空间不确定假设开辟 N 个空间，则还需要
    -- 记录当前已经使用到哪个下标索引了记为 size。且当 size >= N 时
    -- 还需要手动再次开辟空间
    self.list = {}

    -- 是否大根堆
    self._isBigHeap = true;
end

function Heap:SetHeapType(isBigHeap)
    self._isBigHeap = isBigHeap
end

function Heap:DataList()
    return self.list
end

function Heap:MakeEmpty()
    self.list = {}
end

function Heap:Count()
    return #self.list
end

-- lua 中 table 数组是从 1 开始的
-- 一个节点 index
-- 父节点 parentIndex =  math.floor(index / 2)
-- 第一个子节点 child1 = index * 2
-- 第二个子节点 child2 = index * 2 + 1

function Heap:ParentIndex(index)
    index = math.floor(index / 2)
    return index
end

function Heap:Insert(value)
    table.insert(self.list, value)
    self:PercolateUp(self.list, #self.list);
end

-- 获取根节点
function Heap:GetRoot()
    if #self.list <= 0 then
        return 0
    end
    return self.list[1]
end

-- 删除根节点
function Heap:DelRoot()
    if #self.list <= 0 then
        return 0
    end

    local root = self.list[1]
    -- 删除堆顶元素，将末元素填补到堆顶。
    local count = #self.list

    -- 令堆定的元素等于最后一个元素
    self.list[1] = self.list[count]
    -- 删除最后一个元素
    table.remove(self.list, count)

    -- 对堆顶元素下虑
    self:PercolateDown(self.list, 1, #self.list);

    return root
end

-- 批量建堆
function Heap:HeapCreate()
    -- 批量建堆思路为从最后一个非叶子节点开始下虑，一直到跟节点结束
    -- 所有非叶子节点执行完下虑堆自然而成
    local index = self:ParentIndex(#self.list)
    for i = index, 1, -1 do
        self:PercolateDown(self.list, i, #self.list)
    end
end

-- 上虑
function Heap:PercolateUp(dataList, index)
    if index > #dataList then
        return
    end

    -- 直到抵达堆顶
    while (index > 1) do
        -- 获取 index 的父节点
        local parentIndex = self:ParentIndex(index)
        -- 逆序(父节点<子节点)则互换父/子节点的值
        if (self:Compare(dataList[parentIndex], dataList[index]) >= 0) then
            break
        end

        local temp = dataList[parentIndex]
        dataList[parentIndex] = dataList[index]
        dataList[index] = temp

        index = parentIndex
    end
end

-- 下虑
function Heap:PercolateDown(dataList, index, length)
    if (index > #dataList) then
        return
    end

    -- 令 index 位置的值 为自身和子节点中最大者
    local rootIndex = self:ProperParent(dataList, index, length)
    while (index ~= rootIndex) do
        -- index 位置的值，比子节点的值小，则互换自身与较大子节点的值
        local temp = dataList[rootIndex]
        dataList[rootIndex] = dataList[index]
        dataList[index] = temp

        -- 互换位置，继续下虑
        index = rootIndex;
        rootIndex = self:ProperParent(dataList, index, length)
    end
end

-- 自己和左右两个子节点中最大者
function Heap:ProperParent(dataList, index, length)

    local leftChildIndex = index * 2
    local rightChildIndex = index * 2 + 1

    if (length >= leftChildIndex) then
        index = self:Compare(dataList[index], dataList[leftChildIndex]) >= 0 and index or leftChildIndex
    end

    if (length >= rightChildIndex) then
        index = self:Compare(dataList[index], dataList[rightChildIndex]) >= 0 and index or rightChildIndex
    end
    return index
end

function Heap:Compare(x, y)
    local compare = 0
    if type(x) == "number" and type(y) == "number" then
        compare = x - y
    else
        compare = x:CompareTo(y)
    end
    return self._isBigHeap and compare or compare * -1
end

return Heap