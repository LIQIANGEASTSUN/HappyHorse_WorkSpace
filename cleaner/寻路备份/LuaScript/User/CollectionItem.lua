--- @class CollectionItem
local CollectionItem

_G.ORDER_TASK_DEBUG = false
--- @return CollectionItem
CollectionItem = {
    ---@type dictionary<string, boolen> 监听的道具
    listenItems = {}
}

function CollectionItem:Init()
    if self.inited then
        return
    end
    self.inited = true
    local metas = AppServices.Meta:Category("CollectionTemplate")
    local base = {isBase = true, count = 0, total = 1}
    self.listenItems.base = base
    for id, cfg in pairs(metas) do
        local idKey = "CollectionItemRedDot_Suit_" .. id
        local count = 0
        for _, item in ipairs(cfg.items) do
            local itemId = tostring(item[1])
            local have = AppServices.User:GetItemAmount(itemId)
            local total = item[2]
            local cur = have >= total and 1 or 0
            self.listenItems[itemId] = {id = itemId, count = cur, total = total, parent = id}
            if have >= total then
                count = count + 1
            end
        end
        local info = {id = id, count = count, total = #cfg.items, redDotKey = idKey, parent = "base"}
        self.listenItems[id] = info
        if info.count >= info.total then
            base.count = base.count + 1
        end
        AppServices.RedDotManage:RegisterNew(idKey, "CollectionItem", count)
    end
    self:RegisterListener()
end

----EVENT---
---添加监听事件
function CollectionItem:RegisterListener()
    MessageDispatcher:AddMessageListener(MessageType.Global_After_AddItem, self.OnGetItemEvent, self)
    MessageDispatcher:AddMessageListener(MessageType.Global_After_UseItem, self.OnUseItemEvent, self)
end

function CollectionItem:RemoveListener()
    MessageDispatcher:RemoveMessageListener(MessageType.Global_After_AddItem, self.OnGetItemEvent, self)
    MessageDispatcher:RemoveMessageListener(MessageType.Global_After_UseItem, self.OnUseItemEvent, self)
end

function CollectionItem:OnGetItemEvent(itemId, count)
    if not self.listenItems[itemId] then
        return
    end
    self:refreshItemNum(itemId, count)
end

function CollectionItem:OnUseItemEvent(itemId, count)
    if not self.listenItems[itemId] then
        return
    end
    self:refreshItemNum(itemId, -count)
end

function CollectionItem:refreshItemNum(itemId)
    local listenInfo = self.listenItems[itemId]
    if not listenInfo then
        return
    end
    local have = AppServices.User:GetItemAmount(itemId)
    local need = listenInfo.total
    local result = have >= need and 1 or 0
    local haveNew = listenInfo.count == 0 and result > 0
    ---旧的该清除了
    local delOld = (listenInfo.count ~= 0 and result == 0)
    ---数据发生变化
    local isTrigger = delOld or haveNew
    if isTrigger then
        if listenInfo.parent then
            local addCount = result - listenInfo.count
            listenInfo.count = result
            self:FreshDate_Count(listenInfo.parent, addCount)
        end
    end
end

function CollectionItem:FreshDate_Count(itemId, addCount)
    local listenInfo = self.listenItems[itemId]
    if not listenInfo then
        return
    end
    if addCount ~= 0 then
        local result = math.max(0, listenInfo.count + addCount)
        local need = listenInfo.total
        ---有新增的可收集的
        local haveNew = listenInfo.count < need and result >= need
        ---旧的该清除了
        local delOld = (listenInfo.count >= need and result < need)
        ---数据发生变化
        local isTrigger = delOld or haveNew
        listenInfo.count = result
        if not listenInfo.isBase then
            if haveNew then
                self.HaveNewCollectionItems(itemId)
            end
            if isTrigger and listenInfo.redDotKey then
                AppServices.RedDotManage:FreshDate_Count(listenInfo.redDotKey, addCount)
            end
        else
            if haveNew then
                self:SwitchBubble(true)
            end
            if delOld then
                self:SwitchBubble(false)
            end
        end

        if listenInfo.parent and isTrigger then
            self:FreshDate_Count(listenInfo.parent, haveNew and 1 or delOld and -1)
        end
    end
end

function CollectionItem.HaveNewCollectionItems(id)
    if App.scene:GetSceneType() ~= SceneType.Minor then
        return
    end
    PanelManager.showPanel(GlobalPanelEnum.CollectionItemNoticePanel, {id = id})
end

function CollectionItem:SwitchBubble(isShow)
    local agent = App.scene.objectManager:GetAgentByType(AgentType.collectitem)
    if agent then
        if agent:CanBeSeen() then
            if isShow then
                -- local onClick = function()
                --     self:ShowPanel()
                -- end
                MapBubbleManager:ShowBubble(agent:GetId(), BubbleType.Building_Collection)--, onClick)
            else
                MapBubbleManager:CloseBubble(agent:GetId())
            end
        else
            self:AddAgentShowCheck()
        end
    end
end

function CollectionItem:CheckBubble(finishCallback)
    local agent = App.scene.objectManager:GetAgentByType(AgentType.collectitem)
    if agent then
        if agent:CanBeSeen() then
            local agentId = agent:GetId()
            local base = self.listenItems.base
            local needShow = base.count >= base.total
            local isShow = MapBubbleManager:IsShowedBubble(agentId)
            if isShow and not needShow then
                MapBubbleManager:CloseBubble(agentId)
            elseif not isShow and needShow then
                -- local onClick = function()
                --     AppServices.CollectionItem:ShowPanel()
                -- end
                MapBubbleManager:ShowBubble(agentId, BubbleType.Building_Collection)--, onClick)
            end
        else
            self:AddAgentShowCheck()
        end
    end
    if finishCallback then
        Runtime.InvokeCbk(finishCallback)
    end
end

function CollectionItem:AddAgentShowCheck()
    if not self._listenAgentShow then
        self._listenAgentShow = true
        MessageDispatcher:AddMessageListener(MessageType.Global_After_Agent_Clearing, self.OnAgentShowCheckBubble, self)
    end
end

function CollectionItem:OnAgentShowCheckBubble(_, agentId)
    local agent = App.scene.objectManager:GetAgent(agentId)
    if not agent or agent:GetType() ~= AgentType.collectitem then
        return
    end
    if self._listenAgentShow then
        self._listenAgentShow = nil
        MessageDispatcher:RemoveMessageListener(
            MessageType.Global_After_Agent_Clearing,
            self.OnAgentShowCheckBubble,
            self
        )
    end
    self:CheckBubble()
end

function CollectionItem.GetSortedCfgs()
    local cfgs = AppServices.Meta:Category("CollectionTemplate")
    local datas = {}
    for _, cfg in pairs(cfgs) do
        table.insert(datas, cfg)
    end
    table.sort(datas, function(a, b)
        local aId, bId = a.id, b.id
        local aCanGet, bCanGet = CollectionItem.CanChange(aId), CollectionItem.CanChange(bId)
        if aCanGet ~= bCanGet then
            return aCanGet
        else
            return tonumber(aId) < tonumber(bId)
        end
    end)
    return datas
end

---是否可以交换
function CollectionItem.CanChange(id, showError)
    local cfg = AppServices.Meta:GetCollectionItem(id)
    if not cfg then
        -- console.lzl('CollectionTemplate.xls中没有配置', id)
    end
    for _, item in ipairs(cfg.items) do
        local itemId, need = item[1], item[2]
        local have = AppServices.User:GetItemAmount(itemId)
        if have < need then
            if showError then
                local description = Runtime.Translate("errorcode_2001")
                ErrorHandler.ShowErrorMessage(description)
            end
            return false
        end
    end
    return true
end

function CollectionItem:CollectionItemsRequest(id)
    if not self.CanChange(id, true) then
        return
    end
    local params = {
        id = id
    }
    local funcFailedCbk = function(errorCode)
        ErrorHandler.ShowErrorPanel(errorCode)
    end
    local cfg = AppServices.Meta:GetCollectionItem(id)
    local funcSuccessCbk = function()
        for _, item in ipairs(cfg.items) do
            local itemId, need = item[1], item[2]
            AppServices.User:UseItem(itemId, need, ItemUseMethod.collectionExchange)
        end
        local rewards = {}
        for _, v in ipairs(cfg.reward) do
            local itemId, count = v[1], v[2]
            table.insert(rewards, {ItemId = itemId, Amount = count})
            AppServices.User:AddItem(itemId, count, ItemGetMethod.collectionReward, id)
        end
        sendNotification(CollectionItemPanelNotificationEnum.refresh_nodes)
        PanelManager.showPanel(GlobalPanelEnum.SimpleRewardPanel, {rewards = rewards})
        MessageDispatcher:SendMessage(MessageType.Global_After_CollectionItem, id, 1)
    end
    Net.Itemmodulemsg_2008_CollectItems_Request(params, funcFailedCbk, funcSuccessCbk)
end

function CollectionItem.Unlocked()
    local cfg = AppServices.Meta:GetBindingMetaByType(AgentType.collectitem)
    if cfg and cfg.taskunlock and cfg.taskunlock ~= "" then
        return AppServices.Task:IsTaskSubmit(cfg.taskunlock), cfg.taskunlock
    end
    return true
end

function CollectionItem:ShowPanel(id)
    local isUnlock, taskId = self:Unlocked()
    if not isUnlock then
        if taskId then
            AppServices.Task:ShowTaskLock(taskId)
        end
        return
    end
    PanelManager.showPanel(GlobalPanelEnum.CollectionItemPanel, {id = id})
end

function CollectionItem.GetFirstCanChange()
    local sortedCfgs = CollectionItem.GetSortedCfgs()
    for i, cfg in ipairs(sortedCfgs) do
        if CollectionItem.CanChange(cfg.id) then
            return i, cfg.id
        end
    end
end

return CollectionItem