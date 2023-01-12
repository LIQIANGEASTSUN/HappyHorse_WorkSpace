---@class FTPSDK
local FTPSDK = require "System.Buy.FTPSDK"
---@class ProductManager_Mobile
local ProductManager = require("System.Buy.ProductManager")
---@class ProductManager_Mobile 手机端支付
local ProductManager_Mobile = class(ProductManager,"ProductManager_Mobile")

--手机端
function ProductManager_Mobile:RequestProductPrice()
    local function OnSuccess(productsInfo)
        --console.lj("拉取商品列表成功 productsInfo" .. table.tostring(productsInfo)) --@DEL
        for key, value in pairs(productsInfo) do
            self.priceData[value.productId] = {
                localPrice = self.metaMap[value.productId].price,
                localCentPrice = math.floor(self.metaMap[value.productId].price * 100 + 0.0001),
                currency = value.currency,
                areaPrice = value.price,
                currencySymbol = value.currencySymbol,
                currencyPrice = value.currencySymbol .. value.price
            }

            if string.isEmpty(value.currencySymbol) then
                if not self.isLogSymbolError then
                    self.isLogSymbolError = true
                    DcDelegates:Log(SDK_EVENT.ProductSymbolError)
                end
                self.priceData[value.productId].currencyPrice = value.currency..value.price
            end
        end
        --初始化流程完成，可以开始使用支付功能
        if table.isEmpty(self.priceData) then
            self.fetchState = ProductFetchState.Lock
            self:FetchFinish(false)
            DcDelegates:Log(SDK_EVENT.FectchProductResult,{result = 1})
            return
        end

        console.lj("拉取商品列表成功" .. table.tostring(self.priceData)) --@DEL
        self.fetchState = ProductFetchState.Success
        DcDelegates:Log(SDK_EVENT.FectchProductResult,{result = 0})
        self:FetchFinish(true)
    end

    local function OnFail()
        console.lj("拉取商品列表失败，需要重新尝试") --@DEL
        self.fetchState = ProductFetchState.Fail
        DcDelegates:Log(SDK_EVENT.FectchProductResult,{result = 2})
        self:FetchFinish(false)
    end

    local consumableList = {}
    local subsList = {}
    for key, value in pairs(self.metaMap) do
        local productId = RuntimeContext.UNITY_IOS and value.iosId or value.googleId
        if value.proType == 0 or value.proType == 2 then
            table.insert(consumableList, productId)
        elseif value.proType == 1 then
            -- 目前不存在订阅商品，先干掉
            --table.insert(subsList, productId)
        end
    end
    console.lj("拉取商品列表 consumableList" .. table.tostring(consumableList)) --@DEL
    self.fetchState = ProductFetchState.Fetching
    FTPSDK:GetProductItemsInfo(consumableList, subsList, OnSuccess, OnFail)
end

--请求补单信息
function ProductManager_Mobile:RequestReissuePurchase()
    --注册补单逻辑
    if not self.initReissue then
        FTPSDK:InitReissuePurchase(
            function(reissueProductsInfo)
                self:HandleReissuePurchase(reissueProductsInfo)
            end
        )
        self.initReissue = true
    end

    FTPSDK:ReissuePurchase()
end

--补单流程
function ProductManager_Mobile:HandleReissuePurchase(reissueProductsInfo)
    local function finishNode()
        QueueLineManage.Instance():FinishNode()
    end

    local pcb = PanelCallbacks:Create(function()
        finishNode()
    end)

    local function ShowReward(value)
        local list = table.deserialize(value.ext)
        local _ext = self:Build64ListToTable(list)

        if _ext and _ext ~= "" and _ext.shopType then
            value.extJson = true
            value.ext = _ext
        else
            value.extJson = false
        end
        value.isReissue = true

        local function onFail(errorCode)
            if errorCode and errorCode == ErrorCodeEnums.RECHARGE_REPEATE_ORDER then
                FTPSDK:FinishProductItem(value.productID)
                --AppServices.EventDispatcher:dispatchEvent(GlobalEvents.ReissuePurchase, { productId = value.productID})
                local package = self.metaMap[value.productID]
                --发奖
                local rwds = {}
                for _, item in pairs(package.itemIds) do
                    table.insert(rwds, {ItemId = item[1], Amount = item[2]})
                end
                do --动态奖励
                    if package.shopType == 13 then
                        --local ext = table.deserialize(value.ext)
                        local reward = AppServices.FashionLimitedGiftManager:GetReward(value.ext.giftSkinId, value.ext.shopId)
                        for _, item in pairs(reward) do
                            table.insert(rwds, {ItemId = item[1], Amount = item[2]})
                        end
                    elseif package.shopType == 9 then
                        if value.ext and value.ext.goldTeam then
                            local extraStrs = AppServices.Meta:GetConfigMetaValue("monthGiftGoldTribeReward") or {}
                            local extraRewardsMeta = table.deserialize(extraStrs)
                            for _, v in ipairs(extraRewardsMeta) do
                                local itemId = tostring(v[1])
                                local count = v[2]
                                AppServices.User:AddItem(itemId, count, ItemGetMethod.month_gift_extra_reward, value.productID)
                            end
                        end
                    end
                end
                if table.count(rwds) == 0 then
                    finishNode()
                else
                    PanelManager.showPanel(GlobalPanelEnum.CommonRewardPanel, {rewards = rwds},pcb)
                end
                Util.LogPayLevel()
                return
            end

            ErrorHandler.ShowErrorPanel(errorCode,finishNode)
        end

        local function onSuccess()
            local package = self.metaMap[value.productID]
            --发奖
            local rwds = {}
            for _, item in pairs(package.itemIds) do
                AppServices.User:AddItem(item[1], item[2], ItemGetMethod.purchase,value.productID)
                table.insert(rwds, {ItemId = item[1], Amount = item[2]})
            end
            do --动态奖励
                if package.shopType == 13 then
                    --local ext = table.deserialize(value.ext)
                    local reward = AppServices.FashionLimitedGiftManager:GetReward(value.ext.giftSkinId, value.ext.shopId)
                    for _, item in pairs(reward) do
                        AppServices.User:AddItem(item[1], item[2], ItemGetMethod.purchase, value.productID)
                        table.insert(rwds, {ItemId = item[1], Amount = item[2]})
                    end
                elseif package.shopType == 9 then
                    if value.ext and value.ext.goldTeam then
                        local extraStrs = AppServices.Meta:GetConfigMetaValue("monthGiftGoldTribeReward") or {}
                        local extraRewardsMeta = table.deserialize(extraStrs)
                        for _, v in ipairs(extraRewardsMeta) do
                            local itemId = tostring(v[1])
                            local count = v[2]
                            table.insert(rwds, {ItemId = itemId, Amount = count})
                            AppServices.User:AddItem(itemId, count, ItemGetMethod.month_gift_extra_reward, value.productID)
                        end
                    end
                end
            end
            AppServices.User:MarkLastRechargeTime()
            AppServices.EventDispatcher:dispatchEvent(GlobalEvents.ReissuePurchase, { productId = value.productID,ext = value.ext})

            FTPSDK:FinishProductItem(value.productID)
            if table.count(rwds) == 0 then
                finishNode()
            else
                PanelManager.showPanel(GlobalPanelEnum.CommonRewardPanel, {rewards = rwds},pcb)
            end
            DcDelegates:Log(
                SDK_EVENT.in_app_purchase_reissue,
                Util.AddUserStatsParamsForPayment(
                    {
                        productId = value.productID,
                    }
                )
            )
            Util.LogPayLevel()
        end

        Net.Rechargemodulemsg_3001_Recharge_Request({orderInfo = table.serialize(value)},onFail,onSuccess)
    end

    QueueLineManage.Instance():Start(
        "ReissuePurchase",
        function()
            if reissueProductsInfo then
                for _, value in pairs(reissueProductsInfo) do
                    value = FTPSDK:ConverterStruct(value)
                    if value.status == "0" and value.shipped ~= "1" then
                        QueueLineManage.Instance():CreateNode("ShowReissueReward",function()
                            ShowReward(value)
                        end)
                    end
                end
                QueueLineManage.Instance():CreateNode("ReissueMail",function()
                    --拉取邮件
                    AppServices.MailManager:RequestMailList()
                    finishNode()
                end)
            end
            finishNode()
        end,
        function()
            finishNode()
            self:ReissueFinish()
        end
    )
end

function ProductManager_Mobile:StartPay(productId, ext, _onFail, _onSuccess,isJson)
    if not self.priceData[productId] then
        console.lj("没有找到商品，检查配置" .. productId) --@DEL
        return
    end

    local function onNetFail(errorCode)
        --订单重复问题：只有当服务器已经发过货了，前端重复发送订单才会发生，默认已走完支付流程，不算失败
        --服务器已经记录了商品数据，前端则只做表现，在下一次同步数据的时候使用服务器数据
        --SDK还未标记已发货，需要提交SDK
        console.lj("商城 net失败")--@DEL
        if errorCode and errorCode == ErrorCodeEnums.RECHARGE_REPEATE_ORDER then
            FTPSDK:FinishProductItem(productId)
            return
        end

        Runtime.InvokeCbk(_onFail,errorCode)
    end

    local function onNetSuc()
        AppServices.User:MarkLastRechargeTime()
        FTPSDK:FinishProductItem(productId,true)
        Util.LogPayLevel()
        Runtime.InvokeCbk(_onSuccess,{productId = productId,ext  = ext})
        console.lj("商城 net成功")--@DEL
    end

    --与SDK交互成功后，给服务器发送，触发发货流程
    local function onFTPSuccess(paymentResult)
        if isJson then
            paymentResult.extJson = true
            local list = table.deserialize(paymentResult.ext)
            paymentResult.ext = self:Build64ListToTable(list)
        else
            paymentResult.extJson = false
        end
        --将list转化成table
        local jsonStr = table.serialize(paymentResult)
        console.lj("商城 sdk成功"..jsonStr)--@DEL
        Net.Rechargemodulemsg_3001_Recharge_Request({orderInfo = jsonStr},onNetFail,onNetSuc)
    end

    local function onFTPFail(failReason)
        ErrorHandler.ShowErrorMessage(Runtime.Translate("purchase.fail.text", {reason = failReason or ""}))
        console.lj("商城 sdk失败")--@DEL
    end

    local cost = self.priceData[productId].localCentPrice
    local source = ext
    local extJson = ext
    if isJson then
        source = ext.source
        local extList = self:BuildTableTo64List(ext)
        extJson = table.serialize(extList)
    end

    FTPSDK:Pay(productId, cost, extJson, onFTPSuccess, onFTPFail)

    DcDelegates:Log(
        SDK_EVENT.in_app_purchase_start,
        Util.AddUserStatsParamsForPayment(
            {
                productId = productId,
                price = cost,
                source = source
            }
        )
    )
end


---请求获取还在有效的订阅信息(登陆后调用)
---拉到有效的订阅信息后请求服务器返回过期订单
function ProductManager_Mobile:RequestSubsOrders()
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

    local function OnFTPSuccess(SubsOrder)
        self.SubsOrderInfos = {}
        local data = {}
        for key, value in pairs(SubsOrder) do
            value = FTPSDK:ConverterSubsOrder(value)
            self.SubsOrderInfos[value.productId] = value
            table.insert(data, {productId = value.productId,expired = value.expired})
        end

        Net.Rechargemodulemsg_3002_SubscribeInfo_Request({subscribes = data},onNetFail,onNetSuc)
    end

    local function OnFTPFail(failReason)
        ErrorHandler.ShowErrorMessage(Runtime.Translate("purchase.fail.text", {reason = failReason or ""}))
    end

    FTPSDK:GetSubsOrders(OnFTPSuccess, OnFTPFail)
end

--检查订单过期
function ProductManager_Mobile:CheckAllSubscribeExpired()
    if table.count(self.SubsOrderInfos) == 0 then
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

        if table.count(self.SubsOrderInfos) == 0 then
            WaitExtension.CancelTimeout(self.expiredTimer)
            self.expiredTimer = nil
            return
        end

        for key, subscribe in pairs(self.SubsOrderInfos) do
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
function ProductManager_Mobile:RemoveSubscribe()
    while #self.expiredList > 0 do
        MessageDispatcher:SendMessage("RemoveSubscribe_"..self.expiredList[1])
        Net.Rechargemodulemsg_3003_SubscribeExpired_Request({productId = self.expiredList[1]})
        table.remove(self.expiredList, 1)
    end
end

local extDataKey = {"shopType","giftSkinId","shopId","gourp","source","activityId","version","goldTeam"}
function ProductManager_Mobile:BuildTableTo64List(data)
   if table.isEmpty(data) then
        return {}
   end

   local temp = {}
   for index, value in ipairs(extDataKey) do
       temp[index] = tostring(data[value]) or ""
   end

   for index = #extDataKey, 1,-1 do
       if temp[index] == "nil" then
            table.remove(temp, index)
       else
            break
       end
   end
   return temp
end

function ProductManager_Mobile:Build64ListToTable(list)
    if table.isEmpty(list) then
         return {}
    end

    local temp = {}
    for index, value in ipairs(extDataKey) do
        if not string.isEmpty(list[index]) then
            temp[value] = list[index]
        end
    end
    return temp
 end

return ProductManager_Mobile
