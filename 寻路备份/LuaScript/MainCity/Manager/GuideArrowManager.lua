--列表中的agent没有被清除之前不要出待机引导
local ignoreAgentList = {
    "18607"
}
local Input = CS.UnityEngine.Input
---@class GuideArrowManager
local GuideArrowManager = {}

function GuideArrowManager:OnSceneLoaded()
    self:Init()
    self.checking = false
    self:CheckShowGuideArrows()
end

local screenWidth = Screen.width
local screenHeight = Screen.height

function GuideArrowManager:CheckShowGuideArrows()
    local function isInScreen(screenPos)
        return screenPos.x > 0 and screenPos.x < screenWidth and screenPos.y > 0 and screenPos.y < screenHeight
    end

    local function showArrow(agent, worldPos)
        local screenPos = App.scene.mainCamera:WorldToScreenPoint(worldPos)
        if not isInScreen(screenPos) then
            return
        end
        self.hasShow = true
        local agentId = agent:GetId()
        SceneServices.AgentTip:ClearTip(agentId)
        MapBubbleManager:ShowGuideArrow(
            agentId,
            {
                position = worldPos
            }
        )
    end

    local function checkFeed()
        if not App.scene:IsMainCity() then
            return
        end
        if not AppServices.MagicalCreatures:HasHungry() then
            return
        end
        local agent = App.scene.objectManager:GetAgentByTemplateId(BuildingTemplateIdEnum.MagicalCreaturesNest)
        if not agent or not agent.render or not agent:IsRenderValid() then
            return
        end
        local worldPos = agent:GetWorldPosition()
        worldPos.x = worldPos.x + 0.13
        worldPos.y = worldPos.y + 3.7
        showArrow(agent, worldPos)
    end

    local function checkFactory()
        local productIds = AppServices.FactoryManager:GetFinishProductCountExludeSingle()
        if #productIds == 0 then
            return
        end

        local agent = AppServices.FactoryManager:GetFactoryAgent()
        if not agent or not agent.render or not agent:IsRenderValid() then
            return
        end
        local worldPos = agent:GetWorldPosition()
        worldPos.x = worldPos.x - 0.1
        worldPos.y = worldPos.y + 3.5
        showArrow(agent, worldPos)
    end

    local function checkFarm()
        if self.farmAgent then
            return
        end
        local agent = AppServices.FarmManager:GetFinishedAgent()
        if not agent or not agent.render or not agent:IsRenderValid() then
            return
        end

        local worldPos = agent:GetWorldPosition()
        worldPos.y = worldPos.y + 0.5
        showArrow(agent, worldPos)
        self.farmAgent = agent
    end

    local function checkCollection()
        local agent = App.scene.objectManager:GetAgentByType(AgentType.collectitem)
        if not agent or not agent.render or not agent:IsRenderValid() then
            return
        end
        local agentId = agent:GetId()
        local isShow = MapBubbleManager:IsShowedBubble(agentId)
        if not isShow then
            return
        end
        local worldPos = agent:GetAnchorPosition()
        worldPos = Vector3(worldPos.x, worldPos.y + 1, worldPos.z)
        showArrow(agent, worldPos)
    end

    local function delayDo()
        self.timeId = nil
        if App.mapGuideManager:HasRunningGuide() then
            return
        end
        ---@type TaskIconButton
        local taskBtn = App.scene:GetWidget(CONST.MAINUI.ICONS.TaskBtn)
        if not taskBtn or taskBtn:NeedWeakGuide() then
            return
        end

        for index, value in ipairs(ignoreAgentList) do
            local agent = App.scene.objectManager:GetAgent(value)
            if agent and agent:GetState() < CleanState.cleared then
                return
            end
        end

        if self.hasShow then
            return
        end
        checkFactory()
        if self.hasShow then
            return
        end
        checkFeed()
        if self.hasShow then
            return
        end
        checkFarm()
        if self.hasShow then
            return
        end
        checkCollection()
    end

    local function idleDo()
        self.checking = nil
        self.timeId = WaitExtension.SetTimeout(delayDo, 5)
    end

    if self.checking then
        return
    end
    self.checking = true
    PopupManager:CallWhenIdle(idleDo)
end

function GuideArrowManager:OnMouseDown()
    self:CloseAll()
end

function GuideArrowManager:OnMouseUp()
    self:CheckShowGuideArrows()
end

function GuideArrowManager:Update()
    if Input.GetMouseButtonDown(0) then
        self:OnMouseDown()
    elseif Input.GetMouseButtonUp(0) then
        self:OnMouseUp()
    end
end

function GuideArrowManager:CloseAll()
    self.hasShow = false
    MapBubbleManager:CloseAllGuideArrows()
    if self.timeId then
        WaitExtension.CancelTimeout(self.timeId)
        self.timeId = nil
    end
    self.farmAgent = nil
end

function GuideArrowManager:OnDramaStart()
    self:CloseAll()
end

function GuideArrowManager:OnDramaOver()
    self:CheckShowGuideArrows()
end

function GuideArrowManager:OnCameraZoom()
    self:CloseAll()
    self:CheckShowGuideArrows()
end

function GuideArrowManager:Init()
    if self.inited then
        return
    end
    self.inited = true
    MessageDispatcher:AddMessageListener(MessageType.Global_Drama_Start, self.OnDramaStart, self)
    MessageDispatcher:AddMessageListener(MessageType.Global_Drama_Over, self.OnDramaOver, self)
    MessageDispatcher:AddMessageListener(MessageType.Global_Camera_Size_Changed, self.OnCameraZoom, self)
end

return GuideArrowManager
