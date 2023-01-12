---@class FTPSDK
local FTPSDK = {
    delegate = CS.BetaGame.MainApplication.ftpDelegate,
    onPaySuccess = nil,
    onPayFail = nil,
    getProductItemsSuccess = nil,
    getProductItemsFail = nil,
    getSubsOrdersSuccess = nil,
    getSubsOrderFail = nil
}

--提前到开启游戏就初始化
function FTPSDK:Init()
    if not self.delegate then
        return
    end

    --self:InitSDK()
    local isDebug = not RuntimeContext.VERSION_DISTRIBUTE
    self.delegate:InitSDK("",isDebug)
    --验证结果回调
    self.delegate:Regiset_onOrderVerifyResult(
        function(PaymentResult)
            self:onOrderVerifyResult(PaymentResult,"Verify")
        end
    )

    --支付结果回调（跟上面的返回值一模一样，没必要分开注册的嘛）
    self.delegate:Regiset_onPaymentResult(
        function(PaymentResult)
            self:onOrderVerifyResult(PaymentResult,"Payment")
        end
    )

    --拉取商品回调
    self.delegate:Regiset_getProductsSucceededCallback(function (ProductList)
        Runtime.InvokeCbk(self.getProductItemsSuccess, ProductList)
        self.getProductItemsSuccess = nil
        self.getProductItemsFail = nil
    end)

    self.delegate:Regiset_getProductsFailed(function ()
        Runtime.InvokeCbk(self.getProductItemsFail)
        self.getProductItemsSuccess = nil
        self.getProductItemsFail = nil
    end)

    --拉取订阅回调
    self.delegate:Regiset_onGetSubsOrdersSuccess(function (SubsOrder)
        Runtime.InvokeCbk(self.getSubsOrdersSuccess, SubsOrder)
        self.getSubsOrdersSuccess = nil
        self.getSubsOrderFail = nil
    end)

    self.delegate:Regiset_onGetSubsOrdersFailed(function ()
        Runtime.InvokeCbk(self.getSubsOrderFail)
        self.getSubsOrdersSuccess = nil
        self.getSubsOrderFail = nil
    end)
end

function FTPSDK:UpdateUser(userID)
    self.delegate:updateUser(userID)
end

function FTPSDK:FinishProductItem(productId,finishPay)
    self.delegate:FinishProductItem(productId)
    if finishPay then
        AppServices.Connecting_Pay:ClosePanel()
    end
end

---支付消耗型商品
function FTPSDK:Pay(productId, cost, ext, onSuccess, onFail)
    self.onPaySuccess = onSuccess
    self.onPayFail = onFail
    self.delegate:Pay(productId, "1", cost, ext or "")
    --打开等待界面
    AppServices.Connecting_Pay:ShowPanel(1)
    self.timeOutDelayId = WaitExtension.SetTimeout(
        function()
            self:onOrderVerifyResult({status = -1})
        end,
        30
    )
end

function FTPSDK:ConverterStruct(PaymentResult)
    local result = {}
    result.id = PaymentResult.id
    result.orderID  = PaymentResult.orderID
    result.productID = PaymentResult.productID
    result.price= PaymentResult.price
    result.currency= PaymentResult.currency
    result.userID= PaymentResult.userID
    result.ext= PaymentResult.ext
    result.status= PaymentResult.status
    result.errorCode= PaymentResult.errorCode
    result.errorDesc= PaymentResult.errorDesc
    result.paymentType= PaymentResult.paymentType
    result.expiryTime = PaymentResult.expiryTime
    result.isTrialPeriod = PaymentResult.isTrialPeriod
    result.shipped = PaymentResult.shipped
    return result
end

function FTPSDK:ConverterSubsOrder(SubsOrder)
    local result = {}
    result.id = SubsOrder.id
    result.orderId  = SubsOrder.orderId
    result.appId = SubsOrder.appId
    result.productID = SubsOrder.productID
    result.packageName = SubsOrder.packageName
    result.env = SubsOrder.env
    result.isTrialPeriod = SubsOrder.isTrialPeriod
    result.paymentType = SubsOrder.paymentType
    result.expiryTime = SubsOrder.expiryTime
    return result
end
---验证结果回调 0订单验证成功，1支付成功，2订单支付失败，3订单验证失败.4支付服务器没有响应请求； 其他值为无法确认状态
function FTPSDK:onOrderVerifyResult(PaymentResult,source)
    if self.timeOutDelayId then
        WaitExtension.CancelTimeout(self.timeOutDelayId)
        self.timeOutDelayId = nil
    end
    local result = self:ConverterStruct(PaymentResult)
    console.lj("打点:"..table.tostring(result))--@DEL
    if PaymentResult.status == "1" then
        if self.onPaySuccess == nil then
            return
        end
        AppServices.Connecting_Pay:ShowPanel(2)
        self:LogBI_State(result)
        console.lj("订单支付成功"..source)--@DEL
        return
    end

    if source == "Payment" then
        return
    end

    local function Finish()
        AppServices.Connecting_Pay:ClosePanel()
        self.onPaySuccess = nil
        self.onPayFail = nil
    end

    if PaymentResult.status == "6" then
        console.lj("订单支付pending"..source)--@DEL
        Finish()
        ErrorHandler.ShowErrorPanel(Runtime.Translate("UI_pay_family_confirm"))
        self:LogBI_State(result)
        return
    end

    if PaymentResult.status == "0" then
        if self.onPaySuccess == nil then
            return
        end

        Runtime.InvokeCbk(self.onPaySuccess,result)
        self:LogBI(result)
        self:LogBI_State(result)
        --Finish()
        self.onPaySuccess = nil
        self.onPayFail = nil
        console.lj("订单验证成功"..source)--@DEL
        return
    end

    if PaymentResult.status == "2" then--@DEL
        console.lj("订单支付失败"..source)--@DEL
    elseif PaymentResult.status == "9" then--@DEL
        console.lj("安卓订单支付取消"..source)--@DEL
    elseif PaymentResult.status == "3" then--@DEL
        console.lj("订单验证失败"..source)--@DEL
    elseif PaymentResult.status == "4" then--@DEL
        console.lj("支付服务器没有响应请求"..source)--@DEL
    elseif PaymentResult.status == "6" then--@DEL
        console.lj("订单支付pending"..source)--@DEL
    else--@DEL
        console.lj("无法确认的错误"..source)--@DEL
    end--@DEL

    if self.onPayFail ~= nil then
        Runtime.InvokeCbk(self.onPayFail,PaymentResult.errorCode)
        self:LogBI_State(result)
    end
    Finish()
end

function FTPSDK:GetProductItemsInfo(inappItemIds,subsItemIds,onSuccess,onFail)
    self.getProductItemsSuccess = onSuccess
    self.getProductItemsFail = onFail
    self.delegate:GetProductItemsInfo(inappItemIds,subsItemIds)
end

function FTPSDK:GetSubsOrders(onSuccess,onFail)
    self.getSubsOrdersSuccess = onSuccess
    self.getSubsOrderFail = onFail
    self.delegate:GetSubsOrders()
end

--补单流程有点绕，以后优化
function FTPSDK:InitReissuePurchase(callback)
    self.reissuePurchaseCB = function (paymentResultList)
        Runtime.InvokeCbk(callback,paymentResultList)
    end
end

local isRegistReissue = false
function FTPSDK:ReissuePurchase()
    if not isRegistReissue then
        self.delegate:Regiset_onReissueVerifyResult(function (paymentResultList)
            Runtime.InvokeCbk(self.reissuePurchaseCB,paymentResultList)
        end)
        isRegistReissue = true
    end
    self.delegate:ReissuePurchase()
end

function FTPSDK:LogBI(paymentResult)
    local function GetChannel()
        local channel
        if RuntimeContext.UNITY_ANDROID then
            channel = "android"
        elseif RuntimeContext.UNITY_IOS then
            channel = "ios"
        else
            channel = "editor"
        end
        return channel
    end
    console.lj("打点:"..table.tostring(paymentResult))--@DEL
    local info = {}
    info.productId = paymentResult.productID
    local config = AppServices.ProductManager:GetProductMeta(info.productId)
    if config and config.proType == 1 then
        --订阅不打点
       return
   end
    local usDollarPrice = tonumber(config.price)
    info.usCentPrice = math.floor(usDollarPrice * 100 + 0.0001) -- 防止1999.0在floor之后变成1998
    info.name = config.name
   -- info.storeSpecificId = order.storeSpecificId
    info.priceLocal = paymentResult.price
    info.currencyCode = paymentResult.currency
    info.channel = GetChannel()
    info.isTest = paymentResult.paymentType == "0"
    info.isTrial = paymentResult.isTrialPeriod == "1"
    info.isScalp = false
    local params = {
        source = paymentResult.ext,
        orderId = paymentResult.orderID,
        --playLevelId = AppServices.User:GetCurrentLevelId(),
        --playNumber = order.playNumber,
        --diamondacquire = order.diamondacquire or self:GetPayoutDiamond(order.productId),
        productId = paymentResult.productID,
    }
    info.params = params
    DcDelegates:LogPayment(info)
    console.lj("打点:"..table.tostring(info))--@DEL
    console.lj("打点:"..table.tostring(params))--@DEL
end
function FTPSDK:LogBI_State(paymentResult)
    local function GetChannel()
        local channel
        if RuntimeContext.UNITY_ANDROID then
            channel = "android"
        elseif RuntimeContext.UNITY_IOS then
            channel = "ios"
        else
            channel = "editor"
        end
        return channel
    end
    console.lj("打点:"..table.tostring(paymentResult))--@DEL
    local info = {}
    info.productId = paymentResult.productID
    local config = AppServices.ProductManager:GetProductMeta(info.productId)
    if config and config.proType == 1 then
        --订阅不打点
       return
   end
    local usDollarPrice = tonumber(config.price)
    info.usCentPrice = math.floor(usDollarPrice * 100 + 0.0001) -- 防止1999.0在floor之后变成1998
    info.name = config.name
    info.priceLocal = paymentResult.price
    info.currencyCode = paymentResult.currency
    info.channel = GetChannel()
    info.isTest = paymentResult.paymentType == "0"
    info.source = paymentResult.ext
    info.orderId = paymentResult.orderID
    info.status = paymentResult.status
    DcDelegates:Log(SDK_EVENT.recharge_process,info)
end
FTPSDK:Init()
return FTPSDK
