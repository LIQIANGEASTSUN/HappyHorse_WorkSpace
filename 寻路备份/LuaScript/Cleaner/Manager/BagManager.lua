local BagManager = {}

function BagManager:Init()
    self.dataDirty = true
    self.itemTotalCount = 0
    self:_InitLevelCapacity()
    self:_InitBagItemDatas()

    self:_RegisterEvent()
end

function BagManager:_InitLevelCapacity()
    local levelCapacity = {}
    local template = AppServices.Meta.metas.LevelTemplate
    for _, v in pairs(template) do
        levelCapacity[v.sn] = v.bagSpace
    end
    self.levelCapacity = levelCapacity
    local val = AppServices.Meta:GetConfigMetaValue("bagOverNum")
    self.bagOverNum = tostring(val)
end

function BagManager:_InitBagItemDatas()
    local itemList = AppServices.User:GetItemsList()
    if not itemList then
        return
    end
    local datas = {}
    local showedDatas = {}--挂件上显示的item
    local count = 0
    local mgr = AppServices.Meta
    for _, v in pairs(itemList) do
        local id = v.itemId
        local config = mgr:GetItemMeta(id)
        local bagPage = config.bagPage
        if bagPage > 0 then
            local dt = datas[bagPage] or {}
            local tmp = {
                itemId = id,
                count = v.count,
                bagSort = config.bagSort,
                mainShow = config.mainShow,
                config = config
            }
            table.insert(dt, tmp)
            datas[bagPage] = dt
            if tmp.mainShow == 1 then
                table.insert(showedDatas, tmp)
            end
            count = count + v.count
        end
    end
    for _, v in pairs(datas) do
        self:_SortData(v)
    end
    self:_SortData(showedDatas)
    self.itemTotalCount = count
    self.itemDatas = datas
    self.showedDatas = showedDatas
end

function BagManager:_SortData(datas)
    if not datas then
        return
    end
    table.sort(datas, function(a, b)
        if a and b then
            if a.bagSort < b.bagSort then
                return true
            end
        end
        return false
    end)
end


function BagManager:CheckBagView()
    --背包界面
    local view = PanelManager.GetPanel(GlobalPanelEnum.BagPanel.panelName)
    if view then
        view:RefreshView()
    end
    local widget = App.scene:GetWidget(CONST.MAINUI.ICONS.BagButton)
    if widget then
        widget:Refresh()
    end
end

function BagManager:SyncPropWidget(itemId, count)
    local widget = App.scene:GetWidget(CONST.MAINUI.ICONS.PropsWidget)
    if widget then
        widget:SyncItemCount(itemId, count)
    end
end

--获取当前背包的容量
function BagManager:GetCurrentBagCapacity()
    local level = AppServices.User:GetCurrentLevelId()
    return (self.levelCapacity[level] or 0)
end

function BagManager:GetBagOverNum()
    return self.bagOverNum or 0
end

function BagManager:GetItemTotalCount()
    return self.itemTotalCount
end

function BagManager:GetBagItemDatas()
    return self.itemDatas or {}
end

function BagManager:GetMainShowedDatas()
    return self.showedDatas or {}
end

function BagManager:_RegisterEvent()
    MessageDispatcher:AddMessageListener(MessageType.Global_After_AddItem, self.OnAddItem, self)
    MessageDispatcher:AddMessageListener(MessageType.Global_After_UseItem, self.OnUseItem, self)
end

function BagManager:_RemoveEvent()
    MessageDispatcher:RemoveMessageListener(MessageType.Global_After_AddItem, self.OnAddItem, self)
    MessageDispatcher:RemoveMessageListener(MessageType.Global_After_UseItem, self.OnUseItem, self)
end

function BagManager:OnAddItem(itemId, count)
    local config = AppServices.Meta:GetItemMeta(itemId)
    local bagPage = config.bagPage
    if bagPage>0 then
        self.dataDirty = true
        local dt = self.itemDatas[bagPage] or {}
        local target = nil
        local index = -1
        for k, v in ipairs(dt) do
            if v.itemId == itemId then
                target = v
                index = k
                break
            end
        end
        local current = count
        if target then
            target.count = target.count + count
            current = target.count
        else
            local tmp = {
                itemId = itemId,
                count = count,
                bagSort = config.bagSort,
                mainShow = config.mainShow,
                config = config
            }
            table.insert(dt, tmp)
            self:_SortData(dt)
            if tmp.mainShow == 1 then
                table.insert(self.showedDatas, tmp)
                self:_SortData(self.showedDatas)
            end
        end
        if current == 0 and index > 0 then
            table.remove(dt, index)
        end
        self.itemTotalCount = self.itemTotalCount + count
        self.itemDatas[bagPage] = dt
        self:CheckBagView()
        self:SyncPropWidget(itemId, current)
    end
end

function BagManager:OnUseItem(itemId, count)
    self:OnAddItem(itemId, -count)
end

BagManager:Init()
return BagManager