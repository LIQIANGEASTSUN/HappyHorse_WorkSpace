---@class FastFlyRewards:LuaUiBase @快速飞行的奖励显示
local FastFlyRewards = class(LuaUiBase)

local assets = {
	"Prefab/UI/Common/FastFlyRewards.prefab",
    "Prefab/UI/Common/Buildin/RewardItem/RewardItemScaleCurve.asset"
}

function FastFlyRewards:ctor()
	---@type RewardItem[]
    self.flyItems = {}
end

function FastFlyRewards:InitGameObject(rewards, flyCallback, finishCallback)
	local gameObject = BResource.InstantiateFromAssetName(assets[1])
    self.finishCallback = finishCallback
    self.flyCallback = flyCallback
	self:setGameObject(gameObject)
	self.transform:SetParent(App.scene.panelLayer.transform, false)
	self.container_items = find_component(self.gameObject, 'go_ItemContaniner', RewardContainer)
	self:InitRewards(rewards)
end


function FastFlyRewards.Create(rewards, flyCallback, finishCallback)
	local function onLoaded()
		local ins = FastFlyRewards.new()
		ins:InitGameObject(rewards, flyCallback, finishCallback)
	end
	App.uiAssetsManager:LoadAssets(assets, onLoaded)
end

local RewardItem = require("UI.Components.RewardItem")
function FastFlyRewards:InitRewards(rewards)
    self.rewards = rewards
    self:SortRewards(rewards)
    for _, v in ipairs(rewards) do
        local reward = RewardItem.new()
        local item = BResource.InstantiateFromAssetName(CONST.ASSETS.G_REWARD_ITEM)
        reward:InitWithGameObject(item)
        reward:Generate(v)
        reward.transform.localScale = Vector3.zero
        self.container_items:AddItem(item)
        table.insert(self.flyItems, reward)
    end
    self.container_items.transform.anchoredPosition = Vector2(0, 0)
	self:ShowRewards()
end

function FastFlyRewards:SortRewards(rewards)
    local priorityCfg = AppServices.Meta:GetRewardAnimPriority()
    table.sort(
        rewards,
        function(a, b)
            local priority_a = priorityCfg[a.ItemId] or 999
            local priority_b = priorityCfg[b.ItemId] or 999
            return priority_a < priority_b
        end
    )
end

function FastFlyRewards:ShowRewards()
    local scaleTime = 0.3
    local flyDelay = 0.5
	local time = 0.3
    local function waitFinished()
        for _, value in ipairs(self.flyItems) do
            value.img_glow.gameObject:SetActive(false)
            value.transform:DOScale(1, time):SetEase(Ease.Linear)
        end
        self:FlyRewards()
    end

    local ease = self.curveAsset and self.curveAsset.curve or Ease.Linear
    for _, value in ipairs(self.flyItems) do
        value.transform:DOScale(1, scaleTime):SetEase(ease)
    end

    WaitExtension.SetTimeout(waitFinished, scaleTime + flyDelay)
end


function FastFlyRewards:FlyRewards()
    if self.flyCallback then
        Runtime.InvokeCbk(self.flyCallback)
        self.flyCallback = nil
    end
    local total = #self.rewards or 0
    if total == 0 then
        self:FlyOver()
        return
    end

    local counter = 0

    local function onFinish()
        counter = counter + 1
        if counter == total then
            self:FlyOver()
        end
    end

    -- local function flyItemCallback(flyObject)

    -- end

	local flyTime = 0.8
    for k, v in ipairs(self.rewards) do
		local itemId = v.ItemId
        local flyItem = self.flyItems[k]
        flyItem.transform:DOScale(0.45, flyTime)
        if flyItem.trail_jinbi and (itemId == ItemId.COIN or itemId == ItemId.EXP) then
            flyItem.trail_jinbi:SetActive(true)
        elseif flyItem.trail_tili and (itemId == ItemId.ENERGY or itemId == ItemId.DIAMOND) then
            flyItem.trail_tili:SetActive(true)
        end
		local target = ItemId.GetWidget(itemId)
		if target then
			AppServices.FlyAnimation.FlyObjectToObject(
				flyItem.gameObject,
				target:GetMainIconGameObject(),
				function()
					if target.Refresh then
						target:Refresh()
					else
						console.terror(target.gameObject, "No Refresh")
					end
					Runtime.InvokeCbk(onFinish)
				end,
				flyTime
			)
		else
			console.error("No Widget Found Of ID: ", itemId) --@DEL
			WaitExtension.InvokeDelay(onFinish)
		end
    end
end

function FastFlyRewards:FlyOver()
	if self.finishCallback then
		Runtime.InvokeCbk(self.finishCallback)
	end
	self:Dispose()
end

return FastFlyRewards