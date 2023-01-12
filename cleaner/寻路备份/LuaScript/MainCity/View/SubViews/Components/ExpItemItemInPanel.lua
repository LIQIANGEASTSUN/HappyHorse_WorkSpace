local SuperCls = require "UI.Components.ExpItem"
---@class ExpItemItemInPanel:HomeSceneTopIconBase
local ExpItemItemInPanel = class(SuperCls)

function ExpItemItemInPanel:CreateWithGameObject(gameObject)
    local instance = ExpItemItemInPanel.new()
    instance:InitWithGameObject(gameObject)
    instance:InitGrowth()
    return instance
end

function ExpItemItemInPanel:Refresh(callback)
    SuperCls.Refresh(self, callback)
    local level = AppServices.User:GetCurrentLevelId()
    local curExp = AppServices.User:GetExp()
    local fullExp = AppServices.Meta:GetLevelConfig(level).exp
    local lerp = curExp / fullExp
    self:SetLevelText(level)
    if AppServices.User:IsMaxLevel() and curExp == fullExp then
        self:RefreshMaxLevel()
    else
        self:SetSliderValue(lerp)
        self:SetStageProgressText(curExp, fullExp)
    end
end

-- 面板上的不做屏蔽处理
function ExpItemItemInPanel:SetInteractable(value)
end

function ExpItemItemInPanel:ShowExitAnim(instant, finishCallback, distance)
end

function ExpItemItemInPanel:ShowEnterAnim(instant, finishCallback)
end

function ExpItemItemInPanel:InitGrowth()
    self.go_GrowthFund = self.gameObject.transform.parent:FindGameObject("go_GrowthFund")
    if Runtime.CSNull(self.go_GrowthFund) then
        return
    end

    self.reddot = self.go_GrowthFund:FindGameObject("reddot")
    local function OnClick_btn_bubble(go)
        require("Game.Processors.RequestIAPProcessor").Start(function()
            PanelManager.showPanel(GlobalPanelEnum.GrowthFundPanel)
        end)
    end
    Util.UGUI_AddButtonListener(self.go_GrowthFund, OnClick_btn_bubble, {noAudio = true})

    local state = AppServices.GrowthFundManager:GetGrowthFundState()
    --if state ~= GrowthState.lock and state ~= GrowthState.finish then
        self:ShowBubble(state)
    --end
    self.extraTag = true
    MessageDispatcher:AddMessageListener(MessageType.GrowthFund_RefreshState, self.ShowBubble, self)
end

function ExpItemItemInPanel:ShowBubble(state)
    if Runtime.CSNull(self.go_GrowthFund) then
        return
    end
    self.go_GrowthFund:SetActive(state ~= GrowthState.lock and state ~= GrowthState.finish)
    self.reddot:SetActive(AppServices.GrowthFundManager:GetAcitveLenth() > 0)
end

function ExpItemItemInPanel:Dispose()
    if self.extraTag then
        MessageDispatcher:RemoveMessageListener(MessageType.GrowthFund_RefreshState, self.ShowBubble, self)
        self.extraTag = false
    end
    SuperCls.Dispose(self)
end

return ExpItemItemInPanel
