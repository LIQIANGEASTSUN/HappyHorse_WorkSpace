--------------------Job_InitPurchase
local Job_InitPurchase = {}

function Job_InitPurchase:Init(priority)
    self.name = priority
end

function Job_InitPurchase:CheckPop()
    --检查补单
    if not RuntimeContext.UNITY_ANDROID and not RuntimeContext.UNITY_IOS then
        return  false
    end
    return true
end

--商城初始化与拉取补单强制执行，不然后面的逻辑和数据都会变得混乱
function Job_InitPurchase:Do(finishCallback)
    AppServices.ProductManager:CheckFetchAll(function (result)
        if not result then
            Runtime.InvokeCbk(finishCallback)
            return
        end

        AppServices.ProductManager:ReissuePurchase(finishCallback)
    end)
end

return Job_InitPurchase