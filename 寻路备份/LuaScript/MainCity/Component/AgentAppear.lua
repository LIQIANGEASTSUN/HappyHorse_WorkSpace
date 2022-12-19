---@class AgentAppear
local AgentAppear = {
	---出现的障碍物数据
	---@type dictionary<string, string[]>
	datas = {}
}

function AgentAppear:InitFromResponse(sceneId, appears)
	-- 旧数据抛弃, 新数据重置
	self.datas[sceneId] = appears or {}
	self.datas[sceneId].inited = true
end

function AgentAppear:SetAgentAppear(sceneId, agentId, callback)
	-- console.lzl('---SetAgentAppear----', sceneId, agentId)
	if not self.datas[sceneId] then
		self.datas[sceneId] = {}
	end
	if table.exists(self.datas[sceneId], agentId) then
		return
	end
	local params = {
        sceneId = sceneId,
        plantId = agentId
    }
	local function funcSuccessCbk()
		-- console.lzl('---SetAgentAppear---funcSuccessCbk-', sceneId, agentId)
		table.insertIfNotExist(self.datas[sceneId], agentId)
		Runtime.InvokeCbk(callback)
	end
	local function funcFailedCbk(errorCode)
		console.lzl('---SetAgentAppear---funcFailedCbk', sceneId, agentId, errorCode) --@DEL
	end
	Net.Scenemodulemsg_25311_PlantAppear_Request(params, funcFailedCbk, funcSuccessCbk, nil, false)
end

function AgentAppear:OnAgentCleard(sceneId, agentId)
	if not self.datas[sceneId] then
		return
	end
	table.removeIfExist(self.datas[sceneId], agentId)
end

function AgentAppear:IsAgentAppear(sceneId, agentId)
	local datas = self.datas[sceneId]
	if not datas then
		return false, true
	end
	local have = table.exists(datas, agentId)
	if have then
		return true, not datas.inited
	end
	if not datas.inited then
		return false, true
	end
	return false, false
end

function AgentAppear:RequestState(sceneId, agentId, callback)
	local plantIds = { agentId }

	local function funcSuccessCbk(response)
		local state = CleanState.locked
		for i, v in ipairs(response.plantIds) do
			if table.exists(plantIds, v) then
				state = CleanState.clearing
				break
			end
		end
		if state == CleanState.clearing then
			if not self.datas[sceneId] then
				self.datas[sceneId] = {}
			end
			table.insertIfNotExist(self.datas[sceneId], agentId)
		end
		Runtime.InvokeCbk(callback, sceneId, agentId, state)
	end

	local function funcFailedCbk(errorCode)
		Runtime.InvokeCbk(callback, sceneId, agentId, CleanState.locked)
	end
	local params = {
		sceneId = sceneId,
		plantIds = plantIds
	}
	Net.Scenemodulemsg_25315_FindPlantAppear_Request(params, funcFailedCbk, funcSuccessCbk, extraParams, showLoading)
end

return AgentAppear
