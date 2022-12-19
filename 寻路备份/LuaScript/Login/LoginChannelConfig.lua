local LoginChannelConfig = {}

function LoginChannelConfig.GetFBChannelMap()
    local map = {"visitor", "fb"}

    if RuntimeContext.UNITY_IOS then
        local function CheckSystemVersion(target)
            --只检查第一位 "IOS 13.0.0"
            for w in string.gmatch(BCore.SystemVersion(), "%d+") do
                if tonumber(w) >= target then
                    return true
                end
            end
            return false
        end

        if CheckSystemVersion(13) then
            table.insert(map, "ios")
            --加载苹果SDK
            local mapp = CS.BetaGame.MainApplication
            App.iosSdk = mapp.s_goEngineRoot:AddComponent(typeof(CS.UnityEngine.SignInWithApple.SignInWithApplePlugin))
        end
    end
    if RuntimeContext.VERSION_DEVELOPMENT and RuntimeContext.FEATURES_USER_DEFINED_ACCOUNT then
        table.insert(map, "visitor_test")
    end
    return map
end

return LoginChannelConfig
