---@type IslandTemplateTool
local IslandTemplateTool = require "Fsm.Ship.IslandTemplateTool"

local _ShipDockPanelBase = require "UI.ShipSailing.ShipDockPanel.View.UI.Base._ShipDockPanelBase"

---@class ShipDockPanel:_ShipDockPanelBase
local ShipDockPanel = class(_ShipDockPanelBase)

function ShipDockPanel:ctor()
    self.arguments = nil
end

function ShipDockPanel:SetArguments(arguments)
    self.arguments = arguments
    -- local arguments = {id = self.id, sn = self.data.meta.sn}
end

function ShipDockPanel:refreshUI()
    local agent = App.scene.objectManager:GetAgent(self.arguments.id)
    local level = agent.data:GetLevel()

    local key = AppServices.BuildingLevelTemplateTool:GetKey(self.arguments.sn, level)
    self.data = AppServices.Meta:Category("BuildingLevelTemplate")[tostring(key)]

    if self.data.upgradeCost and #self.data.upgradeCost > 0 then
        local nextKey = AppServices.BuildingLevelTemplateTool:GetKey(self.arguments.sn, level + 1)
        self.nextData = AppServices.Meta:Category("BuildingLevelTemplate")[tostring(nextKey)]
    end

    self.txt_title.text = "升级"
    self.txt_level.text = string.format("Lv.%d", self.data.level)
    self.txt_level_next.text = self.nextData and string.format("Lv.%d", self.nextData.level) or ""

    self:refreshUnLockIsland()
    self:refreshUpCost()
    self:refreshUpLevelBtn()
end

function ShipDockPanel:refreshUnLockIsland()
    if not self.nextData then
        self.unlockTr.gameObject:SetActive(false)
        return
    end

    self.txt_title_unlock.text = "解锁岛屿"

    local index = 0
    local ids = IslandTemplateTool:GetAllIsland()
    for _, id in pairs(ids) do
        local islandConfig = IslandTemplateTool:GetData(id)
        for _, data in pairs(islandConfig.unlockCondition) do
            local level = self.nextData.level
            if data[1] == IslandUnlockCondition.ShipDock_Level and data[2] == level then
                index = index + 1
                self:refreshIsland(index, islandConfig)
            end
        end
    end
end

function ShipDockPanel:refreshIsland(index, islandConfig)
    local name = string.format("Item%d", index)
    local itemTr = self.itemUnlockParent:Find(name)
end

function ShipDockPanel:refreshUpCost()
    self.txt_title_cost.text = "升级所需"

    for index = 1, #self.data.upgradeCost do
        local name = string.format("Item%d", index)
        local itemTr = self.itemCostParent:Find(name)

        if Runtime.CSValid(itemTr) then
            local material = self.data.upgradeCost[index]
            local itemKey = tostring(material[1])

            local icon = itemTr:Find("Icon"):GetComponent(typeof(Image))
            local txt_count = itemTr:Find("txt_count"):GetComponent(typeof(Text))

            local itemData = AppServices.Meta:Category("ItemTemplate")[itemKey]
            icon.sprite = self:GetItemSprite(itemData.icon)

            local ownerCount = AppServices.User:GetItemAmount(tonumber(itemKey))
            txt_count.text = string.format("%d/%d", material[2], ownerCount)

            itemTr.gameObject:SetActive(true)
        end
    end
end

function ShipDockPanel:refreshUpLevelBtn()
    local result = AppServices.BuildingLevelTemplateTool:EnableUp(self.data)

    self.btn_up_level.gameObject:SetActive(result == UpgradeEnableType.Enable)
    self.btn_disable.gameObject:SetActive(result ~= UpgradeEnableType.Enable)
    if result == UpgradeEnableType.Enable then
        self.txt_up_level.text = "升级"
    else
        local disable = ""
        if result == UpgradeEnableType.ItemNotEnougth then
            disable = "材料不足"
        elseif result == UpgradeEnableType.PlayerLevelSmall then
            disable = string.format("需要达到Lv.%d", self.data.roleLevel)
        elseif result == UpgradeEnableType.MaxLevel then
            disable = "最大等级"
        end
        self.txt_name_disable.text = disable
    end
end

function ShipDockPanel:GetItemSprite(spriteName)
    local atlas = App.uiAssetsManager:GetAsset(CONST.ASSETS.G_ITEM_ICONS)
    local sprite = atlas:GetSprite(spriteName)
    return sprite
end

function ShipDockPanel:UpLevelClick()
    AppServices.NetBuildingManager:SendBuildLevel(self.arguments.id)
    PanelManager.closePanel(GlobalPanelEnum.ShipDockPanel)
end

function ShipDockPanel:Hide()

end

return ShipDockPanel