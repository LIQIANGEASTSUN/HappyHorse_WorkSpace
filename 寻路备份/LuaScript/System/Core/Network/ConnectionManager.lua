--local OfflineRequest = {}

--默认不显示网络状态图标
local SilentRequest =
{
    1011,
    1021,
    2303,
    12001,
    23003,
    27302
}

--[[
local OfflineRequestMap = {}
for k, v in pairs(OfflineRequest) do
    OfflineRequestMap[v] = true
end
]]
local SilentRequestMap = {}
for k, v in pairs(SilentRequest) do
    SilentRequestMap[v] = true
end

-------------------------------------------------------------------------
--	Class include, HttpBase
-------------------------------------------------------------------------
local isAlerted = false
--
-- ConnectionManager ---------------------------------------------------------
--
ConnectionManager = {
    isConnectionManagerInitialized = 0
}

function ConnectionManager:reset( userId, sessionKey )
	if self.isConnectionManagerInitialized == 0 then
		self.isConnectionManagerInitialized = 1
		self:initialize(userId, sessionKey)
	else
		self:changeUserID(userId, sessionKey)
	end
end

function ConnectionManager:isInited()
	return self.isConnectionManagerInitialized > 0
end

-- 使用uid和sessionKey初始化一条链接（初始个一个transponder）
function ConnectionManager:initialize(uid, sessionKey)
	local config = {url = NetworkConfig.logicUrl, queueSize = 10, flushInterval = 10, timeout = 2}

	-- 构建一个transponder, 并传递给ConnectionManager
    ---@type Transponder
    local Transponder = include('System.Core.Network.Transponder')
    ---@type Transponder
	self.transponder = Transponder.new(config)
	self.transponder:invalidateSessionKey()
	self.transponder:changeUID("VISITOR")
    self.transponder:setSessionKey(-999)

	if not self.transponder:isBlocked() then
        self.transponder:flush()
	end
end

function ConnectionManager:invalidateSessionKey(  )
	local transponder = self.transponder
	transponder:invalidateSessionKey()
end

function ConnectionManager:changeUserID( uid, sessionKey, sequenceId )
	local transponder = self.transponder
	transponder:invalidateSessionKey()
	transponder:changeUID(uid)
	transponder:setSessionKey(sessionKey)
    transponder:UpdateSequenceId(sequenceId)
end

function ConnectionManager:block()
	self.transponder:block()
end

function ConnectionManager:flush(showLoading)
	self.transponder:flush(showLoading)
end

--[[
function ConnectionManager:IsOfflineRequest(messageId)
    return OfflineRequestMap[messageId] == true
end
]]
function ConnectionManager:IsSilentRequest(messageId)
    return SilentRequestMap[messageId] == true
end

--对外的统一接口，封装了不同模式下的请求模块，包括登陆请求模块，离线请求模块和其他协议模块
function ConnectionManager:sendRequest(messageId, body, callback, extraParams, showLoading)
    --[[
    if messageId == 1001 then
        self:sendLoginRequest(messageId, body, callback, extraParams, showLoading)
    elseif self:IsOfflineRequest(messageId) then
        self:sendOfflineRequest(messageId, body, callback, extraParams)
    else
        if showLoading == nil then
            showLoading = not self:IsSilentRequest(messageId)
        end
        self:sendOnlineRequest(messageId, body, callback, extraParams, showLoading)
    end
  ]]

    --登陆请求模块
    if messageId == 1001 then
        self:sendLoginRequest(messageId, body, callback, extraParams, showLoading)
        return
    end

    --[[离线请求模块
    if self:IsOfflineRequest(messageId) then
        self:sendOfflineRequest(messageId, body, callback, extraParams)
        return
    end
    ]]
    if extraParams and extraParams.weakOnline then
        self:sendWeakOnlineRequest(messageId, body, callback, extraParams, showLoading)
        return
    end
    --其他协议模块
    if showLoading == nil then
        showLoading = not self:IsSilentRequest(messageId)
    end
    -- showLoading = showLoading or not self:IsSilentRequest(messageId)
    self:sendOnlineRequest(messageId, body, callback, extraParams, showLoading)

end

function ConnectionManager:sendOnlineRequest(messageId, body, callback, extraParams, showLoading)
--没有离线登陆后必然只有登陆游戏后才能发送协议，且不会在游戏中重登陆
    self.transponder:call(messageId, body, callback, extraParams, showLoading)
end
function ConnectionManager:sendWeakOnlineRequest(messageId, body, callback, extraParams, showLoading)
    self.transponder:weakcall(messageId, body, callback, extraParams, showLoading)
end
function ConnectionManager:sendLoginRequest(messageId, body, callback, extraParams, showLoading)
    self.transponder:sendLogin(messageId, body, callback, extraParams, showLoading)
end

-- function ConnectionManager:sendOfflineRequest(messageId, body, callback, ts, showLoading)
--     self.transponder:call(messageId, body, callback, ts, showLoading)
-- end

function ConnectionManager:handleError(messageIds, err, requests)
	if not err or tonumber(err) ~= 108 then return false end
	if isAlerted then return false end

	return true
end

function ConnectionManager:GetSequenceId()
    return self.transponder:GetSequenceId()
end
function ConnectionManager:GetNewSequenceId()
    return self.transponder:GetNewSequenceId()
end

function ConnectionManager:SetSequenceId(newSequenceId)
    console.assert(false, 'SetSequenceId Will be discarded, DO NOT use it again')
    self.transponder:SetSequenceId(newSequenceId)
end

function ConnectionManager:UpdateSequenceId(newSequenceId)
    self.transponder:UpdateSequenceId(newSequenceId)
end

--[[现在没有心跳包逻辑
function ConnectionManager:StartHeartBeat()
    local timeDelta = 5
    local function onTick()
        local curState = self.transponder:GetSendState()
        --如果当前正在发送中，终止心跳发送
        if curState then
            self.lastSendState = curState
            return
        end

        --如果是刚结束发送，则+5秒后心跳
        if self.lastSendState ~= curState or not self.finalTime then
            self.finalTime = TimeUtil.ServerTime() + timeDelta
            self.lastSendState = curState
        end

        if TimeUtil.ServerTime() >= self.finalTime then
            self.finalTime = nil
            console.print("InvokeCbk time:"..TimeUtil.ServerTime())  --@DEL
            local function onSuc(response)
            end

            local function onFail(errorCode)
                local key = "errorcode_" .. errorCode --@DEL
                local message = Runtime.Translate(key) --@DEL
                console.print("心跳包错误"..message) --@DEL
            end
            --只要登录了就发送心跳，不管离线和消息失败
            Net.Coremodulemsg_1021_HeartBeat_Request({}, onFail, onSuc)
        end
    end

    self.lastSendState = false
    WaitExtension.InvokeRepeating(onTick, 0, 1)
end
]]
function ConnectionManager:RestartGame()
    self.transponder:RestartGame()
end