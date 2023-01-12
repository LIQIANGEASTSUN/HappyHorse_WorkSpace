---@class BaseAgent
local BaseAgent = class(nil, "BaseAgent")
function BaseAgent:ctor(id, data)
    self.alive = true
    ---@type AgentRender
    self.render = nil
    self.id = id
    ---@type AgentData
    self.data = data
    self.colorVal = nil
    self.instantiateCBs = {}
    self.cleaners = {}
    self.isCleaning = nil
end

function BaseAgent:InitAgent()
end

function BaseAgent:GetAssetName()
    if not self.assetName then
        self.assetName = self.data.meta.model
    end
    return self.assetName
end
function BaseAgent:SetAssetName(name)
    self.assetName = name
end

function BaseAgent:InitRender(callback)
    if not self.render then
        local AgentRender = require "MainCity.Render.AgentRender"
        self.render = AgentRender.new(self:GetAssetName())
    end
    self.render:SetPrune(self.prune)
    return self.render:Init(self.data, callback)
end

function BaseAgent:InitState(state)
    self.data:InitState(state)
end

function BaseAgent:DestroyRender()
    if self.render then
        self.render:OnDestroy()
        self.render = nil
    end
end

function BaseAgent:GetRender()
    return self.render
end

function BaseAgent:IsRenderValid()
    if not self.render then
        return false
    end
    return Runtime.CSValid(self.render.gameObject)
end

---获取当前状态
---@return CleanState
function BaseAgent:GetState()
    if self.data then
        return self.data:GetState()
    end
    console.warn(nil, "the agent has been destroyed but you are still trying to access it!") --@DEL
    return CleanState.cleared
end

function BaseAgent:GetId()
    return self.id
end

function BaseAgent:SetId(id)
    self.id = id
    if self.data then
        self.data:SetId(id)
    end
end

function BaseAgent:GetData()
    return self.data
end

function BaseAgent:GetMeta()
    local data = self:GetData()
    return data and data.meta
end

function BaseAgent:GetLevel()
    local data = self:GetData()
    if data then
        return data.mapData and data.mapData.level or 1
    else
        return 1
    end
end

function BaseAgent:SetLevel(level)
    self.data:SetLevel(level)
end

function BaseAgent:GetTemplateId()
    if self.data then
        return self.data:GetTemplateId()
    end
end

--获取agent类型，是建筑，障碍物还是迷雾
function BaseAgent:GetType()
    if self.data then
        return self.data:GetType()
    end
end
--获取攻击类型
function BaseAgent:GetSkillMatchType()
    if self.data then
        return self.data:GetSkillMatchType()
    end
end

function BaseAgent:InitServerData(serverData)
    if self.data then
        self.data:InitServerData(self.id, serverData)
    end
end
function BaseAgent:InitExtraData(extraData)
    if self.data then
        self.data:InitExtraData(extraData)
    end
end

function BaseAgent:SetServerData(serverData)
    self.data:SetServerData(serverData)
    if serverData.collectRewards then
        MapBubbleManager:ShowBubble(serverData.plantId, BubbleType.Collection, serverData.collectRewards)
    end

    App.mapGuideManager:OnGuideFinishEvent(GuideEvent.CustomEvent, "CollectBubble")
end

function BaseAgent:GetModelName()
    if self.render then
        return self.render:GetModelName()
    end
end

function BaseAgent:SetModelName(modelName, callback)
    if self.render then
        self.render:SetModelName(modelName, callback)
    end
end

function BaseAgent:SetPrune(prune)
    self.prune = prune
    if self.render then
        self.render:SetPrune(prune)
    end
end

-- ----------------子类必须实现的方法--------------------------
-- function BaseAgent:SetState(state) end
-- function BaseAgent:OnStateChanged() end
-- function BaseAgent:OnClick() end

---设置透明度
function BaseAgent:SetTransparency(value)
    if self.render then
        self.render:SetTransparency(value)
    end
end
---透明度渐变动画
function BaseAgent:TweenTransparency(value)
    if self.render then
        return self.render:TweenTransparency(value)
    end
end
function BaseAgent:SetHighlight(active)
    if self.render then
        self.render:SetHighlight(active)
    end
end
---设置显隐
function BaseAgent:SetVisible(isVisible)
    if self.render then
        self.render:SetVisible(isVisible)
    end
end

---获取地图坐标
function BaseAgent:GetMin()
    return self.data:GetMin()
end
---获取占地大小
function BaseAgent:GetSize()
    return self.data:GetSize()
end
---获取碰撞体头顶世界坐标
function BaseAgent:GetAnchorPosition(forceReset)
    if self.render then
        if forceReset then
            self.render.anchorPosition = nil
        end
        return self.render:GetAnchorPosition()
    end
    return self:GetWorldPosition() + Vector3(0, 0.5, 0)
end

--获取agent世界坐标
function BaseAgent:GetWorldPosition()
    if not self.data then
        return
    end
    local pos = self.data:GetPosition()
    return pos
end

function BaseAgent:GetCenterPostion()
    if not self.render then
        return
    end
    if Runtime.CSNull(self.render.collider) then
        return
    end
    local collider = self.render.collider
    return collider.bounds.center
end

---设置建筑修复等级(有可能非建筑也有)
---@param noAnima bool 如果传入noAnima, 则不播放动画, 动画由drama去控制
function BaseAgent:SetRepaireLevel(newLevel, setClean, animaOverCallback, noMsg, noAnima, repairDrawMsg)
    if self.data then
        local old = self.data:GetRepaireLevel()
        if old == newLevel then
            return
        end
        self.data:UpdateRepaireLevel(newLevel)
        if noAnima then
            if animaOverCallback then
                Runtime.InvokeCbk(animaOverCallback)
            end
            if not noMsg then
                AppServices.BuildingRepair:LvupMessage(self:GetId(), self:GetTemplateId(), newLevel)
            end
            if setClean then
                self:RepaireDone(repairDrawMsg)
            end
            return
        end

        local idleAnima = self.data:GetIdleAnimaName()
        -- TODO LZL 播放清理动画
        local callback = function()
            self._isPlayingLvup = false
            if self.render then
                self.render:UpdateDefaultAnima(idleAnima, true)
            end
            if animaOverCallback then
                Runtime.InvokeCbk(animaOverCallback)
            else
                Util.BlockAll(0, "BuildingRepairManager")
            end
            if not noMsg then
                AppServices.BuildingRepair:LvupMessage(self:GetId(), self:GetTemplateId(), newLevel)
            end
            if setClean then
                self:RepaireDone(repairDrawMsg)
            end
            App.audioManager:PlayEffectAudio(CONST.AUDIO.Interface_sound_story_restoring_building)
        end
        local lvupAnima = self.data:GetLvupAnimaName()
        if lvupAnima and self.render then
            self._isPlayingLvup = true
            self.render:PlayAnimation(lvupAnima, false, callback, true)
        else
            callback()
        end
    end
end

function BaseAgent:PlayIdleAnimation()
    if self.data then
        local idleAnima = self.data:GetIdleAnimaName()
        if self.render then
            self.render:UpdateDefaultAnima(idleAnima, true)
        end
    end
end

function BaseAgent:GetRepaireLevel()
    if self.data then
        return self.data:GetRepaireLevel()
    end
end

function BaseAgent:UpdateRepairProgress(progress)
    if self.data then
        self.data:UpdateRepairProgress(progress)
    end
end

function BaseAgent:GetRepairProgress()
    if self.data then
        return self.data:GetRepairProgress()
    else
        return 0
    end
end

---agent修复完成
function BaseAgent:RepaireDone(repairDrawMsg)
    local agentId = self:GetId()
    self:Clean(0)
    MessageDispatcher:SendMessage(
        MessageType.Building_Repair_Done,
        App.scene:GetCurrentSceneId(),
        agentId,
        repairDrawMsg
    )
end

function BaseAgent:PlayAnimation(animaName, loop, callback)
    if self.render then
        self.render:PlayAnimation(animaName, loop, callback)
    end
end

function BaseAgent:UpdateDefaultAnima(idleAnima)
    if self.render then
        self.render:UpdateDefaultAnima(idleAnima, true)
    end
end
-----------------------------清除逻辑-----------------------------
---从配置信息获取消除消耗物品和数量
function BaseAgent:GetMetaCost()
    if not self.data then
        console.terror(self:GetGameObject(), "agent data is nil, maybe this object has been destroyed") --@DEL
        return
    end
    return self.data:GetMetaCost()
end
function BaseAgent:GetCurrentCost()
    if not self.data then
        console.terror(self:GetGameObject(), "agent data is nil, maybe this object has been destroyed") --@DEL
        return
    end
    local id, cost, total = self.data:GetCurrentCost()
    return id, cost, total
end

function BaseAgent:Clean(value)
    local orgState = self.data:GetState()
    self.data:Clean(value)
    local state = self.data:GetState()
    if orgState ~= state and state == CleanState.cleared then
        MessageDispatcher:SendMessage(
            MessageType.Global_After_Plant_Cleared,
            App.scene:GetCurrentSceneId(),
            self:GetId()
        )
        self:HandleStateChanged()
    end
    self:AfterCleaned()
end

function BaseAgent:HandleStateChanged()
    local state = self:GetState()
    if self.handledState == state then
        return
    end
    self.handledState = state
    return self:OnStateChanged()
end

function BaseAgent:SetCleanState(val)
    self.isCleaning = val
end

function BaseAgent:IsCleaning()
    return self.isCleaning or (#self.cleaners > 0)
end

function BaseAgent:IsComplete()
    return self.data == nil or self:GetState() == CleanState.cleared
end

---是否阻挡格子传递
function BaseAgent:BlockGrid()
    return true
end
function BaseAgent:BlockBuilding()
    return true
end
------------------------------------------------------------------
function BaseAgent:GetGameObject()
    if self.render then
        return self.render.gameObject
    end
end

---设置是否可点击
function BaseAgent:SetClickable(clickable)
    if self.render then
        self.render:SetClickable(clickable)
    end
end
function BaseAgent:GetClickable()
    if self.render then
        return self.render.clickable
    end
end

---判断是否已经任务解锁
function BaseAgent:IsTaskUnlock()
    return true
end

function BaseAgent:IsBuildingTaskUnlock()
    return true
end

function BaseAgent:GetLockTaskId()
    if self.data then
        return self.data:GetLockTaskId()
    end
end

function BaseAgent:OnClearingEvent()
    MessageDispatcher:SendMessage(
        MessageType.Global_After_Agent_Clearing,
        App.scene:GetCurrentSceneId(),
        self:GetId(),
        self:GetTemplateId()
    )
end

---能被玩家看到
function BaseAgent:CanBeSeen(onlyClearing)
    if not self.alive then
        return false
    end
    local state = self:GetState()
    if onlyClearing then
        return state >= CleanState.clearing
    else
        return state > CleanState.locked
    end
end

---隐藏BindingTip
function BaseAgent:HideBindingTip()
    return false
end
-------------------------------------------------------------------------------------------
function BaseAgent:CanEdit()
    return self:GetState() == CleanState.cleared
end
function BaseAgent:EnterEditMode()
    if self.sendingRequest then
        return
    end
    self.isEditing = true
    self.originPosition = self:GetWorldPosition()
    self.data:CheckBuildingPosValid()
    if self.render then
        self.render:OnEnterEditMode()
    end
    SceneServices.GridRationalityIndicator:Show(0, self.data)
    return true
end
function BaseAgent:IsInEditMode()
    return self.isEditing
end
function BaseAgent:SetPosition(position)
    if self.data then
        local modify = self.data:SetPosition(position)
        if modify then
            if self.render then
                self.render:SetPosition(self.data:GetPosition())
            end
            local ret = self.data:CheckBuildingPosValid()
            if self.isEditing then
                SceneServices.GridRationalityIndicator:Show(ret, self.data)
            end
        end
        return modify
    end
end
function BaseAgent:ExitEditMode(put)
    if not self.isEditing then
        return
    end
    self.isEditing = false
    if put then
        if self.data and self.data:IsModified() then
            local result = self.data:CheckBuildingRationality()
            if result then
                self.sendingRequest = true
                AppServices.BuildingModifyManager:SendMove(self)
            else
                self:OnMoveFailed()
            end
        end
    else
        self:OnMoveFailed()
    end
    if self.render then
        self.render:OnExitEditMode()
    end
    SceneServices.GridRationalityIndicator:Hide()
end
function BaseAgent:OnMoveSucess()
    self.sendingRequest = nil
    if self.data then
        local map = App.scene.mapManager
        -- local pos = self.data:GetPosition()
        -- local flip = self.data:GetFlip()
        -- self.data:RevertTile()
        map:CleanPrevious(self)
        -- self.data:SetFlip(flip)
        -- self.data:SetPosition(pos)
        self.data:CommitTile()
        map:InsertObject(self)
    end
end
function BaseAgent:OnMoveFailed()
    self.sendingRequest = nil
    if self.data then
        self.data:RevertTile()
        if self.render then
            self.render:SetPosition(self.data:GetPosition())
        end
    end
end
-------------------------------------------------------------------------------------------
---是否与吸尘器交互(被吸)
function BaseAgent:Suckable()
    return false
end
function BaseAgent:GetSuckLevel()
    return 0
end
function BaseAgent:AfterCleaned()
end
-------------------------------------------------------------------------------------------
function BaseAgent:OnRegionLinked()
end
-------------------------------------------------------------------------------------------
local StateColor = {
    [0] = Color(0, 0, 0, 0.7), --locked(black)
    [1] = Color(1, 1, 0, 0.7), --prepare(yellow)
    [2] = Color(0, 0, 1, 0.7), --clearing(blue)
    [3] = Color(0, 1, 0, 0.7) --cleared(green)
}
function BaseAgent:DrawGizmos()
    if CS.GizmosUtil.showAgent then
        local map = App.scene.mapManager
        local Gizmos = CS.UnityEngine.Gizmos
        local p1 = self:GetWorldPosition()
        local x, z = self:GetMin()
        local p2 = map:ToWorld(x, z)
        Gizmos.color = StateColor[self:GetState()]
        Gizmos.DrawLine(p1, p2)
        local sx, sz = self:GetSize()
        local size = Vector3(0.95, 0.01, 0.95)
        if sx > 0 and sz > 0 then
            for i = x, x + sx - 1 do
                for j = z, z + sz - 1 do
                    local position = map:ToWorld(i,j)
                    Gizmos.DrawCube(position, size)
                end
            end
        end
    end
    if CS.GizmosUtil.showAgentId then
        local p1 = self:GetWorldPosition()
        if p1 then
            CS.XEditor.Label(p1, self:GetId())
        end
    end
end

function BaseAgent:Destroy()
    self.alive = false
    self.deleted = true

    if App.scene.mapManager then
        App.scene.mapManager:RemoveObject(self)
    end
    if App.scene.objectManager then
        App.scene.objectManager:DestroyObject(self:GetId())
    end

    if self.render then
        self.render:OnDestroy()
        self.render = nil
    end
    if self.data then
        self.data:OnDestroy()
        self.data = nil
    end
    self.instantiateCBs = {}
end

return BaseAgent
