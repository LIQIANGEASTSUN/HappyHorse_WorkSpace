local SuperCls = require "UI.Components.DiamondItem"

---@class DiamondItemInPanel:DiamondItem
local DiamondItemInPanel = class(SuperCls)

function DiamondItemInPanel:CreateWithGameObject(gameObject)
    local instance = DiamondItemInPanel.new()
    instance:InitWithGameObject(gameObject)
    instance:InitMoncard()

    return instance
end

function DiamondItemInPanel:SetInteractable(value)
end

function DiamondItemInPanel:ShowEnterAnim(instant, finishCallback)
    self:Refresh()
end

function DiamondItemInPanel:ShowExitAnim(instant, finishCallback, distance)
end

function DiamondItemInPanel:InitMoncard()
    local state = AppServices.MonCard:GetMonCardState()
    if state ~= MonCardState.Lock then
        self:ShowBubble(state)
    end
    MessageDispatcher:AddMessageListener(MessageType.MonCard_RefreshState, self.ShowBubble, self)
end

function DiamondItemInPanel:ShowBubble(state)
    if not self.go_MonCard then
        self.go_MonCard = self.gameObject.transform.parent:FindGameObject("go_MonCard")
        self.reddot = self.go_MonCard:FindGameObject("reddot")
        local function OnClick_btn_bubble(go)
            AppServices.MonCard:OpenPanel({source = 1})
        end
        Util.UGUI_AddButtonListener(self.go_MonCard, OnClick_btn_bubble, {noAudio = true})
    end


    self.go_MonCard:SetActive(state ~= MonCardState.Lock)
    self.reddot:SetActive(state == MonCardState.NotRecieved)
end

function DiamondItemInPanel:Dispose()
    MessageDispatcher:RemoveMessageListener(MessageType.MonCard_RefreshState, self.ShowBubble, self)
    SuperCls.Dispose(self)
end

return DiamondItemInPanel
