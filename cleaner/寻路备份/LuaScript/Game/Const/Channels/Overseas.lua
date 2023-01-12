local rpcHost = "https://dtest.gameyici.com" -- Server(国内服)

------------------------DO NOT TOUCH THE FOLLOWING CODE-----------------------
if RuntimeContext.PKG_OVERSEA then
    rpcHost = "https://online.hphorse.net"
elseif RuntimeContext.PKG_QA then
    rpcHost = "https://dqa.hphorse.net"
elseif RuntimeContext.PKG_ACTIVITY then
    rpcHost = "https://dact.gameyici.com"
end
-- rpcHost = "http://10.0.60.202:8083" --宏旭
-- rpcHost = "http://10.0.60.195:8083" --张立
-- rpcHost = "http://10.0.60.206:8083" --包福珍
rpcHost = "cleaner.hphorse.net" --林晨光
local port = 59999
NetworkConfig = {
    rpcUrl = rpcHost,
    rpcPort = port,
    logicUrl = rpcHost .. "/game",
    chatUrl = rpcHost .. "/chat",
    videoUrl = "https://cdn.gameyici.com", --视频服务器
    shutDownServerUrl = "https://cdn.gameyici.com/Maintenance_time.txt",    --停服公告地址
    appStoreUrl_iOS = "https://apps.apple.com/au/app/dragon-farm-adventure-fun-game/id1563159261",
    appStoreUrl_android = "https://play.google.com/store/apps/details?id=com.dragonmonster.idlefarmadventure.free",
    cdKeyUrl =  rpcHost .. "/auth/wind-service/gift-code",
}

---------------------- SWITCHERS ---------------------
