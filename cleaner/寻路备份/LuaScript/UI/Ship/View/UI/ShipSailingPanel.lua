local _ShipSailingPanelBase = require "UI.Ship.View.UI.Base._ShipSailingPanelBase"

---@type IslandInfoItem
local IslandInfoItem = require "UI.Ship.View.UI.IslandInfoItem"

---@type ShipSailingPath
local ShipSailingPath = require "UI.Ship.View.UI.ShipSailingPath"

---@type IslandTemplateTool
local IslandTemplateTool = require "Fsm.Ship.IslandTemplateTool"

---@type ShipOrder
local ShipOrder = require "UI.Ship.View.UI.ShipOrder"

---@class ShipSailingPanel:_ShipSailingPanelBase
local ShipSailingPanel = class(_ShipSailingPanelBase, "ShipSailingPanel")

function ShipSailingPanel:ctor()
    self.islandList = {}
    self.arguments = {}
    self.selectIslandId = 0

    self.itemGoList = {}
end

function ShipSailingPanel:SetArguments(arguments)
    self.arguments = arguments
end

function ShipSailingPanel:refreshUI()
    ShipSailingPath:SetPathParent(self.pathParent)
    self:TextInfo()

    self:refreshHomeland()
    self:RefreshIslandGroup()
end

function ShipSailingPanel:TextInfo()
    --self.txt_title.text = Runtime.Translate("ui_mail_title")
    --self.txt_go.text = Runtime.Translate("ui_mail_title")

    local _, _, level = AppServices.IslandManager:GetShipDockInfo()
    self.txt_dock_level.text = string.format("Lv.%d", level)
end

function ShipSailingPanel:refreshHomeland()
    local homelandId = IslandTemplateTool:GetHomelandId()
    local data = IslandTemplateTool:GetData(tostring(homelandId))
    self.txt_name_homeland.text = data.name

    local homelandAnchored = self.homelandRect.anchoredPosition
    local sizeDelta = self.homelandRect.sizeDelta

    ShipSailingPath:SetHomelandData(homelandAnchored, sizeDelta)
end

function ShipSailingPanel:RefreshIslandGroup()
    local ids = IslandTemplateTool:GetAllIsland()

    local select = false
    for _, id in pairs(ids) do
        local item = IslandInfoItem.new(id, self.IslandGroupTr, self.islandItemTr, self)
        item:refreshUI()
        table.insert(self.islandList, item)
        local enableSailing = AppServices.IslandManager:EnableSailling(id)
        if not select and enableSailing then
            select = true
            self:SelectIslandEvent(item)
        end
    end
end

function ShipSailingPanel:SelectIslandEvent(islandInfoItem)
    self.selectIslandId = islandInfoItem:GetIslandId()
    self.selectIsland.gameObject:SetActive(true)

    local islandConfig = IslandTemplateTool:GetData(self.selectIslandId)

    self.txt_island.text = islandConfig.name
    self.txt_progress.text = islandInfoItem:GetProgressMsg()

    for _, v in pairs(self.islandList) do
        v:RefreshArrow(self.selectIslandId)
    end

    local enableSailing = AppServices.IslandManager:EnableSailling(self.selectIsland)

    local anchoredPosition, sizeDelta = islandInfoItem:GetRectInfo()
    ShipSailingPath:ResetPath(anchoredPosition, sizeDelta, enableSailing)

    self:ClearItem()
    self:refreshMonster(islandConfig)
    self:refreshItem(islandConfig)
    self:refresCost(enableSailing)
end

function ShipSailingPanel:refreshMonster(islandConfig)
    local islandMonster = islandConfig.islandMonster
    for _, monsterSn in pairs(islandMonster) do
        local monsterConfig = AppServices.Meta:Category("MonsterTemplate")[tostring(monsterSn)]

        if monsterConfig then
            local go = self:CreateItem(self.petCloneTr, self.petParent)
            table.insert(self.itemGoList, go)
            local icon = go.transform:Find("Icon"):GetComponent(typeof(Image))
            icon.sprite = self:GetItemSprite(monsterConfig.icon)
        end
    end
end

function ShipSailingPanel:refreshItem(islandConfig)
    local islandItems = islandConfig.islandItem
    for _, itemSn in pairs(islandItems) do
        local itemData = AppServices.Meta:Category("ItemTemplate")[tostring(itemSn)]

        if itemData then
            local go = self:CreateItem(self.materialTr, self.materialParent)
            table.insert(self.itemGoList, go)
            local icon = go.transform:Find("Icon"):GetComponent(typeof(Image))
            icon.sprite = self:GetItemSprite(itemData.icon)
        end
    end
end

function ShipSailingPanel:refresCost(enableSailing)
    local product = ShipOrder:RequestOrder()
    local recipe = product.recipe or {}

    self.itemNotEnougth = nil
    local itemEnougth = true
    for _, data in pairs(recipe) do
        local key = data.key
        local count = data.value
        local itemData = AppServices.Meta:Category("ItemTemplate")[tostring(key)]

        if itemData then
            local go = self:CreateItem(self.costTr, self.costParent)
            table.insert(self.itemGoList, go)
            local icon = go.transform:Find("Icon"):GetComponent(typeof(Image))
            icon.sprite = self:GetItemSprite(itemData.icon)
            local txt_count = go.transform:Find("txt_count"):GetComponent(typeof(Text))
            local ownCount = AppServices.User:GetItemAmount(key)
            txt_count.text = string.format("%d/%d", count, ownCount)

            if ownCount < count then
                itemEnougth = false
                self.itemNotEnougth = key
            end
        end
    end

    local showEnable = enableSailing and itemEnougth
    self.btn_go.gameObject:SetActive(showEnable)
    self.btn_disable.gameObject:SetActive(not showEnable)
end

function ShipSailingPanel:ClickGo()
    local id = AppServices.IslandManager:GetShipDockInfo()
    AppServices.NetOrderManager:SendStartOrder(id)
    local islandId = self:GetSelectIslandId()
    MessageDispatcher:SendMessage(MessageType.GoToIsland, islandId)
end

function ShipSailingPanel:ClickGoDisable()
    if not self.itemNotEnougth then
        return
    end

    local msg = string.format("%d 不足", self.itemNotEnougth)
    AppServices.UITextTip:Show(msg)
end

function ShipSailingPanel:GetSelectIslandId()
    return self.selectIslandId
end

function ShipSailingPanel:MapReset()
    self.mapScrollRect.normalizedPosition = Vector2(0.5, 0.5)
end

function ShipSailingPanel:CreateItem(cloneTr, parent)
    local go = GameObject.Instantiate(cloneTr.gameObject)
    go.transform:SetParent(parent, false)
    go.transform.localScale = Vector3.one
    go.transform.localEulerAngles = Vector3.zero
    go.transform.localPosition = Vector3.zero
    go:SetActive(true)
    return go
end

function ShipSailingPanel:GetItemSprite(spriteName)
    local atlas = App.uiAssetsManager:GetAsset(CONST.ASSETS.G_ITEM_ICONS)
    local sprite = atlas:GetSprite(spriteName)
    return sprite
end

function ShipSailingPanel:ClearItem()
    for _, go in pairs(self.itemGoList) do
        if Runtime.CSValid(go) then
            GameObject.Destroy(go)
        end
    end

    self.itemGoList = {}
end

function ShipSailingPanel:Hide()
    for _, v in pairs(self.islandList) do
        v:Hide()
    end
    self.islandList = {}

    self:ClearItem()
end

return ShipSailingPanel



--[[
function ShipSailingPanel:ScrollValueChange(pos)
    --console.error("ScrollValueChange:"..pos.x.."   "..pos.y)
end

function ShipSailingPanel:RegisterEvent()
    --self.mapScrollRect.onValueChanged:AddListener(function(pos) self:ScrollValueChange(pos) end)
end

function ShipSailingPanel:UnRegisterEvent()
    --self.mapScrollRect.onValueChanged:RemoveAllListeners()
end
--]]