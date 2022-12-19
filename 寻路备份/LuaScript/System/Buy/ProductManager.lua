---@class FTPSDK
local FTPSDK = require "System.Buy.FTPSDK"
---@class ProductManager
local ProductManager = class(nil, "ProductManager")
--[[
local ProductManager = {
    isInit = false,
    meta = AppServices.Meta:Category("ShopTemplate"),
    ---key:productId value:metab
    metaMap = {},
    --商城列表
    shopList = {},
    ---localPrice:美元价格 localCentPrice:美分价格 currency：地区货币 areaPrice：地区价格 currencyPrice：价格显示标签
    priceData = {},
    ---拉取商品列表的状态
    fetchState = 1,
    consumableList = {},
    subsList = {}
}
]]
ProductFetchState = {
    Unfetch = 1,
    Fetching = 2,
    Success = 3,
    Fail = 4,
    Lock = 5
}

function ProductManager:Init()
    self.meta = AppServices.Meta:Category("ShopTemplate")
    ---key:productId value:metab
    self.metaMap = {}
    --商城列表
    --self.shopList = {}
    ---localPrice:美元价格 localCentPrice:美分价格 currency：地区货币 areaPrice：地区价格 currencyPrice：价格显示标签
    self.priceData = {}
    ---拉取商品列表的状态
    self.fetchState = 1
    self.consumableList = {}
    self.subsList = {}
    --有效订阅map
    self.subsOrderInfos = {}
    --过期订阅map
    self.expiredList = {}

    for key, value in pairs(self.meta) do
        local productId = RuntimeContext.UNITY_IOS and value.iosId or value.googleId
        self.metaMap[productId] = value
    end

    if not RuntimeContext.IAP_ENABLE then
        self.fetchState = ProductFetchState.Lock
        return
    end

    --拉取商品价格和信息
    self:RequestProductPrice()
end

--base:子类必须实现
--RequestProductPrice() 请求拉取商品信息
--RequestReissuePurchase(callback) 请求补单
--StartPayConsumableProduct(productId, ext, onSuccess, onFail) 请求支付

---检查拉取结果（不需要回调）
function ProductManager:CheckFetch()
    if self.fetchState == ProductFetchState.Lock then
        console.lj("商城未开启，配置或者华为手机") --@DEL
        return false
    end

    if self.fetchState == ProductFetchState.Success then
        return true
    end
    if self.fetchState == ProductFetchState.Fetching then
        console.lj("列表还在拉取中，请等待...") --@DEL
        return false
    end

    console.lj("列表没有拉或者失败了，重新拉取...") --@DEL
    self:RequestProductPrice()
    return false
end

---检查拉取结果流程（需要回调）=>FetchFinish
function ProductManager:CheckFetchAll(callback)
    if self.fetchResultCB then
        console.lj("警告：有商城的列表还在拉取，又申请了一次") --@DEL
    end
    self.fetchResultCB = callback

    if self.fetchState == ProductFetchState.Lock then
        self:FetchFinish(false)
        return
    end

    if self.fetchState == ProductFetchState.Success then
        self:FetchFinish(true)
        return
    end

    if self.fetchState == ProductFetchState.Fetching then
        --拉取中等待
        self:FetchFinish(false)
        return
    end
    console.lj("列表没有拉或者失败了，重新拉取...") --@DEL
    self:RequestProductPrice()
end

function ProductManager:FetchFinish(result)
    local callback = self.fetchResultCB
    self.fetchResultCB = nil
    Runtime.InvokeCbk(callback, result)
    MessageDispatcher:SendMessage(MessageType.Product_Fetch_Result, result)
end

---检查补单流程（需要回调）=>ReissueFinish
function ProductManager:ReissuePurchase(callback)
    if self.reissuePurchaseCB then
        console.lj("警告：上一次补单回调没有清除") --@DEL
    end
    self.reissuePurchaseCB = callback
    self:RequestReissuePurchase()
end

function ProductManager:ReissueFinish()
    Runtime.InvokeCbk(self.reissuePurchaseCB)
    self.reissuePurchaseCB = nil
end

--登陆后调用
function ProductManager:UpdateUser(userID)
    if self.fetchState == ProductFetchState.Lock then
        console.lj("支付功能未开启") --@DEL
        return
    end
    --修改玩家id
    FTPSDK:UpdateUser(userID)
end

--获得发货商品通常表现流程
function ProductManager:ShowReward(productId, callback)
    local config = self:GetProductMeta(productId)
    local rwds = {}
    if table.count(config.itemIds) == 0 then
        Runtime.InvokeCbk(callback)
        return
    end
    local buffCount = 0
    for _, v in pairs(config.itemIds) do
        local itemId = v[1]
        local amount = v[2]
        if AppServices.Meta:GetItemFuncType(itemId) == 10 then
            buffCount = buffCount + 1
        end
        table.insert(rwds, {ItemId = itemId, Amount = amount})
        AppServices.User:AddItem(itemId, amount, ItemGetMethod.purchase, productId)
    end

    local pcb = nil
    if callback then
        pcb = PanelCallbacks:Create(callback)
    end
    if #rwds - buffCount > 0 then --体力减半buff礼包买完后不弹这个物品获得界面哈，因为已经有了一个buff获得界面了，这次只有buff，如果之后出，那么就要做新的类型了，那就会先弹出通用物品获得界面（包含buff），关闭后弹出buff获得界面  by xieyanjiao
        PanelManager.showPanel(GlobalPanelEnum.CommonRewardPanel, {rewards = rwds}, pcb)
    end
end

function ProductManager:ShowRewardWithBonus(productId, extra, pos, callback)
    local config = self:GetProductMeta(productId)
    local rwds = {}
    if table.count(config.itemIds) == 0 then
        Runtime.InvokeCbk(callback)
        return
    end
    local buffCount = 0
    for _, v in pairs(config.itemIds) do
        local itemId = v[1]
        local amount = v[2]
        if AppServices.Meta:GetItemFuncType(itemId) == 10 then
            buffCount = buffCount + 1
        end
        table.insert(rwds, {ItemId = itemId, Amount = amount})
        AppServices.User:AddItem(itemId, amount, ItemGetMethod.purchase, productId)
    end

    local extraStrs = AppServices.Meta:GetConfigMetaValue("monthGiftGoldTribeReward") or {}
    local extraRewardsMeta = table.deserialize(extraStrs)
    local extraRewards = {}
    for _, v in ipairs(extraRewardsMeta) do
        local itemId = tostring(v[1])
        local count = v[2]
        table.insert(extraRewards, {ItemId = itemId, Amount = count})
        AppServices.User:AddItem(itemId, count, ItemGetMethod.month_gift_extra_reward, productId)
    end

    local parentTrans = App.scene and App.scene.panelLayer and App.scene.panelLayer.transform
    local animBox = require "UI.Components.AccumulateBox"
    animBox:CreateWithStartPos(
        pos,
        parentTrans,
        extraRewards,
        GlobalPanelEnum.CommonRewardPanel,
        nil,
        function()
            if #rwds - buffCount > 0 then --体力减半buff礼包买完后不弹这个物品获得界面哈，因为已经有了一个buff获得界面了，这次只有buff，如果之后出，那么就要做新的类型了，那就会先弹出通用物品获得界面（包含buff），关闭后弹出buff获得界面  by xieyanjiao
                local pcb = nil
                if callback then
                    pcb = PanelCallbacks:Create(callback)
                end
                PanelManager.showPanel(GlobalPanelEnum.CommonRewardPanel, {rewards = rwds}, pcb)
            else
                Runtime.InvokeCbk(callback)
            end
        end,
        "purple"
    )
end
--订阅
--[[
function ProductManager:InitSubscribe(subscribeInfos)
    local count = table.maxn(subscribeInfos.subscribes)
    if count == 0 then
        return
    end
    for i = 1, count do
        local info = subscribeInfos.subscribes[i]
        self.subscribeItemInfos[info.productId] = {productId=info.productId,expired = info.expired}
    end
    --self:CheckAllSubscribeExpired()
end

--添加订阅
function ProductManager:AddSubscribe(productId,expired)
    self.subscribeItemInfos[info.productId] = {productId=info.productId,expired = info.expired}
end

--移除订阅
function ProductManager:RemoveSubscribe(productIds)
    local function removeLogic(subscribe)
        if subscribe.expired <= TimeUtil.ServerTime() then
            self.subscribeItemInfos[subscribe.productId] = nil
            MessageDispatcher:SendMessage(MessageType.RemoveSubscribe.."_"..subscribe.productId)
        end
    end


    local function onfail(errorcode)
        -- body
        --先暂停订阅，等下次刷新

    end

    local function onSuccess(respones)
        local subscribes = respones.subscribes
        for i = 1, #productIds do
            local info = subscribes[i]
            removeLogic(info)
        end

        self.pause = false
    end
    Net.Rechargemodulemsg_3002_SubscribeInfo_Request({productIds = productIds},onfail,onSuccess)
end

--检查订阅到期
function ProductManager:CheckAllSubscribeExpired()
    if table.count(self.subscribeItemInfos) == 0 then
        return
    end

    self.pause = false
    if self.expiredTimer then
        return
    end

    self.expiredTimer = WaitExtension.InvokeRepeating(function ()
        if self.pause then
            return
        end

        if table.count(self.subscribeItemInfos) == 0 then
            WaitExtension.CancelTimeout(self.expiredTimer)
            self.expiredTimer = nil
            return
        end

        local temp = {}
        for key, subscribe in pairs(self.subscribeItemInfos) do
            if subscribe.expired <= TimeUtil.ServerTime() then
                table.insert(temp, subscribe.productId)
            end
        end
        if #temp > 0 then
            self:RemoveSubscribe(temp)
            self.pause = true
        end
    end, 0, 1)
end

function ProductManager:SubscribeRecover(errorCode)
    -- body
end
]]
-----------数据层----------
---通过id获取商品的配置信息
function ProductManager:GetProductMetabyId(metaId)
    return self.meta[metaId]
end

---通过id获取商品名
function ProductManager:GetProductId(metaId)
    local value = self.meta[metaId]
    return RuntimeContext.UNITY_IOS and value.iosId or value.googleId
end

---通过商品名获取配置信息
function ProductManager:GetProductMeta(productId)
    return self.metaMap[productId] or ""
end

---通过商品名获取价格信息
function ProductManager:GetProductPrice(productId)
    return self.priceData[productId] or ""
end

---通过商品名获取订阅信息
function ProductManager:GetSubscribe(productId)
    return self.subscribeItemInfos[productId]
end
return ProductManager
