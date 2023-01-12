local Result = CS.UnityEngine.Purchasing.Result

local SubscriptionInfo = class()
function SubscriptionInfo:ctor(csInfo)
    self.csInfo = csInfo
end

function SubscriptionInfo:IsFreeTrial()
    if not self.csInfo then return false end
    return self.csInfo:isFreeTrial() == Result.True
end

function SubscriptionInfo:IsCancelled()
    if not self.csInfo then return false end
    return self.csInfo:isCancelled() == Result.True
end

function SubscriptionInfo:IsExpired()
    if not self.csInfo then return false end
    return self.csInfo:isExpired() == Result.True
end

function SubscriptionInfo:IsSubscribed()
    if not self.csInfo then return false end
    return self.csInfo:isSubscribed() == Result.True
end

return SubscriptionInfo