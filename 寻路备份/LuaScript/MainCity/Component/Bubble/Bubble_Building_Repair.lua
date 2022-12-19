require("MainCity.Component.Bubble.Bubble_base")
---@class Bubble_Building_Repair
local Bubble_Building_Repair = class(Bubble_Interface, "Bubble_Building_Repair")

function Bubble_Building_Repair:ctor()
    self.type = BubbleType.Building_Repair
    self.canClick = true
    self.needCache = true
end

function Bubble_Building_Repair:InitData(param)
    self.agentId = param.agentId
    self.agent = App.scene.objectManager:GetAgent(self.agentId)
    self:SetPosition(self.agent:GetAnchorPosition())
    -- 刚开始的龙巢 位置需要特殊调整
    if self.agentId == "5944" then
        local anchoredPosition = self.rectTransform.anchoredPosition
        self.rectTransform.anchoredPosition = Vector2(anchoredPosition.x, anchoredPosition.y - 50)
    end
end

function Bubble_Building_Repair:onBubbleClick()
    if self.clickCallback then
        Runtime.InvokeCbk(self.clickCallback)
        return
    end
    if self.agent then
        self.agent:ProcessClick()
    end
    --[[if self.agentId then
        AppServices.BuildingRepair:ShowPanel(self.agentId)
    end--]]
end

function Bubble_Building_Repair:ResetBubbleClick(cbk)
    self.clickCallback = cbk
end

function Bubble_Building_Repair:ClearState()
    self.clickCallback = nil
    self.agentId = nil
end

return Bubble_Building_Repair