---@class FlyAnimation
local FlyAnimation = {}
function FlyAnimation.FlyItem(itemId, flyItem, onFinish, flyItemCallback, flyTime, targetShowEnterAnim, ease)
    flyTime = flyTime or 0.6
    local target = ItemId.GetWidget(itemId)
    if target then
        if targetShowEnterAnim then
            if target.inLayout then
                target:ShowEnterAnimInLayout()
            else
                target:ShowEnterAnim()
            end
            target:SetInteractable(false)
        end
        FlyAnimation.FlyObjectToObject(flyItem.gameObject, target:GetMainIconGameObject(), nil, flyTime, ease)
        local target2 = ItemId.GetWidget(itemId, HUD_ICON_ENUM.HEAD)
        Runtime.InvokeCbk(target2.Refresh, target2, true, flyTime)
        WaitExtension.SetTimeout(
            function()
                Runtime.InvokeCbk(flyItemCallback, flyItem.gameObject)
                local target1 = ItemId.GetWidget(itemId, HUD_ICON_ENUM.ITEM)
                Runtime.InvokeCbk(target1.OnHit, target1)
                Runtime.InvokeCbk(target1.Refresh, target1, true)

                Runtime.InvokeCbk(target2.OnHit, target2)

                local flyCbk = function()
                    if targetShowEnterAnim then
                        if target.inLayout then
                            target:ShowExitAnimInLayout(
                                function()
                                    target:SetInteractable(true)
                                end
                            )
                        else
                            target:ShowExitAnim(
                                nil,
                                function()
                                    target:SetInteractable(true)
                                end
                            )
                        end
                    end
                    if onFinish ~= nil then
                        WaitExtension.InvokeDelay(onFinish)
                    end
                end
                if not target.SetTimeout then
                    console.error("no settimeout", target)
                    WaitExtension.SetTimeout(flyCbk, 1)
                else
                    target:SetTimeout(nil, flyCbk, 1)
                end
            end,
            flyTime
        )
    else
        console.error("No Widget Found Of ID: ", itemId) --@DEL
        WaitExtension.InvokeDelay(onFinish)
    end
end

function FlyAnimation.FlyCostDiamond(sourceObject, destObject, onFinish, ease)
    FlyAnimation.FlyCostDiamondToPos(sourceObject, destObject:GetPosition(), onFinish, ease)
end

function FlyAnimation.FlyObjectToObject(flyObject, destObject, onFinish, time, ease, size)
    flyObject:SetParent(destObject, true)
    local startPos = flyObject:GetLocalPosition()
    local destPos = Vector3.zero
    local offsetX = startPos[0] * (-0.5)
    local controlPos = Vector3(startPos.x + offsetX, startPos.y, startPos.z)

    local wayPoints = Vector3List()
    local BezierCurve = require("System.Core.BezierCurve")
    for i = 1, 8 do
        local p = BezierCurve.SecondOrder(startPos, controlPos, destPos, i / 8)
        wayPoints:AddItem(p)
    end
    time = time or 0.6
    flyObject.transform:DOSizeDelta(size or Vector2(90, 90), time, true)

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
                    Runtime.InvokeCbk(onFinish)
                end
            )
        end
    )
end

function FlyAnimation.FlyObjectToObjectWithTrail(flyObject, destObject, trailIndex, onFinish, time, ease)
    flyObject:SetParent(destObject, true)
    flyObject:SetLocalScale(Vector3.one)
    local startPos = flyObject:GetLocalPosition()
    local destPos = Vector3.zero
    local offsetX = startPos[0] * (-0.5)
    local controlPos = Vector3(startPos.x + offsetX, startPos.y, startPos.z)

    local wayPoints = Vector3List()
    local BezierCurve = require("System.Core.BezierCurve")
    for i = 1, 8 do
        local p = BezierCurve.SecondOrder(startPos, controlPos, destPos, i / 8)
        wayPoints:AddItem(p)
    end
    time = time or 0.6
    -- flyObject.transform:DOSizeDelta(Vector2(90, 90), time, true)

    local trailGo = BResource.InstantiateFromAssetName(CONST.ASSETS.G_REWARD_TRAIL_ITEM)
    trailGo:SetParent(flyObject, false)
    -- trailGo:SetLocalPosition(Vector3.zero)
    trailGo.transform.localScale = Vector3.zero
    trailGo.transform.localEulerAngles = Vector3.zero
    local trialObj
    if trailIndex == 1 then
        trialObj = find_component(trailGo, "trail_jinbi")
    else
        trialObj = find_component(trailGo, "trail_tili")
    end
    trialObj:SetActive(true)
    if trialObj ~= nil then
        local trialRenderer = find_component(trialObj, "Trail", TrailRenderer)
        if trialRenderer ~= nil then
            local mainCamera = Camera.main
            local size = mainCamera.orthographicSize / CameraBaseSize
            trialRenderer.startWidth = trialRenderer.startWidth * size
            trialRenderer.endWidth = trialRenderer.endWidth * size
        end
    end

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
                    Runtime.InvokeCbk(onFinish)
                end
            )
        end
    )
end

return FlyAnimation
