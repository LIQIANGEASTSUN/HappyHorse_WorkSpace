local base = require "MainCity.Interaction.InteractionLogic.BaseInteractionLogic"
---@class Interaction : BaseInteractionLogic
local Interaction = class(base, "Interaction")

local mousePosition = nil
local deltaPosition = nil
local pressOffset = nil
local UserInputType = UserInputType
local UserInput = UserInput
local Input = CS.UnityEngine.Input

function Interaction:ctor()
    self.editingAgent = nil
end

function Interaction:Update()
    -- if not self:GetActive() then
    -- end
    UserInput.Clear()
    self.inputMgr:Update()
    -- if PanelManager.isShowingAnyPanel() then
    --     local down = Input.GetMouseButtonDown(0)
    --     if down then
    --         local position = Camera.main.ScreenToWorldPoint(Input.mousePosition)
    --         position = position:Flat()
    --         AppServices.ClickEffectTool:Show(false, position)
    --     end
    -- end
    if Input.GetKeyDown(CS.UnityEngine.KeyCode.L) then --@DEL
        local func = include("Configs.GuideTest") --@DEL
        Runtime.InvokeCbk(func) --@DEL
    end --@DEL

    if Input.GetKeyDown(CS.UnityEngine.KeyCode.K) then --@DEL
        local func = include("Configs.GuideTest1") --@DEL
        Runtime.InvokeCbk(func) --@DEL
    end --@DEL
end
function Interaction:OnGUI()
    if not self:GetActive() then
        return
    end
    if self.inputMgr and self.inputMgr.OnGUI then
        self.inputMgr:OnGUI()
    end
end

function Interaction:RegisterListeners()
    if App.scene:IsScene(SceneMode.home) then
        -- console.error("LUA  AddShakeListener")
        self:RegisterRoamListener()
    else
        -- console.error("LUA  NOT MAIN CITY")
        -- self:RegisterKeyListener()
        self:RegisterDragScreenListener()
    end
    self:RegisterClickListener()
    self:RegisterShakeListener()
    self:RegisterLongPressListener()
    self:RegisterScaleListener()
    self:RegisterKeyListener()
    self:RegisterDragListener()

    self.inputMgr:Awake()
end

---@param input CustomInput
local function GetHit(input)
    local hitCount = input:GetHitCount()
    for index = 1, hitCount do
        local hitInfo = input:GetHitInfo(index - 1)
        if hitInfo and hitInfo.transform and Runtime.CSValid(hitInfo.transform) then
            local pickObject = hitInfo.transform:GetComponent(typeof(CS.PickObject))
            if Runtime.CSValid(pickObject) then
                return hitInfo
            end
        end
    end
    return input.hit
end

local Time = Time
local doubleClickThreshold = 0.2
function Interaction:ProcessDoubleClick(input)
    if self.preClick then
        local deltaTime = Time.realtimeSinceStartup - self.preClick[2]
        -- console.error(deltaTime)
        local hit = GetHit(input)
        if not hit.transform then
            return
        end
        if deltaTime < doubleClickThreshold and hit.collider == self.preClick[1].hit.collider then
            self:OnDoubleClick(input)
            -- console.error("ProcessDoubleClick")
            self.preClick = {input, Time.realtimeSinceStartup}
        else
            self.preClick = {input, Time.realtimeSinceStartup}
        end
    else
        self.preClick = {input, Time.realtimeSinceStartup}
    end
end

function Interaction:UnRegisterListeners()
    self.inputMgr:AddShakeListener()
    self.inputMgr:AddDragListener()
    self.inputMgr:AddLongPressListener()
    self.inputMgr:AddClickListener()
    self.inputMgr:AddScaleListener()
    self.inputMgr:AddUpDownListener()
    self.inputMgr:AddRoamListener()
end

function Interaction:OnMouseDown(input)
    if not App.mapGuideManager:HasRunningGuide() then
        MoveCameraLogic.Instance():StopMoveCamera()
    end
    local hit = GetHit(input)
    if not hit.transform then
        return
    end
    local mainHitName = hit.collider.name
    local char = CharacterManager.Instance():Find(mainHitName)
    if char and char.OnDragBegin then
        self.currentCharacter = char
        char:OnDragBegin()
        return
    end

    local agent = App.scene.objectManager:GetAgent(mainHitName)
    if agent and agent.OnMouseDown then
        agent:OnMouseDown()
    end

    UserInput.onTrigger(UserInputType.mouseDown)
end

function Interaction:OnMouseUp(input)
    local hit = GetHit(input)
    if not hit.transform then
        return
    end

    if self.currentCharacter and self.currentCharacter.OnDragEnd then
        self.currentCharacter:OnDragEnd()
        self.currentCharacter = nil
        return
    end

    local mainHitName = hit.collider.name
    local agent = App.scene.objectManager:GetAgent(mainHitName)
    if agent and agent.OnMouseUp then
        agent:OnMouseUp()
    end

    UserInput.onTrigger(UserInputType.mouseUp)
end

function Interaction:OnShake()
    local result = -1
    if App.scene:IsMainCity() then
        if not App.mapGuideManager:HasRunningGuide() then
            result = AppServices.MagicalCreatures:CollectAllHangupReward()
        end
        App.mapGuideManager:OnGuideFinishEvent(GuideEvent.OnShake)
    end
    MessageDispatcher:SendMessage(MessageType.Global_OnShake)
    return result
end

function Interaction:OnZoomCamera(scale)
    if App.mapGuideManager:IsScaleScreenDisabled() then
        return
    end
    if RuntimeContext.DisableScaleScreen then
        return
    end

    MoveCameraLogic.Instance():ZoomCamera(scale)
end

---@param input CustomInput
function Interaction:OnDragBoundary(input)
end

---@param input CustomInput
function Interaction:OnDragBegin(input)
    if App.mapGuideManager:IsDragScreenDisabled() then
        return
    end
    if RuntimeContext.DisableDragScreen then
        return
    end

    local hit = GetHit(input)
    if not hit.transform then
        return
    end
end

---@param input CustomInput
function Interaction:OnDragging(input)
    if App.mapGuideManager:IsDragScreenDisabled() then
        return
    end

    if RuntimeContext.DisableDragScreen then
        return
    end

    if self.currentCharacter and self.currentCharacter.OnDrag then
        self.currentCharacter:OnDrag(input.worldDelta)
    else
        self:DragScreen(input)
    end
end

---@param input CustomInput
function Interaction:OnDragEnd(input)
    if App.mapGuideManager:IsDragScreenDisabled() then
        return
    end

    if RuntimeContext.DisableDragScreen then
        return
    end

    if self.currentCharacter and self.currentCharacter.OnDragEnd then
        self.currentCharacter:OnDragEnd()
        self.currentCharacter = nil
    else
        MoveCameraLogic.Instance():MoveCamera(input.worldDelta, true)
    end
end

---@param input CustomInput
function Interaction:OnLongPress(input)
    if App.mapGuideManager:IsLongPressDisabled() then
        return
    end
    if self.editingAgent and self.editingAgent.alive then
        if input.progress < 1 then
            local position = self.editingAgent:GetAnchorPosition(true)
            local param = {
                position = position,
                progress = input.progress
            }
            sendNotification(CONST.GLOBAL_NOFITY.BUILDING_PRESS_PROGRESS, param)
        else
            if self.editingAgent:EnterEditMode() then
                PanelManager.showPanel(GlobalPanelEnum.MovePanel)
            end
            self.editingAgent = nil
            sendNotification(CONST.GLOBAL_NOFITY.BUILDING_PRESS_PROGRESS_END, 1)
        end
        return
    end
    local hit = GetHit(input)
    if not hit.transform then
        return
    end
    SceneServices.BindingTip:HideAll()
    -- SceneServices.PathTip:ClearAllTips()
    ---显示障碍物详情气泡
    if Runtime.CSValid(hit.collider) then
        local hitName = hit.collider.name
        local agent = App.scene.objectManager:GetAgent(hitName)
        if agent and agent:CanEdit() then
            agent:SetHighlight(true)
            local agentState = agent:GetState()
            if agentState == CleanState.cleared then
                self.editingAgent = agent
            elseif agentState == CleanState.clearing or agentState == CleanState.prepare then
                self.editingAgent = agent --TODO TEST DELETE
                -- agent:ShowAgentDetail()
            end
        end
    end
end

function Interaction:OnCancelPress()
    -- SceneServices.GridRationalityIndicator:Hide()
    -- if self.editingAgent then
    --     local agent = self.editingAgent
    --     self.editingAgent = nil
    --     agent:ExitEditMode()
    --     agent:SetHighlight(false)
    -- end
    sendNotification(CONST.GLOBAL_NOFITY.BUILDING_PRESS_PROGRESS_END, 0)
end

function Interaction:OnDoubleClick(input)
    local mainHitName = input.hit.collider.name
    if not mainHitName then
        return
    end
    if App.mapGuideManager:IsDoubleClickDisabled(mainHitName) then
        return
    end
    ---@type NormalAgent
    local agent = App.scene.objectManager:GetAgent(mainHitName)
    if not agent then
        return
    end

    AppServices.EventDispatcher:dispatchEvent(GlobalEvents.DoubleClickCollider, agent)
end

local clickState = {
    others = 0,
    ground = 1,
    agent = 2,
    character = 3,
    entity = 4,
    unit_tips = 5,
}

local onClickHandler = {
    [clickState.ground] = function(pos)
        UserInput.setPosition(pos)
        if App.mapGuideManager:HasRunningGuide() and not App.mapGuideManager:IsWeakStep() then
            return
        end
        console.lh("click Ground") --@DEL
        UserInput.onTrigger(UserInputType.clickGround)
    end,
    [clickState.agent] = function(data)
        ---@type BaseAgent
        local agent = data.agent
        local input = data.input
        local mainHitName = data.mainHitName
        if not agent:IsCleaning() then
            if App.mapGuideManager:IsAgentClickDisabled(mainHitName) then
                return
            end
            -- local locked = agent:IsLocked()
            -- if locked then
            --     local tip = agent:GetLockTip()
            --     if tip then
            --         -- UITool.ShowContentTipAni(tip, agent:GetAnchorPosition())
            --         AppServices.UITextTip:Show(tip)
            --     end
            --     return
            -- end
            local castList = {mainHitName}
            local castCount = input:GetHitCount()
            for i = 1, castCount, 1 do
                local hit = input:GetHitInfo(i - 1)
                local hitName = hit.collider.name
                table.insertIfNotExist(castList, hitName)
            end
            UserInput.setCastList(castList)
            UserInput.onTrigger(UserInputType.clickObstacle)
        end
    end,
    [clickState.entity] = function(entity)
        local castList = {entityId = entity.entityId}
        UserInput.setCastList(castList)
        UserInput.onTrigger(UserInputType.clickEntity)
    end,
    [clickState.unit_tips] = function(tips)
        local castList = {name = tips:TipsName()}
        UserInput.setCastList(castList)
        UserInput.onTrigger(UserInputType.clickTips)
    end,
    [clickState.character] = function(character)
        character:OnClick()
    end
}

function Interaction:OnClick(input)
    -- SceneServices.BindingTip:HideAll()
    -- SceneServices.PathTip:ClearAllTips()
    -- AppServices.FarmManager:HideCropInfo()

    self:ProcessDoubleClick(input)
    local hit = GetHit(input)
    if not hit.transform then
        return
    end

    local function getHitState()
        local pos = input.worldPosition
        local mainHitName = hit.collider.name
        local mapMgr = App.scene.mapManager
        local grid_x, grid_z = mapMgr:ToLocal(pos)
        local isPassable = mapMgr:IsPassable(grid_x, grid_z)
        local gridState = mapMgr:GetState(grid_x, grid_z)

        if input:IsHitGround() then
            --地面点击特效
            AppServices.ClickEffectTool:Show(isPassable, pos)
            if isPassable and gridState == CleanState.cleared then
                return clickState.ground, pos
            end
        end

        local agent = App.scene.objectManager:GetAgent(mainHitName)
        if agent then
            return clickState.agent, {agent = agent, input = input, mainHitName = mainHitName}
        end
        local character = CharacterManager.Instance():Find(mainHitName)
        if character then
            return clickState.character, character
        end
        local entity = AppServices.EntityManager:GetEntityWithName(mainHitName)
        if entity then
            return clickState.entity, entity
        end
        local tips = AppServices.UnitTipsManager:GetTipsWithName(mainHitName)
        if tips then
            return clickState.unit_tips, tips
        end
        return clickState.others
    end

    local state, param = getHitState()
    if state == clickState.others then
    else
        local handler = onClickHandler[state]
        if handler then
            return Runtime.InvokeCbk(handler, param)
        end
    end

    if App.mapGuideManager:IsClickDragonDisabled() then
        return
    end

    AppServices.EventDispatcher:dispatchEvent(GlobalEvents.ClickNothing)
    return
end

----------------------------------------相机移动----------------------------------------
---@param input CustomInput
function Interaction:DragScreen(input)
    if App.mapGuideManager:IsDragScreenDisabled() then
        return
    end
    if RuntimeContext.DisableDragScreen then
        return
    end
    MoveCameraLogic.Instance():MoveCamera(input.worldDelta)
end
--------------------------------建筑的指示图标--------------------------------
---是否正在编辑模式
function Interaction:InEdit()
    return false
end
--------------------------------------------测试画线--------------------------------------------
function Interaction:DrawGizmos()
    if mousePosition and deltaPosition then
        local Gizmos = CS.UnityEngine.Gizmos
        Gizmos.color = Color.red
        CS.GizmosUtil.DrawArrow(mousePosition, mousePosition + pressOffset)

        Gizmos.color = Color.green
        CS.GizmosUtil.DrawArrow(mousePosition + pressOffset - deltaPosition, mousePosition + pressOffset)
    end
end
----------------------------------------------销毁----------------------------------------------
function Interaction:Destroy()
    self.inputMgr:Destroy()
    self.inputMgr = nil
    UserInput.Clear()
end

return Interaction
