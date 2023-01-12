--insertWidgetsBegin
--    btn_close    go_orderInfo    go_orderCd
--insertWidgetsEnd

--insertRequire
local _OrderTaskPanelBase = require "UI.OrderTask.View.UI.Base._OrderTaskPanelBase"

---@class OrderTaskPanel:_OrderTaskPanelBase
local OrderTaskPanel = class(_OrderTaskPanelBase)

function OrderTaskPanel:ctor()
    ---@type OrderTaskItem[]
    self._childCache = {}
    self.SubmitAim = {}
    self.submit_effectTimerId = nil
end

function OrderTaskPanel:onAfterBindView()
    local orderTask, orderTaskProgress, sel = AppServices.OrderTask:GetShowOrderInfos()
    if App.mapGuideManager:HasRunningGuide(GuideIDs.GuideOrder) then
        sel = 1
    end
    self.go_orderAds.gameObject:SetActive(false)
    self.orders = orderTask
    self.orderTaskProgress = orderTaskProgress
    self.SelectPosition = sel or 1
    self.submit_effect:SetActive(false)
    self:refreshUI()
    self:ShakeAll()
    self:RefreshPorgressCD()
end

function OrderTaskPanel:refreshUI(orders, orderTaskProgress, sel)
    self.orders = orders or self.orders
    self.orderTaskProgress = orderTaskProgress or self.orderTaskProgress
    self.SelectPosition = sel or self.SelectPosition or 1
    self:refreshOrderNodes(self.orders) -- 刷新奖励节点
    self:OnSelectOrder(self.SelectPosition)
    self:refreshOrderTaskProgress()
end

function OrderTaskPanel:ShakeAll()
    for i = 1, 9 do
        local itemNode = self._childCache[i]
        if itemNode then
            itemNode:Shake()
        end
    end
end

function OrderTaskPanel:TriggerOrderSpine(position, oldOrderType, newOrderType)
    self:SetItemSubmitAim(true, position)
    local itemNode = self._childCache and self._childCache[position]
    if itemNode then
        itemNode:RewardMatchSpine()
        local function afterSpineAnim()
            if Runtime.CSValid(self.btn_delete) then
                self.btn_delete.interactable = true
            end
            if Runtime.CSValid(self.btn_submit) then
                self.btn_submit.interactable = true
            end
            if Runtime.CSValid(self.btn_ads) then
                self.btn_ads.interactable = true
            end
            self:SetItemSubmitAim(false, position)
            itemNode:RewardMatchSpineEnd()
        end
        if Runtime.CSValid(self.btn_delete) then
            self.btn_delete.interactable = false
        end

        local firstAnim = oldOrderType == 1 and 1 or 0
        firstAnim = AppServices.OrderTask.IsAbsType(oldOrderType) and 2 or firstAnim
        local secAnim = newOrderType == 1 and 1 or 0
        secAnim = AppServices.OrderTask.IsAbsType(newOrderType) and 2 or secAnim
        local state = firstAnim * 10 + secAnim

        if state == 0 then
            return itemNode:PlayItemSpineAnim("refresh01", afterSpineAnim)
        end
        if state == 1 then
            return itemNode:PlayItemSpineAnim("refresh03", afterSpineAnim)
        end
        if state == 10 then
            return itemNode:PlayItemSpineAnim("refresh04", afterSpineAnim)
        end
        if state == 11 then
            return itemNode:PlayItemSpineAnim("refresh02", afterSpineAnim)
        end
        if state == 2 then
            return itemNode:PlayItemSpineAnim("refresh05", afterSpineAnim)
        end
        if state == 12 then
            return itemNode:PlayItemSpineAnim("refresh06", afterSpineAnim)
        end
        if state == 20 then
            return itemNode:PlayItemSpineAnim("refresh07", afterSpineAnim)
        end
        if state == 21 then
            return itemNode:PlayItemSpineAnim("refresh08", afterSpineAnim)
        end
        if state == 22 then
            return itemNode:PlayItemSpineAnim("refresh09", afterSpineAnim)
        end
    else
        self:SetItemSubmitAim(false, position)
    end
end

---刷新左侧每个订单的节点
function OrderTaskPanel:refreshOrderNodes(orders)
    -- console.assert(orders and #orders > 1, 'must have order')

    for i = 1, 9 do
        local order = orders and orders[i]
        local ItemNode = self:GetChildItem(i, order)
        if ItemNode then
            ItemNode:SetData(order, self.SelectPosition)
        end
    end
end

function OrderTaskPanel:GetOrderWorldPos(position)
    local itemNode = self._childCache and self._childCache[position]
    if itemNode then
        return itemNode:GetSpecialRewardPos()
    end
end

function OrderTaskPanel:GetOrderCenterPos(position)
    local itemNode = self._childCache and self._childCache[position]
    if itemNode then
        return itemNode.gameObject:GetPosition()
    end
end

function OrderTaskPanel:GetOrderReward(position)
    local itemNode = self._childCache and self._childCache[position]
    if itemNode then
        return itemNode:GetRewardFlyObj()
    end
    return {}
end

local childAssetPath = "Prefab/UI/OrderTask/OrderTaskItem.prefab"
function OrderTaskPanel:GetChildItem(pos, order)
    local child = self._childCache[pos]
    if not order then
        if child then
            child:setActive(false)
        end
        return
    end
    if not child then
        local item = include("UI.OrderTask.View.UI.OrderTaskItem")
        child = item.Create(self, childAssetPath, self.go_layout_orders)
        self._childCache[pos] = child
    else
        child:setActive(true)
    end
    return child
end

function OrderTaskPanel:OnSelectOrder(position)
    if self.SelectPosition ~= position then
        AppServices.DiamondConfirmUIManager:UndoClick()
    end
    self.SelectPosition = position
    local order = self.orders[position]
    local inCd = AppServices.OrderTask.IsInCD(order)
    local isAds = AppServices.OrderTask.IsAbs(order)
    self.go_orderInfo.gameObject:SetActive(not inCd and not isAds)
    self.go_orderCd.gameObject:SetActive(inCd)
    local oldActive = self.go_orderAds.gameObject.activeSelf
    self.go_orderAds.gameObject:SetActive(not inCd and isAds)
    if not oldActive and self.go_orderAds.gameObject.activeSelf then
        DcDelegates.Ads:LogEntryShow(AdsTypes.AdsOrder)
        --console.error("OrderTaskPanel:OnSelectOrder" .. position)
    end
    if inCd then
        self:showOrderCd(order)
    else
        if not isAds then
            self:showOrderInfo(order)
        end
    end
    for pos, child in pairs(self._childCache) do
        child:SetSelect(pos == position)
    end
end

function OrderTaskPanel:showOrderCd()
    self:StartTimer()
end

function OrderTaskPanel:SetItemSubmitAim(value, position)
    self.SubmitAim[position] = value
end

    function OrderTaskPanel:GetItemSubmitAnim(position)
    return self.SubmitAim[position] == true
end

function OrderTaskPanel:IsItemSubmitAnim()
    for _, v in pairs(self.SubmitAim) do
        if v then
            return true
        end
    end
    return false
end

function OrderTaskPanel:RefreshCD()
    local position = self.SelectPosition
    local order = self.orders[position]
    local cdSec = AppServices.Meta:GetConfigMetaValueNumber("orderCD")
    local cd = order.cdStartTime / 1000 + cdSec - TimeUtil.ServerTime()
    if cd <= 0 then
        self:StopTimer()
    end
    local s = TimeUtil.SecToOver48H(cd)
    self.label_orderCD.text = s
    local cost = AppServices.OrderTask.CalClearCdCost(order)
    self.label_clearCost.text = cost
end

function OrderTaskPanel:showOrderInfo(order)
    self:StopTimer()
    local orderIconCfg = AppServices.OrderTask:GetOrderIcon(order.orderIcon)
    -- 设置头像
    AppServices.ItemIcons:SetOrderTaskIcon(self.img_npc, orderIconCfg[1])
    -- 设置名字
    Runtime.Localize(self.label_npcName, orderIconCfg[2])
    local taskItems = order.taskItems
    local go_items = self:CopyComponent(self.go_orderItem, self.go_layout_ordeItems, #taskItems)
    for i, go_item in ipairs(go_items) do
        local item = taskItems[i]
        local img_icon = find_component(go_item, 'img_itemIcon', Image)
        local btn_icon = find_component(go_item, 'img_itemIcon', Button)
        local label_num = find_component(go_item, 'label_num', Text)
        local btn_tip = find_component(go_item, 'btn_tip', Button)
        local itemId = item.itemTemplateId
        local sprite = AppServices.ItemIcons:GetSprite(itemId)
        img_icon.sprite = sprite
        local have = AppServices.User:GetItemAmount(itemId)
        label_num.text = Runtime.formartCount(have, item.count)
        local enough = have >= item.count
        self:SetComponentVisible(btn_tip, not enough)
        Util.UGUI_AddButtonListener(btn_tip, function()
            local getWays = AppServices.GetWay.getWays(itemId)
            if #getWays > 1 then
                self:ShowTip(itemId, btn_icon.gameObject)
            else
                local canJump = AppServices.Jump.AutoByItemId(itemId, GlobalPanelEnum.OrderTaskPanel)
                if not canJump then
                    local tipGo = btn_tip.gameObject
                    UITool.ShowItemDescTip(self, itemId, tipGo, tipGo.transform.sizeDelta.y)
                end
            end
        end)
        Util.UGUI_AddButtonListener(btn_icon, function()
           self:ShowTip(itemId, btn_icon.gameObject)
        end)
        img_icon.transform:DOKill()
        img_icon.transform.localScale = Vector3(1, 1, 1)
        img_icon.transform:DOScale(1.1, 0.2):OnComplete(function () img_icon.transform:DOScale(1, 0.2) end)
    end
end

function OrderTaskPanel:ShowTip(itemId, itemGo)
    if not self.tip then
        local detailTip = require "UI.Bag.BagPanel.View.UI.ItemDetailTip"
        self.tip = detailTip.Create(self.gameObject)
    end
    self.tip:ShowTip(itemId, itemGo)
    -- self.tip.mask.gameObject:SetActive(true)
    self.tip:ShowMask(true)
    App.mapGuideManager:StartSeries("GuideFlourOrder", {itemId = itemId, tip = self.tip})
end

function OrderTaskPanel:StopTimer()
    if self.timerId then
        WaitExtension.CancelTimeout(self.timerId)
        self.timerId = nil
    end
end

function OrderTaskPanel:StartTimer()
    self:StopTimer()
    local function onTick()
        self:RefreshCD()
    end
    self.timerId = WaitExtension.InvokeRepeating(onTick, 0, 1)
    onTick()
end

---刷新进度条
function OrderTaskPanel:refreshOrderTaskProgress()
    local progress = self.orderTaskProgress
    local cur = progress.finishCnt
    Runtime.Localize(self.label_progress, 'ui_order_cumulative', {num=tostring(cur)})
    local targets = require("Order.OrderMetaTool"):GetOrderTaskProgressTarget(progress.playerLevel)
    local per = 0
    local total = 1
    if targets then
        total = targets[#targets]
        per = cur / total
    end
    self.slider_orderProgress.value = math.clamp(per, 0, 1)
    if not targets then return end
    local coms = self:CopyComponent(self.go_awardNode, self.slider_orderProgress, #targets)
    local size = self.slider_orderProgress.gameObject.transform.sizeDelta.x
    for i, go in ipairs(coms) do
        local btn = find_component(go, 'btn_icon', Button)

        local label_prog = find_component(go, 'label_prog', Text)
        local isDone = progress.rewardIndex >= i
        for j = 1, 3 do
            local icon_img = find_component(go, 'btn_icon/icon_'..j, Image)
            self:SetComponentVisible(icon_img, j == i and not isDone)
            local img_done = find_component(go, 'dones/done_'..j, Image)
            self:SetComponentVisible(img_done, j == i and isDone)
        end

        local nodePro = targets[i]
        local curPer = nodePro / total
        label_prog.text = nodePro
        local pos = size * curPer
        if pos == size then
            pos = pos - 10
        end

        go.transform.anchoredPosition = Vector2(pos, 0)
        self.progressPositions = self.progressPositions or {}
        -- local p = go:GetPosition()
        self.progressPositions[i] = go
        Util.UGUI_AddButtonListener(btn, function()
            sendNotification(OrderTaskPanelNotificationEnum.Click_orderTaskProgress, {index = i})
        end)
    end
end

---刷新进度条CD
function OrderTaskPanel:RefreshPorgressCD()
    local isInCd = AppServices.OrderTask:IsInProgressRewardCd()
    if isInCd then
        self:SetComponentVisible(self.go_orderPorgress, false)
        self:SetComponentVisible(self.label_orderProgressCd, true)
        self:StartRewardCD()
    else
        self:StopRewardCD()
        self:SetComponentVisible(self.go_orderPorgress, true)
        self:SetComponentVisible(self.label_orderProgressCd, false)
    end
end

function OrderTaskPanel:StartRewardCD()
    self:StopRewardCD()
    local function onTick()
        self:RefreshRewardCD()
    end
    self.timerProgressId = WaitExtension.InvokeRepeating(onTick, 0, 1)
    onTick()
end
function OrderTaskPanel:StopRewardCD()
    if self.timerProgressId then
        WaitExtension.CancelTimeout(self.timerProgressId)
        self.timerProgressId = nil
    end
end

function OrderTaskPanel:RefreshRewardCD()
    local cdTime = AppServices.OrderTask:GetProgressRewardCd()
    local now = TimeUtil.ServerTimeMilliseconds()
    if cdTime <= now then
        self:RefreshPorgressCD()
        return
    end
    local s = TimeUtil.SecToOver48H((cdTime - now) / 1000)
    local str = Runtime.Translate('ui_order_CumulativeRewardCD') .. s
    self.label_orderProgressCd.text =  str
end

function OrderTaskPanel:GetProgressWorldPos(index)
    local go = self.progressPositions and self.progressPositions[index]
    return go and go:GetPosition()
end

function OrderTaskPanel:ShowItemTips(index)
    local progress = self.orderTaskProgress
    local items = require("Order.OrderMetaTool"):GetOrderTaskProgressReward(progress.playerLevel, index)
    local parentGameObject = self.copyComponents[self.go_awardNode][index]
    local offsetHeight = parentGameObject.transform.sizeDelta.y
    UITool.ShowItemGiftTips(self, items, parentGameObject, offsetHeight)
end

function OrderTaskPanel:GetSubmitBtnObj()
    return self.btn_submit.gameObject
end

function OrderTaskPanel:GetOrderItemObj(index)
    index = index or 1
    return self._childCache[index].gameObject
end

---激活提交CD
function OrderTaskPanel:ActiveSubmitCd()
    local cd = tonumber(AppServices.Meta:GetConfigMetaValue('orderInterval'))
    self.img_progress.fillAmount = 0
    self.img_progress:DOFillAmount(1, cd)
    self.submit_effect:SetActive(false)
    if self.submit_effectTimerId then
        WaitExtension.CancelTimeout(self.submit_effectTimerId)
    end
    self.submit_effectTimerId =  WaitExtension.SetTimeout(function ()
        self.submit_effectTimerId = nil
        self.submit_effect:SetActive(true)
    end, cd)
end

---不允许点击状态
function OrderTaskPanel:SetClickBlock(key)
    console.assert(key, 'click Block Must Have Key') --@DEL
    self._clickBlock = key
end
function OrderTaskPanel:RemoveClickBlock()
    self._clickBlock = nil
end

---是否不允许点击
function OrderTaskPanel:IsClickBlock()
    if self._clickBlock then
        -- console.terror(self, 'click block ing', self._clickBlock) --@DEL
        AppServices.OrderTask.SubmitCDNotice()
        return true
    end
end

function OrderTaskPanel:destroy()
    if self.tip then
        self.tip:Destory()
    end
    self.tip = nil
    self.progressPositions = nil

    self:StopTimer()
    self:StopRewardCD()
    if self.submit_effectTimerId then
        WaitExtension.CancelTimeout(self.submit_effectTimerId)
        self.submit_effectTimerId = nil
    end
    for _, v in pairs(self._childCache) do
        v:Destory()
    end
    BasePanel.destroy(self)
end


return OrderTaskPanel
