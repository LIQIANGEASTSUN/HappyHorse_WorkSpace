-- 道具网络消息模块
---@class NetItemManager
local NetItemManager = {}

function NetItemManager:Init()
    self:RegisterEvent()
end

-- 角色道具变化 返回的是最终值 不是变化值
function NetItemManager:ReceiveItemChange(msg)
    if msg.add then
        for _, item in pairs(msg.add) do
            AppServices.User:SetPropNumber(item.sn, item.num)
        end
    end

    if msg.del then
        for _, item in pairs(msg.del) do
            AppServices.User:SetPropNumber(item.sn, item.num)
        end
    end
end

function NetItemManager:RegisterEvent()
    AppServices.NetWorkManager:addObserver(MsgMap.SCItemChanged, self.ReceiveItemChange, self)
end

function NetItemManager:UnRegisterEvent()
    AppServices.NetWorkManager:removeObserver(MsgMap.SCItemChanged, self.ReceiveItemChange, self)
end

function NetItemManager:Release()
    self:UnRegisterEvent()
end

return NetItemManager