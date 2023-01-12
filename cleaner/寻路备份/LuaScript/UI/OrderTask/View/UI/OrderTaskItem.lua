---@class OrderTaskItem
local OrderTaskItem = class(PanelItemBase, "OrderTaskItem")

function OrderTaskItem.Create(parentPanel, assetPath, ...)
    local instance = OrderTaskItem.new(parentPanel, ...)
    local go = BResource.InstantiateFromAssetName(assetPath)
    instance:InitWithGameObject(go, ...)
    return instance
end

function OrderTaskItem:InitWithGameObject(gameObject, parentGameObject)
    self.gameObject = gameObject
    local go = find_component(gameObject, 'root')
    self.shakeRoot = go
    ---普通背景
    self.img_normal = find_component(go, "img_normal", Image)
    ---选中背景
    self.img_selected = find_component(go, "img_selected", Image)
    ---困难任务背景
    self.img_special = find_component(go, "img_special", Image)
    ---困难任务选中背景
    self.img_special_select = find_component(go, "img_special_select", Image)
    self.img_specialIcon = find_component(go, "img_specialIcon", Image)
    ---广告
    self.img_ads = find_component(go, "img_ads", Image)
    self.img_ads_select = find_component(go, "img_ads_select", Image)
    ---奖励layout
    self.go_awards = find_component(go, 'go_awards')
    ---奖励节点
    self.go_awardNode = find_component(go, 'go_awards/go_awardNode')
    ---完成任务图片
    self.img_done = find_component(go, 'img_done', Image)
    ---CD图片
    self.img_Cd = find_component(go, 'img_Cd', Image)

    self.gameObject.transform:SetParent(parentGameObject.transform, false)

    self.img_spine = find_component(go, "spine")

    self.spine_select = nil
    self.spine_normal = nil
    self.timerId1 = nil
end

function OrderTaskItem:ctor(parentPanel)
    self.parentPanel = parentPanel
    self.rewardFlyObj = {}
end

function OrderTaskItem:SetSpineColor(isSel)
    if self.spine_select == nil or self.spine_normal == nil then
        return
    end
    if isSel then
        self.spine_select.color = Color(1, 1, 1, 1)
        self.spine_normal.color = Color(1, 1, 1, 0)
    else
        self.spine_select.color = Color(1, 1, 1, 0)
        self.spine_normal.color = Color(1, 1, 1, 1)
    end
end

function OrderTaskItem:AdsLog(oldOrder, newOrder)
    if newOrder == nil then
        return
    end
    local orderMgr = AppServices.OrderTask
    if not orderMgr.IsAbs(newOrder) then
        return
    end
    if oldOrder == nil or not orderMgr.IsAbs(oldOrder) then
        DcDelegates.Ads:LogWinShow(AdsTypes.AdsOrder)
        --console.error("OrderTaskPanel:AdsLog")
    end
end

function OrderTaskItem:SetData(order, SelectPosition)
    self:AdsLog(self.order, order)
    self.order = order
    local position = order.position
    local orderMgr = AppServices.OrderTask
    local isInCd = orderMgr.IsInCD(order)
    local isSel = SelectPosition == position
    if isInCd then
        self:SetComponentVisible(self.img_Cd, true)
        if not self.parentPanel:GetItemSubmitAnim(order.position) then
            self:SetComponentVisible(self.img_normal, not isSel)
            self:SetComponentVisible(self.img_special, false)
            self:SetComponentVisible(self.img_special_select, false)
            self:SetComponentVisible(self.img_specialIcon, false)
            self:SetComponentVisible(self.img_selected, isSel)
            self:SetComponentVisible(self.img_ads, false)
            self:SetComponentVisible(self.img_ads_select, false)
            self:SetComponentVisible(self.img_done, false)
            self:SetComponentVisible(self.go_awards, false)
        else
            self:SetSpineColor(isSel)
        end
    else
        local isSpecial = orderMgr.isDifficultyOrder(order.orderType)
        local isAds = orderMgr.IsAbs(order)
        local isNormal = not isAds and not isSpecial
        local isDone = orderMgr:IsDone(order)
        self:SetComponentVisible(self.img_Cd, false)
        if not self.parentPanel:GetItemSubmitAnim(order.position) then
            self:SetComponentVisible(self.img_normal, not isSel and isNormal)
            self:SetComponentVisible(self.img_special, not isSel and isSpecial)
            self:SetComponentVisible(self.img_ads, not isSel and isAds)
            self:SetComponentVisible(self.img_special_select, isSel and isSpecial)
            self:SetComponentVisible(self.img_specialIcon, isSpecial)
            self:SetComponentVisible(self.img_selected, isSel and isNormal)
            self:SetComponentVisible(self.img_ads_select, isSel and isAds)
            self:SetComponentVisible(self.img_done, not not isDone)
            self:SetComponentVisible(self.go_awards, true)
        else
            self:SetSpineColor(isSel)
        end
        local reward = order.rewardItems
        if reward then
            local go_items = self:CopyComponent(self.go_awardNode, self.go_awards, #reward)
            for i, go_item in ipairs(go_items) do
                local item = reward[i]
                local img_icon = find_component(go_item, 'img_icon', Image)
                local label_num = find_component(go_item, 'label_num', Text)
                local label_numAds = find_component(go_item, 'label_numAds', Text)
                local sprite = AppServices.ItemIcons:GetSprite(item.itemTemplateId)
                img_icon.sprite = sprite
                label_num.text = item.count
                label_numAds.text = item.count
                label_num.gameObject:SetActive(not isAds or isSel)
                label_numAds.gameObject:SetActive(isAds and not isSel)
                --self.rewardFlyObj[item.id] = img_icon.gameObject
            end
        end
    end

    local btn_orderNode = self.gameObject:GetComponent(typeof(Button))
    Util.UGUI_AddButtonListener(btn_orderNode, function()
        -- sendNotification(OrderTaskPanelNotificationEnum.Select_Order, {position = position})
        --if self.parentPanel:IsItemSubmitAnim() == false then
            self.parentPanel:OnSelectOrder(position)
            self:Shake()
        --end
    end, nil, true)
end

function OrderTaskItem:SetSelect(isSel, order)
    order = order or self.order
    local orderMgr = AppServices.OrderTask
    local isInCd = orderMgr.IsInCD(order)
    if isInCd then
        if not self.parentPanel:GetItemSubmitAnim(order.position) then
            self:SetComponentVisible(self.img_normal, not isSel)
            self:SetComponentVisible(self.img_special, false)
            self:SetComponentVisible(self.img_selected, isSel)
            self:SetComponentVisible(self.img_special_select, false)
            self:SetComponentVisible(self.img_ads, false)
            self:SetComponentVisible(self.img_ads_select, false)
            self:SetComponentVisible(self.img_done, false)
            self:SetComponentVisible(self.go_awards, false)
        else
            self:SetSpineColor(isSel)
        end
    else
        local isSpecial = orderMgr.isDifficultyOrder(order.orderType)
        local isAds = orderMgr.IsAbs(order)
        local isNormal = not isAds and not isSpecial
        if not self.parentPanel:GetItemSubmitAnim(order.position) then
            self:SetComponentVisible(self.img_normal, not isSel and isNormal)
            self:SetComponentVisible(self.img_special, not isSel and isSpecial)
            self:SetComponentVisible(self.img_ads, not isSel and isAds)
            self:SetComponentVisible(self.img_special_select, isSel and isSpecial)
            self:SetComponentVisible(self.img_selected, isSel and isNormal)
            self:SetComponentVisible(self.img_ads_select, isSel and isAds)
            self:SetComponentVisible(self.go_awards, true)
        else
            self:SetSpineColor(isSel)
        end
        local reward = order.rewardItems
        if reward then
            local go_items = self:CopyComponent(self.go_awardNode, self.go_awards, #reward)
            for i, go_item in ipairs(go_items) do
                local label_num = find_component(go_item, 'label_num', Text)
                local label_numAds = find_component(go_item, 'label_numAds', Text)
                label_num.gameObject:SetActive(not isAds or isSel)
                label_numAds.gameObject:SetActive(isAds and not isSel)
            end
        end
    end
end

local _ShakeVec = Vector3(0, 0, 10)
local _Vibrato = 3
local _duration = 1
function OrderTaskItem:Shake()
    if self.shakeTween then
        self.shakeTween:Kill()
    end
    self.shakeRoot.transform.localRotation = Quaternion.identity

    -- self.shakeTween = self.shakeRoot.transform:DOShakeRotation(duration, vec, 10, 90, true)
    self.shakeTween = self.shakeRoot.transform:DOPunchRotation(_ShakeVec, _duration, _Vibrato, 1)
end

function OrderTaskItem:GetSpecialRewardPos()
    return self.img_specialIcon.gameObject:GetPosition()
end

function OrderTaskItem:InitSpine(callback)
    local assetsPath = "Prefab/UI/OrderTask/spine/OrderTaskItem.prefab"
    self.img_spine:SetActive(true)
    self.img_spine.transform:ClearAllChildren()
    local go = BResource.InstantiateFromAssetName(assetsPath)
    if Runtime.CSNull(go) then
        console.print(nil, "Missing spine Prefab:", assetsPath)
        Runtime.InvokeCbk(callback)
        return
    end
    go:SetParent(self.img_spine, false)
    self.spine_select = find_component(go, 'select', SkeletonGraphic)
    self.spine_normal = find_component(go, 'normal', SkeletonGraphic)
    local isSel = self.parentPanel.SelectPosition == self.order.position
    self:SetSpineColor(isSel)
    Runtime.InvokeCbk(callback)
end

function OrderTaskItem:PlayItemSpineAnim(triggerName, callback)
    local function afterInitSpine()
        GameUtil.PlaySpineAnimation(
            self.spine_select.gameObject,
            triggerName,
            false,
            function()
                self.spine_select = nil
                self.spine_normal = nil
                if Runtime.CSValid(self.img_spine) then
                    self.img_spine.transform:ClearAllChildren()
                    self.img_spine:SetActive(false)
                end
                Runtime.InvokeCbk(callback)
            end
        )
        GameUtil.PlaySpineAnimation(
        self.spine_normal.gameObject,
        triggerName,
        false,
        nil
        )
    end
    self:InitSpine(afterInitSpine)
end

function OrderTaskItem:GetRewardFlyObj()
    local scene = App:getRunningLuaScene()
    local ret = {}
    if scene then
        for k, v in pairs(self.rewardFlyObj) do
            ret[k] = GameObject.Instantiate(v, scene.canvas.transform)
            ret[k].transform.position = v.transform.position
            ret[k]:SetActive(false)
        end
    end
    return ret
end

function OrderTaskItem:RewardMatchSpine()
    GameUtil.DoFade(self.go_awards, 0, 0.1)
    self:SetComponentVisible(self.img_normal, false)
    self:SetComponentVisible(self.img_special, false)
    self:SetComponentVisible(self.img_special_select, false)
    self:SetComponentVisible(self.img_selected, false)
    self:SetComponentVisible(self.img_done, false)
    self:SetComponentVisible(self.img_specialIcon, false)
    self:SetComponentVisible(self.img_ads, false)
    self:SetComponentVisible(self.img_ads_select, false)
    self.timerId1 = WaitExtension.SetTimeout(
    function ()
        self.timerId1 = nil
        self:SetComponentVisible(self.go_awards, true)
        GameUtil.DoFade(self.go_awards, 1, 0.1)
    end, 0.8)
end

function OrderTaskItem:RewardMatchSpineEnd()
    local orderMgr = AppServices.OrderTask
    local isSpecial = orderMgr.isDifficultyOrder(self.order.orderType)
    local isSel = self.parentPanel.SelectPosition == self.order.position
    local isAds = orderMgr.IsAbs(self.order)
    local isNormal = not isAds and not isSpecial
    local isDone = orderMgr:IsDone(self.order)
    self:SetComponentVisible(self.img_normal, not isSel and isNormal)
    self:SetComponentVisible(self.img_special, not isSel and isSpecial)
    self:SetComponentVisible(self.img_special_select, isSel and isSpecial)
    self:SetComponentVisible(self.img_specialIcon, isSpecial)
    self:SetComponentVisible(self.img_selected, isSel and isNormal)
    self:SetComponentVisible(self.img_ads, not isSel and isAds)
    self:SetComponentVisible(self.img_ads_select, isSel and isAds)
    self:SetComponentVisible(self.img_done, isDone)
    self:SetComponentVisible(self.spine_select, false)
    self:SetComponentVisible(self.spine_normal, false)
end

function OrderTaskItem:Destory()
    if self.timerId1 then
        WaitExtension.CancelTimeout(self.timerId1)
        self.finishTimerId = nil
    end
end

return OrderTaskItem
