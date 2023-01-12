local BindingTip = require("MainCity.Component.BindingTip")
---@class BindingTipManager
BindingTipManager = class(nil, "BindingTipManager")
local opacity = 1 --不透明
local transparency = 0.5 --半透明

local instance
---@return BindingTipManager
function BindingTipManager.Instance()
    if not instance then
        instance = BindingTipManager.new()
    end
    return instance
end

function BindingTipManager.Destroy()
    if not instance then
        return
    end

    instance:OnDestroy()
    instance = nil
end

function BindingTipManager:ctor()
    self.cacheTips = {}
    self.inited = false
    self.cacheIds = {}
end

function BindingTipManager:Init()
    if self.inited then
        return
    end
    self.inited = true
    self.gameObject = BResource.InstantiateFromAssetName(CONST.ASSETS.G_BINDINGTIP_PREFAB)
    self.gameObject:SetActive(true)

    self.tipGo = self.gameObject:FindGameObject("Tip")
    self.tipGo:SetActive(false)
    if not table.isEmpty(self.cacheIds) then
        self:Show(self.cacheIds)
    end
    MessageDispatcher:AddMessageListener(MessageType.Global_Camera_Size_Changed, self.SetTipsScale, self)
    MessageDispatcher:AddMessageListener(MessageType.Global_After_Show_Panel, self.HideAll, self)
    MessageDispatcher:AddMessageListener(MessageType.Global_Drama_Start, self.HideAll, self)
end

function BindingTipManager:Show(agentIdList)
    local function isShowAgentTip(agent)
        if not agent then
            return
        end
        if not agent.alive then
            return
        end
        if agent:IsCleaning() then
            return
        end

        if not agent:IsTaskUnlock() then
            return
        end

        if agent:IsComplete() then
            return
        end

        if agent:IsLocked() then
            return
        end

        local id = agent:GetCurrentCost()
        if id ~= 0 and ItemId.IsDragonKey(id) then
            return
        end
        local tp = agent:GetType()
        if tp == AgentType.dragonCollect then
            return
        end

        if not agent:IsBuildingTaskUnlock() then
            return
        end

        if agent:HideBindingTip() then
            return
        end
        return true
    end
    self:HideAll()
    local agentIds = {}
    local objMgr = App.scene.objectManager
    for _, id in ipairs(agentIdList or {}) do
        local agent = objMgr:GetAgent(id)
        if isShowAgentTip(agent) then
            table.insertIfNotExist(agentIds, id)
            if #agentIds == 3 then
                break
            end
        end
    end
    if #agentIds == 0 then
        return
    end

    -- local agentIds = {}
    -- if #agentIds > 3 then
    --     for i = 1, 3 do
    --         agentIds[i] = agentIds[i]
    --     end
    -- else
    --     agentIds = agentIds
    -- end
    self.cacheIds = agentIds
    if not self.inited or Runtime.CSNull(self.gameObject) then --切换场景预制被销毁，需要判断并重新init
        self:Init()
        return
    end
    --选中障碍物音效
    App.audioManager:PlayEffectAudio(CONST.AUDIO.Interface_ClickObstacle)
    SceneServices.AgentTip:ClearTip(agentIds)
    for index = #agentIds, 1, -1 do --显示的越晚气泡层级越在上面，所以要倒序循环
        ---@type BindingTip
        local tip = self:Get()
        local agent = objMgr:GetAgent(agentIds[index])
        tip:Show(agent, index)
        if index == 1 then
            AppServices.EventDispatcher:dispatchEvent(GlobalEvents.ShowBindingTip, agent)
        end
        local alpha = index == 1 and opacity or transparency
        tip:SetTransparency(alpha)
    end
    App.audioManager:PlayEffectAudio(CONST.AUDIO.Interface_sound_story_bounce_bubbles)
end

---@return BindingTip
function BindingTipManager:Get()
    for _, tip in pairs(self.cacheTips) do
        if not tip.inUse then
            return tip
        end
    end
    local go = GameObject.Instantiate(self.tipGo)
    go:SetParent(self.gameObject, false)
    local tip = BindingTip.new(go)
    table.insert(self.cacheTips, tip)
    return tip
end

function BindingTipManager:OnclickHalfTransparencyTip(agentId)
    local firstId = agentId
    table.removeIfExist(self.cacheIds, firstId)
    table.insert(self.cacheIds, 1, firstId)
    self:Show(self.cacheIds)
end

function BindingTipManager:RefreshOtherTips(agentId)
    if #self.cacheIds == 0 then
        return
    end
    table.removeIfExist(self.cacheIds, agentId)
    self:Show(self.cacheIds)
end

function BindingTipManager:HideAll()
    if App.mapGuideManager:IsAgentClickDisabled() then
        return
    end
    if not self.cacheTips then
        return
    end
    for i = #self.cacheTips, 1, -1 do
        local tip = self.cacheTips[i]
        if tip then
            if Runtime.CSValid(tip.gameObject) then
                tip:Hide()
            else
                table.remove(self.cacheTips, i)
            end
        end
    end

    AppServices.EventDispatcher:dispatchEvent(GlobalEvents.HideBindingTip)
end

function BindingTipManager:OnCleanInterruptedFromOut()
    if not self.cacheTips then
        return
    end
    for i = #self.cacheTips, 1, -1 do
        local tip = self.cacheTips[i]
        if tip then
            Runtime.InvokeCbk(tip.CancelZoomTween, tip)
            Runtime.InvokeCbk(tip.SetZoomingFalse, tip)
        end
    end
end

function BindingTipManager:GetTipByAgent(agentId)
    for _, tip in pairs(self.cacheTips) do
        if tip and tip.agentId == agentId then
            return tip
        end
    end
end

function BindingTipManager:IsShowTip(agentId)
    return table.exists(self.cacheIds, agentId)
end

function BindingTipManager:SetTipsScale()
    MoveCameraLogic.Instance():GetCamera(
        function(camera)
            local orgCamSize = 3
            local curCamsize = camera.orthographicSize
            for _, tip in pairs(self.cacheTips) do
                if Runtime.CSValid(tip.gameObject) and tip.gameObject.activeInHierarchy then
                    local size = Vector3.one * curCamsize / orgCamSize
                    tip:SetSize(size)
                end
            end
        end
    )
end

function BindingTipManager:OnDestroy()
    if self.inited then
        MessageDispatcher:RemoveMessageListener(MessageType.Global_Camera_Size_Changed, self.SetTipsScale, self)
        MessageDispatcher:RemoveMessageListener(MessageType.Global_After_Show_Panel, self.HideAll, self)
        MessageDispatcher:RemoveMessageListener(MessageType.Global_Drama_Start, self.HideAll, self)
    end
    Runtime.CSDestroy(self.gameObject)
    self.gameObject = nil
    self.inited = nil

    for _, tip in pairs(self.cacheTips) do
        if Runtime.CSValid(tip.gameObject) then
            Runtime.InvokeCbk(tip.Hide, tip)
        end
    end
    self.cacheTips = nil
end

return BindingTipManager.Instance()
