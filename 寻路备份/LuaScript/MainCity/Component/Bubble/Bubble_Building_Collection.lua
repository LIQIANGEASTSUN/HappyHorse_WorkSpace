require("MainCity.Component.Bubble.Bubble_base")
---@class Bubble_Building_Collection:Bubble_Interface
local Bubble_Building_Collection = class(Bubble_Interface, "Bubble_Building_Collection")

function Bubble_Building_Collection:ctor()
    self.type = BubbleType.Building_Collection
    self.canClick = true
    self.needCache = true
end

function Bubble_Building_Collection:InitData(param)
    local agent = App.scene.objectManager:GetAgent(param.agentId)
    self:SetPosition(agent:GetAnchorPosition())
end

function Bubble_Building_Collection:onBubbleClick()
    AppServices.CollectionItem:ShowPanel()
end

return Bubble_Building_Collection