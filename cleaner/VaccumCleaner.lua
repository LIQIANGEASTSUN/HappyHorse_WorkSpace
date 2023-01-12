---@class VaccumCleaner
local VaccumCleaner = {
    alive = true,
    actions = {},
    cacheActions = {}
}

---不同的建筑使用不同的触发表现
local VaccumActions =
    setmetatable(
    {
        _cache = {
            [AgentType.resource] = "VaccumAction",
            [AgentType.ground] = "PayAction",
            [AgentType.animal] = "CollectAnimalAction",
            [AgentType.linkHomeland_groud] = "PayAction"
            -- [AgentType.animal] = "CollectAnimalAction",
        }
    },
    {
        __index = function(t, k)
            local name = t._cache[k]
            if not name then
                name = "VaccumAction"
                console.error("VaccumAction of AgentType:[", tostring(k), "] Not Found! Using DefaultType!") --@DEL
            end

            local value = include("MainCity.Logic.VaccumActions." .. name)
            rawset(t, k, value)
            return value
        end
    }
)

---@param player PlayerCharacter
function VaccumCleaner:Create(player)
    self.player = player
    local playerObj = self.player:GetGameObject()
    if Runtime.CSNull(playerObj) then
        return
    end
    local curInfo = AppServices.User:GetVaccumInfo()
    if not curInfo then
        return
    end
    local detector = playerObj:GetOrAddComponent(typeof(CS.ColliderDetector))
    detector:SetTriggerListener(
        function(collider)
            self:OnTriggerEnter(collider)
        end,
        function(collider)
            self:OnTriggerStay(collider)
        end,
        function(collider)
            self:OnTriggerExit(collider)
        end
    )
    -- detector:SetCollisionListener(
    --     function(collision)
    --         self:OnCollisionEnter(collision)
    --     end,
    --     function(collision)
    --         self:OnCollisionStay(collision)
    --     end,
    --     function(collision)
    --         self:OnCollisionExit(collision)
    --     end
    -- )
    self.detector = detector
    MessageDispatcher:AddMessageListener(MessageType.VaccumChanged, self.OnVaccumChanged, self)
    self:InitData(curInfo)
end

function VaccumCleaner:CreateGameObject(modelPath)
    local function onLoaded()
        local playerObj = self.player:GetGameObject()
        if Runtime.CSNull(playerObj) then
            return
        end
        local bag_dummy = playerObj:FindInDeep("bag_dummy")
        if Runtime.CSValid(self.gameObject) then
            Runtime.CSDestroy(self.gameObject)
        end
        self.gameObject = BResource.InstantiateFromAssetName(modelPath, bag_dummy, false)
        if Runtime.CSValid(self.vaccumPort) then
            Runtime.CSDestroy(self.vaccumPort)
        end
        self.vaccumPort = self.gameObject:FindInDeep("collider")
        local x = self.meta.xValue
        local scale = self.meta.scaleValue
        if Runtime.CSValid(self.vaccumPort) then
            self.vaccumPort:SetLocalScale(scale, 1, x * scale)
        end
    end

    App.buildingAssetsManager:LoadAssets({modelPath}, onLoaded)
end
function VaccumCleaner:GetGameObject()
    return self.gameObject
end

function VaccumCleaner:InitData(equipInfo)
    self.equipInfo = equipInfo
    self.meta = AppServices.Meta:GetVaccumMeta(equipInfo.type, equipInfo.level)
    local modelName = self.meta.model
    if string.isEmpty(modelName) then
        modelName = "VaccumCleaner"
    end
    local modelPath = string.format("Prefab/Art/Characters/%s.prefab", modelName)
    self:CreateGameObject(modelPath)
end

function VaccumCleaner:OnVaccumChanged(equipInfo)
    if not self.alive then
        return
    end

    local orgMeta = self.meta or {}
    self.meta = AppServices.Meta:GetVaccumMeta(equipInfo.type, equipInfo.level)
    local x = self.meta.xValue
    local scale = self.meta.scaleValue
    if Runtime.CSValid(self.vaccumPort) then
        self.vaccumPort:SetLocalScale(scale, 1, x * scale)
    end

    if orgMeta.model == self.meta.model then --如果模型没变化就不用走替换逻辑
        return
    end
    local modelName = self.meta.model
    if string.isEmpty(modelName) then
        modelName = "VaccumCleaner"
    end
    local modelPath = string.format("Prefab/Art/Characters/%s.prefab", modelName)
    self:CreateGameObject(modelPath)
end

function VaccumCleaner:OnTriggerEnter(collider)
    if not self.alive then
        console.error("vaccum cleaner has been destroyed!!") --@DEL
        return
    end
    local id = collider.name
    console.hjs("OnTriggerEnter", id) --@DEL
    local agent = App.scene and App.scene.objectManager:GetAgent(id)
    if not agent then
        return
    end
    --判断之前是否已经触碰过
    local action = self.actions[id]
    if action then
        return
    end
    if agent:Suckable() then
        local suckLevel = agent:GetSuckLevel()
        if not suckLevel or self:GetSuckLevel() < suckLevel then
            local position = agent:GetAnchorPosition()
            local message = string.format("Need Level %s Vaccum Cleaner", tostring(suckLevel))
            AppServices.SceneTextTip:Show(message, position)
            return
        end

        self:CreateAction(agent)
    end
end
function VaccumCleaner:OnTriggerStay(collider)
    -- if not self.alive then
    --     console.error("vaccum cleaner has been destroyed!!") --@DEL
    --     return
    -- end
    -- console.hjs("OnTriggerStay", collider.name)
end
function VaccumCleaner:OnTriggerExit(collider)
    if not self.alive then
        console.error("vaccum cleaner has been destroyed!!") --@DEL
        return
    end
    local id = collider.name
    console.hjs("OnTriggerExit", id) --@DEL
    local agent = App.scene and App.scene.objectManager:GetAgent(id)
    if not agent then
        return
    end
    self:StopAction(agent)
end

-- function VaccumCleaner:OnCollisionEnter(collision)
--     console.hjs("OnCollisionEnter", collision.collider.name) --@DEL
-- end
-- function VaccumCleaner:OnCollisionStay(collision)
--     -- console.hjs("OnCollisionStay", collision.collider.name) --@DEL
-- end
-- function VaccumCleaner:OnCollisionExit(collision)
--     console.hjs("OnCollisionExit", collision.collider.name) --@DEL
-- end

---@param agent BaseAgent
function VaccumCleaner:CreateAction(agent)
    ---@type VaccumAction
    local agentType = agent:GetType()
    local action = self:GetAction(agentType)

    local id = agent:GetId()
    action:Init(agent)
    self.actions[id] = action
end
function VaccumCleaner:StopAction(agent)
    local id = agent:GetId()
    local action = self.actions[id]
    --判断之前是否已经触碰过
    if action and action:CanStop() then
        action:Destroy()
        self.actions[id] = nil
        self:Recycle(action)
    end
end

function VaccumCleaner:GetAction(agentType)
    local group = self.cacheActions[agentType]
    if not group or #group == 0 then
        local VaccumAction = VaccumActions[agentType]
        return VaccumAction.new(self)
    end
    return table.remove(group)
end

function VaccumCleaner:Recycle(action)
    local agentType = action.type
    local group = self.cacheActions[agentType]
    if not group then
        self.cacheActions[agentType] = {action}
        return
    end
    table.insert(group, action)
end

function VaccumCleaner:GetSuckLevel()
    return self.meta.inhaleLevel
end

function VaccumCleaner:GetPortPosition()
    if Runtime.CSValid(self.vaccumPort) then
        return self.vaccumPort:GetPosition()
    end

    local playerObj = self.player:GetGameObject()
    if Runtime.CSValid(playerObj) then
        return playerObj:GetPosition()
    end
end
function VaccumCleaner:GetPosition()
    if Runtime.CSValid(self.gameObject) then
        return self.gameObject:GetPosition()
    end
    local playerObj = self.player:GetGameObject()
    if Runtime.CSValid(playerObj) then
        return playerObj:GetPosition()
    end
end

function VaccumCleaner:Update(deltaTime)
    if not self.alive then
        console.error("vaccum cleaner has been destroyed!!") --@DEL
        return
    end
    local removeList = {}
    for id, action in pairs(self.actions) do
        action:Tick(deltaTime)
        if not action:IsActive() then
            table.insert(removeList, id)
        end
    end
    for _, id in pairs(removeList) do
        local action = self.actions[id]
        self.actions[id] = nil
        self:Recycle(action)
    end
end

function VaccumCleaner:Destroy()
    self.alive = false
    Runtime.CSDestroy(self.detector)
    self.detector = nil
    MessageDispatcher:RemoveMessageListener(MessageType.VaccumChanged, self.OnVaccumChanged, self)
end

return VaccumCleaner
