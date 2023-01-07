
local NetDefine =
{
    NetState =
    {
        None = "None",                              -- 出事状态
        Connecting = "Connecting",                  -- 建立连接的过程中农
        Connected = "Connected",                    -- 连接成功
        Game = "Game",                              -- 接收到秘钥后
        ConnectFailed = "ConnectFailed",            -- 连接时报
        Closed = "Closed",                          -- 客户端主动关闭连接
        Disconnect = "Disconnect",                  -- 服务器关闭连接或者解析消息出错
        PingTimeout = "PingTimeout",                -- 超时
    },

    MessageLenSize = 4,
    MessageIdSize = 4,
    PingInterval = 30,
    CheckPing = false,
    ConnectTimeout = 2,
    PingTimeout = 45,
    AutoReconnectCount = 3,
    UseRC4Crypt = false,
    BigEndian = true,
}

return NetDefine
