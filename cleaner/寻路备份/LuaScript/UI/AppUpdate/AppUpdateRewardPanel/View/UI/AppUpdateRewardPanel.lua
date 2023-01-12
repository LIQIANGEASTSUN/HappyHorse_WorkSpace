--insertWidgetsBegin
--	text_title	img_line1	btn_receive
--insertWidgetsEnd

--insertRequire
local _AppUpdateRewardPanelBase = require "UI.AppUpdate.AppUpdateRewardPanel.View.UI.Base._AppUpdateRewardPanelBase"

local AppUpdateRewardPanel = class(_AppUpdateRewardPanelBase)

function AppUpdateRewardPanel:ctor()
end

function AppUpdateRewardPanel:onAfterBindView()
    self.text_title.text = Runtime.Translate("update_getPrize_title")
    self.text_content.text = Runtime.Translate("update_getPrize_des")
    self.text_award_desc.text = Runtime.Translate("update_getPrize_prize_des")
    local btnText = self.btn_receive.gameObject.transform:GetComponentInChildren(typeof(Text))
    btnText.text = Runtime.Translate("update_getPrize_button")
    -- self.propIcon = self.gameObject.transform:Find("Scroll View/Viewport/Content/prop/img_icon").gameObject:GetComponent(typeof(Image))
    -- self.flyItems[CONST.MAINUI.ICONS.CoinIcon] = arr
    -- AppServices.FlyAnimation.FlyRewards(self.flyItems)
end

function AppUpdateRewardPanel:refreshUI()
end

function AppUpdateRewardPanel:SetRewards(rewardsData)
    self.rewardsData = rewardsData
    if not rewardsData then
        return
    end
    self.rewardItems = {}
    -- self.rewardTexts = {}
    local container = self.gameObject.transform:Find("prop_container")
    local itemTemplate = container.transform:Find("prop")
    for i = 1, #rewardsData do
        local item
        if i == 1 then
            item = itemTemplate
        else
            item = GameObject.Instantiate(itemTemplate, container.transform)
        end
        local icon = item:FindComponentInChildren("img_icon", typeof(Image))
        local countText = item:FindComponentInChildren("text_prop_count", typeof(Text))
        icon.sprite = AppServices.ItemIcons:GetSprite(rewardsData[i].itemId)

        table.insert(self.rewardItems, icon)
        -- table.insert(self.rewardTexts, countText)
        countText.text = "x" .. rewardsData[i].count
    end
end

-- function AppUpdateRewardPanel:FlyRewards(flyBuilding, onFinish)
    -- local sourceObject = self.propIcon.gameObject
    -- local function flyItemCallback()
    -- end

    -- self.flyEndFalg = false
    -- -- local count = 0
    -- local function oneFlyFinish()
    --     if not self.flyEndFalg then
    --         --AppServices.UserCoinLogic:RefreshCoinNumber()
    --         Runtime.InvokeCbk(onFinish)
    --         self.flyEndFalg = true
    --     end
    -- end

    -- local function flyByData(data, sourceObject)
    --     if ItemId.IsCoin(data.itemId) then
    --         --console.assert(false, "还在用金币")
    --         AppServices.UserCoinLogic.coinItem:ShowEnterAnim()
    --         -- AppServices.FlyAnimation.FlyCoin(sourceObject, oneFlyFinish, flyItemCallback)
    --         AppServices.FlyAnimation.FlyItem(data.itemId, sourceObject, oneFlyFinish, flyItemCallback)
    --     elseif ItemId.IsDiamond(data.itemId) then
    --         AppServices.DiamondLogic:GetView():ShowEnterAnim()
    --         local function flyFinishedCallback()
    --             --钻石UI上的add动画
    --             AppServices.DiamondLogic:RefreshDiamondNumber(oneFlyFinish)
    --             oneFlyFinish()
    --         end
    --         -- AppServices.FlyAnimation.FlyDiamond(sourceObject, flyFinishedCallback, flyItemCallback)
    --         AppServices.FlyAnimation.FlyItem(data.itemId, sourceObject, flyFinishedCallback, flyItemCallback)
    --     elseif ItemId.IsMatchGameProp(data.itemId) then
    --         sourceObject.gameObject:SetActive(false)
    --     end
    -- end

    -- Runtime.InvokeCbk(onFinish)
    -- if self.rewardTexts then
    --     for _,v in ipairs(self.rewardTexts) do
    --         v.gameObject:SetActive(false)
    --     end
    -- end
-- end

function AppUpdateRewardPanel:IndependentFlyRewards()
    local flyRewards = {}
    for index, value in ipairs(self.rewardsData) do
        table.insert(flyRewards, {ItemId = value.itemId, Amount = value.count})
    end
    local count = #self.rewardsData

    for index = 1, count do
        flyRewards[index].position = self.rewardItems[index].transform.position
    end
    local time = 0.5
    AppServices.RewardAnimation.FlyReward(flyRewards, nil, 0, 0, time, true, 1, Ease.InCirc)
end

return AppUpdateRewardPanel
