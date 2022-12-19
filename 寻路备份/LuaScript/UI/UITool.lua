UITool = {}

function UITool.ShowMessage(
    title,
    desc,
    label_ok,
    label_cancel,
    okCallback,
    cancelCallback,
    showOk,
    showCancel,
    okColor,
    okDelay,
    hideCloseBtn)
    PanelManager.showPanel(
        GlobalPanelEnum.OkCancelPanel,
        {
            title = title,
            desc = desc,
            label_ok = label_ok,
            label_cancel = label_cancel,
            showOk = showOk,
            showCancel = showCancel,
            okCallback = okCallback,
            cancelCallback = cancelCallback,
            okColor = okColor,
            okDelay = okDelay,
            hideCloseBtn = hideCloseBtn
        }
    )
end

---只有一个按钮的消息框
---@param title string 标题 默认 ''
---@param desc string 显示内容
---@param label_ok string 确认按钮标题文字 默认 ui_common_ok
---@param callback function 确认按钮回调函数
function UITool.ShowMessageBoxSingle(title, desc, label_ok, callback, okColor, okDelay, hideCloseBtn)
    UITool.ShowMessage(title, desc, label_ok, nil, callback, nil, true, false, okColor, okDelay, hideCloseBtn)
end

---只有一个按钮的消息框
---@param title string 标题 默认 ''
---@param desc string 显示内容
---@param label_ok string 确认按钮标题文字 默认 ui_common_ok
---@param callback function 确认按钮回调函数
---@param closeCallback function 关闭按钮回调
function UITool.ShowMessageBoxSingleEx(title, desc, label_ok, callback, closeCallback, okColor)
    UITool.ShowMessage(title, desc, label_ok, nil, callback, closeCallback, true, false, okColor)
end

---两个按钮的消息框
---@param title string 标题 默认 ''
---@param desc string 显示内容
---@param label_ok string 确认按钮标题文字 默认 ui_common_ok
---@param label_cancel string 取消按钮标题文字 默认 idleaccelerate_cancel
---@param okCallback function 确认按钮回调函数
---@param cancelCallback function 取消按钮回调函数, 点击关闭也会调用!!
function UITool.ShowMessageBox(title, desc, label_ok, label_cancel, okCallback, cancelCallback, okColor)
    UITool.ShowMessage(title, desc, label_ok, label_cancel, okCallback, cancelCallback, true, true, okColor)
end

function UITool.ShowMessageBoxTime(title, desc, label_ok, label_cancel, okCallback, cancelCallback, endTime, endTimeStr, timeColor)
    PanelManager.showPanel(
        GlobalPanelEnum.OkCancelPanel,
        {
            title = title,
            desc = desc,
            label_ok = label_ok,
            label_cancel = label_cancel,
            showOk = true,
            showCancel = true,
            okCallback = okCallback,
            cancelCallback = cancelCallback,
            okColor = nil,
            okDelay = nil,
            hideCloseBtn = false,
            endTime = endTime,
            endTimeStr = endTimeStr,
            timeColor = timeColor,
            useShort = true,
        }
    )
end

---带图片的弹窗
function UITool.ShowConfirmTip(tittle, content, ok, cancel, sprName, onConfirm, onCancel)
    local info = {
        tittle = tittle,
        content = content,
        ok = ok,
        cancel = cancel,
        sprite = sprName,
        onConfirm = onConfirm,
        onCancel = onCancel
    }
    PanelManager.showPanel(GlobalPanelEnum.ConfirmPanel, info)
end

function UITool.TryToFinishGuide(guideID)
    local mapGuideManager = App.mapGuideManager
    if mapGuideManager then
        local curGuide = mapGuideManager:GetCurrentGuide()
        if curGuide and curGuide.id == guideID then
            mapGuideManager:FinishCurrentGuide()
        end
    end
end

function UITool.ShowPropsAniList(list, from)
    for id, count in pairs(list) do
        UITool.ShowPropsAni(id, count, from)
    end
end

local cleanEffectPaths = {
    ["Shovel"] = "Prefab/ScreenPlays/DragonEffect/E_clear_grass.prefab",
    ["Hatchet"] = "Prefab/ScreenPlays/DragonEffect/E_clear_tree.prefab",
    ["Pickaxe"] = "Prefab/ScreenPlays/DragonEffect/E_clear_stone.prefab"
}

---显示地图清除奖励动画(专用) 角色用工具清除时用的奖励动画
function UITool.ShowMapConsumeRewardEx(rewardLis, from, toolName, onFinish)
    if not rewardLis or #rewardLis <= 0 then
        return Runtime.InvokeCbk(onFinish)
    end
    local str = cleanEffectPaths[toolName] or "Prefab/ScreenPlays/E_clear_common.prefab"
    local function onLoadFinish()
        local smoke = BResource.InstantiateFromAssetName(str)
        smoke.transform.position = from or Vector3(0, 0, 0)
        smoke.transform.localScale = Vector3(1, 1, 1)
        Runtime.CSDestroy(smoke, 2)
    end
    local list = StringList()
    list:AddItem(str)
    AssetLoaderUtil.LoadAssets(list, onLoadFinish)
    local downAssetPath = "Prefab/UI/Common/Buildin/FlyCleanProps/CleanPropDownCurve.asset"
    local upAssetPath = "Prefab/UI/Common/Buildin/FlyCleanProps/CleanPropUpCurve.asset"
    local function onLoaded()
        local upCurve = App.uiAssetsManager:GetAsset(downAssetPath)
        local downCurve = App.uiAssetsManager:GetAsset(downAssetPath)
        UITool.ShowCleanPropsAni(rewardLis, from, upCurve.curve, downCurve.curve, nil, nil, nil, onFinish)
    end
    App.uiAssetsManager:LoadAssets({downAssetPath, upAssetPath}, onLoaded)
end

---@param itemSize number 图标大小,默认80
function UITool.ShowCleanPropsAni(rewardLis, from, upCurve, downCurve, itemSize, dropRadius, onEachItemReach, onFinish, targetShowEnterAnim)
    if targetShowEnterAnim == nil then
        targetShowEnterAnim = true
    end
    local totalShowCnt = 0
    local widgetPos = {}
    local itemLerp = {} --不同奖励道具在总奖励中起始序号
    local widgets = {}
    for _, v in pairs(rewardLis) do
        local id = v.itemTemplateId
        local widgetType = ItemId.GetWidgetType(id)
        local widget = App.scene:GetWidget(widgetType)
        if widget then
            widgets[id] = widget
            itemLerp[id] = totalShowCnt + 1
            if id == ItemId.ENERGY then
                totalShowCnt = totalShowCnt + 5
            else
                totalShowCnt = totalShowCnt + math.min(10, v.count)
            end
            if targetShowEnterAnim then
                widget:SetInteractable(false)
            end
            if widget.GetInsideWorldPosition then
                widgetPos[id] = widget:GetInsideWorldPosition()
            end
            if not widgetPos[id] then
                widgetPos[id] = widget:GetMainIconGameObject().transform.position
            end
        end
    end
    if not dropRadius then
        dropRadius = Vector2(math.min(1.2, 0.6 + (totalShowCnt - 4) * 0.1), 1.2)
    end
    local parent = App.scene.canvas.transform
    local propsPool = AppServices.PoolManage:GetPool("FlyProps")
    local baseItems = table.deserialize(AppServices.Meta.metas.ConfigTemplate["BasicSuppliesNoEffects"].value)
    local totalFly = table.count(widgetPos)
    local curFly = 0
    local function onFlyDone()
        curFly = curFly + 1
        if curFly >= totalFly then
            Runtime.InvokeCbk(onFinish)
        end
    end
    for _, v in pairs(rewardLis) do
        local id = v.itemTemplateId
        if widgetPos[id] then
            local count = v.count
            local effectiveCount = ItemId.GetEffectiveCount(id, count)
            itemSize = itemSize or 80
            local defaultMaxFly = 10
            local flyCount = math.min(defaultMaxFly, count)

            local cellCount = math.floor(effectiveCount / flyCount)
            local cellCountLis = {}
            for i = 1, flyCount - 1 do
                cellCountLis[i] = cellCount
            end
            cellCountLis[flyCount] = effectiveCount - cellCount * (flyCount - 1)
            local vt2s, _, vt2_wPos =
                GameUtil.RotateVectorWithAvgAngle(
                from,
                widgetPos[id],
                count,
                itemLerp[id],
                dropRadius,
                totalShowCnt,
                parent
            )

            if id == ItemId.ENERGY then
                flyCount = 5
                cellCountLis = {0,0,0,0,count}
                vt2s, _, vt2_wPos = GameUtil.RotateVectorWithAvgAngle(
                    from,
                    widgetPos[id],
                    5,
                    itemLerp[id],
                    dropRadius,
                    totalShowCnt,
                    parent
                )
            end

            local type = AppServices.Meta:GetItemMeta(id).type
            local isBaseItem = table.exists(baseItems, type)
            for i = 1, flyCount do
                local item = propsPool:GetEntity()
                item.img = item.gameObject:GetComponent(typeof(Image))
                item.img.sprite = AppServices.ItemIcons:GetSprite(id)
                item.img:SetNativeSize()
                item.img.color = Color.white
                item.effect = find_component(item.gameObject, "effect")
                item.effect:SetActive(not isBaseItem)
                local trans = item.transform
                trans:SetParent(parent, false)
                item.img:DOFade(0, 0)
                item.gameObject:SetActive(true)
                local size = trans.sizeDelta
                local ratio = size.x / size.y
                trans.sizeDelta = Vector2(ratio * itemSize, itemSize)
                local sPos = vt2s[i - 1]
                trans.anchoredPosition = sPos
                local num = math.random(8, 12) * 0.1
                local height = 70
                local t = 0.15
                local sequence = DOTween.Sequence()
                local interval
                if totalShowCnt <= 4 then
                    interval = (i == 2) and 0.3 or (i == 3 and 0.2 or i * 0.1)
                else
                    interval = math.random(1, flyCount) * 0.05
                end
                sequence:AppendInterval(interval)
                sequence:Append(item.img:DOFade(1, 0))
                sequence:Append(
                    GameUtil.DoAnchorPosY(trans, sPos.y + height * num, t * num):SetEase(upCurve or Ease.OutQuart)
                )
                sequence:Insert(num * 0.1, trans:DOScale(1, 0):SetEase(Ease.OutBack))
                sequence:Append(GameUtil.DoAnchorPosY(trans, sPos.y, t * num):SetEase(downCurve or Ease.InQuart))
                sequence:Append(
                    GameUtil.DoAnchorPosY(trans, sPos.y + height * 0.5 * num, 0.1):SetEase(upCurve or Ease.OutQuart)
                )
                sequence:Append(GameUtil.DoAnchorPosY(trans, sPos.y, 0.1):SetEase(downCurve or Ease.InQuart))
                sequence:Append(trans:DOScale(1.4, 0.1))
                sequence:Append(trans:DOAnchorPos(vt2_wPos, 0.4):SetEase(Ease.InQuart))
                sequence:Append(trans:DOScale(0.4, 0.2))
                sequence:Join(item.img:DOFade(0, 0.2))
                sequence:AppendCallback(
                    function()
                        trans.localScale = Vector3.zero
                        propsPool:RecycleEntity(item, {"parent"})
                        local widget = widgets[id]
                        if widget and not widget:IsDisposed() then
                            local cur = widget.GetValue and widget:GetValue() or 0
                            if widget.SetValue then
                                widget:SetValue(cellCountLis[i] + cur)
                            end
                            if widget.OnHit then
                                widget:OnHit()
                            end

                            if onEachItemReach then
                                onEachItemReach(id, cellCountLis[i])
                            end
                            if targetShowEnterAnim then
                                widget:SetInteractable(true)
                            end
                        else
                            console.warn(nil, "item widget is nil: ", id) --@DEL
                        end
                    end
                )
                if i == flyCount and onFinish then
                    sequence:AppendCallback(
                        function()
                            Runtime.InvokeCbk(onFlyDone)
                        end
                    )
                end
                sequence:SetRecyclable(true)
                sequence:Play()
            end
        end
    end

    if totalFly == 0 then
        Runtime.InvokeCbk(onFinish)
    end
end

---显示地图清除奖励动画
function UITool.ShowMapConsumeReward(rewardLis, pos, onFinish, rate)
    if rewardLis and #rewardLis > 0 then
        local function onLoadFinish()
            local smoke = BResource.InstantiateFromAssetName("Prefab/ScreenPlays/E_clear_common.prefab")
            smoke.transform.position = pos or Vector3(0, 0, 0)
            smoke.transform.localScale = Vector3(1, 1, 1)
            Runtime.CSDestroy(smoke, 2)
        end
        local list = StringList()
        list:AddItem("Prefab/ScreenPlays/E_clear_common.prefab")
        AssetLoaderUtil.LoadAssets(list, onLoadFinish)
        for _, v in pairs(rewardLis) do
            local size = nil
            local effectType = 1
            local tempRate = rate or 1
            if ItemId.IsDiscountProp(v.itemTemplateId) then
                if App.scene and App.scene:GetSceneType() == SceneType.Exploit then
                    size = 50
                    v.count = 1
                    tempRate = 1
                    if v.itemTemplateId == ItemId.Buff2Collect then
                        effectType = 2
                    elseif v.itemTemplateId == ItemId.Buff2Drop then
                        effectType = 3
                    end
                else
                    goto continue
                end
            end

            UITool.ShowPropsAni(v.itemTemplateId, v.count, pos, onFinish, nil, size, nil, nil, tempRate, effectType)
            ::continue::
        end
    else
        Runtime.InvokeCbk(onFinish)
    end
end

--每一个道具动画之间有interval 用于宝箱奖励
function UITool.ShowCleanBoxReward(rewardLis, pos, onFinish)
    if rewardLis and #rewardLis > 0 then
        local function onLoadFinish()
            local smoke = BResource.InstantiateFromAssetName("Prefab/ScreenPlays/E_clear_common.prefab")
            smoke.transform.position = pos or Vector3(0, 0, 0)
            smoke.transform.localScale = Vector3(1, 1, 1)
            Runtime.CSDestroy(smoke, 2)
        end
        local list = StringList()
        list:AddItem("Prefab/ScreenPlays/E_clear_common.prefab")
        AssetLoaderUtil.LoadAssets(list, onLoadFinish)
        local value = AppServices.Meta:GetConfigMetaValue("boxDropInterval")
        local interval = tonumber(value)
        for _, v in pairs(rewardLis) do
            if not ItemId.IsDiscountProp(v.itemTemplateId) then
                UITool.ShowPropsAni(v.itemTemplateId, v.count, pos, onFinish, nil, nil, interval)
            end
        end
    else
        Runtime.InvokeCbk(onFinish)
    end
end

---通用奖励道具动画
---@param id string 奖励item id
---@param count number 奖励item 的数量
---@param from Vector3 奖励的起始位置,为世界坐标
---@param onFinish function 所有item动画完成后的回调
---@param onEachItemReach function 每个item到达目标后的回调
---@param itemSize number 图标大小,默认80
---@param interval number 下一个与上一个item出现的间隔时间
-- local dropRadius
local aniInfo = {isSeries = false, lastCount = 0, delay = 0}
function UITool.ShowPropsAni(
    id,
    count,
    from,
    onFinish,
    onEachItemReach,
    itemSize,
    interval,
    dropRadius,
    rate,
    effectType,
    endPos)
    if count <= 0 then
        return
    end

    rate = rate or 0
    if rate > 1 then
        count = count // rate
    end
    if not dropRadius then
        dropRadius = AppServices.Meta:GetDropAniRadius()
    end
    local effectiveCount = ItemId.GetEffectiveCount(id, count)

    interval = interval or 0
    if not aniInfo.isSeries then
        aniInfo.isSeries = true
        aniInfo.lastCount = math.min(10, count)
        WaitExtension.SetTimeout(
            function()
                aniInfo.isSeries = false
                aniInfo.delay = 0
                aniInfo.lastCount = 0
            end,
            0.05
        )
    else
        aniInfo.delay = aniInfo.delay + interval * aniInfo.lastCount
        aniInfo.lastCount = math.min(10, count)
    end

    local propsPool = AppServices.PoolManage:GetPool("FlyProps")
    local lis = {}
    --TODO 这里以后改成从缓冲池获得, 不要放在这里实例化
    -- local itemGo = BResource.InstantiateFromAssetName(CONST.ASSETS.G_REWARD_PROPS_FLY_ITEM)
    -- if Runtime.CSNull(itemGo) then
    --     return
    -- end
    -- local img = itemGo:GetComponent(typeof(Image))
    -- img.sprite = AppServices.ItemIcons:GetSprite(id)
    -- img:SetNativeSize()
    local widgetType = ItemId.GetWidgetType(id)
    local widget = App.scene:GetWidget(widgetType)
    local weightPos
    if not widget then
        if endPos then
            weightPos = endPos
        else
            return
        end
    else
        if widget.SetInteractable then
            widget:SetInteractable(false)
        end
        if widget.ShowForFly then
            widget:ShowForFly()
        end
        if widget.GetInsideWorldPosition then
            weightPos = widget:GetInsideWorldPosition()
        end
        if not weightPos then
            weightPos = widget:GetMainIconGameObject().transform.position
        end
        weightPos = weightPos
    end
    local parent = App.scene.flyPropsLayer.transform
    local vt3s, tpos, epos = GameUtil.RotateVectorWithRandomAngle(from, weightPos, count, parent, dropRadius)
    itemSize = itemSize or 80
    local flyCount = math.min(10, count)
    local type = AppServices.Meta:GetItemMeta(id).type
    local baseItems = table.deserialize(AppServices.Meta.metas.ConfigTemplate["BasicSuppliesNoEffects"].value)
    local isBaseItem = table.exists(baseItems, type)
    for i = 1, flyCount do
        local item = propsPool:GetEntity()
        item.img = item.gameObject:GetComponent(typeof(Image))
        item.img.sprite = AppServices.ItemIcons:GetSprite(id)
        item.img:SetNativeSize()
        item.img.color = Color.white
        item.txt = find_component(item.gameObject, "txt_Rate", Text)
        if rate > 1 then
            item.txt.text = string.format("x%d", rate)
            item.txt.gameObject:SetActive(true)
        end
        effectType = effectType or 1
        local effectList = {}
        table.insert(effectList, find_component(item.gameObject, "effect"))
        table.insert(effectList, find_component(item.gameObject, "lan"))
        table.insert(effectList, find_component(item.gameObject, "huang"))

        for index, effect in ipairs(effectList) do
            if index == effectType then
                item.effect = effect
            else
                effect:SetActive(false)
            end
        end
        item.effect:SetActive(not isBaseItem)
        local size = item.transform.sizeDelta
        local ratio = size.x / size.y
        item.transform.sizeDelta = Vector2(ratio * itemSize, itemSize)
        lis[#lis + 1] = item
    end
    local cellCount = math.floor(effectiveCount / flyCount)
    local cellCountLis = {}
    for i = 1, flyCount - 1 do
        cellCountLis[i] = cellCount
    end
    cellCountLis[flyCount] = effectiveCount - cellCount * (flyCount - 1)
    local bezier = require("System.Core.BezierCurve")
    for i = 1, flyCount do
        local target = lis[i].transform
        target:SetParent(parent, false)
        target.anchoredPosition = tpos
        lis[i].gameObject:SetActive(true)
        local vt = vt3s[i - 1]
        local points = Vector3List()
        local conp = (tpos + vt) / 2
        conp.y = conp.y + math.random(70, 250)
        conp = Vector3(conp.x, conp.y, 0)
        for t = 1, 8 do
            local p = bezier.SecondOrder(Vector3(tpos.x, tpos.y, 0), conp, Vector3(vt.x, vt.y, 0), t / 8)
            points:AddItem(p)
        end
        local off = (vt - tpos).normalized.x * 10
        vt.x = vt.x + off
        local sequence = DOTween.Sequence()
        sequence:AppendInterval(aniInfo.delay + interval * (i - 1))
        sequence:Append(BPath.DoLocalPath(target, points, 0.4, Ease.Linear))
        sequence:Join(target:DOScale(1, 0):SetEase(Ease.OutBack))
        sequence:Append(target:DOJumpAnchorPos(vt, 40, 1, 0.3):SetEase(Ease.OutSine))
        sequence:Append(target:DOScale(1.4, 0.2))
        sequence:Append(target:DOAnchorPos(epos, 0.8):SetEase(Ease.InCubic))
        sequence:Append(target:DOScale(0.4, 0.2))
        sequence:Join(lis[i].img:DOFade(0, 0.2))
        sequence:AppendCallback(
            function()
                lis[i].transform.localScale = Vector3.zero
                lis[i].txt.gameObject:SetActive(false)
                lis[i].effect:SetActive(false)
                propsPool:RecycleEntity(lis[i], {"parent"})
                if widget and not widget:IsDisposed() then
                    local cur = widget.GetValue and widget:GetValue() or 0
                    if widget.OnHit then
                        widget:OnHit()
                    end
                    local resultRate = rate > 1 and rate or 1
                    widget:SetValue(cellCountLis[i]*resultRate + cur)
                    if onEachItemReach then
                        onEachItemReach(id, cellCountLis[i])
                    end
                    if widget.SetInteractable then
                        widget:SetInteractable(true)
                    end
                end
            end
        )
        if i == flyCount and (onFinish or (widget and widget.HideForFly)) then
            sequence:AppendCallback(
                function()
                    if widget and not widget:IsDisposed() and widget.HideForFly then
                        widget:HideForFly()
                    end
                    Runtime.InvokeCbk(onFinish, id, count)
                end
            )
        end
        sequence:SetRecyclable(true)
        sequence:Play()
    end
end

---通用飞道具数量动画
---@param id string 奖励item id
---@param count number 奖励item 的数量
---@param from Vector3 奖励的起始位置,为世界坐标
---@param onFinish function 动画完成后的回调
---@param itemSize number item图标大小
function UITool.ShowPropsAniWithCount(idOrSpr, count, from, onFinish, itemSize, prefixContent)
    if not idOrSpr then
        return
    end
    local itemGo = BResource.InstantiateFromAssetName(CONST.ASSETS.G_REWARD_PROPS_FLY_ITEM)
    if Runtime.CSNull(itemGo) then
        return
    end
    local parent = App.scene.canvas.transform
    itemGo:SetParent(parent, false)
    local img = itemGo:GetComponent(typeof(Image))
    if type(idOrSpr) ~= "string" then
        img.sprite = idOrSpr
    else
        img.sprite = AppServices.ItemIcons:GetSprite(idOrSpr)
    end
    local txt = find_component(itemGo, "txt_Count", Text)
    txt.text = string.format("+%d", count)
    txt.gameObject:SetActive(true)
    local preTxt = nil
    if prefixContent then
        preTxt = find_component(itemGo, "txt_Prefix", Text)
        preTxt.text = prefixContent
        preTxt.gameObject:SetActive(true)
    end
    img:SetNativeSize()
    local trans = itemGo.transform
    local startPos = GameUtil.WorldToUISpace(parent, from)
    startPos = Vector2(startPos.x, startPos.y)
    trans.anchoredPosition = startPos
    local size = trans.sizeDelta
    local ratio = size.x / size.y
    itemSize = itemSize or 40
    trans.sizeDelta = Vector2(ratio * itemSize, itemSize)
    local sequence = DOTween.Sequence()
    sequence:SetRecyclable(true)
    sequence:Append(trans:DOAnchorPosY(startPos.y + 80, 1.5):SetEase(Ease.Linear))
    sequence:Join(trans:DOScale(1, 0.4):SetEase(Ease.OutBack))
    sequence:Insert(1.1, img:DOFade(0, 0.4))
    sequence:Insert(1.1, txt:DOFade(0, 0.4))
    if preTxt then
        sequence:Insert(1.1, preTxt:DOFade(0, 0.4))
    end
    if onFinish then
        sequence:AppendCallback(onFinish)
    end
    sequence:AppendCallback(
        function()
            Runtime.CSDestroy(itemGo)
        end
    )
    itemGo:SetActive(true)
    sequence:Play()
end

---通用飞道具带Buff数量动画
---@param id string 奖励item id
---@param count number 奖励item 的数量
---@param from Vector3 奖励的起始位置,为世界坐标
---@param onFinish function 动画完成后的回调
---@param itemSize number item图标大小
function UITool.ShowPropsAniWithBuffCount(id, count, from, onFinish, itemSize)
    if not id then
        return
    end
    local itemGo = BResource.InstantiateFromAssetName(CONST.ASSETS.G_REWARD_PROPS_FLY_ITEM)
    if Runtime.CSNull(itemGo) then
        return
    end
    local parent = App.scene.canvas.transform
    itemGo:SetParent(parent, false)
    local img = itemGo:GetComponent(typeof(Image))
    img.sprite = AppServices.ItemIcons:GetSprite(id)
    local txt = find_component(itemGo, "txt_Rate", Text)
    txt.text = string.format("x%d", count)
    txt.gameObject:SetActive(true)
    img:SetNativeSize()
    local trans = itemGo.transform
    local startPos = GameUtil.WorldToUISpace(parent, from)
    startPos = Vector2(startPos.x, startPos.y)
    trans.anchoredPosition = startPos
    local size = trans.sizeDelta
    local ratio = size.x / size.y
    itemSize = itemSize or 40
    trans.sizeDelta = Vector2(ratio * itemSize, itemSize)
    local sequence = DOTween.Sequence()
    sequence:SetRecyclable(true)
    sequence:Append(trans:DOAnchorPosY(startPos.y + 80, 1.5):SetEase(Ease.Linear))
    sequence:Join(trans:DOScale(1, 0.4):SetEase(Ease.OutBack))
    sequence:Insert(1.1, img:DOFade(0, 0.4))
    sequence:Insert(1.1, txt:DOFade(0, 0.4))
    if onFinish then
        sequence:AppendCallback(onFinish)
    end
    sequence:AppendCallback(
        function()
            Runtime.CSDestroy(itemGo)
        end
    )
    itemGo:SetActive(true)
    sequence:Play()
end

---通用文字提示动画
local txtTweenInfo = nil
---@param content string 文本信息
---@param from Vector3 起始位置，世界坐标，nil时为屏幕中心
---@param txtSize number 文字框大小 默认30
---@param iconSize Vector2 icon 大小
function UITool.ShowContentTipAni(content, from, itemSize, iconSize, z, idleTime)
    z = z or 0
    if not content then
        return
    end
    local function FitScreen(text, pos, trans)
        local width = GameUtil.FitTextContentSize(text)
        width = math.min(Screen.width - 100, width)
        local size = text.transform.sizeDelta
        size.x = width
        text.transform.sizeDelta = size
        local min = GameUtil.ScreenToUISpace(trans, Vector2.zero).x + width / 2
        local max = GameUtil.ScreenToUISpace(trans, Vector2(Screen.width, 0)).x - width / 2
        if pos.x < min then
            pos.x = min
        elseif pos.x > max then
            pos.x = max
        end
        return pos
    end
    local function onLoaded()
        local parent = App.scene.canvas.transform
        local pos = Vector3.zero
        if from then
            pos = GameUtil.WorldToUISpace(parent, from)
            pos = Vector3(pos.x, pos.y, 0)
        end
        pos.z = z
        -- itemSize = itemSize or 20
        -- itemSize = math.min(itemSize, 30)
        itemSize = itemSize or 28
        -- itemSize = math.max(10, itemSize)
        if txtTweenInfo then
            txtTweenInfo.txt.text = content
            txtTweenInfo.txt.fontSize = itemSize
            txtTweenInfo.sequence:Rewind()
            txtTweenInfo.sequence:Play()
            pos = FitScreen(txtTweenInfo.txt, pos, parent)
            txtTweenInfo.tweener:ChangeValues(pos, Vector3(pos.x, pos.y + 100, pos.z))
            return
        end
        local itemGo = BResource.InstantiateFromAssetName(CONST.ASSETS.G_REWARD_PROPS_FLY_TEXT)
        itemGo:SetActive(true)
        itemGo:SetParent(parent, false)
        local trans = itemGo.transform
        local txt = find_component(itemGo, "", Text)
        txt.text = content
        txt.fontSize = itemSize
        pos = FitScreen(txt, pos, parent)
        trans.anchoredPosition3D = pos
        pos.y = pos.y + 100
        idleTime = idleTime or 1.2
        local FadeStart = 0.3
        local FadeEnd = 0.3
        local tweener = trans:DOAnchorPos3D(pos, idleTime + FadeEnd):SetEase(Ease.Linear)
        local sequence = DOTween.Sequence()
        sequence:Insert(0, trans:DOScale(1, FadeStart):SetEase(Ease.OutBack))
        sequence:Insert(0, txt.material:DOFade(1, 0.2))
        sequence:Insert(idleTime, txt.material:DOFade(0, FadeEnd))
        sequence:AppendCallback(
            function()
                txtTweenInfo = nil
                if Runtime.CSValid(itemGo) then
                    Runtime.CSDestroy(itemGo)
                end
            end
        )
        sequence:Play()
        txtTweenInfo = {sequence = sequence, tweener = tweener, txt = txt, trans = trans, go = itemGo}
    end

    if txtTweenInfo and Runtime.CSNull(txtTweenInfo.go) then
        onLoaded()
    else
        App.uiAssetsManager:LoadAssets({CONST.ASSETS.G_REWARD_PROPS_FLY_TEXT}, onLoaded)
    end
end

---通用文字加icon的提示动画
---@param icon sprite
---@param content string 文本信息
---@param from Vector3 起始位置，世界坐标，nil时为屏幕中心
---@param txtSize number 文字框大小 默认30
---@param iconSize Vector2 icon大小
function UITool.ShowContentTipAniWithIcon(spr, content, from, txtSize, iconSize, z)
    z = z or 0
    txtSize = txtSize or 28
    if not content or not spr then
        return
    end
    local function FitScreen(text, pos, trans)
        local width = GameUtil.FitTextContentSize(text)
        width = math.min(Screen.width - 400, width)
        local size = text.transform.sizeDelta
        size.x = width
        text.transform.sizeDelta = size
        local min = GameUtil.ScreenToUISpace(trans, Vector2.zero).x + width / 2
        local max = GameUtil.ScreenToUISpace(trans, Vector2(Screen.width, 0)).x - width / 2
        if pos.x < min then
            pos.x = min
        elseif pos.x > max then
            pos.x = max
        end
        return pos
    end
    local function onLoaded()
        local parent = App.scene.canvas.transform
        local pos = Vector3.zero
        if from then
            pos = GameUtil.WorldToUISpace(parent, from)
            pos = Vector3(pos.x, pos.y, 0)
        end
        pos.z = z
        local itemGo = BResource.InstantiateFromAssetName(CONST.ASSETS.G_REWARD_PROPS_FLY_TEXT_WITH_ICON)
        itemGo:SetActive(true)
        itemGo:SetParent(parent, false)
        local trans = itemGo.transform
        local txt = find_component(itemGo, "", Text)
        local icon = find_component(itemGo, "icon", Image)
        local canvasGroup = find_component(itemGo, "", CanvasGroup)
        txt.text = content
        txt.fontSize = txtSize
        UITool.AdaptImage(icon, spr, (iconSize or Vector2(30, 30)).x)
        pos = FitScreen(txt, pos, parent)
        trans.anchoredPosition3D = pos
        pos.y = pos.y + 100
        trans:DOAnchorPos3D(pos, 1.5):SetEase(Ease.Linear)
        local sequence = DOTween.Sequence()
        sequence:Insert(0, trans:DOScale(1, 0.3):SetEase(Ease.OutBack))
        sequence:Insert(0, canvasGroup:DOFade(1, 0.2))
        sequence:Insert(1.2, canvasGroup:DOFade(0, 0.3))
        sequence:AppendCallback(
            function()
                if Runtime.CSValid(itemGo) then
                    Runtime.CSDestroy(itemGo)
                end
            end
        )
        sequence:Play()
    end
    App.uiAssetsManager:LoadAssets({CONST.ASSETS.G_REWARD_PROPS_FLY_TEXT_WITH_ICON}, onLoaded)
end

---datas 数据格式 {{ItemId = "", Amount = 1},....}
function UITool.ShowRewardWithCount(pos, datas, callback, size, color)
    local function getItem()
        local parent = App.scene.canvas.transform
        local go = BResource.InstantiateFromAssetName("Prefab/UI/Common/fly_tween_item.prefab")
        go:SetParent(parent, false)
        local template = find_component(go, "icon")
        local itm = {}
        itm.gameObject = go
        itm.transform = go.transform
        itm.canvasGroup = find_component(go, "", CanvasGroup)
        itm.getIcon = function()
            local iconGo = BResource.InstantiateFromGO(template)
            iconGo:SetParent(go, false)
            local img = find_component(iconGo, "", Image)
            local txt = find_component(iconGo, "count", Text)
            return {gameObject = iconGo, img = img, txt = txt, trans = iconGo.transform}
        end
        return itm
    end

    if not datas or #datas == 0 then
        Runtime.InvokeCbk(callback)
        return
    end
    size = size or 100
    local tweenItem = getItem()
    local items = {}
    for k, v in ipairs(datas) do
        local itm = tweenItem.getIcon()
        itm.txt.text = string.format("x%d", v.Amount)
        if color then
            itm.txt.color = color
        end
        local spr = AppServices.ItemIcons:GetSprite(v.ItemId)
        UITool.AdaptImage(itm.img, spr, size)
        itm.gameObject:SetActive(true)
        itm.ItemId = v.ItemId
        items[k] = itm
    end
    local vt2 = GameUtil.WorldToUISpace(App.scene.canvas.transform, pos)
    tweenItem.transform.anchoredPosition = Vector2(vt2.x, vt2.y)
    local sequence = DOTween.Sequence()
    sequence:Append(tweenItem.canvasGroup:DOFade(1, 0.3))
    sequence:Join(tweenItem.transform:DOScale(1, 0.4):SetEase(Ease.OutBack))
    sequence:AppendInterval(0.3)
    sequence:Append(
        DOTween.To(
            function(val)
                for _, v in ipairs(items) do
                    if not Runtime.CSValid(v.txt) then
                        return
                    end
                    local col = v.txt.color
                    col.a = val
                    v.txt.color = col
                end
            end,
            1,
            0,
            0.2
        )
    )
    sequence:AppendCallback(
        function()
            for _, v in ipairs(items) do
                AppServices.RewardAnimation.FlyItem(
                    v.ItemId,
                    v,
                    function()
                        Runtime.CSDestroy(tweenItem.gameObject)
                    end,
                    nil,
                    0.3,
                    true,
                    Ease.InCubic,
                    Vector3.zero
                )
            end
            Runtime.InvokeCbk(callback)
        end
    )
    sequence:Play()
end

---@param data table rewards, title, desc, on_close, DcAcquisitionSource
function UITool.showReward(data)
    local rewards = {}
    for i, v in pairs(data.rewards) do
        local id, count = v.ItemId, v.Amount
        AppServices.User:AddItem(id, count, "UITool.showReward")
        if data.DcAcquisitionSource then
            DcDelegates.Legacy:LogAcquisition({itemId = id, num = count}, data.DcAcquisitionSource)
        end

        table.insert(rewards, {ItemId = id, Amount = count})
    end
    PanelManager.showPanel(
        GlobalPanelEnum.OpenRewardsPanel,
        {
            title = data.title,
            desc = data.desc,
            RewardItems = rewards
        },
        PanelCallbacks:Create(
            function()
                Util.BlockAll(1, "UITool.showReward")
                local scene = App:getRunningLuaScene()
                scene:HideAllTopIcons(true)
                App.scene.coinItem:ShowExitAnim(true)
                WaitExtension.SetTimeout(
                    function()
                        App.scene.coinItem.gameObject:SetActive(false)
                    end,
                    0.5
                )
                Runtime.InvokeCbk(data.on_close)
                WaitExtension.SetTimeout(
                    function()
                        Util.BlockAll(0, "UITool.showReward")
                    end,
                    1
                )
            end
        )
    )
end

function UITool.GetArrow(parent, callback, offset)
    ---@class arrow
    local arrow = {}
    arrow.Show = function()
        if Runtime.CSNull(arrow.go) then
            return
        end
        arrow.go:SetActive(true)
    end
    arrow.Hide = function()
        if Runtime.CSNull(arrow.go) then
            return
        end
        arrow.go:SetActive(false)
    end
    arrow.Dispose = function()
        if Runtime.CSNull(arrow.go) then
            return
        end
        Runtime.CSDestroy(arrow.go)
    end
    arrow.ResetPosition = function(newParent, newOffset)
        if Runtime.CSNull(arrow.go) then
            return
        end
        arrow.go.transform:SetParent(newParent, false)
        if newOffset then
            local pos = find_component(arrow.go, "pos").transform
            pos.localPosition = newOffset
        end
    end
    arrow.SetScale = function(scale)
        -- arrow.go
        if not Runtime.CSValid(arrow.go) then
            return
        end
        if scale == 1 then
            GameUtil.SetLocalScaleOne(arrow.go)
        else
            GameUtil.SetLocalScale(arrow.go, scale, scale, scale)
        end
    end
    UITool.CreateArrow(
        function(go)
            arrow.go = go
            callback(arrow)
        end,
        parent,
        offset
    )
end

function UITool.CreateArrow(callback, parent, offset)
    local assetPath = "Prefab/UI/BindingTip/arrow.prefab"
    local onLoaded = function()
        local arrowGo = BResource.InstantiateFromAssetName(assetPath)
        arrowGo.transform:SetParent(parent, false)
        local pos = find_component(arrowGo, "pos").transform
        if offset then
            pos.localPosition = offset
        end
        callback(arrowGo)
    end
    App.uiAssetsManager:LoadAssets({assetPath}, onLoaded)
end

---@param rewards dictionary<string, int>[] 内容是 ItemId='', Amount = 0
function UITool.ShowPropsAniByItemList(rewards, from)
    for k, v in ipairs(rewards) do
        local id = v.ItemId or v.itemTemplateId or v[1]
        local count = v.Amount or v.count or v[2]
        local widgetType = ItemId.GetWidgetType(id)
        local widget = App.scene:GetWidget(widgetType)
        local oldShow = not widget.isHided
        local showCallback = function(iconItem)
            local function flyFinishCallback()
                if not oldShow then
                    iconItem:ShowExitAnim()
                end
            end
            UITool.ShowPropsAni(id, count, from, flyFinishCallback)
        end
        if widget.isShowing then
            showCallback(widget)
        else
            App.scene:ControlMainUIIcon(widgetType, true, showCallback)
        end
    end
end

---通用道具小礼包内容展示 用的时候记得释放!!!!!!
------@param panel BasePanel
function UITool.ShowItemGiftTips(panel, items, parentGameObject, offsetHeight, noMask, assetPath)
    assetPath = assetPath or CONST.ASSETS.G_UI_COMMON_ITEMGFITTIP
    local function onLoaded()
        local key = "UI.Components.ItemGiftTip"
        local ItemGiftTip = panel:GetLuaChild(key)
        if not ItemGiftTip then
            ItemGiftTip = include(key).Create(panel, assetPath)
            panel:SetLuaChild(key, ItemGiftTip)
        end
        ItemGiftTip:SetData(items, parentGameObject, offsetHeight, noMask)
    end
    App.uiAssetsManager:LoadAssets({assetPath}, onLoaded)
end

---显示通用道具弹窗描述 用的时候记得释放!!!!!!
---@param panel BasePanel
---@param itemId string 道具ID
---@param parentGameObject GameObject 用来确定位置的GameObject
---@param offsetHeight float 纵向偏移量
function UITool.ShowItemDescTip(panel, itemId, parentGameObject, offsetHeight)
    local metaMgr = AppServices.Meta
    local title = metaMgr:GetItemName(itemId)
    local desc = Runtime.Translate(metaMgr:GetItemDesc(itemId))
    UITool.ShowDescriptionTip(panel, {title, desc}, parentGameObject, offsetHeight)
end

---显示通用道具弹窗描述 用的时候记得释放!!!!!!
---@param panel BasePanel
---@param descs string[] 翻译好的文本数组
---@param parentGameObject GameObject 用来确定位置的GameObject
---@param offsetHeight float 纵向偏移量
function UITool.ShowDescriptionTip(panel, descs, parentGameObject, offsetHeight)
    local function onLoaded()
        local key = "UI.Components.DescriptionTip"
        local DescriptionTip = panel:GetLuaChild(key)
        if not DescriptionTip then
            DescriptionTip = include(key).Create(panel)
            panel:SetLuaChild(key, DescriptionTip)
        end
        DescriptionTip:SetData(descs, parentGameObject, offsetHeight)
    end
    App.uiAssetsManager:LoadAssets({CONST.ASSETS.G_UI_COMMON_DESCRIPTIONTIP}, onLoaded)
end

---显示建筑修复tip 用的时候记得释放
---
---
function UITool.ShowBuildingTaskTip(panel, sceneId, agentId, templateId, level, parentGameObject, offsetHeight, align)
    local function onLoaded()
        local key = "UI.Task.View.UI.BuildingTaskTip"
        ---@type BuildingTaskTip
        local BuildingTaskTip = panel:GetLuaChild(key)
        if not BuildingTaskTip then
            BuildingTaskTip = require(key).Create(panel)
            panel:SetLuaChild(key, BuildingTaskTip)
        end
        BuildingTaskTip:SetData(sceneId, agentId, templateId, level, parentGameObject, offsetHeight, align)
    end
    App.uiAssetsManager:LoadAssets({CONST.ASSETS.G_UI_COMMON_BUILDINGTASKTIP}, onLoaded)
end

function UITool.AdaptRectTransform(rectTrans)
    local factor = (Screen.width / Screen.height) / (1280 / 720)
    local sizeDelta = rectTrans.sizeDelta
    rectTrans.sizeDelta = Vector2(sizeDelta.x * factor, sizeDelta.y)
end

function UITool.AdaptImage(img, spr, size)
    if not Runtime.CSValid(img) or not spr then
        return
    end
    img.sprite = spr
    if size then
        local rect = spr.rect
        local ratio = rect.height / rect.width
        img.transform.sizeDelta = Vector2(size, size * ratio)
    end
end

function UITool.GetProduceText(time, count)
    local produceText
    if time > 60 then
        produceText =
            Runtime.Translate(
            "ui_dragonHome_dragonProduct_minute",
            {num_1 = tostring(count), num_2 = tostring(time // 60)}
        )
    else
        produceText =
            Runtime.Translate("ui_dragonHome_dragonProduct_second", {num_1 = tostring(count), num_2 = tostring(time)})
    end
    return produceText
end

function UITool.GetProduceTextBreed(time, count)
    local produceText
    if time > 60 then
        produceText =
            Runtime.Translate("ui_breedResultPanel_item_minute", {num = tostring(count), time = tostring(time // 60)})
    else
        produceText =
            Runtime.Translate("ui_breedResultPanel_item_second", {num = tostring(count), time = tostring(time)})
    end
    return produceText
end

---刷新控件数字
---@param id 道具ID
---@param count 道具数量
function UITool.RefreshWidgetByGetItem(id, count)
    local widgetType = ItemId.GetWidgetType(id)
    local widget = App.scene:GetWidget(widgetType)
    if widget and widget.GetValue then
        local cur = widget:GetValue()
        widget:SetValue(count + cur)
    end
end

function UITool.ShowMovingHand(parent, hand, from, to, time)
    local trans = hand.transform
    from = GameUtil.WorldToUISpace(parent, from)
    from = Vector2(from.x, from.y)
    to = GameUtil.WorldToUISpace(parent, to)
    to = Vector2(to.x, to.y)
    time = time or 1
    local img = find_component(hand, "icon", Image)
    trans.anchoredPosition = from
    local sequence = DOTween.Sequence()
    sequence:Append(img:DOFade(1, 0.1))
    sequence:Append(trans:DOAnchorPos(to, time):SetEase(Ease.Linear))
    sequence:Append(img:DOFade(0, 0.1))
    sequence:Play()
end

function UITool.CreateFlyItem()
    local flyItem = {}
    flyItem.gameObject = BResource.InstantiateFromAssetName(CONST.ASSETS.G_REWARD_PROPS_FLY_ITEM)
    flyItem.transform = flyItem.gameObject.transform
    local panelTrans = App.scene.panelLayer.transform
    flyItem.transform:SetParent(panelTrans, false)
    flyItem.icon = find_component(flyItem.gameObject, "", Image)
    flyItem.count = find_component(flyItem.gameObject, "txt_Count", Text)
    flyItem.gameObject:SetActive(true)
    return flyItem
end

---通用奖励道具动画
---@param id string 奖励item id
---@param count number 奖励item 的数量
---@param from Vector3 奖励的起始位置,为世界坐标
---@param onFinish function 所有item动画完成后的回调
---@param onEachItemReach function 每个item到达目标后的回调
---@param itemSize number 图标大小,默认80
---@param interval number 下一个与上一个item出现的间隔时间
-- local dropRadius
local aniInfo2 = {isSeries = false, lastCount = 0, delay = 0}
function UITool.ShowPropsAniWithSelAngle(
    id,
    count,
    from,
    onFinish,
    onEachItemReach,
    selAngle,
    itemSize,
    interval,
    dropRadius)
    if count <= 0 then
        return
    end
    if not dropRadius then
        dropRadius = AppServices.Meta:GetDropAniRadius()
    end
    local effectiveCount = ItemId.GetEffectiveCount(id, count)

    interval = interval or 0
    if not aniInfo2.isSeries then
        aniInfo2.isSeries = true
        aniInfo2.lastCount = math.min(10, count)
        WaitExtension.SetTimeout(
            function()
                aniInfo2.isSeries = false
                aniInfo2.delay = 0
                aniInfo2.lastCount = 0
            end,
            0.05
        )
    else
        aniInfo2.delay = aniInfo2.delay + interval * aniInfo2.lastCount
        aniInfo2.lastCount = math.min(10, count)
    end

    local propsPool = AppServices.PoolManage:GetPool("FlyProps")
    local lis = {}
    local widgetType = ItemId.GetWidgetType(id)
    local widget = App.scene:GetWidget(widgetType)
    if not widget then
        return
    end
    if widget.SetInteractable then
        widget:SetInteractable(false)
    end
    if widget.ShowForFly then
        widget:ShowForFly()
    end
    local weightPos
    if widget.GetInsideWorldPosition then
        weightPos = widget:GetInsideWorldPosition()
    end
    if not weightPos then
        weightPos = widget:GetMainIconGameObject().transform.position
    end
    local parent = App.scene.canvas.transform
    local vt3s, tpos, epos =
        GameUtil.RotateVectorWithSelectedAngle(from, weightPos, count, parent, dropRadius, selAngle)
    itemSize = itemSize or 80
    local flyCount = math.min(10, count)
    local type = AppServices.Meta:GetItemMeta(id).type
    local baseItems = table.deserialize(AppServices.Meta.metas.ConfigTemplate["BasicSuppliesNoEffects"].value)
    local isBaseItem = table.exists(baseItems, type)
    for i = 1, flyCount do
        local item = propsPool:GetEntity()
        item.img = item.gameObject:GetComponent(typeof(Image))
        item.img.sprite = AppServices.ItemIcons:GetSprite(id)
        item.img:SetNativeSize()
        item.img.color = Color.white
        item.effect = find_component(item.gameObject, "effect")
        item.effect:SetActive(not isBaseItem)
        local size = item.transform.sizeDelta
        local ratio = size.x / size.y
        item.transform.sizeDelta = Vector2(ratio * itemSize, itemSize)
        lis[#lis + 1] = item
    end
    local cellCount = math.floor(effectiveCount / flyCount)
    local cellCountLis = {}
    for i = 1, flyCount - 1 do
        cellCountLis[i] = cellCount
    end
    cellCountLis[flyCount] = effectiveCount - cellCount * (flyCount - 1)
    local bezier = require("System.Core.BezierCurve")
    for i = 1, flyCount do
        local target = lis[i].transform
        target:SetParent(parent, false)
        target.anchoredPosition = tpos
        lis[i].gameObject:SetActive(true)
        local vt = vt3s[i - 1]
        local points = Vector3List()
        local conp = (tpos + vt) / 2
        conp.y = conp.y + math.random(70, 250)
        conp = Vector3(conp.x, conp.y, 0)
        for t = 1, 8 do
            local p = bezier.SecondOrder(Vector3(tpos.x, tpos.y, 0), conp, Vector3(vt.x, vt.y, 0), t / 8)
            points:AddItem(p)
        end
        local off = (vt - tpos).normalized.x * 10
        vt.x = vt.x + off
        local sequence = DOTween.Sequence()
        sequence:AppendInterval(aniInfo2.delay + interval * (i - 1))
        sequence:Append(BPath.DoLocalPath(target, points, 0.4, Ease.Linear))
        sequence:Join(target:DOScale(1, 0):SetEase(Ease.OutBack))
        sequence:Append(target:DOJumpAnchorPos(vt, 40, 1, 0.3):SetEase(Ease.OutSine))
        sequence:Append(target:DOScale(1.4, 0.2))
        sequence:Append(target:DOAnchorPos(epos, 0.8):SetEase(Ease.InCubic))
        sequence:Append(target:DOScale(0.4, 0.2))
        sequence:Join(lis[i].img:DOFade(0, 0.2))
        sequence:AppendCallback(
            function()
                lis[i].transform.localScale = Vector3.zero
                propsPool:RecycleEntity(lis[i], {"parent"})
                -- local cur = widget.GetValue and widget:GetValue() or 0
                if widget and not widget:IsDisposed() then
                    if widget.OnHit then
                        widget:OnHit()
                    end
                    Runtime.InvokeCbk(widget.Refresh, widget)

                    if onEachItemReach then
                        onEachItemReach(id, cellCountLis[i])
                    end
                    widget:SetInteractable(true)
                end
            end
        )
        if i == flyCount and (onFinish or widget.HideForFly) then
            sequence:AppendCallback(
                function()
                    if widget.HideForFly and not widget:IsDisposed() then
                        widget:HideForFly()
                    end
                    Runtime.InvokeCbk(onFinish, id, count)
                end
            )
        end
        sequence:SetRecyclable(true)
        sequence:Play()
    end
end

---@param com Text组件
---@param width number 指定文本宽度,不是字符個數
---@param key 多语言key
---@param params 多语言参数
function UITool.ShowLimitStringWithDots(com, width, key, params)
    local str = Runtime.Translate(key, params)
    com.text = str
    if not width then
        return
    end
    local curWid = com.preferredWidth
    if curWid <= width then
        return
    end
    local totalLen = string.len(str)
    local j = math.floor(width / curWid * totalLen) - 3
    local text = string.sub(str, 1, j)
    com.text = text .. "..."
end

-- HeadImage_Facebook_Avatar_Num = 999
function UITool.ShowHead(img_icon, img_headFB, icon, account)
    -- local index = tonumber(icon)
    -- img_icon.gameObject:SetActive(index ~= HeadImage_Facebook_Avatar_Num)
    -- img_headFB.gameObject:SetActive(index == HeadImage_Facebook_Avatar_Num)
    img_icon.gameObject:SetActive(true)
    img_headFB.gameObject:SetActive(false)
    --普通头像
    img_icon.sprite = AppServices.ItemIcons:GetFriendIconSprite("Tou" .. icon)
    -- if index ~= HeadImage_Facebook_Avatar_Num then
    --     img_icon.sprite = AppServices.ItemIcons:GetFriendIconSprite("Tou" .. icon)
    --     return
    -- end

    --fb头像
    -- if string.isEmpty(account) then
    --     return
    -- end

    -- img_headFB.FBUid = account
    -- img_headFB.FBAvaterUrl = FbDc.Instance():GetFBUrl(account, false)

    -- WaitExtension.SetNextFrame(
    --     function()
    --         img_headFB:Refresh()
    --     end
    -- )
end

function UITool.ShowTeamIcon(image, icon)
    local path = CONST.ASSETS.G_SPRITES_TEAM_ICON
    local iconAtlas = App.uiAssetsManager:GetAsset(path)
    if iconAtlas then
        image.sprite = iconAtlas:GetSprite("ui_team_icon_" .. icon)
    else
        local function onLoaded()
            iconAtlas = App.uiAssetsManager:GetAsset(path)
            image.sprite = iconAtlas:GetSprite("ui_team_icon_" .. icon)
        end
        App.uiAssetsManager:LoadAssetAsync(path, onLoaded)
    end
end

--[[
    playerInfo = {
        pid = "",
        avatar = "",
        frame = "",
        nickname = ""
    }
--]]
function UITool.SetHead(go_head, playerInfo)
    local iconGame = find_component(go_head, "iconGame", Image)
    local img_frame = find_component(go_head, "img_frame", Image)
    local img_board = find_component(go_head, "img_board", Image)
    local avatar = playerInfo.avatar
    local frame = playerInfo.frame
    if playerInfo.pid == AppServices.User:GetUid() then
        avatar = AppServices.Avatar:GetUsingAvatar()
        frame = AppServices.AvatarFrame:GetUsingFrame()
    end
    AppServices.Avatar:ShowAvatarById(iconGame, avatar)
    AppServices.AvatarFrame:SetAvatarFrameById(img_frame, img_board, frame)
end

function UITool.SetActivityCD(leftTime, com_text, com_outline)
    local ret, time1, time2 = TimeUtil.SecToDayHour(leftTime, 24)
    if Runtime.CSNull(com_text) then
        return
    end
    local txtColor = UICustomColor.white
    local outlineColor
    local str_time
    if ret then
        str_time = Runtime.Translate("ui_goldpass_activitytime", {day = tostring(time1), hour = tostring(time2)})
        outlineColor = "733700"
    else
        str_time = time1
        txtColor = "f14333"
        outlineColor = "ffe6cb"
    end
    com_text.text = Runtime.formatStringColor(str_time, txtColor)
    com_outline.effectColor = Runtime.HexToRGB(outlineColor)
end

function UITool.SetItemSlot(go, itemId, params)
    local icon = find_component(go, 'icon', Image)
    if Runtime.CSValid(icon) then
        AppServices.ItemIcons:SetItemIcon(icon, itemId)
    end
    local txt_count_down = find_component(go, "txt_count_down", Text)
    local txt_count_out = find_component(go, "txt_count_out", Text)
    local count = params and params.count
    if not count then
        txt_count_down:SetActive(false)
        txt_count_out:SetActive(false)
        return
    end
    local useDown = not not (params and params.useDonw)
    txt_count_down:SetActive(useDown)
    txt_count_out:SetActive(not useDown)
    local total = params and params.total
    local showCount = count
    if total then
        showCount = Runtime.formartCount(count, total)
    end
    if useDown then
        txt_count_down.text = showCount
    else
        txt_count_out.text = showCount
    end
end