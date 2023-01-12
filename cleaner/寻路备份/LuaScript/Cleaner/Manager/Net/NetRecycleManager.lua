-- 宠物网络消息模块
---@class NetRecycleManager
local NetRecycleManager = {
    recycles = {}
}

function NetRecycleManager:Init()
    self:RegisterEvent()
end

function NetRecycleManager:Recycle(info)
    local recycles = {}
    for _, item in ipairs(info) do
        local itemCfg = AppServices.Meta:GetItemMeta(item.key)
        for _, recycleItem in ipairs(itemCfg.recycleItem) do
            local id, cnt = recycleItem[1], recycleItem[2]
            recycles[id] = (recycles[id] or 0) + cnt
        end
    end
    table.insert(self.recycles, recycles)
    AppServices.NetWorkManager:Send(MsgMap.CSRecycle, info)
end

function NetRecycleManager:OnRecycle()
    if #self.recycles > 0 then
        local recycle = table.remove(self.recycles, 1)
        MessageDispatcher:SendMessage(MessageType.Global_After_Recycle, recycle)
    end
end

function NetRecycleManager:RegisterEvent()
    AppServices.NetWorkManager:addObserver(MsgMap.SCRecycle, self.OnRecycle, self)
end

function NetRecycleManager:UnRegisterEvent()
    AppServices.NetWorkManager:removeObserver(MsgMap.SCRecycle, self.OnRecycle, self)
end

function NetRecycleManager:Release()
    self:UnRegisterEvent()
end

return NetRecycleManager