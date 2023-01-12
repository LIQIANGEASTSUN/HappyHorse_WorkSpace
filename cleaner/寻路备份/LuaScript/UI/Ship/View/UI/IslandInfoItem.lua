---@type IslandTemplateTool
local IslandTemplateTool = require "Fsm.Ship.IslandTemplateTool"

---@type ShipSailingPath
local ShipSailingPath = require "UI.Ship.View.UI.ShipSailingPath"

---@class IslandInfoItem
local IslandInfoItem = class(nil, "IslandInfoItem")

function IslandInfoItem:ctor(islandId, parent, cloneTr, shipSailingPanel)
    self.islandId = islandId
    self.parent = parent
    self.cloneTr = cloneTr
    self.shipSailingPanel = shipSailingPanel

    self.go = nil
    self.rectTransform = nil
    self.parentRect = self.parent.gameObject:GetComponent(typeof(RectTransform))
    self.btn_island = nil

    self.islinkHomeland = App.scene.mapManager:IsRegionLinked(self.islandId)
    -- 世界坐标与UI界面上比例
    self.worldSizeToUI = 15
end

function IslandInfoItem:refreshUI()
    self.islandData = IslandTemplateTool:GetData(self.islandId)
    self:CreateGo()
    self.rectTransform = self.go:GetComponent(typeof(RectTransform))
    self.go:SetActive(true)
    self.btn_island = self.go.transform:Find("btn_island").gameObject:GetComponent(typeof(Button))
    self.island_icon = self.go.transform:Find("btn_island").gameObject:GetComponent(typeof(Image))
    self.btn_lock = self.go.transform:Find("btn_lock").gameObject:GetComponent(typeof(Button))
    self.island_lock_icon = self.go.transform:Find("btn_lock").gameObject:GetComponent(typeof(Image))
    self.arrow = self.go.transform:Find("arrow").gameObject
    self.txt_island = self.go.transform:Find("txt_island"):GetComponent(typeof(Text))
    self.txt_progress = find_component(self.go, "txt_progress", Text)

    local unlock = AppServices.IslandManager:IsUnLock(self.islandId)
    self.btn_island.gameObject:SetActive(unlock)
    self.btn_lock.gameObject:SetActive(not unlock)

    if Runtime.CSValid(self.btn_island) then
        Util.UGUI_AddButtonListener(self.btn_island, function() self.IslandClick(self) end)
    end

    if Runtime.CSValid(self.btn_lock) then
        Util.UGUI_AddButtonListener(self.btn_lock, function() self.LockClick(self) end)
    end

    local sprite = self:GetSprite(self.islandData.icon)
    self.island_icon.sprite = sprite
    self.island_lock_icon.sprite = sprite

    self.txt_island.text = self.islandData.name
    self.txt_progress.text = self:GetProgressMsg()

    local anchoredPosition, sizeDelta = self:GetRectInfo()
    ShipSailingPath:SetAreaNodeType(anchoredPosition, sizeDelta)
end

function IslandInfoItem:GetIslandId()
    return self.islandId
end

function IslandInfoItem:GetProgressMsg()
    local islinkHomeland = AppServices.User:IsLinkHomeland(self.islandId)
    if islinkHomeland then
        return "已完成"
    end

    local progress = AppServices.IslandManager:GetIslandProgress(self.islandId)
    local progressMsg = string.format("%.0f%s", progress * 100, "%")
    return progressMsg
end

function IslandInfoItem:IslandClick()
    if self.islinkHomeland then
       return
    end

    self.shipSailingPanel:SelectIslandEvent(self)
end

function IslandInfoItem:LockClick()
    local arguments = {islandId = self.islandId}
    PanelManager.showPanel(GlobalPanelEnum.ShipIslandLockPanel, arguments)
end

function IslandInfoItem:CreateGo()
    local clone_go = self.cloneTr.gameObject
    self.go = GameObject.Instantiate(clone_go)
    self.go.transform:SetParent(self.parent, false)
    self.rectTransform = self.go:GetComponent(typeof(RectTransform))
    self:SetPosition()
end

function IslandInfoItem:RefreshArrow(islandId)
    local show = islandId == self.islandId
    self.arrow:SetActive(show)
end

function IslandInfoItem:SetPosition()
    local homelandId = IslandTemplateTool:GetHomelandId()
    local homelandData = IslandTemplateTool:GetData(homelandId)
    local homelandPos = homelandData.bornPos

    local islandPos = self.islandData.bornPos
    local x = islandPos[1] - homelandPos[1]
    local y = islandPos[2] - homelandPos[2]

    local offsetX = self:Offset(x)
    local offsetY = self:Offset(y)

    local anchored = Vector2(x, y) * self.worldSizeToUI + Vector2(offsetX, offsetY)
    self.rectTransform.anchoredPosition = anchored
end

function IslandInfoItem:Offset(value)
    if value > 0 then
        return 250
    elseif value < 0 then
        return -250
    end
    return 0
end

function IslandInfoItem:GetRectInfo()
    return self.rectTransform.anchoredPosition, self.rectTransform.sizeDelta
end

function IslandInfoItem:GetSprite(spriteName)
    local atlas = App.uiAssetsManager:GetAsset(CONST.ASSETS.G_ISLAND_SPRITE)
    local sprite = atlas:GetSprite(spriteName)
    return sprite
end

function IslandInfoItem:Hide()
    if Runtime.CSValid(self.go) then
        GameObject.Destroy(self.go)
    end
end

return IslandInfoItem