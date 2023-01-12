local PREFAB_PATH = "Prefab/UI/Common/AgentTipPanel.prefab"

---@class AgentTipManager
local AgentTipManager = {
    agentIds = {},
    tipGos = {},
    timers = {}
}

function AgentTipManager:Init(callback)
    if self.initializing or self.init then
        return
    end

    self.initializing = true

    local function onLoaded()
        self.init = true
        self.initializing = nil
        self.gameObject = BResource.InstantiateFromAssetName(PREFAB_PATH)
        self.tipGo = self.gameObject:FindGameObject("tip")
        self.tipGo:SetActive(false)
        MessageDispatcher:AddMessageListener(MessageType.Global_Drama_Start, self.ClearAll, self)
        MessageDispatcher:AddMessageListener(MessageType.Global_After_Show_Clean_End, self.OnAgentCleaned, self)
        MessageDispatcher:AddMessageListener(MessageType.Global_After_RepaireBuilding, self.OnBuildingRepaired, self)
        MessageDispatcher:AddMessageListener(MessageType.Task_OnTaskFinish, self.OnTaskFinished, self)

        MapBubbleManager:RegisterBubbleStateEvent(self.OnMapBubbleChanged, self)
        Runtime.InvokeCbk(callback)
    end

    App.uiAssetsManager:LoadAssets({PREFAB_PATH}, onLoaded)
end

---@param data table {
---    {id = id, showTime = showTime, pos = pos},
---    {id = id, showTime = showTime, pos = pos},
---    ...
---    }
function AgentTipManager:Show(data, callback)
    if not data or table.isEmpty(data) then
        Runtime.InvokeCbk(callback)
        return
    end
    if not self.init or Runtime.CSNull(self.gameObject) then
        self:Init(
            function()
                self:Show(data, callback)
            end
        )
        return
    end

    self:ClearAll()

    for _, v in ipairs(data) do
        local agentId = v.id
        if agentId then
            table.insert(self.agentIds, agentId)
        end
        local time = v.showTime
        if time then
            self:StartTimer(agentId, time)
        end
    end

    self:MoveCamera(function()
        self:_Show(data)
        Runtime.InvokeCbk(callback)
    end)
end

function AgentTipManager:ShowWithoutMoveCamera(data, callback)
    if not data or table.isEmpty(data) then
        Runtime.InvokeCbk(callback)
        return
    end
    if not self.init or Runtime.CSNull(self.gameObject) then
        self:Init(
            function()
                self:ShowWithoutMoveCamera(data, callback)
            end
        )
        return
    end

    self:ClearAll()

    for _, v in ipairs(data) do
        local agentId = v.id
        if agentId then
            table.insert(self.agentIds, agentId)
        end
        local time = v.showTime
        if time then
            self:StartTimer(agentId, time)
        end
    end

    self:_Show(data)
    Runtime.InvokeCbk(callback)
end

function AgentTipManager:MoveCamera(callback)
    local id = self.agentIds[1]
    if not id then
        Runtime.InvokeCbk(callback)
        return
    end
    local agent = App.scene.objectManager:GetAgent(id)
    if not agent then
        Runtime.InvokeCbk(callback)
        return
    end
    local pos = agent:GetAnchorPosition()
    local size = MoveCameraLogic.Instance().CS_CameraLogic.SceneCamera.orthographicSize
    MoveCameraLogic.Instance():MoveCameraToLook2(pos, 0.3, size, callback, true)
end

function AgentTipManager:_Show(data)
    local objMgr = App.scene.objectManager
    local orgCamSize = 3
    local size = MoveCameraLogic.Instance().CS_CameraLogic.SceneCamera.orthographicSize / orgCamSize
    for _, v in pairs(data) do
        local id = v.id
        if id and not self.tipGos[id] then
            local agent = objMgr:GetAgent(id)
            if agent then
                local pos
                if v.pos then
                    pos = v.pos
                else
                    pos = agent:GetAnchorPosition()
                    local bubble = MapBubbleManager:GetShowedBubble(id)
                    local expandCnt = 0
                    if bubble and bubble:IsExpandHeight() then
                        expandCnt = expandCnt + 1
                    end
                    local isShow = SceneServices.BindingTip:IsShowTip(id)
                    if isShow then
                        expandCnt = expandCnt  + 1
                    end
                    pos = Vector3(pos[0], pos[1] + 1.2 * size * expandCnt, pos[2])
                end
                local go = GameObject.Instantiate(self.tipGo)
                go:SetParent(self.gameObject, false)
                go:SetActive(true)
                go:SetPosition(pos)
                self.tipGos[id] = go
            else
                table.removeIfExist(self.agentIds, id)
                console.warn(nil, "agentTip no agent: ", id) --@DEL
            end
        end
    end
end

function AgentTipManager:ClearTip(agentIds)
    local function clear(id)
        local tip = self.tipGos[id]
        if Runtime.CSValid(tip) then
            tip:SetActive(false)
            Runtime.CSDestroy(tip)
            self.tipGos[id] = nil
            table.removeIfExist(self.agentIds, id)
        end
    end

    if type(agentIds) == "string" then
        clear(agentIds)
    elseif type(agentIds) == "table" then
        for _, id in pairs(agentIds) do
            clear(id)
        end
    end
end

function AgentTipManager:ClearAll()
    for _, go in pairs(self.tipGos) do
        if Runtime.CSValid(go) then
            go:SetActive(false)
            Runtime.CSDestroy(go)
        end
    end

    for _, v in pairs(self.timers) do
        if v then
            WaitExtension.CancelTimeout(v)
        end
    end
    self.timers = {}
    self.tipGos = {}
    self.agentIds = {}
end

--设置箭头关闭的完成任务监听
function AgentTipManager:SetTaskId(taskId)
    self.taskId = taskId
end

function AgentTipManager:OnAgentCleaned(cost, sceneId, agentId)
    self:ClearTip(agentId)
end

function AgentTipManager:OnBuildingRepaired(agentId)
    self:ClearTip(agentId)
end

function AgentTipManager:OnTaskFinished(taskId)
    if self.taskId and self.taskId == taskId then
        self.taskId = nil
        self:ClearAll()
    end
end

---@param state bool true 表示显示气泡, false or nil 表示隐藏气泡
function AgentTipManager:OnMapBubbleChanged(state, agentId)
    if state then
        self:ClearTip(agentId)
    end
end

function AgentTipManager:StartTimer(id, time)
    local count = 0
    self.timers[id] = WaitExtension.InvokeRepeating(function()
        count = count + 1
        if count >= time then
            self:ClearTip(id)
            WaitExtension.CancelTimeout(self.timers[id])
            self.timers[id] = nil
        end
    end, 0, 1)
end

function AgentTipManager:OnDestroy()
    if self.init then
        MessageDispatcher:RemoveMessageListener(MessageType.Global_Drama_Start, self.ClearAll, self)
        MessageDispatcher:RemoveMessageListener(MessageType.Global_After_Show_Clean_End, self.OnAgentCleaned, self)
        MessageDispatcher:RemoveMessageListener(MessageType.Global_After_RepaireBuilding, self.OnBuildingRepaired, self)
        MessageDispatcher:RemoveMessageListener(MessageType.Task_OnTaskFinish, self.OnTaskFinished, self)
    end
    self.init = nil
    self:ClearAll()
end

return AgentTipManager
