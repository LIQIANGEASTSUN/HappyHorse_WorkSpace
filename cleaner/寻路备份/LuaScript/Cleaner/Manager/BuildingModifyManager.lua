---@class BuildingModifyManager @建筑管理类
local BuildingModifyManager = {
    curUid = 100000
}

function BuildingModifyManager:Init()
    self.sceneName = App.scene:GetCurrentSceneId()
    AppServices.Net:Recieved(
        MsgMap.SCMoveBuildings,
        function(msg)
            self:OnReceiveMove(msg)
        end
    )

    AppServices.Net:Recieved(
        MsgMap.SCCleanObj,
        function(msg)
            self:OnReceiveClean(msg)
        end
    )

    AppServices.Net:Recieved(
        MsgMap.SCUnlockBuildings,
        function(msg)
            self:OnReceivePay(msg)
        end
    )

    AppServices.Net:Recieved(
        MsgMap.SCPutBuildings,
        function(msg)
            self:OnReceivePut(msg)
        end
    )
end
function BuildingModifyManager:IsSceneChanged()
    if App.scene then
        return self.sceneName ~= App.scene:GetCurrentSceneId()
    end
    return true
end

---@param agent BaseAgent
function BuildingModifyManager:SendMove(agent)
    -- CSMoveBuildings
    local x, z = agent:GetMin()
    local msg = {
        id = agent:GetId(),
        toPos = {x = x, y = z}
    }
    AppServices.Net:Send(MsgMap.CSMoveBuildings, msg)
end
function BuildingModifyManager:OnReceiveMove(msg)
    if self:IsSceneChanged() then
        console.error("scene has changed!!!") --@DEL
        return
    end
    local agent = App.scene.objectManager:GetAgent(msg.id)
    if not agent then
        return
    end
    if msg.errorCode and msg.errorCode ~= 0 then
        agent:OnMoveFailed()
    else
        agent:OnMoveSucess()
    end
end

function BuildingModifyManager:SendClean(agent)
    local id = agent:GetId()
    local msg = {
        id = id
    }
    AppServices.Net:Send(MsgMap.CSCleanObj, msg)
end
function BuildingModifyManager:OnReceiveClean(msg)
    if self:IsSceneChanged() then
        console.error("scene has changed!!!") --@DEL
        return
    end
    local agent = App.scene.objectManager:GetAgent(msg.id)
    if not agent then
        return
    end
end

function BuildingModifyManager:OnReceivePay(msg)
    if self:IsSceneChanged() then
        console.error("scene has changed!!!") --@DEL
        return
    end
    local agent = App.scene.objectManager:GetAgent(msg.id)
    if not agent then
        return
    end
end

---建筑全局唯一id(客户端分配)(因为建筑升级时沿用之前低级建筑的通讯识别码uniqueName, 容易造成混乱)
---@return number
function BuildingModifyManager:GetNewUID()
    self.curUid = self.curUid + 1
    return self.curUid
end

---@param buildingData BuildingData
function BuildingModifyManager:ShowBuildingGridRationality(state, buildingData)
    self.GridRationalityIndicator:Show(state, buildingData)
end
function BuildingModifyManager:HideBuildingGridRationality()
    self.GridRationalityIndicator:Hide()
end

function BuildingModifyManager:GetAutoBuildId()
    return "CID_" .. CS.System.DateTime.Now.Ticks
end

---@private
function BuildingModifyManager:GetAutoBuildData(metaId)
    local meta = AppServices.Meta:GetBindingMeta(metaId)
    if meta then
        local AgentDataType = App.scene.objectManager.GetDataType(meta.type)
        ---@type AgentData
        local data = AgentDataType.new({}, meta)
        local uid = self:GetAutoBuildId()
        local msg = {
            id = uid,
            tid = metaId,
            level = 1,
            direction = false,
            pos = {x = 0, y = 0}
        }
        data:InitServerData(uid, msg)

        if App.scene.mapManager:GetAutoBuild(data) then
            data:CommitTile()
            return data
        else
            -- self:PromoteBuyRegion()
            console.warn(nil, "No place to build!")
        end
    else
        console.error(nil, "No Building Meta:", metaId)
    end
end

function BuildingModifyManager:CreateAgentAuto(tid)
    local data = self:GetAutoBuildData(tid)
    if data then
        local sd = data:GetServerData()
        AppServices.Net:Send(
            MsgMap.CSPutBuildings,
            {
                tid = tid,
                pos = sd.pos,
                instanceId = tostring(sd.id)
            }
        )
        local agent = App.scene.objectManager:CreateAgent(data:GetId(), sd)
        App.scene.objectManager.sceneObjs[agent:GetId()] = agent
        App.scene.mapManager:InsertObject(agent)
        agent:InitState(CleanState.cleared)
        agent:HandleStateChanged()
        App.scene.interaction.editingAgent = agent
        agent:EnterEditMode()
        PanelManager.showPanel(GlobalPanelEnum.MovePanel)
        App.scene.interaction.editingAgent = nil
        local position = agent:GetWorldPosition()
        MoveCameraLogic.Instance():MoveCameraToLook2(position, 0.5)
    end
end
function BuildingModifyManager:OnReceivePut(msg)
    if self:IsSceneChanged() then
        console.error("scene has changed!!!") --@DEL
        return
    end
    local agent = App.scene.objectManager:GetAgent(msg.instanceId)
    if msg.errorCode ~= 0 then
        if agent then
            agent:Destroy()
        end
        return
    end
    agent:SetId(msg.id)
    -- App.scene.objectManager.sceneObjs[msg.instanceId] = nil
    App.scene.objectManager.sceneObjs[msg.id] = agent
end

---场景切换, 数据缓存清除
function BuildingModifyManager:Release()
    ---建筑场景配置信息
    if self.GridRationalityIndicator then
        self.GridRationalityIndicator:OnDestroy()
    end
    self.GridRationalityIndicator = nil
end
return BuildingModifyManager
