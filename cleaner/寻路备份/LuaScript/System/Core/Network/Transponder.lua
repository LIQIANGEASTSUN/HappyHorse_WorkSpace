--local GatewayModule_pb = require "Protocol.Message.GatewayModuleMsg_pb"

---@class RpcRequest
local RpcRequest = {}
function RpcRequest.new(messageId, data, handler, extraParams)
    console.assert(handler)
    extraParams = extraParams or {}
    return {
        messageId = messageId,
        data = data,
        handler = handler,
        ts = extraParams.ts or TimeUtil.ServerTimeMilliseconds(),
        sequenceId = extraParams.sequenceId,
        version = extraParams.version or RuntimeContext.BUNDLE_VERSION,
        url = extraParams.url
        --isOfflineRequest = extraParams.isOfflineRequest or false
    }
end
-----------------------------------------------------------------
---@class Transponder
local Transponder = class()
function Transponder:ctor(config)
    self.queueSize = config.queueSize or 5
    self.flushInterval = config.flushInterval or 10 -- 10s, not really use it

    ---@type RpcRequest[]
    self.queue = {}
    self.time = 0
    self.blocked = false
    self.senderId = "VISITOR"
    self.sessionId = -999
    self.sequenceId = 0
    ---@type array<RpcRequest[]>
    self.sendQueue = {}
    self.sendQueueIndex = 0

    self.timeoutTs = 0 -- 超时出错的次数
end

function Transponder:invalidateSessionKey()
    --self.processor.sessionKey = nil
end

function Transponder:setSessionKey(key)
    self.sessionId = key
end

function Transponder:isBlocked()
    return self.blocked
end

function Transponder:block()
    self.blocked = true
end

function Transponder:unblock()
    self.blocked = false
end

function Transponder:flush(showLoading)
    self.blocked = false
    self:send(showLoading, true)
end

function Transponder:isNetworkReady()
    -- fast timeout response
    if math.abs(os.time() - self.timeoutTs) <= 4 then
        return false
    end
    if math.abs(os.time() - self.timeoutTs) <= 60 and BCore.GetNetworkReachability() <= 0 then
        return false
    end
    return true
end

function Transponder:call(messageId, data, handler, extraParams, showLoading)
    if showLoading == nil then
        showLoading = true
    end
    local request = RpcRequest.new(messageId, data, handler or {}, extraParams)
    console.print("Transponder Log : call", messageId) --@DEL
    table.insert(self.queue, request)
    if not self.blocked then
        --[[
        if messageId ~= 1001 and messageId ~= 1002 and table.size(self.queue) > 0 then
            WaitExtension.InvokeDelay(function()
                self:send(showLoading)
            end)
            return
        end
        ]]
        self:send(showLoading)
    end
end

function Transponder:startConnectionPanel(showloading)
    AppServices.Connecting:ShowPanel(showloading)
end

function Transponder:removeConnectionPanel()
    AppServices.Connecting:ClosePanel()
end

function Transponder:ShowRestartBoard(callback, errorCode)
    AppServices.Connecting:ShowRestartBoard(callback, errorCode)
end

--队列协议发送处理的核心逻辑：
--将需要发送的协议先压入发送队列
--显示转菊花
--屏蔽发送状态下有其他新的协议请求，等待前面的请求执行完
--self.sendQueue = [[RpcRequest,...],[RpcRequest,...],... ]
function Transponder:send(showLoading, isMerge)
    if table.size(self.queue or {}) > 0 then
        local requests = self.queue
        self.queue = {}
        local function CheckNeedNew()
            if not RuntimeContext.USE_MERGER_MSG then
                return true
            end

            if #self.sendQueue == 0 then
                return true
            end

            if isMerge then
                return true
            end

            if (#self.sendQueue[#self.sendQueue] + #requests) > 5 then
                return true
            end

            if self.sendQueue[#self.sendQueue][#self.sendQueue[#self.sendQueue]].sequenceId then
                return true
            end
            return false
        end

        if CheckNeedNew() then
            table.insert(self.sendQueue, requests)
        else
            for index, request in ipairs(requests) do
                table.insert(self.sendQueue[#self.sendQueue], request)
            end
        end
    end

    local requests = self.sendQueue[1]

    -- 即使是在sending当中，如果有请求需要showLoading，也应该迅速showLoading
    -- if showLoading and requests then
    -- end
    -- 任何时候都要showLoading 只不过当 showLoading == false的时候, 先静默一秒(ConnectingTimeConfig配置)
    console.print("Transponder Log : send", requests and #requests or 0, showLoading) --@DEL
    if requests then
        AppServices.Connecting:SetMessageId(requests[1].messageId)
        self:startConnectionPanel(showLoading)
    end

    if self.isInSending then
        --console.lj("当前有协议在发送,准备发送的协议："..self.sendQueue[#self.sendQueue].messageId.."正在发送的协议:"..requests[1].messageId)
        return
    end

    if table.isEmpty(requests) then
        self.isInSending = false --貌似没啥用的逻辑
        return
    end

    self.isInSending = true
    -- if self.queue[1].messageId == 1001 or self.queue[1].messageId ==1002 or #self.queue >= self.queueSize then
    --     self.queue = {}
    -- end
    --[[处理错误反馈的回调
    local function finishRemainingHandlers(requestQueue, startIndex, resultCode)
        for i = startIndex, #requestQueue do
            local queueRequests = requestQueue[i]
            for k, v in ipairs(queueRequests) do
                if v.handler then
                    Runtime.InvokeCbk(v.handler.onFailed, ErrorCodeEnums.NOT_SENT)
                end
            end
        end
    end
    ]]
    local function sendNextInQueue(resultCode)
        self.sendQueueIndex = self.sendQueueIndex + 1
        requests = self.sendQueue[self.sendQueueIndex]

        --所有协议都执行完了
        if table.isEmpty(requests) then
            self:FinishSend()
            return
        end

        --如果上条协议包为空，或者发送已成功，则触发下一个协议包到网关，网关单独处理协议包中的序列，并将结果反馈回当前的sendNextInQueue函数
        if resultCode == ErrorCodeEnums.SUCCESS then
            self:sendGatewayRequest(requests, sendNextInQueue, self.sendQueueIndex)
            return
        end
        console.error("should not here") --@DEL
        --如果反馈结果为其他（一般都为前端自定义错误，目前多用于离线消息），则清空队列，并将结果返回到协议的错误回调中
        --目前设计中不应该出现这个流程，如果有服务器错误则返回登录界面，有网络错误，则保持重连
        --如果重连失败目前会返回一个超时错误
        --[[
        local queue = self.sendQueue
        local index = self.sendQueueIndex
        FinishSend()
        -- 下一帧执行,新需求应该不需要由协议处理服务器的错误回调
        WaitExtension.InvokeDelay(
            function()
                finishRemainingHandlers(queue, index, resultCode)
            end
        )
        ]]
    end
    sendNextInQueue(ErrorCodeEnums.SUCCESS)
end

--结束当前的请求
function Transponder:FinishSend()
    self.isInSending = false
    self.sendQueueIndex = 0
    self.sendQueue = {}
    self:removeConnectionPanel()
end

--[[
function Transponder:CancelRemainingRequests(errorCode)
    local startIndex = self.sendQueueIndex + 1
    local requestQueue = self.sendQueue
    self.sendQueueIndex = 0
    self.sendQueue = {}
    for i = startIndex, #requestQueue do
        local queueRequests = requestQueue[i]
        for k, v in ipairs(queueRequests) do
            if v.handler then
                Runtime.InvokeCbk(v.handler.onFailed, errorCode)
            end
        end
    end
end
]]
---网关核心逻辑：将协议打包组装成
--params：协议发送地址
--protobuf：协议包体内容，已加密
--onSuccess：服务器反馈
---@param onError function http失败反馈
function Transponder:sendGatewayRequest(requests, finishCallback, gatewayIndex)
    local function GetPackageInfo(_requests)
        local package = GatewayModule_pb.GatewayPackageRequest()
        package.senderId = self.senderId
        package.sessionId = self.sessionId

        local version
        local pkgId = ""
        local url
        for i, request in ipairs(_requests) do
            --用于缓存，重连时重发用
            request.sequenceId = request.sequenceId or self:GetNewSequenceId()

            local data = package.bodys:add()
            data.code = 0
            data.msgId = request.messageId
            data.genTime = request.ts or TimeUtil.ServerTimeMilliseconds()
            data.msgBody = request.data:SerializeToString()
            data.sequenceId = request.sequenceId
            data.version = request.version or RuntimeContext.BUNDLE_VERSION
            if RuntimeContext.VERSION_DEVELOPMENT then
                pkgId = pkgId .. request.messageId .. "_"
            end
            -- 协议约定一个Gateway所有请求都是同一个版本号
            version = request.version
            url = request.url
        end

        return package, version, pkgId, url
    end

    --不存在离线消息了，因此不会有消息打包序列了
    --local offline_error = false

    --如果有错误则取消后面的协议发送，这里应该不再发送失败回调
    local requestFinishCounter = 0
    local totalRequests = #requests

    --body 组装httpPut参数
    local package, version, pkgId, url = GetPackageInfo(requests)
    local protobuf = package:SerializeToString()
    local params
    if url then
        params = url .. "/" .. version
    else
        params = NetworkConfig.logicUrl .. "/" .. version
    end
    local onServerResp, onHttpError
    if RuntimeContext.VERSION_DEVELOPMENT then
        params = params .. "?id=" .. pkgId .. "&uid=" .. self.senderId --@DEL
    end

    --服务器连接成功，并由服务器反馈的结果
    onServerResp = function(ret)
        local resp = GatewayModule_pb.GatewayPackageResponse()
        resp:ParseFromString(ret)
        local bodys = resp.bodys
        local flags = resp.flags
        --[[服务器系统时间
        --local serverTime = resp.serverTime
        --服务器玩家时间（默认使用玩家时间）
        local playerTime = resp.playerTime

        if playerTime then
            TimeUtil.ServerRefreshTime(playerTime)
        end]]
        --目前没有flag处理
        self:CheckFlags(flags)
        self.timeoutTs = 0

        for i, request in ipairs(requests) do
            local messageStruct = bodys[i]
            --数据报空，说明前面的序列已经出错了
            if table.isEmpty(messageStruct) then
                self:MsgWinRestartGame(ErrorCodeEnums.MSGISNULL)
                return
            end

            local errorCode = messageStruct.code or 500
            request.errorCode = errorCode
            if errorCode > 0 then
                self:OnErrorCode({errorCode = errorCode, url = params, msgId = request.messageId})
            end
            --SESSION过期：重连并重新发送此协议
            if errorCode == ErrorCodeEnums.SESSION_EXPIRED then
                local function Ingamelogin(result)
                    --重连失败，重新登陆吧
                    if not result then
                        self:MsgWinRestartGame(ErrorCodeEnums.TIMEOUT)
                        return
                    end

                    --重连成功，更新sequenceId后再发送一次网关协议
                    local function onReqSendFinish(errorCode)
                        --重登之后检查是否需要更新APP
                        console.assert(errorCode ~= nil, "has a bug here")
                        Runtime.InvokeCbk(finishCallback, errorCode)
                    end
                    self.isInSending = true
                    --未成功的协议需要再发一次，用老的sequenceId，服务器会缓存上一条的处理数据
                    --当这条处理完后之后的requests需要更新为最新的sequenceId
                    self:sendGatewayRequest(requests, onReqSendFinish, gatewayIndex)
                end

                self:OnSessionExpired(Ingamelogin)
                return
            end

            --被顶号：退出游戏
            if errorCode == ErrorCodeEnums.REPEATEDLOGIN then
                self:MsgWinRestartGame(ErrorCodeEnums.REPEATEDLOGIN)
                DcDelegates:Log("repeat_login")
                return
            end

            --版本错误:打开商城更新界面
            if errorCode == ErrorCodeEnums.VERSION_ERROR then
                self:removeConnectionPanel()
                -- 版本错误删除缓存，否则没法进游戏了
                --Offline.Instance():ClearAllForDebug()
                ErrorHandler.ShowErrorPanel(
                    errorCode,
                    function()
                        Util.OpenAppShopPage()
                    end
                )
                return
            end

            --服务器错误：重新登陆
            if IsRestartError(errorCode) then
                self:MsgWinRestartGame(errorCode)
                return
            end
            if request.handler then
                if errorCode == 0 then
                    Runtime.InvokeCbk(request.handler.onSuccess, messageStruct)
                else
                    Runtime.InvokeCbk(request.handler.onFailed, errorCode)
                end
            else
                console.error("No Handler Error", requests.messageId, request.sequenceId)
            end
            -- 由于后端错误码不一定遵守号段规则，所有没有特别定义的错误码都认为是离线错误码
            -- if errorCode > 2000 and request.isOfflineRequest then
            --if IsOfflineError(errorCode) and request.isOfflineRequest then
            --    offline_error = true
            --end

            requestFinishCounter = requestFinishCounter + 1
            if requestFinishCounter >= totalRequests then
                requestFinishCounter = 0
                --当前协议执行完毕，通知开始执行下一条协议
                Runtime.InvokeCbk(finishCallback, ErrorCodeEnums.SUCCESS)
            end
        end
    end

    --http反馈，原则上应该都可以重连（超时，404等）
    local count = 0
    onHttpError = function(errorCode, errorStr)
        errorCode = tonumber(errorCode) or 0
        if errorCode > 0 then
            self:OnErrorCode(
                {errorCode = errorCode, name = errorStr, url = params, msgId = pkgId},
                SDK_EVENT.show_httpError_code
            )
        end

        if errorCode == 2 then
            self.timeoutTs = os.time()
        end
        count = count + 1
        local loop = count % 5 ~= 0
        if requests then
            AppServices.Connecting:SetMessageId(requests[1].messageId)
        end
        self:Retry(
            function()
                App.httpClient:HttpPut(params, protobuf, onServerResp, onHttpError)
            end,
            errorCode,
            loop
        )
    end

    App.httpClient:HttpPut(params, protobuf, onServerResp, onHttpError)
end

function Transponder:OnSessionExpired(finishCallback)
    self.isInSending = false
    App.loginLogic:IngameLogin_start(
        nil,
        function(result)
            Runtime.InvokeCbk(finishCallback, result)
        end
    )
end
--[[
function Transponder:OnSessionExpired(requests, currentGatewayIndex, finishCallback)
    DcDelegates:Log("session_expired")

    self.isInSending = false
    App.loginLogic:IngameLogin( nil,nil,
        function(result)
            --重连失败，按超时处理
            if not result then
                Runtime.InvokeCbk(finishCallback, ErrorCodeEnums.TIMEOUT)
                return
            end

            --重连成功，更新sequenceId后再发送一次网关协议
            local function onReqSendFinish(errorCode)
                --重登之后检查是否需要更新APP
                console.assert(errorCode ~= nil, "has a bug here") --@DEL
                Runtime.InvokeCbk(finishCallback, errorCode)
            end
            self.isInSending = true
            --重新登陆导致sequenceId发生了变化，刷新request当前的sequenceId
            for i, request in ipairs(requests) do
                request.sequenceId = self:GetNewSequenceId()
            end
            self:sendGatewayRequest(requests, onReqSendFinish, currentGatewayIndex)
        end
    )
end
]]
function Transponder:sendLogin(messageId, _data, handler, extraParams, showLoading)
    if self.isLogin then
        return handler.onFailed(ErrorCodeEnums.NOT_PROCESSED)
    end

    self.isLogin = true
    self.isInSending = true
    local request = RpcRequest.new(messageId, _data, handler or {}, extraParams)

    local package = GatewayModule_pb.GatewayPackageRequest()
    package.senderId = "VISITOR"
    package.sessionId = -999

    local data = package.bodys:add()
    data.code = 0
    data.msgId = messageId
    data.genTime = request.ts or TimeUtil.ServerTimeMilliseconds()
    data.msgBody = request.data:SerializeToString()
    data.sequenceId = request.sequenceId or 0
    data.version = RuntimeContext.BUNDLE_VERSION

    if showLoading then
        AppServices.Connecting:SetMessageId(messageId)
        self:startConnectionPanel()
    end

    local params = NetworkConfig.logicUrl .. "/" .. RuntimeContext.BUNDLE_VERSION
    if RuntimeContext.VERSION_DEVELOPMENT then
        params = params .. "?id=" .. 1001 .. "&uid=" .. self.senderId --@DEL
    end

    local function onSuccess(ret)
        self.timeoutTs = 0
        self.isLogin = false
        self.isInSending = false

        -- 队列里面没有请求了才删除
        if not self.sendQueue[self.sendQueueIndex] then
            self:removeConnectionPanel()
        end

        local resp = GatewayModule_pb.GatewayPackageResponse()
        resp:ParseFromString(ret)
        local bodys = resp.bodys
        local flags = resp.flags
        self:CheckFlags(flags)

        local messageStruct = bodys[1]
        if not messageStruct then
            messageStruct = {code = ErrorCodeEnums.NOT_PROCESSED}
        end

        local errorCode = 500
        if messageStruct then
            errorCode = messageStruct.code
        end

        if errorCode > 0 then
            self:OnErrorCode({errorCode = errorCode, url = params, msgId = messageStruct.msgId})
        end

        if errorCode == ErrorCodeEnums.SESSION_EXPIRED then
            -- 如果login接口返回1006，直接报错
            ErrorHandler.ShowErrorPanel(
                ErrorCodeEnums.SESSION_EXPIRED,
                function()
                    --ReenterGame()
                    App:Quit({source = "sendLogin_sessionExpired"})
                end
            )
            return
        elseif errorCode == ErrorCodeEnums.REPEATEDLOGIN then
            self:removeConnectionPanel()
            ErrorHandler.ShowErrorPanel(
                ErrorCodeEnums.REPEATEDLOGIN,
                function()
                    --ReenterGame()
                    App:Quit({source = "sendLogin_repeat_login"})
                end
            )
            DcDelegates:Log("repeat_login")
            return
        elseif errorCode == ErrorCodeEnums.VERSION_ERROR then
            self:removeConnectionPanel()
            ErrorHandler.ShowErrorPanel(
                errorCode,
                function()
                    Util.OpenAppShopPage()
                end
            )
            return
        end

        if errorCode == 0 then
            Runtime.InvokeCbk(request.handler.onSuccess, messageStruct)
        else
            Runtime.InvokeCbk(request.handler.onFailed, errorCode)
        end
    end

    local count = 0
    local function onError(errorCode, errorStr)
        errorCode = tonumber(errorCode)
        if errorCode > 0 then
            self:OnErrorCode(
                {errorCode = errorCode, name = errorStr, url = params, msgId = 1001},
                SDK_EVENT.show_httpError_code
            )
        end
        if errorCode == 2 then
            self.timeoutTs = os.time()
        end

        self.isLogin = false
        self.isInSending = false
        --self:removeConnectionPanel()
        -- Runtime.InvokeCbk(request.handler.onFailed, errorCode)
        count = count + 1
        local loop = count % 5 ~= 0
        AppServices.Connecting:SetMessageId(messageId)
        self:Retry(
            function()
                App.httpClient:HttpPut(params, package:SerializeToString(), onSuccess, onError)
            end,
            errorCode,
            loop
        )
    end

    App.httpClient:HttpPut(params, package:SerializeToString(), onSuccess, onError)
end

function Transponder:dispose()
    self.class = nil
end

function Transponder:changeUID(uid)
    console.assert(uid) --@DEL
    self.senderId = uid
end

--目前没有用到这个接口，给离线用的
function Transponder:SetSequenceId(newSequenceId)
    console.error("SetSequenceId Will be discarded, DO NOT use it again") --@DEL
    self.sequenceId = newSequenceId
end

--登陆才会更新id，第一次使用时不需要递增
function Transponder:UpdateSequenceId(newSequenceId)
    console.print("UpdateSequenceId", newSequenceId, self.sequenceId) --@DEL

    --防止重连后服务器回退ID，导致新发送的SequenceId跟上一条的SequenceId一致而报错
    self.sequenceId = math.max(newSequenceId, self.sequenceId)
end

function Transponder:GetSequenceId()
    return self.sequenceId
end

function Transponder:GetNewSequenceId()
    self.sequenceId = self.sequenceId + 1
    return self.sequenceId
end

function Transponder:GetSendState()
    return self.isInSending
end

function Transponder:CheckFlags(flags)
    if table.maxn(flags) > 0 then
        Runtime.InvokeCbk(self.flagCall)
    end
end

---是否可重连
function Transponder:CanRetry(retryKey)
    self.retryCounts = self.retryCounts or {}
    self.retryCounts[retryKey] = (self.retryCounts[retryKey] or 0) + 1
    if self.retryCounts[retryKey] > 1 then
        return false
    end
    return true
end

---重连
function Transponder:Retry(callback, errorCode, loop)
    --[[
    local ok = self:CanRetry(protobuf)
    console.error('Transponder Retry', ok) --@DEL
    if ok then
        App.httpClient:HttpPut(params, protobuf, onSuccess, onError)
    else
        -- self:RestartGame()
        self:ShowRestartBoard()
    end
    ]]
    if loop then
        Runtime.InvokeCbk(callback)
        return
    end

    self:ShowRestartBoard(callback, errorCode)
end

---是否需要重启
function Transponder:NeedResetart()
end

function Transponder:MsgWinRestartGame(errorCode)
    self:FinishSend()
    console.lj("MsgWinRestartGame", tostring(errorCode)) --@DEL
    ErrorHandler.ShowErrorPanel(
        errorCode,
        function()
            --ReenterGame()
            App:Quit({source = "sendLogin_errorCode" .. errorCode})
        end
    )
end
---重启
function Transponder:RestartGame()
    -- TODO 换成重新进入LoadingScene界面
    self:FinishSend()
    ReenterGame()
end

local ignoreErrorCodes = {
    [28716] = true --您已不再当前部落了
}

function Transponder:OnErrorCode(info, httpError)
    if ignoreErrorCodes[info.errorCode] then
        return
    end
    local logName = httpError or SDK_EVENT.show_error_code
    info.name = info.name or DcDelegates.Legacy:GetErrorCodePrettyName(info.errorCode)
    DcDelegates:Log(logName, info)
    sendNotification(CONST.GLOBAL_NOFITY.Lock_Screen, {false, "*"})
    console.lj("online errorCode:" .. table.tostring(info)) --@DEL
end

--弱弱弱联网，不在乎返回，不需要重连，有结果就显示没结果就丢弃，不显示loading界面，不触发弱网警告,httpError不处理，由主线通道去触发
function Transponder:weakcall(messageId, _data, handler, extraParams)
    local request = RpcRequest.new(messageId, _data, handler or {}, extraParams)
    request.sequenceId = request.sequenceId or self:GetNewSequenceId()
    local version = request.version
    local url = request.url
    local pkgId = ""
    if RuntimeContext.VERSION_DEVELOPMENT then
        pkgId = pkgId .. request.messageId .. "_"
    end

    local package = GatewayModule_pb.GatewayPackageRequest()
    package.senderId = self.senderId
    package.sessionId = self.sessionId
    local data = package.bodys:add()
    data.code = 0
    data.msgId = request.messageId
    data.genTime = request.ts or TimeUtil.ServerTimeMilliseconds()
    data.msgBody = request.data:SerializeToString()
    data.sequenceId = request.sequenceId
    data.version = request.version or RuntimeContext.BUNDLE_VERSION

    local protobuf = package:SerializeToString()
    local params = (url or NetworkConfig.logicUrl) .. "/" .. version
    if RuntimeContext.VERSION_DEVELOPMENT then
        params = params .. "?id=" .. pkgId .. "&uid=" .. self.senderId --@DEL
    end

    --服务器连接成功，并由服务器反馈的结果
    local onServerResp = function(ret)
        local resp = GatewayModule_pb.GatewayPackageResponse()
        resp:ParseFromString(ret)
        local bodys = resp.bodys
        --local flags = resp.flags

        local messageStruct = bodys[1]
        --数据报空，说明前面的序列已经出错了
        if table.isEmpty(messageStruct) then
            self:MsgWinRestartGame(ErrorCodeEnums.MSGISNULL)
            return
        end

        local errorCode = messageStruct.code or 500
        request.errorCode = errorCode
        --SESSION过期：重连并放弃这次连接
        if errorCode == ErrorCodeEnums.SESSION_EXPIRED then
            self:OnSessionExpired()
            return
        end

        --被顶号：退出游戏
        if errorCode == ErrorCodeEnums.REPEATEDLOGIN then
            self:MsgWinRestartGame(ErrorCodeEnums.REPEATEDLOGIN)
            DcDelegates:Log("repeat_login")
            return
        end

        --版本错误:打开商城更新界面
        if errorCode == ErrorCodeEnums.VERSION_ERROR then
            ErrorHandler.ShowErrorPanel(
                errorCode,
                function()
                    Util.OpenAppShopPage()
                end
            )
            return
        end

        --服务器错误：重新登陆
        if IsRestartError(errorCode) then
            self:MsgWinRestartGame(errorCode)
            return
        end
        if request.handler then
            if errorCode == 0 then
                Runtime.InvokeCbk(request.handler.onSuccess, messageStruct)
            else
                Runtime.InvokeCbk(request.handler.onFailed, errorCode)
            end
        end
    end
    App.httpClient:HttpPut(params, protobuf, onServerResp)
end

return Transponder
