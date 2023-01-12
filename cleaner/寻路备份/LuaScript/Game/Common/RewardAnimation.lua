local coinTrailItems = {
    ItemId.COIN,
    ItemId.EXP
}

local energyTrailItems = {
    ItemId.ENERGY,
    ItemId.DIAMOND
}

local Trail3Items = {
    ItemId.ParkourScore,
}

local RewardItem = require("UI.Components.RewardItem")
---@class RewardAnimation
local RewardAnimation = {}

function RewardAnimation.Animation1(rewards, position, index, flyTime, targetShowEnterAnim, ease, offset, offset2)
    local rewardData = rewards[index]
    local reward = RewardItem.new()
    local item = BResource.InstantiateFromAssetName(CONST.ASSETS.G_REWARD_ITEM_BIG_TEXT)
    local scene = App:getRunningLuaScene()
    if scene then
        item:SetParent(scene.canvas, false)
    end
    if rewardData.position then
        item.transform.position = rewardData.position
    else
        item.transform.position = position
    end
    item.transform.localScale = Vector3.zero
    item.transform.localEulerAngles = Vector3.zero
    item.transform:DOScale(0.45, 0.1)
    reward:InitWithGameObject(item)
    reward:Generate(rewardData)

    local delay = rewardData.delay or 0
    local CallFly = function()
        local trialObj = nil
        if reward.trail_jinbi and table.exists(coinTrailItems, rewardData.ItemId) then
            trialObj = reward.trail_jinbi
            reward.trail_jinbi:SetActive(true)
        elseif reward.trail_tili and table.exists(energyTrailItems, rewardData.ItemId) then
            trialObj = reward.trail_tili
            reward.trail_tili:SetActive(true)
        elseif reward.trail_3 and table.exists(Trail3Items, rewardData.ItemId) then
            trialObj = reward.trail_3
            reward.trail_3:SetActive(true)
        end

        if trialObj ~= nil then
            local trialRenderer = find_component(trialObj, "Trail", TrailRenderer)
            if trialRenderer ~= nil then
                local mainCamera = Camera.main
                local size = mainCamera.orthographicSize / CameraBaseSize
                trialRenderer.startWidth = trialRenderer.startWidth * size
                trialRenderer.endWidth = trialRenderer.endWidth * size
            end
        end
        RewardAnimation.FlyItem(rewardData.ItemId, reward, nil, nil, flyTime, targetShowEnterAnim, ease, offset, offset2)
    end
    if delay <= 0 then
        CallFly()
    else
        WaitExtension.SetTimeout(
            CallFly,
            delay
        )
    end
end

function RewardAnimation.Animation2(rewards, position, index, flyTime, targetShowEnterAnim, ease, offset, offset2)
    local rewardData = rewards[index]
    local reward = RewardItem.new()
    local item = BResource.InstantiateFromAssetName(CONST.ASSETS.G_REWARD_ITEM_BIG_TEXT)
    local scene = App:getRunningLuaScene()
    if scene then
        item:SetParent(scene.canvas, false)
    end
    item.transform.localEulerAngles = Vector3.zero
    reward:InitWithGameObject(item)
    reward:Generate(rewardData)
    local scaleTime = 0.1
    item.transform:DOScale(1.2, scaleTime)

    WaitExtension.SetTimeout(
        function()
            if reward.trail_jinbi and (rewardData.ItemId == ItemId.COIN or rewardData.ItemId == ItemId.EXP) then
                reward.trail_jinbi:SetActive(true)
            elseif reward.trail_tili and (rewardData.ItemId == ItemId.ENERGY or rewardData.ItemId == ItemId.DIAMOND) then
                reward.trail_tili:SetActive(true)
            end
            RewardAnimation.FlyItem(rewardData.ItemId, reward, nil, nil, flyTime, targetShowEnterAnim, ease, offset, offset2)
        end,
        scaleTime
    )
end

local function DelayFlyReward(rewards, position, index, interval, flyTime, targetShowEnterAnim, ease, animationIndex, offset, offset2)
    animationIndex = animationIndex or 1
    Runtime.InvokeCbk(rewards[index].beforeFly, index)
    RewardAnimation["Animation" .. animationIndex](rewards, position, index, flyTime, targetShowEnterAnim, ease, offset, offset2)
    index = index + 1
    if index <= #rewards then
        WaitExtension.SetTimeout(
            function()
                DelayFlyReward(rewards, position, index, interval, flyTime, targetShowEnterAnim, ease, animationIndex, offset, offset2)
            end,
            interval
        )
    end
end

function RewardAnimation.FlyReward(
    rewards,
    position,
    delay,
    interval,
    flyTime,
    targetShowEnterAnim,
    animationIndex,
    ease,
    offset,
    offset2)
    if delay > 0 then
        WaitExtension.SetTimeout(
            function()
                DelayFlyReward(rewards, position, 1, interval, flyTime, targetShowEnterAnim, ease, animationIndex, offset, offset2)
            end,
            delay
        )
    else
        DelayFlyReward(rewards, position, 1, interval, flyTime, targetShowEnterAnim, ease, animationIndex, offset, offset2)
    end
end

function RewardAnimation.FlyItem(itemId, flyItem, onFinish, flyItemCallback, flyTime, targetShowEnterAnim, ease, offset, offset2)
    flyTime = flyTime or 0.6
    local target = flyItem.target or ItemId.GetWidget(itemId)
    --找不到的时候用背包
    if not target then
        target = App.scene:GetWidget(CONST.MAINUI.ICONS.BagButton)
    end
    if target then
        if targetShowEnterAnim then
            target:ShowEnterAnim()
            target:SetInteractable(false)
        end
        RewardAnimation.FlyObjectToObject(
            flyItem.gameObject,
            target:GetMainIconGameObject(),
            function()
                Runtime.InvokeCbk(flyItemCallback, flyItem.gameObject)
                --if targetShowEnterAnim then
                    local cur = target.GetValue and target:GetValue() or 0
                    Runtime.InvokeCbk(target.OnHit, target)
                if flyItem.itemInfo ~= nil then
                    Runtime.InvokeCbk(target.SetValue, target, cur + flyItem.itemInfo.Amount)
                    Runtime.InvokeCbk(flyItem.itemInfo.flycallback)
                end
        --end
                Runtime.InvokeCbk(target.Refresh, target)
                local flyCbk = function()
                    if targetShowEnterAnim then
                        target:ShowExitAnim(
                            nil,
                            function()
                                target:SetInteractable(true)
                            end
                        )
                    end
                    if onFinish ~= nil then
                        WaitExtension.InvokeDelay(onFinish)
                    end
                end
                if targetShowEnterAnim or onFinish ~= nil then
                    if not target.SetTimeout then
                        -- console.error("no settimeout", target)
                        WaitExtension.SetTimeout(flyCbk, 1)
                    else
                        target:SetTimeout(nil, flyCbk, 1)
                    end
                end
            end,
            flyTime,
            ease,
            offset,
            offset2
        )
    else
        console.error("No Widget Found Of ID: ", itemId) --@DEL
        if onFinish ~= nil then
            WaitExtension.InvokeDelay(onFinish)
        end
    end
end

function RewardAnimation.FlyObjectToObject(flyObject, destObject, onFinish, time, ease, offset, offset2)
    flyObject:SetParent(App.scene.FlyObjCanvasObj, true)

    local startPos = flyObject:GetLocalPosition()
    offset = offset or Vector3(0, -100, 0)
    offset2 = offset2 or Vector3(0, 0, 0)
    local parent = destObject.transform.parent
    destObject:SetParent(App.scene.FlyObjCanvasObj, true)
    local destPos = destObject:GetLocalPosition() + offset --Vector3.zero
    destObject:SetParent(parent, true)

    local controlPos = Vector3(destPos.x, startPos.y, startPos.z) + offset2

    local wayPoints = Vector3List()
    local BezierCurve = require("System.Core.BezierCurve")
    for i = 1, 8 do
        local p = BezierCurve.SecondOrder(startPos, controlPos, destPos, i / 8)
        wayPoints:AddItem(p)
    end
    time = time or 0.6
    flyObject.transform:DOSizeDelta(Vector2(90, 90), time, true)

    BPath.DoLocalPath(
        flyObject.transform,
        wayPoints,
        time,
        ease or Ease.InOutSine,
        function()
            if Runtime.CSNull(flyObject.gameObject) then
                return Runtime.InvokeCbk(onFinish)
            end
            local tween = GameUtil.DoFade(flyObject, 0, 7 / 30)
            tween:OnComplete(
                function()
                    Runtime.CSDestroy(flyObject.gameObject)
                    flyObject = nil
                    --Runtime.CSDestroy(ptc)
                    Runtime.InvokeCbk(onFinish)
                end
            )
        end
    )
end

return RewardAnimation
