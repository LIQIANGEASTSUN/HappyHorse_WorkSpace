---@class NetIslandManager
local NetIslandManager = {}

-- 初始化
function NetIslandManager:Init()
    self:RegisterEvent()
end

-- 发送出航消息
function NetIslandManager:SendChangeIsland(islandId)
    --[[
    //切换岛屿, 发送给服务器的消息体
    message CSChangeIsland {
        required int32 sn = 1; // 岛屿sn
    }
    ]]

    -- 构建消息体，按照上面消息体的字段写就行了
    -- 如果是 repeated 开头的字段按照数组写就行了
    -- 如下
    --message CSxxx {
    --    repeated int32 xxxs = 1;
    --}
    -- local msg = { xxxs = {5, 10, 3} }

    local msg = { sn = islandId }
    AppServices.NetWorkManager:Send(MsgMap.CSChangeIsland, msg)
end

-- 接收出航
function NetIslandManager:ReceiveChangeIsland(msg)
    --[[
    接收消息的消息体
    message SCChangeIsland {
        required int32 sn = 1; // 岛屿sn
    }
    ]]
    -- 上面消息体中有设么字段，就直接用哪个字段取
    local islandId = msg.sn

    AppServices.User:SetPlayerIslandInfo(islandId)
end

function NetIslandManager:SendUnlockIsland(sn)
    local msg = {
        sn = tonumber(sn)
    }
    AppServices.NetWorkManager:Send(MsgMap.CSUnlockIsland, msg)
end

-- 岛屿解锁
function NetIslandManager:ReceiveUnlockIsland(msg)
    local islandId = tonumber(msg.sn)
    AppServices.User:SetUnlockIsland(islandId)
end

-- 岛屿连接到家园
function NetIslandManager:ReceiveLinkIsland(msg)
    local islandId = tonumber(msg.sn)
    AppServices.User:SetLinkIsland(islandId)
end

-- 注册消息
function NetIslandManager:RegisterEvent()
    -- 注册消息
    AppServices.NetWorkManager:addObserver(MsgMap.SCChangeIsland, self.ReceiveChangeIsland, self)
    AppServices.NetWorkManager:addObserver(MsgMap.SCUnlockIsland, self.ReceiveUnlockIsland, self)
    AppServices.NetWorkManager:addObserver(MsgMap.SCLinkIsland, self.ReceiveUnlockIsland, self)
end

-- 移除消息
function NetIslandManager:UnRegisterEvent()
    -- 移除消息
    AppServices.NetWorkManager:removeObserver(MsgMap.SCChangeIsland, self.ReceiveChangeIsland, self)
    AppServices.NetWorkManager:removeObserver(MsgMap.SCUnlockIsland, self.ReceiveUnlockIsland, self)
    AppServices.NetWorkManager:removeObserver(MsgMap.SCLinkIsland, self.ReceiveLinkIsland, self)
end

-- 释放
function NetIslandManager:Release()
    self:UnRegisterEvent()
end

return NetIslandManager