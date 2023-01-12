local ProductManager = require("System.Buy.ProductManager")
---@class ProductManager_Win 电脑端支付
local ProductManager_Win = class(ProductManager,"ProductManager_Win")

--overview RequestProductPrice
function ProductManager_Win:RequestProductPrice()
    for productId, value in pairs(self.metaMap) do
        self.priceData[productId] = {
            --本地配置价格(美元）
            localPrice = value.price,
            localCentPrice = math.floor(value.price * 100 + 0.0001),
            areaPrice = value.price,
            currencySymbol = "T$",
            --显示价格，经过汇率和货币转换
            currencyPrice = "T$" .. tostring(value.price)
        }
    end

    self.fetchState = ProductFetchState.Success
    self:FetchFinish(true)
end

--overview UpdateUser

--overview ReissuePurchase 电脑端不存在补单
function ProductManager_Win:RequestReissuePurchase()
    self:ReissueFinish()
end

--支付
--消耗品与订阅的逻辑不一致，分开处理
function ProductManager_Win:StartPay(productId, ext, _onFail, _onSuccess,isJson)
    if not self.priceData[productId] then
        console.lj("没有找到商品，检查配置" .. productId) --@DEL
        return
    end

    if self.metaMap[productId].proType == 1 then
        self:StartPay_SubsOrder(productId, ext, _onFail, _onSuccess,isJson)
    else
        self:StartPay_Consumable(productId, ext, _onFail, _onSuccess,isJson)
    end
end

--购买消耗品
function ProductManager_Win:StartPay_Consumable(productId, ext, _onFail, _onSuccess,isJson)
    if isJson == nil then
        isJson = false
    end
    local orderInfo = {productID = productId,ext = table.serialize(ext),isTest = true ,extJson = isJson}
    orderInfo = table.serialize(orderInfo)
    local function onNetFail(errorCode)
        Runtime.InvokeCbk(_onFail, errorCode)
    end

    local function onNetSuc()
        AppServices.User:MarkLastRechargeTime()
        Util.LogPayLevel()
        Runtime.InvokeCbk(_onSuccess,{productId = productId,ext = ext})
    end

    Net.Rechargemodulemsg_3001_Recharge_Request({orderInfo = orderInfo},onNetFail,onNetSuc)
end

function ProductManager_Win:GetSubsOrder()
    if not self.subsOrderInfos then
        self.subsOrderInfos = AppServices.User.SubscribeData:GetData() or {}
    end
    return self.subsOrderInfos
end

function ProductManager_Win:GetValidSubsOrderProduct(productId)
    local orders = self:GetSubsOrder()
    return orders[productId]
end
--购买订阅
function ProductManager_Win:StartPay_SubsOrder(productId, ext, _onFail, _onSuccess)
    local testTime = 10*60
    local testFree = false

    if self:GetValidSubsOrderProduct(productId) then
        console.lj("订阅中的商品不应该再买一次"..productId)
        return
    end

    local orderInfo = {}
    orderInfo.productId = productId
    orderInfo.isTest = true
    orderInfo.expired = TimeUtil.ServerTime() + testTime
    orderInfo.isTrialPeriod = testFree

    local function onNetFail(errorCode)
        Runtime.InvokeCbk(_onFail, errorCode)
    end

    local function onNetSuc()
        AppServices.User:MarkLastRechargeTime()
        AppServices.User.SubscribeData:SetKeyValue(productId,orderInfo)
        self.subsOrderInfos[productId] = orderInfo
        Runtime.InvokeCbk(_onSuccess)
    end

    Net.Rechargemodulemsg_3001_Recharge_Request({orderInfo = table.serialize(orderInfo)},onNetFail,onNetSuc)
end

--unity端为测试数据，存本地
function ProductManager_Win:RequestSubsOrders()
    local function onNetSuc(respones)
        local count = table.maxn(respones.expiredSubscribes)
        if count > 0 then
            for i = 1,count do
                table.insert(self.expiredList,respones.expiredSubscribes[i])
            end
        end

        if #self.expiredList > 0 then
            self:RemoveSubscribe()
            self.pause = true
        end

        --开始监听（可以先挂日更，小于一日了秒更）
        self:CheckAllSubscribeExpired()
    end

    local function onNetFail(errorCode)
        -- body
    end

    --获取当前有效的订阅
    self.subsOrderInfos = AppServices.User.SubscribeData:GetData()
    --同步服务器，获取已经过期的订阅
    local data = AppServices.User.SubscribeData:GetServerData()
    Net.Rechargemodulemsg_3002_SubscribeInfo_Request({subscribes = data},onNetFail,onNetSuc)
end

--检查订单过期
function ProductManager_Win:CheckAllSubscribeExpired()
    if table.count(self.subsOrderInfos) == 0 then
        return
    end

    self.pause = false
    if self.expiredTimer then
        return
    end

    self.expiredTimer = WaitExtension.InvokeRepeating(function ()
        if self.pause then
            --正在执行删除操作
            return
        end

        if table.count(self.subsOrderInfos) == 0 then
            WaitExtension.CancelTimeout(self.expiredTimer)
            self.expiredTimer = nil
            return
        end

        for key, subscribe in pairs(self.subsOrderInfos) do
            if subscribe.expired <= TimeUtil.ServerTime() then
                table.insert(self.expiredList, subscribe.productId)
            end
        end
        if #self.expiredList > 0 then
            self:RemoveSubscribe()
            self.pause = true
        end
    end, 0, 1)
end

--移除过期订单，并同步服务器
function ProductManager_Win:RemoveSubscribe()
    while #self.expiredList > 0 do
        MessageDispatcher:SendMessage("RemoveSubscribe_"..self.expiredList[1])
        Net.Rechargemodulemsg_3003_SubscribeExpired_Request({productId = self.expiredList[1]})
        table.remove(self.expiredList, 1)
    end
end

return ProductManager_Win
