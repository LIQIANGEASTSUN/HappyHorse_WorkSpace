--insertWidgetsBegin
--    go_ItemContaniner
--insertWidgetsEnd

local RewardItem = require("UI.Components.RewardItem")

--insertRequire
local _SimpleRewardPanelBase = require "UI.Common.SimpleRewardPanel.View.UI.Base._SimpleRewardPanelBase"

---@class SimpleRewardPanel:_SimpleRewardPanelBase
local SimpleRewardPanel = class(_SimpleRewardPanelBase)
function SimpleRewardPanel:ctor()
    ---@type RewardItem[]
    self.flyItems = {}
end

function SimpleRewardPanel:onAfterBindView()
    -- local rewards = self.arguments.rewards
    self.container_items:SetSpacing(25)

    local curveAssetPath = "Prefab/UI/Common/Buildin/RewardItem/RewardItemScaleCurve.asset"
    local function onLoaded()
        self.curveAsset = App.uiAssetsManager:GetAsset(curveAssetPath)
    end
    App.uiAssetsManager:LoadAssets({curveAssetPath}, onLoaded)
end

function SimpleRewardPanel:InitRewards(rewards)
    self.rewards = rewards
    self:SortRewards()
    for k, v in ipairs(rewards) do
        local reward = RewardItem.new()
        local item = BResource.InstantiateFromAssetName(CONST.ASSETS.G_REWARD_ITEM)
        reward:InitWithGameObject(item)
        reward:Generate(v)
        reward.transform.localScale = Vector3.zero
        self.container_items:AddItem(item)
        table.insert(self.flyItems, reward)
    end
    self.container_items.transform.anchoredPosition = Vector2(0, 0)
end

function SimpleRewardPanel:SortRewards()
    local priorityCfg = AppServices.Meta:GetRewardAnimPriority()
    table.sort(
        self.rewards,
        function(a, b)
            local priority_a = priorityCfg[a.ItemId] or 999
            local priority_b = priorityCfg[b.ItemId] or 999
            return priority_a < priority_b
        end
    )
end

function SimpleRewardPanel:ShowRewards()
    local scaleTime = 0.5
    local t, c = 0, 0

    local function prepareFly()
        self:FlyRewards()
    end

    local function waitFinished()
        c = c + 1
        if t ~= c then
            return
        end

        local time = 0.3
        for _, value in ipairs(self.flyItems) do
            if Runtime.CSValid(value.text_count) then
                value.text_count.gameObject:SetActive(false)
                value.img_glow.gameObject:SetActive(false)
                value.transform:DOScale(0.9, time):SetEase(Ease.Linear)
            end
        end
        WaitExtension.SetTimeout(prepareFly, time)
    end
    t = t + 1

    local function wait()
        WaitExtension.SetTimeout(waitFinished, 0.3)
    end
    -- GameUtil.DoScale(self.container_items.gameObject, Vector3.one, scaleTime, wait)

    local ease = self.curveAsset and self.curveAsset.curve or Ease.Linear
    for _, value in ipairs(self.flyItems) do
        value.transform:DOScale(0.6, scaleTime):SetEase(ease)
    end

    WaitExtension.SetTimeout(wait, scaleTime)
end

function SimpleRewardPanel:FlyRewards()
    local total = #self.rewards or 0
    if total == 0 then
        sendNotification(SimpleRewardPanelNotificationEnum.Fly_Finish)
        return
    end

    -- local counter = 0

    local function onFinish()
        -- counter = counter + 1
        -- if counter == total then
        --     sendNotification(SimpleRewardPanelNotificationEnum.Fly_Finish)
        --     Runtime.InvokeCbk(self.arguments.dayRewardCbk)
        -- end
    end

    local function flyItemCallback(flyObject)
    end

    local flyTime = 0.5
    for k, v in ipairs(self.rewards) do
        local flyItem = self.flyItems[k]

        flyItem.transform:DOScale(0.45, flyTime)
        if flyItem.trail_jinbi and (v.ItemId == ItemId.COIN or v.ItemId == ItemId.EXP) then
            flyItem.trail_jinbi:SetActive(true)
        elseif flyItem.trail_tili and (v.ItemId == ItemId.ENERGY or v.ItemId == ItemId.DIAMOND) then
            flyItem.trail_tili:SetActive(true)
        end
        AppServices.FlyAnimation.FlyItem(v.ItemId, flyItem, onFinish, flyItemCallback, flyTime)
    end
    sendNotification(SimpleRewardPanelNotificationEnum.Fly_Finish)
    Runtime.InvokeCbk(self.arguments.dayRewardCbk)
end

function SimpleRewardPanel:refreshUI()
end

return SimpleRewardPanel
