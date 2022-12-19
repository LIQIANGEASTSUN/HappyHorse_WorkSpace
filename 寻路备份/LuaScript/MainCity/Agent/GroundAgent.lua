local NormalAgent = require("MainCity.Agent.NormalAgent")
---@class GroundAgent:BaseAgent 可消除障碍物
local GroundAgent = class(NormalAgent, "GroundAgent")

local opacity = 1 --不透明
local transparency = 0.5 --半透明
local StateChangedHandles = {
    ---@param agent BaseAgent
    [CleanState.prepare] = function(agent)
        local modelName = "airWall"
        if agent.render then
            agent.render:SetModelName(modelName)
        else
            agent:SetAssetName(modelName)
        end
        --GetAssetName
        agent:InitRender(
            function(result)
                agent:SetClickable(true)
                local go = agent:GetGameObject()
                go.name = "prepare"
            end
        )
    end,
    ---@param agent GroundAgent
    [CleanState.clearing] = function(agent)
        local modelName = "airWall"
        if agent.render then
            agent.render:SetModelName(modelName)
        else
            agent:SetAssetName(modelName)
        end

        agent:InitRender(
            function(result)
                agent:SetClickable(true)
                local go = agent:GetGameObject()
                go.name = agent:GetId()
                agent:ShowTip()
            end
        )
        --Prefab/UI/BindingTip/GroundConsume.prefab

        -- local x, z = agent:GetMin()
        -- local sx, sz = agent:GetSize()
        -- --后触发格子状态
        -- ---@type MapManager
        -- local map = App.scene.mapManager
        -- return map:SetBlockState(x, sx, z, sz, CleanState.clearing)
    end,
    ---@param agent GroundAgent
    [CleanState.cleared] = function(agent)
        agent:DestroyTip()
        if agent.render then
            agent.render:OnDestroy()
            agent.render = nil
        end
        agent:SetAssetName(nil)
        agent:InitRender(
            function(result)
                agent:SetClickable(true)
                MessageDispatcher:SendMessage(MessageType.AgentCleaned, agent.id)
            end
        )
        local x, z = agent:GetMin()
        local sx, sz = agent:GetSize()
        --后触发格子状态
        ---@type MapManager
        local map = App.scene.mapManager

        return map:SetBlockState(x, sx, z, sz, CleanState.cleared)
    end
}

---@private
---触发显示更新/格子状态更新
function GroundAgent:OnStateChanged()
    local state = self:GetState()
    local handler = StateChangedHandles[state]
    if handler then
        return handler(self)
    end
end

function GroundAgent:BlockBuilding()
    return false
end

function GroundAgent:ShowTip()
    if not self.alive then
        return
    end
    if Runtime.CSValid(self.tipGo) then
        self.tipGo:SetActive(true)
        return
    end
    local assetPath = "Prefab/UI/BindingTip/GroundConsume.prefab"
    App.commonAssetsManager:LoadAssets(
        {assetPath},
        function()
            if not self.alive then
                return
            end
            self.tipGo = BResource.InstantiateFromAssetName(assetPath)
            self.tipGo:SetParent(App.scene.worldCanvas)
            self.tipGo:SetLocalScale(1, 1, 1)
            local position = self:GetCenterPostion()
            position.y = 0.3
            self.tipGo:SetPosition(position)
            self.tipText = find_component(self.tipGo, "Text", Text)
            self.tipIcon = find_component(self.tipGo, "Icon", Image)
            self.tipSlider = self.tipGo:GetComponent(typeof(Slider))
            self:OnConsume(0)
        end
    )
end
function GroundAgent:DestroyTip()
    Runtime.CSDestroy(self.tipGo)
    self.tipGo = nil
    self.tipText = nil
    self.tipSlider = nil
    self.tipIcon = nil
end

function GroundAgent:OnConsume(payed)
    if Runtime.CSValid(self.tipGo) then
        local id, cost, total = self:GetCurrentCost()
        local count = cost - payed
        count = math.max(0, count)
        self.tipText.text = count
        self.tipSlider.value = 1 - count / total
    end
end

function GroundAgent:EnterEditMode()
    return false
end

function GroundAgent:Suckable()
    if self.alive then
        return self:GetState() == CleanState.clearing
    end
end

function GroundAgent:InitExtraData(extra)
    self.data:InitExtraData(extra)
end

return GroundAgent
