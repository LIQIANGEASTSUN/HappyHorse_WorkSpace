--insertRequire
local _OpenRewardsPanelBase = require "MainCity.UI.OpenRewardsPanel.View.UI.Base._OpenRewardsPanelBase"
---@class OpenRewardsPanel:_OpenRewardsPanelBase
local OpenRewardsPanel = class(_OpenRewardsPanelBase)

local RewardItem = require("UI.Components.RewardItem")

function OpenRewardsPanel:ctor()
end

function OpenRewardsPanel:refreshUI()
end

function OpenRewardsPanel:SetRewards(rewardItems)
    local function SortItems(items)
        local ret = {}
        local i = 1
        local j = 0
        local diamond = ItemId.DIAMOND
        local coin = ItemId.COIN

        for _, v in pairs(items) do
            if v.ItemId == diamond then
                table.insert(ret, i, v)
                i = i + 1
            elseif v.ItemId == coin then
                table.insert(ret, i + j, v)
                j = j + 1
            else
                table.insert(ret, v)
            end
        end

        return ret
    end

    rewardItems = SortItems(rewardItems)
    ---@type RewardItem[]
    self.flyItems = {}
    table.removeIf(
        rewardItems,
        function(item)
            return item.Amount == nil or item.Amount == 0
        end
    )

    local container = self.row1
    for k, v in pairs(rewardItems) do
        local reward = RewardItem.new()
        container:SetActive(true)
        local item = BResource.InstantiateFromAssetName(CONST.ASSETS.G_REWARD_ITEM)
        reward:InitWithGameObject(item)
        reward:Generate(v)
        container:AddItem(item)

        table.insert(self.flyItems, reward)
    end

    self.rewardItems = rewardItems
    self.titleGo:SetActive(false)

    if self.row1.transform.childCount > 5 then
        self.row1:SetSpacing(-50)
    end
end

function OpenRewardsPanel:ShowRewards(finishCallback)
    -- local arguments = self:getArguments()
    self.titleGo:SetActive(true)

    GameUtil.DoScale(
        self.go_container.transform,
        Vector3.one,
        0.5,
        function()
            self:StartFirework()
            Runtime.InvokeCbk(finishCallback)
        end
    )
end

function OpenRewardsPanel:beforFlyRewards()
    self.titleGo:SetActive(false)
    RewardContainer.DisableLayout(self.go_container)
    self.go_starPaticles:SetActive(false)
    -- self.go_container:SetActive(false)
end

function OpenRewardsPanel:FlyRewards(finishCallback)
    self:beforFlyRewards()
    local counter = 0
    local total = 0
    local doFinish = function()
        if App.scene:IsScene(SceneMode.home) and self.arguments.autoExitIconItem then
            App.scene:HideAllIcons()
        end
        if finishCallback then
            finishCallback()
        end
    end
    local function onFinish()
        counter = counter + 1
        if counter == total then
            doFinish()
        end
    end

    local function flyItemCallback(flyObject)
        local reward = RewardItem.new()
        reward:InitWithGameObject(flyObject)
        reward:DoSizeDelta(Vector2(71, 71), 1)
        reward:HideGlow()
    end
    for k, v in pairs(self.rewardItems) do
        local flyItem = self.flyItems[k]
        flyItem.text_count:SetActive(false)
        flyItem:HideGlow()
        AppServices.FlyAnimation.FlyItem(v.ItemId, flyItem, onFinish, flyItemCallback)
    end
end

function OpenRewardsPanel:StartFirework()
    if self.fireworkStopped then
        return
    end
    local effect = BResource.InstantiateFromAssetName(CONST.UIEFFECT_ASSETS.FIREWORKS)
    effect.transform:SetParent(self.gameObject.transform, false)
    self.effect_fireWork = effect
    App.audioManager:PlayEffectAudio(CONST.AUDIO.Interface_Celebrate, false, true)
end

function OpenRewardsPanel:StopFirework()
    self.fireworkStopped = true
    if Runtime.CSValid(self.effect_fireWork) then
        self.effect_fireWork:SetActive(false)
    end
    App.audioManager:StopAudio(CONST.AUDIO.Interface_Celebrate)
end

return OpenRewardsPanel
