--insertWidgetsBegin
--insertWidgetsEnd

--insertRequire
local _RecyclePanelBase = require "UI.RecyclePanel.View.UI.Base._RecyclePanelBase"
---@type SellItem
local SellItem = require "UI.RecyclePanel.View.UI.SellItem"

---@class RecyclePanel:_RecyclePanelBase
local RecyclePanel = class(_RecyclePanelBase)

function RecyclePanel:ctor()
    self.items = {}
end

function RecyclePanel:onAfterBindView()
    -- local itemPath = "Prefab/UI/RecyclePanel/SellItem.prefab"
    -- local metas = AppServices.User:GetRecyclableItemMetas()
    -- for key, meta in pairs(metas) do
    --     local item = SellItem.new(meta)
    --     local go = BResource.InstantiateFromAssetName(itemPath, self.container, false)
    --     item:RefreshUI(go)
    --     table.insert(self.items, item)
    -- end
    self.datas = AppServices.User:GetRecyclableItemDatas()
    self:InitItems(self.datas)
end

function RecyclePanel:InitItems(datas)
    if not datas then
        datas = {}
    end
    local itemPath = "Prefab/UI/RecyclePanel/SellItem.prefab"
    self.itmList = {}
    local function onCreate(key)
        local go = BResource.InstantiateFromAssetName(itemPath)
        local itm = SellItem.new(go)
        self.itmList[key] = itm
        return itm.gameObject
    end
    local function onUpate(key, index)
        local itm = self.itmList[key]
        itm:SetData(datas[index])
    end
    self.scrollList:InitList(#datas, onCreate, onUpate)
end

function RecyclePanel:SellAll()
    local info = {items = {}}
    for _, data in ipairs(self.datas) do
        if data.select > 0 then
            local item = {key = data.meta.sn, value = data.select}
            table.insert(info.items, item)
            data.select = 0
        end
    end
    if #info.items > 0 then
        for _, item in pairs(self.itmList) do
            item:ResetSell()
        end
        -- AppServices.Net:Send(MsgMap.CSRecycle, info)
        AppServices.NetRecycleManager:Recycle(info)
    end
end

function RecyclePanel:refreshUI()
end

return RecyclePanel
