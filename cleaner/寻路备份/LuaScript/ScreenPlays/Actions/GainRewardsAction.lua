local RewardItem = require("UI.Components.RewardItem")
local BezierCurve = require("System.Core.BezierCurve")

---@class GainRewardsAction:BaseFrameAction
local GainRewardsAction = class(BaseFrameAction, "GainRewardsAction")
function GainRewardsAction:Create(args, finishCallback)
    local instance = GainRewardsAction.new(args, finishCallback)
    return instance
end

function GainRewardsAction:ctor(args, finishCallback)
    self.args = args
    self.finishCallback = finishCallback
end

function GainRewardsAction:Awake()
    local position = self.args.position
    local itemId = self.args.itemId
    local amount = self.args.amount
    local duration = self.args.duration or 1.5

    -- 资源
    local rewardPrefab = G_REWARD_ITEM
    local blueTail = G_ITEM_FLY_TAIL_BLUE
    local goldTail = G_ITEM_FLY_TAIL_GOLD

    local function OnLoadFinish()
        local args = {
            title = Runtime.Translate("ui.gain_reward_title"),
            desc = Runtime.Translate("ui.gain_reward_des"),
            duration = duration,
            opacity = 0.3,
            RewardItems = {}
        }
        local rewards = {}

        args.Callback = function()
            App.scene:HideAllIcons()
            self.isFinished = true
        end

        if ItemId.IsGift(itemId) then
            local giftMeta = AppServices.Meta:GetItemMeta(itemId)
            -- 礼包
            for i, v in ipairs(giftMeta.funcValue) do
                local id = tostring(v[1])
                local count = v[2]
                AppServices.User:AddItem(id, count, "GainRewardsAction")
                DcDelegates.Legacy:LogAcquisition({itemId = id, num = count}, DcAcquisitionSource.Drama)

                local itemData = {
                    ItemId = id,
                    Amount = count
                }
                table.insert(args.RewardItems, itemData)
                local reward = self:CreateReward(rewardPrefab, position, id)
                table.insert(rewards, reward)
            end
        else
            AppServices.User:AddItem(itemId, amount, "GainRewardsAction")
            DcDelegates.Legacy:LogAcquisition({itemId = itemId, num = amount}, DcAcquisitionSource.Drama)
            local itemData = {
                ItemId = itemId,
                Amount = amount
            }
            table.insert(args.RewardItems, itemData)
            local reward = self:CreateReward(rewardPrefab, position, itemId)
            table.insert(rewards, reward)
        end

        self:FlyRewards(rewards, args)
    end

    AssetLoaderUtil.LoadAssets({rewardPrefab, blueTail, goldTail}, OnLoadFinish)
end

function GainRewardsAction:CreateReward(assetPath, position, itemId, delay)
    local rewardGo = BResource.InstantiateFromAssetName(assetPath)
    rewardGo:SetParent(App.scene.canvas, false)
    rewardGo:SetLocalScale(Vector3.zero)
    rewardGo:SetPosition(position)

    local reward = RewardItem.new()
    reward:InitWithGameObject(rewardGo)
    reward:Generate({ItemId = itemId})
    reward:HideText()
    return reward
end

function GainRewardsAction:FlyObject(flyObject, onFinish, delay)
    delay = delay or 0
    GameUtil.DoScale(flyObject.transform, Vector3.one, 1.5)

    local startPos = flyObject:GetLocalPosition()
    -- console.terror(flyObject, startPos:ToString())
    local x = 0.8 + delay * 5
    local y = 0.8 + delay * 5
    if startPos.x > 0 then
        x = -x
    end
    if startPos.y > 0 then
        y = -y
    end
    x = x * math.abs(startPos.x * 0.2)
    y = y * math.abs(startPos.y * 0.5)

    local destPos = Vector3.zero
    local controlPos = Vector3(startPos.x + x, startPos.y + y, startPos.z)

    local wayPoints = Vector3List()
    for i = 1, 8 do
        local p = BezierCurve.SecondOrder(startPos, controlPos, destPos, i / 8)
        wayPoints:AddItem(p)
    end
    flyObject.transform:DOSizeDelta(Vector2(90, 90), 0.75, true)

    BPath.DoLocalPath(
        flyObject.transform,
        wayPoints,
        1.5,
        Ease.InOutSine,
        function()
            Runtime.InvokeCbk(onFinish)
            if Runtime.CSNull(flyObject.gameObject) then
                return
            end
            local fadeCallback = function()
                Runtime.CSDestroy(flyObject.gameObject)
                flyObject = nil
            end
            local tween = GameUtil.DoFade(flyObject, 0, 7 / 30)
            tween:OnComplete(fadeCallback)
            local tail = flyObject:FindComponentInChildren("tail/E_Diamond3_2_trail", typeof(TrailRenderer))
            if Runtime.CSValid(tail) then
                GameUtil.DoFade(tail, 0, 7 / 30)
            end
        end
    )
end
function GainRewardsAction:FlyRewards(rewards, arguments)
    local count = 0
    local function onFlyFinished()
        count = count - 1
        if count == 0 then
            sendNotification(CONST.GLOBAL_NOFITY.Open_Panel, GlobalPanelEnum.OpenRewardsPanel, arguments)
        end
    end
    local delay = 0

    for i = 1, #rewards do
        count = count + 1
        local reward = rewards[i]
        local data = arguments.RewardItems[i]

        if ItemId.IsDiamond(data.ItemId) then
            local tail = BResource.InstantiateFromAssetName(CONST.ASSETS.G_ITEM_FLY_TAIL_BLUE)
            tail.name = "tail"
            tail:SetParent(reward.gameObject, false)
            tail:SetLocalPosition(Vector3.zero)
        else
            local tail = BResource.InstantiateFromAssetName(CONST.ASSETS.G_ITEM_FLY_TAIL_GOLD)
            tail.name = "tail"
            tail:SetParent(reward.gameObject, false)
            tail:SetLocalPosition(Vector3.zero)
        end

        self:FlyObject(reward.gameObject, onFlyFinished, delay)
        delay = delay + 0.2
    end
end

function GainRewardsAction:Update()
    if not self.started then
        self.started = true
        self:Awake()
    end
end

function GainRewardsAction:Reset()
    self.started = false
    self.isFinished = false
end

return GainRewardsAction
