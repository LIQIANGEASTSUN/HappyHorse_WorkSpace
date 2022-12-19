local function RunDemoScript()
    --if not isDone then
    --    GetPers("Configs.ScreenPlays.Dramas.Zone4.zone4_AskHelpFromVincent"):SetIdlePaused(true)
    --    isDone = true
    --end

    --App.mapGuideManager:StartSingleInSeries("Configs.ScreenPlays.Dramas.Zone4.zone4_AskHelpFromVincent"Configs.ScreenPlays.Dramas.Zone4.zone4_AskHelpFromVincent"Configs.ScreenPlays.Dramas.Zone4.zone4_AskHelpFromVincent")

    --XGE.EffectExtension.AddCircleWipeCircleWithPosition(1, Vector3(-5.2, 0, -3.4), Vector3(-6.1, 0, -1.4))
    --App:changeScene("Configs.ScreenPlays.Dramas.Zone4.zone4_AskHelpFromVincent")
    --RegionManager.Instance():UnlockRegion(1)

    -- AppServices.PaymentManager:StartPurchase("Configs.ScreenPlays.Dramas.Zone4.zone4_AskHelpFromVincent", function()
    --     print("Configs.ScreenPlays.Dramas.Zone4.zone4_AskHelpFromVincent")
    -- end, "Configs.ScreenPlays.Dramas.Zone4.zone4_AskHelpFromVincent", function()
    --     print("Configs.ScreenPlays.Dramas.Zone4.zone4_AskHelpFromVincent")
    -- end)
    --drama()
    --[[
    for i = 1, 14 do
        local info = AppServices.PaymentManager:GetSubscriptionInfo("Configs.ScreenPlays.Dramas.Zone4.zone4_AskHelpFromVincent"..i)
        print('info:IsSubscribed()', info:IsSubscribed())
        print('info:isFreeTrial()', info:IsFreeTrial())
        print('info:IsCancelled()', info:IsCancelled())
        print('info:IsExpired()', info:IsExpired())

    end

    --AppServices.FlyAnimation.FlyDiamond(App.scene.storyIconButton.gameObject, function() end, Ease.InSine)
    --]]
    --------------------------------------------------------------
    -- local name = "Configs.ScreenPlays.Dramas.Zone4.zone4_Grabthehidinghotelowner2"
    -- package.loaded[name] = nil
    -- local func = require(name)
    -- func()
end
return RunDemoScript