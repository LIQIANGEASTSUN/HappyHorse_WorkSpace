require("MainCity.Component.Bubble.Bubble_base")
---@class Bubble_BreedNew
local Bubble_BreedNew = class(Bubble_Interface, "Bubble_BreedNew")

function Bubble_BreedNew:ctor()
    self.type = BubbleType.BreedNew
    self.canClick = true
    self.needCache = true
end

function Bubble_BreedNew:InitData(param)
    self.agentId = param.agentId
    local agent = App.scene.objectManager:GetAgent(param.agentId)
    if not agent or Runtime.CSNull(agent:GetGameObject()) then
        return
    end
    self:SetPosition(agent:GetAnchorPosition())
    local anchoredPosition = self.rectTransform.anchoredPosition
    self.rectTransform.anchoredPosition = Vector2(anchoredPosition.x, anchoredPosition.y + 30)
end

function Bubble_BreedNew:onBubbleClick()
    SceneServices.BreedManager:ShowMainPanel()
    -- MapBubbleManager:CloseBubble(self.agentId)
end

return Bubble_BreedNew
