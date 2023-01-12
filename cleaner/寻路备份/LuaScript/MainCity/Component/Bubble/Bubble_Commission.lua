require("MainCity.Component.Bubble.Bubble_base")
---@class Bubble_Commission
local Bubble_Commission = class(Bubble_Interface, "Bubble_Commission")

function Bubble_Commission:ctor()
    self.type = BubbleType.Commission
    self.canClick = true
    self.needCache = true
end

function Bubble_Commission:InitData(param)
    self.agent = App.scene.objectManager:GetAgent(param.agentId)
    self:SetPosition(self.agent:GetAnchorPosition())
    self.data = param.data
    if self.data.commission.hasReward then
        self.rewardGo:SetActive(true)
        self.timeGo:SetActive(false)
    else
        self.rewardGo:SetActive(false)
        self.timeGo:SetActive(true)
        self:StartTimer()
    end
end

function Bubble_Commission:BindView(go)
    self.timeGo = find_component(go, "bg/timeTip")
    self.rewardGo = find_component(go, "bg/rewardTip")
    self.txtTime = find_component(self.timeGo, "icon/txt_time",Text)
end

function Bubble_Commission:StartTimer()
    self:StopTimer()
    local duration = self.data.meta.time * 60
    local function update()
        local startTime = self.data.commission.startTime
        local time = startTime + duration - TimeUtil.ServerTime()
        self.txtTime.text = TimeUtil.SecToHMS(time)
    end
    self.repeatId = WaitExtension.InvokeRepeating(function()
        update()
    end, 0, 1)
    update()
end


function Bubble_Commission:StopTimer()
    if self.repeatId then
        WaitExtension.CancelTimeout(self.repeatId)
        self.repeatId = nil
    end
end

function Bubble_Commission:onBubbleClick()
    local commission = self.data.commission
    if commission then
        -- local reward = AppServices.CommissionManager:GetReward(commission.commissionId)
        -- if reward and Runtime.CSValid(reward.gameObject) then
        --     local destPos = reward.gameObject:GetPosition()
        --     MoveCameraLogic.Instance():MoveCameraToLook2(destPos, 0.5)
        --     local arrow = reward.gameObject:FindGameObject("canvas/Image/arrow")
        --     arrow:SetActive(true)
        --     WaitExtension.SetTimeout(
        --         function()
        --             if Runtime.CSValid(arrow) then
        --                 arrow:SetActive(false)
        --             end
        --         end,
        --         3
        --     )
        -- end
        if commission.hasReward then
            AppServices.CommissionManager:CommissionRewardRequest({commissionId = commission.commissionId})
        else
            local id = AppServices.CommissionManager:HasCommission()
            if id then
                PanelManager.showPanel(GlobalPanelEnum.ExploringPanel, {commissionId = id})
            end
        end
    else
        -- PanelManager.showPanel(GlobalPanelEnum.CommissionPanel,{attribute = self.data.attribute})
        ---todo
    end
end

function Bubble_Commission:ClearState()
    self:StopTimer()
end

return Bubble_Commission