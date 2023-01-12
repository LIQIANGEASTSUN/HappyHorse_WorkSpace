---@class ChestTip
local PREFAB_PATH = "Prefab/UI/Common/ChestTipPanel.prefab"
local orgCamSize = 4

local ChestTip = {
    init = nil,
    showingAgent = nil,
    tipGos = {}
}

function ChestTip:OnDestroy()
    if self.init then
        MessageDispatcher:RemoveMessageListener(MessageType.Global_Camera_Size_Changed, self.SetTipsScale, self)
        MessageDispatcher:RemoveMessageListener(MessageType.Global_After_Show_Panel, self.ClearAllTips, self)
        MessageDispatcher:RemoveMessageListener(MessageType.Global_Drama_Start, self.ClearAllTips, self)
    end
    self.init = nil
    self:ClearAllTips()
end

function ChestTip:Init(callback)
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
        MessageDispatcher:AddMessageListener(MessageType.Global_After_Show_Panel, self.ClearAllTips, self)
        MessageDispatcher:AddMessageListener(MessageType.Global_Drama_Start, self.ClearAllTips, self)
        MessageDispatcher:AddMessageListener(MessageType.Global_Camera_Size_Changed, self.SetTipsScale, self)
        Runtime.InvokeCbk(callback)
    end

    App.uiAssetsManager:LoadAssets({PREFAB_PATH}, onLoaded)
end

function ChestTip:ShowTip(agent, player, distance)
    if not self.init or Runtime.CSNull(self.gameObject) then
        return self:Init(
            function()
                self:ShowTip(agent, player, distance)
            end
        )
    end

    if App:IsScreenPlayActive() then
        return
    end
    if self.showingAgent == agent then
        return
    end
    if self.showingAgent then
        local showingDistance = self:GetDistance(self.showingAgent, player)
        if showingDistance <= distance then
            return
        end
        self.showingAgent:HideChestTip()
    end
    self.showingAgent = agent
    if agent and agent.alive then
        local pos = agent:GetAnchorPosition()
        local id = agent:GetId()
        local go = GameObject.Instantiate(self.tipGo)
        local btn = find_component(go, "", Button)
        Util.UGUI_AddButtonListener(
            btn,
            function()
                agent:ProcessClick()
            end
        )
        go:SetParent(self.gameObject, false)
        go:SetActive(true)
        go:SetPosition(pos)
        self.tipGos[id] = go
        self:SetTipsScale()
    end
end

function ChestTip:GetDistance(agent, player, defaultDistance)
    local distance = defaultDistance or 0
    pcall(function()
        local playerPos = player:GetPosition()
        distance = Vector3.Distance(agent:GetWorldPosition(), playerPos)
    end)
    return distance
end

function ChestTip:SetTipsScale()
    MoveCameraLogic.Instance():GetCamera(
        function(camera)
            local curCamsize = camera.orthographicSize
            for _, tip in pairs(self.tipGos) do
                if Runtime.CSValid(tip) then
                    local size = Vector3.one * curCamsize / orgCamSize
                    tip.gameObject:SetLocalScale(size)
                end
            end
        end
    )
end

function ChestTip:HideTip(agentId)
    if self.showingAgent and self.showingAgent.data then
        local id = self.showingAgent:GetId()
        if id == agentId then
            self.showingAgent = nil
        end
    end
    if self.tipGos[agentId] then
        local go = self.tipGos[agentId]
        if Runtime.CSValid(go) then
            go:SetActive(false)
            Runtime.CSDestroy(go)
        end
        self.tipGos[agentId] = nil
    end
end

function ChestTip:ClearAllTips()
    self.showingAgent = nil
    for _, go in pairs(self.tipGos) do
        if Runtime.CSValid(go) then
            go:SetActive(false)
            Runtime.CSDestroy(go)
        end
    end
    self.tipGos = {}
end

return ChestTip
